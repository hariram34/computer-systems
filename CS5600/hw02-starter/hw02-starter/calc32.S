/*
n1 = ebx
argv[2] = operator = esi
n2 = edi
result = r15
*/

.global main
.text
main:
  enter $0,$0
  push %ebx
  push %esi
  push %edi
  cmp $4,8(%ebp) //check if user enters correct number of arguments
  jne usage_fault
  mov 12(%ebp),%ecx 
  mov 4(%ecx),%ebx //accessing the arguments and storing them in safe registers
  mov 8(%ecx),%esi
  mov 12(%ecx),%edi

//the result of ascii to long is put pack in respective safe registers

  push %ebx
  call atol //ascii to long of n1
  mov %eax, %ebx

  push %edi
  call atol //ascii to long of n2
  mov %eax,%edi
//comparing the operator stored in esi with allowed operators
  cmpb $'+,(%esi)
  je add
  cmpb $'-, (%esi)
  je sub
  cmpb $'*, (%esi)
  je mul
  cmpb $'/, (%esi)
  je div
  jmp usage_fault //if nothing matches go to usage fault

add:
  mov %edi, %eax //using eax to save edi for later use
  add %ebx, %eax
  push %eax //pushing result,n2, operator and n1
  push %edi
  push %esi
  push %ebx
  push $outputfmt
  call printf
  jmp exit //jump to exit 
sub: 
  mov %ebx, %eax //using eax to save edi for later use
  sub %edi, %eax
  push %eax //pushing result,n2, operator and n1
  push %edi
  push %esi
  push %ebx
  push $outputfmt
  call printf
  jmp exit //jump to exit

mul:
  mov %edi, %eax //same steps as above 
  imul %ebx
  push %eax
  push %edi
  push %esi
  push %ebx
  push $outputfmt
  call printf
  jmp exit

div:
  mov %ebx, %eax //same steps as above
  cdq     //used to avoid floating point exception
  idiv %edi, %eax
  push %eax
  push %edi
  push %esi
  push %ebx
  push $outputfmt
  call printf
  jmp exit
  
usage_fault: //if the input is entered incorrectly this label will print usage fault and exit
  push $usage
  call printf
  add $4,%esp
  jmp exit
exit: //exit by popping safe registers
  pop %edi
  pop %esi
  pop %ebx
  leave 
  ret
.data
usage: .string "usage : ./fib32 N op N\n"
outputfmt: .string "%ld %s %ld = %ld\n"
