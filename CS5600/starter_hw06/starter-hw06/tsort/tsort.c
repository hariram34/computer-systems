#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <fcntl.h>
#include <math.h>
#include <limits.h>
#include "float_vec.h"
#include "barrier.h"
#include "utils.h"

//global array shared between threads
struct parameters
{
    floats* samples;
    barrier* bb;
    long* sizes;
    long size;
    float* data;
    int P;
}ins;

//qsort utility fn for comaparing
int comparator (const void * a, const void * b)
{
   if( *(float*)a > *(float*)b){
      return 1;
  }else if( *(float*)a < *(float*)b){
      return -1;
  }

  return 0;
}
void
qsort_floats(floats* xs)
{
    qsort(xs->data, xs->size, sizeof(float), comparator);
}
/*
This function takes 3(t-1) samples and performs the median calcn.
Then it stores the value into a global struct instead of returning it
*/
void
sample()
{
    int index = 0;
    ins.samples = make_floats(0);
    float* meds = malloc((3*(ins.P-1))*sizeof(float));
    for(int i=0;i<3*(ins.P-1);i++)
    {
        index = rand()%(int)ins.size;
        meds[i] = ins.data[index];
       
    }
   
    qsort(meds,3*(ins.P-1),sizeof(float),comparator);
  
    floats_push(ins.samples,0);
    
    for(int i=0;i<3*(ins.P-1);i++)
    {
        if((i+1)%3==0){
         floats_push(ins.samples,meds[i-1]);
        }
    }
    floats_push(ins.samples,__INT_MAX__);
    //free_floats(samples);
    free(meds);
    //return samples;
    
}
long calc_start(int pnum, int P, long* sizes)
{
    long sum = 0;
    if(pnum!=0){
        for(int i =0;i<pnum;i++){
            sum += sizes[i]; 
        }
        return sum;
    }else{
        return 0;
    }
} 
void*
sort_worker(void*arg)
{
    //argument is thread number from the for loop
    int pnum = *((int*)arg);

    //local array.
    floats* xs;
    xs = make_floats(0);

    // data for the partition is copied into the local array.
    for(int i=0; i<ins.size; i++)
    {
        if(ins.data[i]>=ins.samples->data[pnum] && ins.data[i]<ins.samples->data[pnum+1])
            floats_push(xs, ins.data[i]);
    }
    ins.sizes[pnum] = xs->size;

        printf("%d: start %.04f, count %ld\n", pnum, ins.samples->data[pnum], xs->size);
    
    //Sort the local array.
    qsort_floats(xs);

    //make all thread to wait until every partition is sorted
    barrier_wait(ins.bb);  
    //find end points
    long start = calc_start(pnum,ins.P,ins.sizes);
    long end = start + xs->size;
    //restore the array with sorted elements
    int j = 0;
    for(int i=start; i<end; i++)
    {
        ins.data[i] = xs->data[j];
        j++;
    }

    free_floats(xs);
    return NULL;
}
/*
this function creates and joins pthreads,
the spawned pthread runs sort worker
*/
void
run_sort_workers()
{
    int arr[ins.P];
    pthread_t threads[ins.P];
    for(int i=0; i<ins.P; i++)
    {
        arr[i] = i;
        pthread_create(&threads[i], NULL,sort_worker,&arr[i]);
    }
    
    for(int i=0; i<ins.P; i++)
    {
        pthread_join(threads[i], NULL);
    }

   }

void
sample_sort()
{
    //perform sampling duty and stores median values into a structure
    sample();
    //call run sort workers
    run_sort_workers();
    free_floats(ins.samples);
}

int
main(int argc, char* argv[])
{    if (argc != 3) {
        printf("Usage:\n");
        printf("\t%s P data.dat\n", argv[0]);
        return 1;
    }
    const int P = atoi(argv[1]);
    ins.P = P;
    const char* fname = argv[2];
    struct stat buf;
    seed_rng();

    int fd = open(fname, O_RDWR);
    check_rv(fd);
    int fs = fstat(fd, &buf);
    if(fs<0){
        printf("failed file stat\n");
    }
    void* file = mmap(NULL, buf.st_size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if(file == MAP_FAILED)
    {
       printf("mapping failed");
    exit(1);
    }

    //get the size of the array and array elements from file
    ins.size = *(long*)file;
    ins.data = (float*)(file+8);


    long sizes_bytes = P * sizeof(long);
//    long* sizes = malloc(sizes_bytes); // TODO: insis should be shared memory.

    long* sizes = malloc(sizes_bytes);
    barrier* bb = make_barrier(P);

    ins.sizes = sizes;
    ins.bb = bb;
    sample_sort();

    free_barrier(bb);

    // TODO: Clean up resources.
    munmap(sizes, sizeof(long));
    munmap(file, buf.st_size);
    close(fd);

    return 0;

 }
