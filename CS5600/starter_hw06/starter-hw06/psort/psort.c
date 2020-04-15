#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>
#include <fcntl.h>
#include <math.h>

#include "float_vec.h"
#include "barrier.h"
#include "utils.h"
//qsort utility fn for comaparing
int comparator(const void * a, const void *b)
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
    // TODO: man 3 qsort ?
    qsort(xs->data,xs->size,sizeof(float),comparator);
    return;
}
/*
This function performs sampling and also calculates medians and returns the array with median values
*/
floats*
sample(float* data, long size, int P)
{
    
    int index = 0;
    floats* samples = make_floats(0);
    float* meds = malloc((3*(P-1))*sizeof(float));
    for(int i=0;i<3*(P-1);i++)
    {
        index = rand()%(int)size;
        meds[i] = data[index];
       
    }
   
    qsort(meds,3*(P-1),sizeof(float),comparator);
  
    floats_push(samples,0);
    
    for(int i=0;i<3*(P-1);i++)
    {
        if((i+1)%3==0){
         floats_push(samples,meds[i-1]);
        }
    }
    floats_push(samples,__INT_MAX__);
    //free_floats(samples);
    free(meds);
    return samples;
    
}
// function to find end points
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
//everything above is working
//worker function will make processes perform sorting,
//wait for all processes to complete sorting
//and then stores back in the array
void
sort_worker(int pnum, float* data, long size, int P, floats* samps, long* sizes, barrier* bb)
{
 floats* xs = make_floats(0);
    //printf("%d .I am a child \nsize=%ld\n",pnum,size);
    
     //TODO: Copy the data for our partition into a locally allocated array.
    for(int i =0;i<size;i++){
        if((data[i] >= samps->data[pnum]) && (data[i] < samps->data[pnum+1])){
            floats_push(xs,data[i]);
        }
    }
    printf("%d: start %.04f, count %ld\n", pnum, samps->data[pnum], xs->size);
    
    // TODO: Sort the local array.
    qsort_floats(xs);
    sizes[pnum]=xs->size;
    barrier_wait(bb);
    // TODO: Make sure this function doesn't have any data races.
    
    // TODO: Using the shared sizes array, determine where the local
    //printf("end points determined\n");
    long start = calc_start(pnum,P,sizes);
    long end = start + xs->size;
    // TODO: Copy the local array to the appropriate place in the global array.
    int j = 0;
     for(long i=start;i<end;i++)
     {
        data[i] = xs->data[j];
        j++;
     }
    
    free_floats(xs);  
    free_floats(samps);
}

//function spawns processes
void
run_sort_workers(float* data, long size, int P, floats* samps, long* sizes, barrier* bb)
{
    // TODO: Spawn P processes running sort_worker 
      for(int i=0;i<P;i++){
        
        if(fork()== 0)
        {  
            sort_worker(i,data, size, P, samps, sizes, bb);
            exit(0); 
        }
    }
    //wait and kill child properly
    for(int i=0;i<P;i++){
        wait(NULL);
    }
    
    // TODO: Once all P processes have been started, wait for them all to finish.

}
//sample sort 
void
sample_sort(float* data, long size, int P, long* sizes, barrier* bb){
    //printf("size passed in sample_sort = %ld",size);
    floats* _sample = sample(data,size, P);
    
    // TODO: Sequentially sample the input data.
    //
    // TODO: Sort the input data using the sampled array to allocate work
    // between parallel processes.
    run_sort_workers(data, size, P, _sample, sizes, bb);
    free_floats(_sample);
    return;
}

int
main(int argc, char* argv[])
{
    if (argc != 3) 
    {
        printf("Usage:\n");
        printf("\t%s P data.dat\n", argv[0]);
        return 1;
    }

    const int P = atoi(argv[1]);
    const char* fname = argv[2];

    seed_rng();

    int fd = open(fname, O_RDWR);
    check_rv(fd);
    struct stat s;
    int fs = fstat (fd, &s);
    if(fs < 0)
    {
        printf("Failed to open file\n");
        exit(1);
    }
    void* file = mmap(0, s.st_size, PROT_READ | PROT_WRITE,
                       MAP_SHARED, fd, 0); 
    // TODO: Use mmap for I/O
    
    
    long count = *((long*)file); // TODO: this is in the file
    
    float* data = (float*)(file+sizeof(long)); // TODO: this is in the file
  
    long sizes_bytes = P * sizeof(long);
    
    // TODO: This should be shared memory.
    long* sizes = mmap(0, sizes_bytes, PROT_READ | PROT_WRITE,
                       MAP_SHARED | MAP_ANONYMOUS, -1, 0);
    
    // = malloc(sizes_bytes); 
    barrier* bb = make_barrier(P);

    sample_sort(data, count, P, sizes, bb);
     
    free_barrier(bb);

    // TODO: Clean up resources.
    munmap(file,s.st_size);
    munmap(sizes,sizes_bytes);
    (void) file;
    close(fd);
    return 0;
}

