#Author Jackson Collalti
.data
.text
main:
 
addi $t0, $0, 5              # move input (N) to $t0
addi $t2,$0, 5    # n to $t2
lui $sp, 0x7FFF
nop
nop
ori $sp,$sp,0xEFFC


# Call function to get fibonnacci #n
add $a0,$t2, $0
add $v0,$t2 $0
jal fib     #call fib (n)
nop
nop
add $t3,$v0,$0    #result is in $t3

halt

fib:
# Compute and return fibonacci number
beq $a0,$0,zero   #if n=0 return 0
nop
nop
beq $a0,1,one   #if n=1 return 1
nop
nop

#Calling fib(n-1)
addi $sp,$sp,-4   #storing return address on stack
nop
nop
sw $ra,0($sp)

addi $a0,$a0,-1   #n-1
jal fib     #fib(n-1)
nop
nop
addi $a0,$a0,1

lw $ra,0($sp)   #restoring return address from stack
addi $sp,$sp,4
nop
nop

addi $sp,$sp,-4   #Push return value to stack
nop
nop
sw $v0,0($sp)
#Calling fib(n-2)
addi $sp,$sp,-4   #storing return address on stack
nop
nop
sw $ra,0($sp)

addi $a0,$a0,-2   #n-2
jal fib     #fib(n-2)
nop
nop
add $a0,$a0,2

lw $ra,0($sp)   #restoring return address from stack
addi $sp,$sp,4
nop
nop
#---------------
lw $s7,0($sp)   #Pop return value from stack
addi $sp,$sp,4
nop
add $v0,$v0,$s7 # f(n - 2)+fib(n-1)
jr $ra # decrement/next in stack
nop
nop

zero:
li $v0,0
jr $ra
nop
nop
one:
li $v0,1
jr $ra
nop
nop
