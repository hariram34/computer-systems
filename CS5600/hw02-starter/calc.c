#include<stdio.h>
#include<stdlib.h>
int main(int argc, char *argv[]){
int n1=0,n2=0;
if(argc!=4){
 printf("Usage : ./calc N op N\n");
 return 1;
}
n1 = atol(argv[1]);
n2 = atol(argv[3]);
//printf("%d %d\n",n1,n2);
if(argv[2][0]=='+'){
 int res = n1+n2;
 printf("%ld + %ld = %ld\n",n1,n2,res);
 return res;
}else if(argv[2][0]=='-'){
 int res = 0;
 res= n1-n2;
 printf("%ld - %ld = %ld\n",n1,n2,res);
 return res;
}else if(argv[2][0]=='*'){
 int res = n1*n2;
 printf("%ld * %ld = %ld\n",n1,n2,res);
 return res;
}else if(argv[2][0]=='/'){
 int res = n1/n2;
 printf("%ld / %ld = %ld\n",n1,n2,res);
 return res;
} else{
printf("Usage: N op N\nop-+,-,*,/\n");
return 1;
}
}
