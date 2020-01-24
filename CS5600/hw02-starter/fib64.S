  .global main

  .text
main:
  enter $24, $0 
  push %r14 

  cmp $2, %rdi
  jne args
  mov 8(%rsi),%rdi
  mov %rdi, %r14
  call atol
  mov %rax, %r14
  cmp $0,%r14
  jl args
  push %rax
  mov %r14, %rdi
  call fib 
  pop %r14

  mov $output_fmt,%rdi
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
*/
fib:
  enter $0,$0
  push %rbx
  push %r12
  push %r13

  cmp $0,%rdi
  je fib_done_0
  cmp $1,%rdi
  je fib_done_1
 
  mov %rdi,%rbx
  dec %rdi
  call fib
  mov %rax, %r12

  mov %rbx,%rdi
  dec %rdi
  dec %rdi
  call fib
  
  add %r12, %rax
  jmp done

args:
  mov $1,%rax
  mov $usage_fault, %rdi
  mov $0, %al
  call printf
  jmp done

fib_done_1:
  mov $1,%rax
  jmp done 
fib_done_0:
  mov $0,%rax
  jmp done 

done:
  pop %r13
  pop %r12
  pop %rbx
  pop %r14
  leave 
  ret
.data
usage_fault: .string "Usage : ./fib64 N\n"
output_fmt:  .string "fib(%ld) = %ld\n"
