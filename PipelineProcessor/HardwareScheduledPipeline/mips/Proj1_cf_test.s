#Author Jackson Collalti
.data
.text
main:
 
addi $t0, $0, 5              # move input (N) to $t0
addi $t2,$0, 5    # n to $t2
lui $sp, 0x7FFF
addi $sp,$sp,0xEFFC


# Call function to get fibonnacci #n
add $a0,$t2, $0
add $v0,$t2 $0
jal fib     #call fib (n)
add $t3,$v0,$0    #result is in $t3

halt

fib:
# Compute and return fibonacci number
beq $a0,$0,zero   #if n=0 return 0
beq $a0,1,one   #if n=1 return 1

#Calling fib(n-1)
addi $sp,$sp,-4   #storing return address on stack
sw $ra,0($sp)

addi $a0,$a0,-1   #n-1
jal fib     #fib(n-1)
addi $a0,$a0,1

lw $ra,0($sp)   #restoring return address from stack
addi $sp,$sp,4


addi $sp,$sp,-4   #Push return value to stack
sw $v0,0($sp)
#Calling fib(n-2)
addi $sp,$sp,-4   #storing return address on stack
sw $ra,0($sp)

addi $a0,$a0,-2   #n-2
jal fib     #fib(n-2)
add $a0,$a0,2

lw $ra,0($sp)   #restoring return address from stack
addi $sp,$sp,4
#---------------
lw $s7,0($sp)   #Pop return value from stack
addi $sp,$sp,4

add $v0,$v0,$s7 # f(n - 2)+fib(n-1)
jr $ra # decrement/next in stack

zero:
li $v0,0
jr $ra
one:
li $v0,1
jr $ra
