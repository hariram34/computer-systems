.global main

.text
main:
	enter $128,$0
	//pushing safe registers
	push %ebx
	push %esi
	push %edi

	//getting argc value
	mov 8(%ebp),%edx
	//checking if correct args are entered
	cmp $3, %edx
	jne usage_fault
	
	mov 12(%ebp), %ebx
	mov 4(%ebx), %edi  //input file
	mov 8(%ebx), %esi  //output file
	mov %edi, -16(%ebp)
	mov %esi, -20(%ebp) //saving into stack so that I can relieve 
						//the safe registers and use for other puposes	

	//push %edi
	//using open syscall
	mov %edi , %ebx      //file input name
    mov $0, %ecx         //O_RDONLY 
    mov $0, %edx         
    mov $5, %eax         //open = 5
    int $0x80
	mov %eax, %ebx 		//fd is in ebx
	mov %ebx, -24(%ebp)
    cmp $0, %eax 
	jle error
 
	//pop %edi
    //fnewstate
    mov %edi, %ebx     	  	//file  
    mov %esp , %ecx    
    mov $106, %eax			//stat syscall
    int $0x80
    cmp $0 , %eax			//stat will return 0 upon success
    jne error

    mov 20(%esp), %ecx 	//size obained
	mov %ecx, -28(%ebp)		//save size onto stack

    sub %ecx, %esp

	lea 0(%esp), %edx
    mov $15, %edx 			//aligning the stack
    not %edx
    and %edx, %esp

	//read syscall
	mov -24(%ebp) , %ebx     //fd
    mov %esp , %ecx          //passing the array to read into
    mov -28(%ebp) , %edx     //bytes to read
    mov $3 , %eax
    int $0x80

	cmp $0 , %eax			//eax should return no of bytes read(>0)
    jle  error

	

	lea 0(%esp), %eax
	push -28(%ebp)			//N
	push %eax				//address

	call sort
	add $8, %esp
	
	
	//close the input file
	mov -24(%ebp), %ebx    		//fd
    mov $6 , %eax           	//close syscall is 6
    int $0x80

	//open output file
	mov -20(%ebp), %ebx  		 //file input name
    mov $65, %ecx         		//O_WRONLY and create
    mov $0644, %edx         		
    mov $5, %eax         		//open = 5
    int $0x80		

	mov %eax, %ebx 		 		 //fd is in ebx
    cmp $0, %eax 
	jle error

	mov %eax, %ebx           //output file fd
    mov %esp, %ecx      	 //Array 
    mov -28(%ebp), %edx      //#of bytes
    mov $4 , %eax             //write syscall is 4
    int $0x80
	cmp $0, %eax
    jl error
    mov $0, %eax
	jmp done

stat_fail:
	push $stat_failed
	call length
	mov %eax, %edx

	//write syscall
	mov $4, %eax
	mov $1, %ebx
	mov $stat_failed, %ecx
	int $0x80
	jmp done
usage_fault:
	push $usage_msg
	call length
	mov %eax, %edx

	//write syscall
	mov $4, %eax
	mov $1, %ebx
	mov $usage_msg, %ecx
	int $0x80
	jmp done
file_error:
	push $file_open_fail
	call length
	mov %eax, %edx

	//write syscall
	mov $4, %eax
	mov $1, %ebx
	mov $file_open_fail, %ecx
	int $0x80
	jmp done
o_file_error:
	push $ofile_open_fail
	call length
	mov %eax, %edx

	//write syscall
	mov $4, %eax
	mov $1, %ebx
	mov $ofile_open_fail, %ecx
	int $0x80
	jmp done
failed_to_read:
	push $file_read_fail
	call length
	mov %eax, %edx

	//write syscall
	mov $4, %eax
	mov $1, %ebx
	mov $file_read_fail, %ecx
	int $0x80
	jmp done
error:
	//strerror used here
	neg %eax
	call strerror
	mov %eax, %edi
	push %eax
	call length
	mov %eax, %edx

	mov $4, %eax
	mov $1, %ebx
	mov %edx, %ecx
	int $0x80 

	mov $1, %eax    //sys_exit
    mov $1, %ebx   //exit code
    int $0x80

done:
    mov $0, %eax
	pop %edi
	pop %esi
	pop %ebx
	leave 
	ret

length:
//strlen function
	enter $0,$0
	push %edi
	mov $1, %eax 		//rax will hold strlen
	mov $0,%ecx 		//count value
	mov 8(%ebp), %edx

loop:
	mov (%edx,%ecx,1), %eax	// mov 1 byte(char) from rdi to dl(lower 8 bits)
	cmp  $0, %al 		//if nothing exit
	je loop_exit
	
continue:
	//increment count value, this count should give the sting length in the end
	inc %ecx 
	jmp loop 			//repeat until we reach the string's end
loop_exit:
	mov %ecx, %eax  
    pop %edi	//return strlen
	leave 
	ret
sort:
	
	enter $32,$0
	push %ebx
	push %esi
	push %edi

	mov 8(%ebp),%esi	//address
	mov 12(%ebp),%edi	//N(in bytes)
	
	
    mov %edi , %eax
    mov $4 , %ebx
	cdq
    idiv %ebx
    mov %eax ,-16(%ebp)
	mov %eax, %edi		//N, now has number of elements

	cmp $0, %edi
	jle invalid_size	//checking if N value is valid
	//edi free,eax
Insertion:
	
	mov $1,%ecx
Ins:
	cmp -16(%ebp), %ecx				//for loop
	jge exit
	mov (%esi, %ecx, 4),%ebx		//key = ebx
	dec %ecx
	mov %ecx, %edx				//j
	inc %ecx
while:
	cmp $0,%edx               //j>=0
    jl  stop

	cmp (%esi, %edx, 4),%ebx   //arr[j]>key
    jge   stop

	mov (%esi, %edx, 4),%eax
	inc %edx
	mov %eax,(%esi, %edx, 4)
	dec %edx
    dec %edx
    jmp while
stop:
    inc %edx
    mov %ebx,(%esi, %edx, 4)
	dec %edx
    inc %ecx
    jmp Ins


	//push -16(%ebp)
	//push $fd
	//call printf
invalid_size:
	push $invalid_size_
	call length
	mov %eax, %edx

	//write syscall
	mov $4, %eax
	mov $1, %ebx
	mov $invalid_size_, %ecx
	int $0x80
	jmp exit


exit:
	mov %esi, %eax
	pop %edi
	pop %esi
	pop %ebx
	leave 
	ret

.data
usage_msg:  .string "Usage: ./sort input output\n"
simple_msg:  .string "we are done!\n"
strlen: .string "file size = %d\n"
strlen_p: .string "file size inside printf = %d\n"
input: .string "num.dat"
output: .string "output.dat"
file_open_fail: .string "failed to open file\n"
ofile_open_fail: .string "output file failed to open file\n"
file_read_fail: .string "failed to read file\n"
stat_failed: .string "stat failed\n"
invalid_size_: .string "stat failed\n"
fd: .string "num = %d\n"
newline: .string "Insertion\n"



