.data
    msg: .asciiz "Hello, world"	#at 0x00500000
.text
    addi $a0,$a0, 80			#load str1 addr to $a0 and print.
    sll $a0,$a0,16
    addi $v0, $zero, 4
    syscall
    addi $v0, $zero, 10
    syscall
