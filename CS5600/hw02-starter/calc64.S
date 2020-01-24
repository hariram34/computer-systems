.global main
.text
main:
  push %r12
  push %r13
  push %r14
  enter $0,$0
  cmp $4, %rdi
  jne args
  mov 8(%rsi),%r12
  mov 16(%rsi),%r13
  mov 24(%rsi),%r14
 
  mov %r12, %rdi
  call atol
  mov %rax, %r12
  
  mov %r14, %rdi
  call atol
  mov %rax, %r14
   
/*  mov $outputfmt,%rdi
  mov %r12, %rsi
  mov $0, %al
  call printf

  mov $outputfmt,%rdi
  mov %r14, %rsi
  mov $0, %al
  call printf
*/ 
  mov %r13,%rcx
  cmpb $'+,(%rcx)
  je add
  cmpb $'-,(%rcx)
  je sub
  cmpb $'*,(%rcx)
  je mul
  cmpb $'/,(%rcx)
  je div
  mov $1, %rax
  jmp fail

add:
  mov %r12, %r8
  mov %r14, %r9 
  add %r8, %r9
  mov %r9, %r15
  jmp print
sub:
  mov %r12, %r8
  mov %r14, %r9 
  sub %r9, %r8
  mov %r8, %r15
  jmp print
mul: 
  mov %r12, %r8
  mov %r14, %rax 
  imul %r8
  mov %rax, %r15
  jmp print

div: 
  mov %r12,%rax
  mov %r14, %r8
  cqo
  idiv %r8
  mov %rax, %r15
  jmp print

fail : 
  mov $1, %rax 
  mov $arg_fault,%rdi
  mov $0, %al
  call printf
  jmp exit

args : 
  mov $1, %rax 
  mov $arg_fault,%rdi
  mov $0, %al
  call printf
  jmp exit
print:
  mov $outputfmt,%rdi
  mov %r12, %rsi
  mov %r13, %rdx
  mov %r14, %rcx
  mov %r15, %r8
  mov $0, %al
  call printf
  jmp exit

exit:
  leave 
  pop %r14
  pop %r13
  pop %r12
  ret
.data
usage_fault: .string "Usage : N op N\n"
outputfmt: .string "%ld %s %ld  = %ld\n"
arg_fault: .string "Usage : N op N\n"
