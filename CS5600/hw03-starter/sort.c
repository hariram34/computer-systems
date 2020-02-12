#include<stdio.h>
#include<unistd.h>
#include <errno.h>
#include<string.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <stdlib.h>

//utility fn to calc strlen
int strlength(char *string)
{
    int count=0;
    for (int i = 0; string[count] != 0 ; i++){
        count++;
    }
    return count; //return strlen
}

//sorting algorithm
void insertion_sort(int *arr, int len)
{
    
    for (int i=1; i<len; i++)  
    {
        int key = arr[i];
    	int j=i-1;           
        while(j>=0 && arr[j]>key) //check conditions
        {
            arr[j+1] = arr[j];    
            j--;
        }
        arr[j+1] = key;   //assign key in its position
    }
}

int main(int argc, char* argv[]){
 //fstat structure instance is created
struct stat buf;
char* usage = "Usage: ./sort input output\n";
if(argc!=3){
        write(1, usage, strlength(usage));
        exit(1);
} 

int ifd = open(argv[1], O_RDONLY); //fd for input file 
//check if file is opened succesfully or not
if(ifd<0){
char* err = strerror(errno);
write(2, err, strlength(err));
exit(1);
}

//get file size using fstat
int y = fstat(ifd, &buf);
//check for success
if( y < -1){
char* err = strerror(errno);
write(2, err, strlength(err));
exit(1);
}
 int size = buf.st_size; //accessing size of file from stuct
 int n = size/4; //calc no of elements, since 32 bits, divide by 4
 int readbuff[n];
 int rx = read(ifd, readbuff, size); //read and store in array
 if(rx<1)
 {
  char* err = strerror(errno);
  write(2, err, strlength(err));    
  exit(1);
 }   
 close(ifd);
 insertion_sort(readbuff, n); //sort
//creating output file to write 
int ofd = open(argv[2], O_WRONLY | O_CREAT | O_TRUNC, 0644);  //create op file
 if(ofd<0)
 {
     char* err = strerror(errno);
     write(2, err, strlength(err));
     exit(1);
 }
 int x=write(ofd, readbuff, size);
if(x<1){
char* err = strerror(errno);
write(2, err, strlength(err));    
exit(1);
}
close(ofd);
return 0;
}