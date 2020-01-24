.global main
.text
main:
  enter $0,$0
  push %ebx
  push %esi
  push %edi
  cmp $4,8(%ebp)
  jne usage_fault
  mov 12(%ebp),%ecx
  mov 4(%ecx),%ebx
  mov 8(%ecx),%esi
  mov 12(%ecx),%edi
  push %ebx
  call atol
  mov %eax, %ebx

  push %edi
  call atol
  mov %eax,%edi

  cmpb $'+,(%esi)
  je add
  cmpb $'-, (%esi)
  je sub
  cmpb $'*, (%esi)
  je mul
  cmpb $'/, (%esi)
  je div
  jmp usage_fault

add:
  mov %edi, %eax
  add %ebx, %eax
  push %eax
  push %edi
  push %esi
  push %ebx
  push $outputfmt
  call printf
  jmp exit
sub: 
  mov %ebx, %eax
  sub %edi, %eax
  push %eax
  push %edi
  push %esi
  push %ebx
  push $outputfmt
  call printf
  jmp exit

mul:
  mov %edi, %eax
  imul %ebx
  push %eax
  push %edi
  push %esi
  push %ebx
  push $outputfmt
  call printf
  jmp exit

div:
  mov %ebx, %eax
  cdq
  idiv %edi, %eax
  push %eax
  push %edi
  push %esi
  push %ebx
  push $outputfmt
  call printf
  jmp exit
  
usage_fault:
  push $usage
  call printf
  add $4,%esp
  jmp exit
exit:
  pop %edi
  pop %esi
  pop %ebx
  leave 
  ret
.data
usage: .string "usage : ./fib32 N op N\n"
outputfmt: .string "%ld %s %ld = %ld\n"
