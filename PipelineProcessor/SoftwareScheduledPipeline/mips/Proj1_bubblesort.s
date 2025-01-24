.data
	array:  .word 8, 4, -6, -9, 3    # Array to be sorted
	size:   .word 5                           # Size of the array
.text
	.globl main

main:
	# Load the size of the array into $s0
	lui $1,4097
	nop
	nop
	ori $s1,$1,0
	lw   $s0, size              # Load the size of the array into $s0
	nop
	nop
	add  $s2, $s0, $zero        # Copy size into $s2 for outer loop (outer loop counter)
	lw   $t0, 0($s1)
	lw   $t1, 4($s1)
	lw   $t2, 8($s1)
	lw   $t3, 12($s1)
	lw   $t4, 16($s1)

outer_loop:
	addi $s2, $s2, -1           # Decrement outer loop counter

	# Two no opperations for $t1 to update for beq
	nop
	nop

	beq  $s2, $0, sorted     # If $s2 == 0, array is sorted
	nop
	nop

	# Inner loop to go through the array
	# Moved up add by one
	add  $s4, $s0, $0           # Load size into $s4 for inner loop bounds
	li   $s3, 0                 # $s3 = inner loop counter
	nop
	addi $s4, $s4, -1           # Subtract 1 from size for inner loop

inner_loop:
	beq  $s3, $s4, outer_loop   # If inner loop counter equals size-1, go to outer loop
	nop
	nop
	# Load array elements for comparison
	sll  $t0, $s3, 2            # $t0 = $s3 * 4 (calculate offset)
	
	# Two no opperations for $t0 to update for add instruction can't move sll up before beq and can't move add down because 
	# add $t1 depends on $t0 and $t1 is a dependenant for $t2
	nop
	nop

	addi $t3, $t0, 4            # Offset to the next element (array[$t1+1])
	add  $t1, $s1, $t0          # $t1 = base address + offset
	nop
	add  $t4, $s1, $t3          # $t4 = base address + offset
	nop
	# Moved lw   $t2, 0($t1) down to break up one nop  
	lw   $t2, 0($t1)            # Load array[$t1] into $t2
	lw   $t5, 0($t4)            # Load array[$t4] into $t5

	nop
	nop

	# Compare array[$t1] and array[$t1+1]
	bne  $t2, $t5, check_swap   # If array[$t1] != array[$t1+1], check if swap needed
	nop
	nop

check_swap:
	slt  $t7, $t2, $t5      # $t7 = array[$t1] < array[$t1+1], check if swap needed
	
	nop
	nop

	bne  $t7, $0, no_swap       # If $t7 != 0 (array[$t1] < array[$t1+1] is true), no swap
	nop
	nop
	add  $t6, $t2, $zero        # Temporarily store array[$t1] in $t6
	sw   $t5, 0($t1)            # Move array[$t1+1] to array[$t1]
	nop
	sw   $t6, 0($t4)            # Move array[$t1] to array[$t1+1]

no_swap:
	addi $s3, $s3, 1            # Increment inner loop counter
	j    inner_loop             # Jump back to the start of the inner loop
	#Time for jump to evaluate 
	nop
	nop

sorted:
	# Print sorted array
	li   $s3, 0                 # Reset counter to 0 for printing 
	lw   $t0, 0($s1)
	lw   $t1, 4($s1)
	lw   $t2, 8($s1)
	lw   $t3, 12($s1)
	lw   $t4, 16($s1)
	halt
