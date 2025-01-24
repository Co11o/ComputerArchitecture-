.data
    array:  .word 8, 4, -6, -9, 3    # Array to be sorted
    size:   .word 5                           # Size of the array
.text
    .globl main

main:
    # Load the size of the array into $s0
    la   $s1, array             # Load base address of the array into $s1
    lw   $s0, size              # Load the size of the array into $s0
    add  $s2, $s0, $zero        # Copy size into $s2 for outer loop (outer loop counter)
    lw   $t0, 0($s1)
    lw   $t1, 4($s1)
    lw   $t2, 8($s1)
    lw   $t3, 12($s1)
    lw   $t4, 16($s1)

outer_loop:
    addi $s2, $s2, -1           # Decrement outer loop counter
    beq  $s2, $0, sorted     # If $s2 == 0, array is sorted

    # Inner loop to go through the array
    li   $s3, 0                 # $s3 = inner loop counter
    add  $s4, $s0, $0           # Load size into $s4 for inner loop bounds
    addi $s4, $s4, -1           # Subtract 1 from size for inner loop

inner_loop:
    beq  $s3, $s4, outer_loop   # If inner loop counter equals size-1, go to outer loop

    # Load array elements for comparison
    sll  $t0, $s3, 2            # $t0 = $s3 * 4 (calculate offset)
    add  $t1, $s1, $t0          # $t1 = base address + offset
    lw   $t2, 0($t1)            # Load array[$t1] into $t2

    addi $t3, $t0, 4            # Offset to the next element (array[$t1+1])
    add  $t4, $s1, $t3          # $t4 = base address + offset
    lw   $t5, 0($t4)            # Load array[$t4] into $t5

    # Compare array[$t1] and array[$t1+1]
    bne  $t2, $t5, check_swap   # If array[$t1] != array[$t1+1], check if swap needed

check_swap:
    slt  $t7, $t2, $t5      # $t7 = array[$t1] < array[$t1+1], check if swap needed
    bne  $t7, $0, no_swap       # If $t7 != 0 (array[$t1] < array[$t1+1] is true), no swap
    add  $t6, $t2, $zero        # Temporarily store array[$t1] in $t6
    sw   $t5, 0($t1)            # Move array[$t1+1] to array[$t1]
    sw   $t6, 0($t4)            # Move array[$t1] to array[$t1+1]

no_swap:
    addi $s3, $s3, 1            # Increment inner loop counter
    j    inner_loop             # Jump back to the start of the inner loop

sorted:
    # Print sorted array
    li   $s3, 0                 # Reset counter to 0 for printing 
    lw   $t0, 0($s1)
    lw   $t1, 4($s1)
    lw   $t2, 8($s1)
    lw   $t3, 12($s1)
    lw   $t4, 16($s1)
    halt
