/*
Variable Mapping :
xx = r14
*/
  .global main

  .text
main:
  enter $24, $0 
  push %r14 

  cmp $2, %rdi //argc is rdi, check if the user enters correct no.of args
  jne args 
  mov 8(%rsi),%rdi //copy the N value to rdi
  mov %rdi, %r14 
  call atol //ascii to long
  mov %rax, %r14 //store result in a safe register
  cmp $0,%r14 //check if the user enters only positive values
  jl args
  push %rax 
  mov %r14, %rdi //load N into rdi and call fib
  call fib 
  pop %r14 

  mov $output_fmt,%rdi //printf rax- has the result, r14 has the N
  mov %r14,%rsi
  mov %rax,%rdx
  mov $0, %al
  call printf
  jmp done
/*
int fib(int number){
if(number==0)return 0;
if(number==1)return 1;
int x = 0;
x = fib(number-1)+fib(number-2);
return x;
}
safe : rbx,r12-15

Variable Mapping:
Number = rbx,rdi
fib(number-1) = r12
fib(number-2 ) = rax
x = rax
*/
fib:
  enter $0,$0
  push %rbx //pushing safe registers
  push %r12
  push %r13

  cmp $0,%rdi //return 0 
  je fib_done_0
  cmp $1,%rdi //return 1
  je fib_done_1
 
  mov %rdi,%rbx //save rdi in safe register rbx
  dec %rdi      //decrement by 1 and call fib(number-1)
  call fib
  mov %rax, %r12 //store result in a safe register

  mov %rbx,%rdi //restore rdi value 
  dec %rdi  
  dec %rdi  //decrement by 2 and call fib(number-2)
  call fib
  add %r12, %rax //rax has the sum of fib(n-1)+fib(n-2)
  jmp done

args:
  mov $1,%rax //print usage fault and return 1
  mov $usage_fault, %rdi
  mov $0, %al
  call printf
  jmp done

fib_done_1:
  mov $1,%rax //return 1
  jmp done 
fib_done_0:
  mov $0,%rax //return 0
  jmp done 

done:
  pop %r13 //exit after popping
  pop %r12
  pop %rbx
  pop %r14
  leave 
  ret
.data
usage_fault: .string "Usage : ./fib64 N\n"
output_fmt:  .string "fib(%ld) = %ld\n"
