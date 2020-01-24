.global cube
.text
cube:
enter $0,$0
mov %rdi,%rax
imul %rax
imul %rdi
leave
ret
