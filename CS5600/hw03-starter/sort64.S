    .global main
    .data
usage_msg:  .string "Usage: ./sort input output\n"
simple_msg:  .string "we are done!\n"


    .text
main:
    enter $0, $0
    cmp $3, %rdi
    jne label
 
    mov $simple_msg, %rdi
    call puts  // FIXME: That's not a syscall
    jmp done
label:    
    mov $usage_msg, %rdi
    call puts  // FIXME: That's not a syscall
done:
    mov $2, %rax
    leave
    ret
   
