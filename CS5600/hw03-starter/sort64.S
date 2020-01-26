    .global main
    .data
usage_msg:  .string "Usage: ./sort input output\n"
simple_msg:  .string "we are done!\n"
strlen: .string "file size = %d\n"
input: .string "num.dat"
output: .string "output.dat"
ERROR: .string "ERROR\n"


    .text
main:
    enter $0, $0
    cmp $3, %rdi
    jne usage_fault
    
	//SYSCALL_OPEN
    mov $input, %rdi
    mov $0, %rsi     		// 0 = O_RDONLY
    mov $0, %rdx     		// third arg, unused
    mov $2, %rax     		// syscall 2 = open
    syscall
    mov %rax, %r14   		// fd
    
    cmp $0, %rax
    jl  error_opening_file
	
	//Getting file size using SYSCALL_LSEEK
	mov $8, %rax   			// syscall 8: lseek
    mov %r14, %rdi   		// fd in r14
    mov $0, %rsi			//offset
    mov $2, %rdx   		    // SEEK_END = 2, till EOF
    syscall
	mov %rax, %r15			//preserve file size
	
	mov $strlen, %rdi
	mov %r15, %rsi
	call printf
    
	//done
    mov $simple_msg, %rdi
    call length			//find strlen
    mov %rax,%r12 		//preserve strlen 

    mov $1, %rax   		// syscall 1: write
    mov $1, %rdi   		// fd 1: stdout
    mov $simple_msg, %rsi
    mov %r12, %rdx   		// strlen = 13
    syscall
	
    jmp done
	
usage_fault:    
    mov $usage_msg, %rdi	//find strlen			
    call length			   //preserve strlen
    mov %rax,%r12
    
    mov $1, %rax   		// syscall 1: write
    mov $1, %rdi  		// fd 1: stdout
    mov $usage_msg, %rsi
    mov %r12, %rdx  		// strlen = 27
    syscall 
	jmp done
	
error_opening_file:
	mov $ERROR, %rdi
    call length			//find strlen
    mov %rax,%r12 		//preserve strlen 

    mov $1, %rax   		// syscall 1: write
    mov $1, %rdi   		// fd 1: stdout
    mov $ERROR, %rsi
    mov %r12, %rdx   		// strlen = 13
    syscall
	
done:
    mov $2, %rax
    leave
    ret
	
//string length function
length:
	enter $0,$0
	
	mov $1, %rax 		//rax will hold strlen
	mov $0,%rcx 		//count value
	mov $'\0, %rsi

loop:
	mov (%rdi,%rcx,1), %dl 	// mov 1 byte(char) from rdi to dl(lower 8 bits)
	cmp  $0, %dl  		//if nothing exit
	je loop_exit
	
	cmp %sil, %dl 		//compare if the string has reached it's end
	je loop_exit_0 		//if yes exit
	
continue:
	//increment count value, this count should give the sting length in the end
	inc %rcx 
	jmp loop 		//repeat until we reach the string's end
loop_exit:
	mov %rcx, %rax  	//return strlen
	leave 
	ret
loop_exit_0:
	mov $0, %rax 
	leave 
	ret
	
 
