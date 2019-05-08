# objdump-to-opcodes
takes a file containing the output of calling "objdump -d <asm file>" and returns only the op codes section.

<h1> How to use </h1>
<ul>
	<li>Install SBCL with whatever package manager you have:<br>
		"emerge sbcl" on Gentoo</li>

<li>Take the output of objdump and put into a file:</li>



```


bash-asm:     file format elf64-x86-64


Disassembly of section .text:

00000000004000b0 <_start>:
  4000b0:	b8 3b 00 00 00       	mov    $0x3b,%eax
  4000b5:	48 bf c8 00 60 00 00 	movabs $0x6000c8,%rdi
  4000bc:	00 00 00 
  4000bf:	48 31 f6             	xor    %rsi,%rsi
  4000c2:	48 31 d2             	xor    %rdx,%rdx
  4000c5:	0f 05                	syscall 


	
```



</li>

<li>Now save this file op-codes.lisp into the same directory as your compiled assembly and make it executable<br>

```

chmod +x op-codes.lisp

```

</li>
<li>then run it it with the file name you created a minute ago as the argument:</li>

```

./op-codes.lisp bash-asm-op 

\xb8\x3b\x00\x00\x00\x48\xbf\xc8\x00\x60\x00\x00\x00\x00\x00\x48\x31\xf6\x48\x31\xd2\x0f\x05


```


</ul>

