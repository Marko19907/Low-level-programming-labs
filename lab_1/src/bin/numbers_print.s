.global _start
_start:
    mov r0, #0           // Decimal 0 to register r0, used as a counter
    mov r1, #100         // Decimal 100 to register r1, used as a limit
    b loop               // Branch to loop

loop:
    cmp r0, r1           // Compare r0 and r1
    beq _exit            // Branch to _exit if equal

    add r0, r0, #1       // Increment r0 by 1

    cmp r0, #10          // Compare r0 and 10

    blt print_below_10   // Branch to print_below_10 if less than
    bge print_above_10   // Branch to print_above_10 if greater than or equal to

    // b loop               // Branch back to the start of the loop

print_below_10:
    ldr r3, =0xff201000  // Load address of JTAG UART data register into r3
    mov r2, #48          // Decimal 48 to register r2, used for converting to ASCII
    add r2, r2, r0       // Add r2 and r0 and store in r2
    strb r2, [r3]        // Store byte in JTAG UART data register
    bl print_newline     // Branch to print_newline
    b loop               // Branch back to the start of the loop

print_above_10:
    ldr r3, =0xff201000  // Load address of JTAG UART data register into r3
    mov r7, #0           // Decimal 0 to register r7
    mov r8, r0           // Move r0 to register r8
    b print_loop         // Branch to print_loop

print_loop:
    cmp r8, #10          // Compare r8 and 10
    blt end_print_above_10 // Branch to end_print_above_10 if less than
    sub r8, r8, #10      // Subtract 10 from dividend
    add r7, r7, #1       // Increment index
    b print_loop         // Repeat division

end_print_above_10:
    ldr r3, =0xff201000  // Load address of JTAG UART data register into r3
    mov r2, #48          // Decimal 48 to register r2, used for converting to ASCII
    add r2, r2, r7       // Add ASCII value of '0' to quotient
    strb r2, [r3]        // Store byte in JTAG UART data register
    mov r2, #48          // Decimal 48 to register r2, used for converting to ASCII
    add r2, r2, r8       // Add r2 and r8 and store in r2
    strb r2, [r3]        // Store r2 in the JTAG UART data register
    bl print_newline     // Branch to print_newline
    b loop               // Branch back to the start of the loop


print_newline:
    ldr r3, =0xff201000  // Load address of JTAG UART data register into r3
    mov r2, #10          // Decimal 10 to register r2, used for newline character
    strb r2, [r3]        // Store byte in JTAG UART data register
    bx lr                // Return to the calling function

wait_for_space:
    ldr r1, [r4]         // Load value of control register into r1
    ldr r5, =0xffff      // Load 0xffff into r5
    and r1, r1, r5       // Mask out all but the lower 16 bits of r1
    cmp r1, #0           // Compare r1 with 0
    beq wait_for_space   // If no space available, branch back to start of loop

    strb r2, [r3]        // Store byte in JTAG UART data register
    bx lr                // Return to the calling function


_exit:
	// Branch to itself
	// b .               // Branch to the current address
	wfi                  // Wait for interrupt, halting the processor, was not in covered in lectures but using this instead of the above line will save power
                         // This ISA has no halt instruction, so this is the best we can do

.data
.align
	// This section is evaluated before execution to put things into
	// memory that are required for the execution of your application
.end
