.data
    array: .word 10, 20, 30, 40, 50   # Array for load/store tests
.text
.globl main

main:
    # Initialize some registers with values
    la   $s3, array             # Load base address of the array into $s3 
    addi $s0, $0, 10           # $s0 = 10
    addi $s1, $0, 20           # $s1 = 20
    addi $s2, $0, -1           # $s2 = -1 

    # Arithmetic operations
    add $t0, $s0, $s1    # $t0 = $s0 + $s1 = 10 + 20 = 30
    addi $t1, $s0, 5     # $t1 = $s0 + 5 = 10 + 5 = 15
    addiu $t2, $s2, 1    # $t2 = $s2 + 1 = -1 + 1 = 0
    addu $t3, $s0, $s1   # $t3 = $s0 + $s1 = 10 + 20 = 30
    sub $t4, $s1, $s0    # $t4 = $s1 - $s0 = 20 - 10 = 10
    subu $t5, $s1, $s0   # $t5 = $s1 - $s0 = 20 - 10 = 10

    # Logical operations
    and $t0, $s0, $s1    # $t0 = $s0 & $s1 = 0
    andi $t7, $s0, 15    # $t7 = $s0 & 15 = 10
    or $t8, $s0, $s1     # $t8 = $s0 | $s1 = 30
    ori $t9, $s0, 25     # $t9 = $s0 | 25 = 27
    xor $t3, $s0, $s1    # $t8 = $s0 ^ $s1 = 30
    xori $t2, $s0, 15    # $t1 = $s0 ^ 15 = 5
    nor $t1, $s0, $s1    # $t2 = ~($s0 | $s1) = FFFFFFE1 = -31

    # Shift operations
    sll $t3, $s0, 2      # $t3 = $s0 << 2 = 40
    srl $t4, $s1, 2      # $t4 = $s1 >> 2 (logical shift) = 5
    sra $t3, $t1, 1      # $t3 = $t1 >> 2 (arithmetic shift) = FFFFFFF0 = -16

    # Comparison operations
    slt $t6, $s0, $s1    # $t6 = ($s0 < $s1) true
    slti $t7, $s0, 5    # $t7 = ($s0 < 5) false


    # Branch and Jump instructions
    bne $s0, $s1, label1 # If $s0 != $s1, jump to label1 true
Loops:
    addi $s0, $s0, 10           # $s0 = 20 
    beq $s0, $s1, label2 # If $s0 == $s1, jump to label2 true
    j end

label1:
    lui $t8, 0x1000      # $t8 = 0x10000000 (upper immediate)
    lw $t9, 0($s3)       # Load word from array (10)
    sw $t4, 4($s3)       # Store 5 in memory at $t3 + 4
    j Loops

label2:
    addi $t1, $t1, 1     # Increment $t1 if branch taken
    j Loops

end:
    jal JumpAndLink
    halt

JumpAndLink:
    addi $t1, $t1, 3     # Increment $t1 by 3 if jal taken
    jr $ra
    
