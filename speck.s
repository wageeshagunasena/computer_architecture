@ Speck cipher

	.text
	
rol:	@ rol(x,r) 1stx=r0	2ndx=r1 r=r2

	@ reserve callee reserved registers
	sub sp,sp,#20
	str lr,[sp,#0]
	str r4,[sp,#4]
	str r5,[sp,#8]
	str r6,[sp,#12]
	str r7,[sp,#16]
	
	lsl r4,r0,r2	@ r4 = 1stx<<r
	mov r5,#32
	sub r5,r5,r2	@ r5 = 32-r
	lsr r6,r1,r5	@ r6 = 2ndx>>32-r
	orr r4,r4,r6	@ r4 = 1stx<<r | 2ndx>>32-r
	
	lsl r6,r1,r2	@ r6 = 2ndx<<r
	lsr r7,r0,r5	@ r6 = 1stx>>32-r
	orr r5,r6,r7	@ r4 = 2ndx<<r | 1stx>>32-r
	
	mov r0,r4		@ return 1stx from r0
	mov r1,r5		@ return 2ndx from r1
	
	@ restore callee reserved registers
	ldr lr,[sp,#0]
	ldr r4,[sp,#4]
	ldr r5,[sp,#8]
	ldr r6,[sp,#12]
	ldr r7,[sp,#16]
	add sp,sp,#20
	mov pc,lr
	
	
ror:	@ ror(x,r) 1stx=r0	2ndx=r1 r=r2

	@ reserve callee reserved registers
	sub sp,sp,#20
	str lr,[sp,#0]
	str r4,[sp,#4]
	str r5,[sp,#8]
	str r6,[sp,#12]
	str r7,[sp,#16]
	
	lsr r4,r0,r2	@ r4 = 1stx>>r
	mov r5,#32
	sub r5,r5,r2	@ r5 = 32-r
	lsl r6,r1,r5	@ r6 = 2ndx<<32-r
	orr r4,r4,r6	@ r4 = 1stx>>r | 2ndx<<32-r
	
	lsr r6,r1,r2	@ r6 = 2ndx>>r
	lsl r7,r0,r5	@ r7 = 1stx<<32-r
	orr r5,r6,r7	@ r4 = 2ndx>>r | 1stx<<32-r
	
	mov r0,r4		@ return 1stx from r0
	mov r1,r5		@ return 2ndx from r1
	
	@ restore callee reserved registers
	ldr lr,[sp,#0]
	ldr r4,[sp,#4]
	ldr r5,[sp,#8]
	ldr r6,[sp,#12]
	ldr r7,[sp,#16]
	add sp,sp,#20
	mov pc,lr	
	
	
r:		@ r(x,y,k)	1stx=r0  2ndx=r1  1sty=r2  2ndy=r3  1stk=r4  2ndk=r5

	@ reserve callee reserved registers
	sub sp,sp,#28
	str lr,[sp,#0]
	str r6,[sp,#4]
	str r7,[sp,#8]
	str r8,[sp,#12]
	str r9,[sp,#16]
	str r10,[sp,#20]
	str r11,[sp,#24]
	
	mov r6,r0	@ r6=1stx
	mov r7,r1	@ r7=2ndx
	
	mov r8,r2	@ r8=1sty
	mov r9,r3	@ r9=2ndy
	
	@ call ror(x,8)
	mov r0,r6
	mov r1,r7
	mov r2,#8
	bl ror
	
	mov r6,r0		@ r6 = 1st part of ror(x,8)
	mov r7,r1		@ r7 = 2nd part of ror(x,8)
	
	adds r7,r7,r9	@ x+=y 2nd
	adc r6,r6,r8	@ x+=y 1st
	
	eor r7,r7,r5	@ x^=k 2nd
	eor r6,r6,r4	@ x^=k 1st
	
	@ calling rol(y,3)
	mov r0,r8
	mov r1,r9
	mov r2,#3
	bl rol
	
	mov r8,r0		@ r8 = 1st rol(y,3)
	mov r9,r1		@ r9 = 2nd rol(y,3)
	
	eor r9,r9,r7	@ y^=x 2nd
	eor r8,r8,r6	@ y^=x 1st
	
	mov r0,r6	@ return 1stx
	mov r1,r7	@ return 2ndx
	
	mov r2,r8	@ return 1sty
	mov r3,r9	@ return 2ndy
	
	@ restore callee reserved registers
	ldr lr,[sp,#0]
	ldr r6,[sp,#4]
	ldr r7,[sp,#8]
	ldr r8,[sp,#12]
	ldr r9,[sp,#16]
	ldr r10,[sp,#20]
	ldr r11,[sp,#24]
	add sp,sp,#28
	mov pc,lr	
	
	
encrypt:	@ base pt[0]y=r0 pt[1]x=r1 k[0]b=r2 k[1]a=r3
	
	@ reserve callee reserved registers
	sub sp,sp,#36
	str lr,[sp,#0]
	str r4,[sp,#4]
	str r5,[sp,#8]
	str r6,[sp,#12]
	str r7,[sp,#16]
	str r8,[sp,#20]
	str r9,[sp,#24]
	str r10,[sp,#28]
	str r11,[sp,#32]

	ldr r4,[r1,#4]	@ 1stx
	ldr r5,[r1,#0]	@ 2ndx
	
	ldr r6,[r0,#4]	@ 1sty
	ldr r7,[r0,#0]	@ 2ndy

	ldr r8,[r3,#4]	@ 1sta
	ldr r9,[r3,#0]	@ 2nda
	
	ldr r10,[r2,#4]	@ 1stb
	ldr r11,[r2,#0]	@ 2ndb
	
	@ calling r(x,y,b)
	mov r0,r4	@ parse 1stx
	mov r1,r5	@ parse 2ndx
	mov r2,r6	@ parse 1sty
	mov r3,r7	@ parse 2nd
	mov r4,r10	@ parse 1stb
	mov r5,r11	@ parse 2ndb
	bl r
	
	mov r4,r0	@ return 1stx
	mov r5,r1	@ return 2ndx
	mov r6,r2	@ return 1sty
	mov r7,r3	@ return 2ndy
	
	mov r12,#0	@ i=0
loop:	
	cmp r12,#31
	bge exit
	
	@ calling r(a,b,i)
	mov r0,r8	@ parse 1sta
	mov r1,r9	@ parse 2nda
	mov r2,r10	@ parse 1stb
	mov r3,r11	@ parse 2ndb
	sub sp,sp,#8
	str r4,[sp,#0]	@ reserve r4,r5
	str r5,[sp,#4]
	mov r4,#0	@ parse 1sti
	mov r5,r12	@ parse 2ndi
	bl r
	
	ldr r4,[sp,#0]	@ restore r4,r5
	ldr r5,[sp,#4]
	add sp,sp,#8
	mov r8,r0	@ return 1sta
	mov r9,r1	@ return 2nda
	mov r10,r2	@ return 1stb
	mov r11,r3	@ return 2nda
	
	@ calling r(x,y,b)
	mov r0,r4	@ parse 1stx
	mov r1,r5	@ parse 2ndx
	mov r2,r6	@ parse 1sty
	mov r3,r7	@ parse 2ndy
	mov r4,r10	@ parse 1stb
	mov r5,r11	@ parse 2ndb
	bl r
	
	mov r4,r0	@ return 1sta
	mov r5,r1	@ return 2nda
	mov r6,r2	@ return 1stb
	mov r7,r3	@ return 2nda
	
	add r12,r12,#1	@ r12(i)++
	b loop
	
exit:	
	@ return x1,x2,y1,y2
	mov r0,r4
	mov r1,r5
	mov r2,r6
	mov r3,r7
	
	@ restore callee reserved registers
	ldr lr,[sp,#0]
	ldr r4,[sp,#4]
	ldr r5,[sp,#8]
	ldr r6,[sp,#12]
	ldr r7,[sp,#16]
	ldr r8,[sp,#20]
	ldr r9,[sp,#24]
	ldr r10,[sp,#28]
	ldr r11,[sp,#32]
	add sp,sp,#36
	mov pc,lr
	
	
	.global main
main:
	sub sp,sp,#4
	str lr,[sp,#0]
	
	@ printf "Enter the key:"
	ldr r0,=formatskey
	bl printf
	
	sub sp,sp,#8
	@ scanf key[1] "%llx"
	ldr r0,=formathex
	mov r1,sp
	bl scanf	
	mov r4,sp
	
	sub sp,sp,#8	
	@ scanf key[0] "%llx"
	ldr r0,=formathex
	mov r1,sp
	bl scanf
	mov r5,sp
	
	@ printf "Enter plain text:"
	ldr r0,=formatstxt
	bl printf
	
	sub sp,sp,#8
	@ scanf pt[1] "%llx"
	ldr r0,=formathex
	mov r1,sp
	bl scanf
	mov r6,sp
	
	sub sp,sp,#8
	@ scanf pt[0] "%llx"
	ldr r0,=formathex
	mov r1,sp
	bl scanf	
	mov r7,sp
	
	mov r0,r7
	mov r1,r6
	mov r2,r5
	mov r3,r4	
	bl encrypt
	
	mov r4,r0	@ c11
	mov r5,r1	@ c12
	mov r6,r2	@ c21
	mov r7,r3	@ c22
	
	@print ciphertext
	ldr r0,=formato
	bl printf
	
	ldr r0,=formathex
	mov r1,r5
	mov r2,r4
	bl printf
	
	ldr r0,=formathexn
	mov r1,r7
	mov r2,r6
	bl printf
	
	
	add sp,sp,#32
	
	ldr lr,[sp,#0]
	add sp,sp,#4
	mov pc,lr
	
	.data
formatskey: .asciz "Enter the key:\n"
formathex: .asciz "%llx"
formathexn: .asciz " %llx\n"
formatstxt: .asciz "Enter the plain text:\n"
formi: .asciz "%d\n"
formato: .asciz "Cipher text is:\n"
