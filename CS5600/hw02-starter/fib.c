
#include <stdio.h>
#include <stdlib.h>
int fib(int number){
if(number==0)return 0;
if(number==1)return 1;
int x = 0;
x = fib(number-1)+fib(number-2);
return x;
}
int
main(int argc, char* argv[])
{   if(argc!=2){
	printf("Usage : ./fib N\n");
	return 1;
	       }
    long xx = atol(argv[1]);
    if(xx<0){
    printf("Usage : ./fib N\n");
    return 1;
    }
    printf("fib(%ld) = %ld\n",xx, fib(xx));
    return 0;
}

