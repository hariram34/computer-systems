/*
n1 = r12
argv[2] = operator = r13
n2 = r14
result = r15
*/
.global main
.text
main:
  push %r12
  push %r13
  push %r14
  enter $0,$0
  cmp $4, %rdi //check if user enters correct number of arguments
  jne args
  mov 8(%rsi),%r12 //accessing the arguments and storing them in safe registers
  mov 16(%rsi),%r13
  mov 24(%rsi),%r14
 
///the result of ascii to long is put pack in respective safe registers
  mov %r12, %rdi //ascii to long of n1
  call atol
  mov %rax, %r12 
  
  mov %r14, %rdi //ascii to long of n2
  call atol
  mov %rax, %r14
   
  mov %r13,%rcx //using a temporary register to compare the entered operator
		//with allowed operations
  cmpb $'+,(%rcx)
  je add
  cmpb $'-,(%rcx)
  je sub
  cmpb $'*,(%rcx)
  je mul
  cmpb $'/,(%rcx)
  je div
  mov $1, %rax //if none is satisifed print usage fault and return 1
  jmp fail
/*
temporary registers 
r8 = r12(n1)
r9 = r14(n2)
r15 = result //safe register
*/
add:
  mov %r12, %r8 //performing addition and print result
  mov %r14, %r9 
  add %r8, %r9
  mov %r9, %r15
  jmp print //jump to print
sub:
  mov %r12, %r8 //performing subraction and print result
  mov %r14, %r9 
  sub %r9, %r8
  mov %r8, %r15
  jmp print
mul: 
  mov %r12, %r8 //performing multiplication and print result
  mov %r14, %rax //storing r14 into rax
  imul %r8
  mov %rax, %r15 //moving result into r15
  jmp print

div: 
  mov %r12,%rax //performing division and print result
  mov %r14, %r8
  cqo
  idiv %r8
  mov %rax, %r15 //same steps as mul
  jmp print

fail : //if none of the operators match
  mov $1, %rax 
  mov $arg_fault,%rdi
  mov $0, %al
  call printf
  jmp exit

args :  //if # of argument is not correct
  mov $1, %rax //return 1 and exit
  mov $arg_fault,%rdi
  mov $0, %al
  call printf
  jmp exit
print: //printig result
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
