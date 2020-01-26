    .global main
    .data
usage_msg:  .string "Usage: ./sort input output\n"
simple_msg:  .string "we are done!\n"
strlen: .string "strlen = %d\n"
strlen_d: .string "strlen_d = %d\n"


    .text
main:
    enter $0, $0
    cmp $3, %rdi
    jne label
    
    mov $simple_msg, %rdi
    call length
    mov %rax,%r12
	
    mov $strlen, %rdi
    mov %rax, %rsi
    mov $0, %al
    call printf
	
    mov $1, %rax   // syscall 1: write
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
length:
	enter $0,$0
	
	mov $1, %rax //rax will hold strlen
	mov $0,%rcx //count value
	mov $'\0, %rsi

loop:
	mov (%rdi,%rcx,1), %dl // mov 1 byte(char) from rdi to dl(lower 8 bits)
	cmp  $0, %dl  //if nothing exit
	je loop_exit
	
	cmp %sil, %dl //compare if the string has reached it's end
	je loop_exit_0 //if yes exit
	
continue:
	//increment count value, this count should give the sting length in the end
	inc %rcx 
	jmp loop //repeat until we reach the string's end
loop_exit:
	mov %rcx, %rax  //return strlen
	leave 
	ret
loop_exit_0:
	mov $0, %rax 
	leave 
	ret
	
 
