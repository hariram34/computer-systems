    .global main
    .data
usage_msg:  .string "Usage: ./sort input output\n"
simple_msg:  .string "we are done!\n"


    .text
main:
    enter $0, $0
    cmp $3, %rdi
    jne label
 
    mov $:1, %rax   // syscall 1: write
    mov $1, %rdi   // fd 1: stdout
    mov $simple_msg, %rsi
    mov $13, %rdx   // strlen = 13
    syscall
    jmp done
label:    
    mov $1, %rax   // syscall 1: write
    mov $1, %rdi   // fd 1: stdout
    mov $usage_msg, %rsi
    mov $27, %rdx   // strlen = 27
    syscall   
done:
    mov $2, %rax
    leave
    ret
   
