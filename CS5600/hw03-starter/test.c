
#include <unistd.h>
#include <stdio.h> // for perror
#include<string.h>

#include<sys/types.h>
#include<sys/stat.h>
#include<fcntl.h>

int
main(int argc, char* argv[])
{   
	
    int readbuf[5]; //buffer to store the integers from file
    char* usage = "Usage: ./sort input output\n";
    char* sorted = "\nSorted Output :\n";
    int no;
    struct stat buf;
    int fd = open(argv[1],O_RDONLY);
      if (fd < 0) {
         perror("write in main");
        _exit(1);
    }
    //using stat syscal to get file size  
    int size_stat = stat(argv[1],&buf);
    if (size_stat < 0) {
         perror("write in main");
        _exit(1);
    }
    printf("address of size obtained through stat: %u\n,address of struct itself: %u \n",&buf.st_size,&buf);

    //reading 20 bytes from file
/*    int size = read(fd,readbuf,20); 
   // printf("size = %d\n",size);
     if (size < 0) {
         perror("write in main");
        _exit(1);
    }
    //number of integers in the file 
    no = size/4;

    //printing the integers from array
    for(int i=0;i<no;i++){
	char buff[10];     
	sprintf(buff,"%d ",readbuf[i]);
	int tt = write(1, buff, length(buff));
	if (tt < 0) {
        perror("write in main-sprintf ");
        _exit(1);
    	}	
    }

    //printing sorted from write 
    int t = write(1, sorted, length(sorted));
    if (t < 0) {
       perror("write in main");
        _exit(1);
    }
    
    insertion_sort(readbuf,no);

    for(int i=0;i<no;i++){
	char buff[10];     
	sprintf(buff,"%d ",readbuf[i]);
	int tt = write(1, buff, length(buff));
	if (tt < 0) {
        perror("write in main-sprintf ");
        _exit(1);
    	}
    }
	printf("\n");
 //   length(usage);
 // int i = strlen(usage);
 //   printf("function %d",i); 
    if(argc != 2){
    int rv = write(1, usage, length(usage));
    if (rv < 0) {
       // Checking your syscall return values is a
        // really good idea.
        perror("write in main");
        _exit(1);
    }
    }

*/
    return 2;
//    return 0;
}
