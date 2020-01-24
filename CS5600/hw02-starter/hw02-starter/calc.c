#include<stdio.h>
#include<stdlib.h>
int main(int argc, char *argv[]){
int n1=0,n2=0;
if(argc!=4){ //check if user enters correct number of arguments
 printf("Usage : ./calc N op N\n");
 return 1;
}
n1 = atol(argv[1]); //ascii to long
n2 = atol(argv[3]);
//printf("%d %d\n",n1,n2);
//Compare argv[2] with the allowed arithmetic operations and perform it
if(argv[2][0]=='+'){ //perform addition and return 
 int res = n1+n2;
 printf("%ld + %ld = %ld\n",n1,n2,res);
 return 0;
}else if(argv[2][0]=='-'){ //perform subraction and return 
 int res = 0;
 res= n1-n2;
 printf("%ld - %ld = %ld\n",n1,n2,res);
 return 0;
}else if(argv[2][0]=='*'){ //perform multiplication and return 
 int res = n1*n2;
 printf("%ld * %ld = %ld\n",n1,n2,res);
 return 0;
}else if(argv[2][0]=='/'){ //perform division and return 
 int res = n1/n2;
 printf("%ld / %ld = %ld\n",n1,n2,res);
 return 0;
} else{
printf("Usage: N op N\nop-+,-,*,/\n"); //if invalid operator print usage and return 1
return 1;
}
}
