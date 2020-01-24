    .global main

    .text
main:
    enter $0, $0
    cmp $2,8(%ebp)
    jne fail
    mov 12(%ebp), %ecx
    mov 4(%ecx), %eax
    push %eax
    call atoi
    add $4, %esp
    cmp $0, %eax
    jl fail
    mov %eax, %edx
    push %edx
    push %eax
    call fib
    pop %edx

    push %eax
    push %edx
    push $output_fmt
    call printf
    add $8, %esp

    leave
    ret
fib:
    enter $0, $0
    push %ebx
    push %esi
    push %edi
    mov 8(%ebp),%ebx
    cmp $0,%ebx
    je fib_done_0
    cmp $1,%ebx
    je fib_done_1
 
    mov %ebx,%esi
    dec %ebx
    push %ebx
    call fib
    add $4, %esp
    mov %eax, %edi

    mov %esi,%ebx
    dec %ebx
    dec %ebx
    push %ebx
    call fib
    add $4, %esp
  
    add %edi, %eax
    jmp done
fib_done_1:
    mov $1,%eax
    jmp done 
fib_done_0:
    mov $0,%eax
    jmp done 
fail:
    mov $1, %eax
    push $arg_fault
    call printf
    add $4, %esp
    leave
    ret

done:
    pop %edi	
    pop %esi
    pop %ebx
    leave 
    ret
.data
output_fmt:  .string "fib(%ld) = %ld\n"
arg_fault: .string "Usage: ./fib32 N\n"
