    .global main
    .data
usage_msg:  .string "Usage: ./sort input output\n"
simple_msg:  .string "we are done!\n"
strlen: .string "file size = %d\n"
strlen_p: .string "file size inside printf = %d\n"
input: .string "num.dat"
output: .string "output.dat"
error_opening_file: .string "failed to open file\n"
error_stat: .string "stat failed\n"
fd: .string "num = %d\n"
newline: .string "Insertion\n"
error: .string "The following error occured "

    .text
main:
    enter $128, $0
	push %r14				//fd
	push %r15				//size
    cmp $3, %rdi
    jne usage_fault
    
	
    //SYSCALL_OPEN
    mov 16(%rsi),%rbx
    //mov %rax,%rbx
    //push %rax
    mov 8(%rsi), %rdi
    mov $0, %rsi     		// 0 = O_RDONLY
    mov $0, %rdx     		// third arg, unused
    mov $2, %rax     		// syscall 2 = open
    syscall
    mov %rax, %r14   		// fd
    
    cmp $0, %rax
    jl  ERROR
	//using stat to get the file size
	mov %rsp,%rsi //stat
	mov $4, %rax
	syscall
	cmp $0, %rax
	jne ERROR
	mov 48(%rsp),%r15

	
	sub 48(%rsp),%rsp		//allocating memory on stack
	lea 0(%rsp), %r12
	mov $15, %r10			//realign stack
	not %r10
	and %r10, %rsp
    

	//mov $20, %r15
 	//SYSCALL_READ
	mov %r14, %rdi     // fd
    lea 0(%rsp), %rsi  // buffer is read_buf
    mov %r15, %rdx     // buffer size
    mov $0, %rax       // syscall 0 = read
    syscall
    mov %rax, %r15     // # of bytes read
	cmp $0, %rdx
    jl ERROR

/*

    Function arguments: %rdi, %rsi, %rdx, %rcx, %r8, %r9
    Temporary registers: %r10, %r11, (argument registers)
    Safe registers: %r12, %r13, %r14, %r15, %rbx
	
	pass address and N value
	r15 -> file size -> N
	r13 -> address


*/
	lea 0(%rsp), %r13
	mov %r15, %rdi	//N
	mov %r13, %rsi	//addr

	call sort

	//closing the input file
	mov $3, %rax
    mov %r14, %rdi
    syscall

here: 		
    mov  %rbx, %rdi
    mov $65, %rsi     		// create op file
    mov $0644, %rdx     		
    mov $2, %rax     		// syscall 2 is open
    syscall
    mov %rax, %r12   		// fd
	cmp $0,%rax
    jl ERROR

	mov $1, %rax   		// syscall 1: write
    mov %r12, %rdi   		// fd for output file
    mov %r13, %rsi
    mov %r15, %rdx   		
    syscall
	cmp $0, %rax
    jl error

    jmp done
	
usage_fault:    
    mov $usage_msg, %rdi	//find strlen			
    call length				//preserve strlen
    mov %rax,%r10
    
    mov $1, %rax   			// syscall 1: write
    mov $1, %rdi  			// fd 1: stdout
    mov $usage_msg, %rsi
    mov %r10, %rdx  		// strlen = 27
    syscall 
	jmp done
	
ERROR:
	neg %rax
    //mov $error,%rdi
    call strerror
	mov %rax, %rbx
	mov %rax, %rdi	//find strlen			
    call length				//preserve strlen
    mov %rax,%r10

	mov $1, %rax   			// syscall 1: write
    mov $1, %rdi  			// fd 1: stdout
	mov %rbx, %rsi
    mov %r10, %rdx  		// strlen = 27
    syscall 

    mov $60, %rax 			// exit
    mov $1, %rdi 			//ret value
    syscall
/*error_opening_file:
	mov $error_opening_file, %rdi
    call length			//find strlen
    mov %rax,%r10 		//preserve strlen 

    mov $1, %rax   		// syscall 1: write
    mov $1, %rdi   		// fd 1: stdout
    mov $error_opening_file, %rsi
    mov %r10, %rdx   		// strlen
    syscall
	jmp done
error_stat:
	mov $error_stat, %rdi
    call length			//find strlen
    mov %rax,%r10 		//preserve strlen 

    mov $1, %rax   		// syscall 1: write
    mov $1, %rdi   		// fd 1: stdout
    mov $error_stat, %rsi
    mov %r10, %rdx   		// strlen
    syscall	*/
done:
	//close the output file
	mov $3, %rax
    mov %r12, %rdi
    syscall
    mov $0, %rax
	pop %r15
    pop %r14
	//spop %r13
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
	jmp loop 			//repeat until we reach the string's end
loop_exit:
	mov %rcx, %rax  	//return strlen
	leave 
	ret
loop_exit_0:
	mov $0, %rax 
	leave 
	ret

sort:
	enter $32, $0
	push %r15
	push %r14
	push %r13
	push %r12
	push %rbx

	mov %rsi, %r12		//address
	mov %rdi, %rbx 		//no of bytes

	/*mov %rdi, %rsi
	mov $strlen_p, %rdi
	mov $0, %al
	call printf	
*/
	//calculate number of integers
	mov %rbx, %rax
	mov $4,%rbx
	cqo
	idiv %rbx
	mov %rax, %rbx 		//rbx has N value
	mov $0,%rcx

/*
rbx N
r12 addr
r15 i
r14 key
r13 j
*/
Insertion:
    mov $1, %r15   //i
Ins:   
    cmp %rbx, %r15 	//for loop
    jge exit
    mov (%r12, %r15, 4),%r14    //key
	dec %r15
    mov %r15, %r13		//j
    inc %r15                   
while:
    cmp $0,%r13                 //j>=0
    jl  stop

    cmp (%r12, %r13, 4),%r14d    //arr[j]>key
    jge   stop

	mov (%r12, %r13, 4),%r8     //arr[j]
    inc %r13
    mov %r8d ,(%r12, %r13, 4) 	//arr[j+1] = a[j]
	dec %r13
    dec %r13
    jmp while
stop:
    inc %r13
    mov %r14d,(%r12, %r13, 4)
	dec %r13
    inc %r15
    jmp Ins

exit:    
	pop %rbx
	pop %r12
	pop %r13
	pop %r14
	pop %r15
	leave
	ret

