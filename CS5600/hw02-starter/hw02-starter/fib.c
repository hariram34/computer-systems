
#include <stdio.h>
#include <stdlib.h>
int fib(int number){
if(number==0)return 0;
if(number==1)return 1;
int x = 0;
x = fib(number-1)+fib(number-2); //recursively call fibonacci function by passing n-1 and n-2
return x; //return nth number in the sequence
}
int
main(int argc, char* argv[])
{   if(argc!=2){ //check if there are two args 
	printf("Usage : ./fib N\n");
	return 1;
	       }
    long xx = atol(argv[1]); //ascii to long coversion
    if(xx<0){ //making sure user enters only positive values
    printf("Usage : ./fib N\n");
    return 1;
    }
    printf("fib(%ld) = %ld\n",xx, fib(xx));//print result
    return 0;
}

