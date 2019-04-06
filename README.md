# objdump-to-opcodes
takes a file containing the output of calling "objdump -d <asm file>" and returns only the op codes section.

<h1> How to use </h1>
<ul>
	<li>Install SBCL with whatever package manager you have:<br>
		"emerge sbcl" on Gentoo</li>

<li>Next get your ASM:</li>
```
global _start
	section .data
program:	db '/bin/bash', 0
	section .text
_start:
				;need file descriptor for stdout
	mov rax, 59 		;syscall number execve
	mov rdi, program             
	xor rsi, rsi
	xor rdx, rdx
	syscall
```


<li>Next compile that and link it:

nasm -felf64 bash.asm -o bash-asm <br>
ld bash-asm.o -o bash-asm</li>

<li>use objdump to create a file for use with the script:<br>
objdump -d bash-asm >> bash-asm-op
</li>

<li>Now save this file op-codes.lisp into the same directory as your compiled assembly and make it executable<br>
chmod +x op-codes.lisp</li>

<li>then run it it with the file name you created a minute ago as the argument:</li>
```
./op-codes.lisp bash-asm-op
\xb8\x83\x3b\xb0\x00\x00\x00\x00\x00\x0\x48\x8b\xbf\xfc\xc8\x80\x00\x06\x60\x00\x00\x00\x00\x0\x48\x83\x31\x1f\xf6\x6\x48\x83\x31\x1d\xd2\x2\x0f\xf0\x05\x5
```



