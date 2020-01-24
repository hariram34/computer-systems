/*
Variable Mapping :
argc = 8(%ebp)
argv[1] = N = edx (initially stored in eax then moved to edx)
*/

    .global main

    .text
main:
    enter $0, $0 
    cmp $2,8(%ebp) //check if the user enters correct no.of args
    jne fail
    mov 12(%ebp), %ecx
    mov 4(%ecx), %eax //copy N to eax
    push %eax
    call atol //ascii to long
    add $4, %esp
    cmp $0, %eax //check if user enters only positive values
    jl fail
    mov %eax, %edx
    push %edx
    push %eax
    call fib
    pop %edx //restore N

    push %eax //result 
    push %edx //N
    push $output_fmt
    call printf
    add $8, %esp

    leave
    ret
/*
Variable Mapping:
Number = ebx
fib(number-1) = edi
fib(number-2 ) = eax
x = edi*/
fib:
    enter $0, $0
    push %ebx 
    push %esi
    push %edi
    mov 8(%ebp),%ebx //save N in ebx
    cmp $0,%ebx //return 0 if N is 0
    je fib_done_0
    cmp $1,%ebx  //return 1 if N is 1
    je fib_done_1
 
    mov %ebx,%esi 
    dec %ebx //dec by 1 and call fib
    push %ebx
    call fib
    add $4, %esp
    mov %eax, %edi

    mov %esi,%ebx
    dec %ebx
    dec %ebx //dec by 2 and call fib
    push %ebx
    call fib
    add $4, %esp
  
    add %edi, %eax ///eax has the sum of fib(n-1)+fib(n-2)
    jmp done
fib_done_1: //return 1
    mov $1,%eax
    jmp done 
fib_done_0: //return 0
    mov $0,%eax
    jmp done 
fail:
    mov $1, %eax //print usage fault and return 1
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
