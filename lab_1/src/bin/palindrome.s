.global _start


// Please keep the _start method and the input strings name ("input") as
// specified below
// For the rest, you are free to add and remove functions as you like,
// just make sure your code is clear, concise and well documented.

_start:
	// Here your execution starts
	bl check_input
	b _exit


check_input:
	// You could use this symbol to check for your input length
	// you can assume that your input string is at least 2 characters
	// long and ends with a null byte
	ldr r0, =input                          // load address of input into r0
	ldrb r1, [r0, #1]                       // load character at index 1 into r1
	cmp r1, #0                              // compare input[1] with 0 (null byte)
	beq  is_no_palindrome                   // input is shorter than 2 characters, not a palindrome
	bl check_palindrome                     // input is at least 2 characters, check if it's a palindrome


get_input_length:
    push {lr}                               // save link register on stack
    mov r1, #0                              // initialize counter to 0
    ldr r2, =input                          // load address of input into r2
    bl get_input_length_loop                // call get_input_length_loop
    pop {lr}                                // restore link register from stack
    bx lr                                   // return from function
input_loop_exit:
    mov r0, r1                              // move counter to r0 (return value)
    bx lr                                   // return from function

get_input_length_loop:
    ldrb r3, [r2], #1                       // load current character into r3 and increment r2
    cmp r3, #0                              // compare current character with 0 (null byte)
    beq input_loop_exit                     // if equal, exit loop
    add r1, r1, #1                          // increment counter
    b get_input_length_loop                 // branch to start of loop


check_palindrome:
	// Here you could check whether input is a palindrome or not
	bl get_input_length                     // call get_input_length

	sub r0, r0, #1                          // subtract 1 from input length
    mov r1, r0                              // move adjusted input length to r1, to use as the rightmost index
    mov r0, #0                              // initialize counter to 0, to use as the leftmost index

check_palindrome_loop:
    cmp r0, r1                              // compare leftmost index with rightmost index
    bge is_palindrome                       // if leftmost index is greater than or equal to rightmost index, input is a palindrome

    ldr r5, =input                          // load address of input into r5
    ldrb r2, [r5, r0]                       // load character at leftmost index into r2
    ldrb r3, [r5, r1]                       // load character at rightmost index into r3

    cmp r2, #32                             // compare character at leftmost index with ascii space
    beq increment_left_index                // if equal, increment leftmost index to skip space

    cmp r3, #32                             // compare character at rightmost index with ascii space
    beq decrement_right_index               // if equal, decrement rightmost index to skip space
check_palindrome_loop_lowercase:
    cmp r2, #96                             // compare character at leftmost index with ascii lowercase a
    ble to_ascii_lowercase_left             // if less than, convert to lowercase

    cmp r3, #96                             // compare character at rightmost index with ascii lowercase a
    ble to_ascii_lowercase_right            // if less than, convert to lowercase

    cmp r2, r3                              // compare character at leftmost index with character at rightmost index
    bne is_no_palindrome                    // if not equal, input is not a palindrome

    b increment_indexes                     // increment the leftmost index and decrement the rightmost index


increment_left_index:
    add r0, r0, #1                          // increment leftmost index
    b check_palindrome_loop                 // branch to start of loop

decrement_right_index:
    sub r1, r1, #1                          // decrement rightmost index
    b check_palindrome_loop                 // branch to start of loop

increment_indexes:
    add r0, r0, #1                          // increment leftmost index
    sub r1, r1, #1                          // decrement rightmost index
    b check_palindrome_loop                 // branch to start of loop


to_ascii_lowercase_left:
    add r2, r2, #32                         // convert character at leftmost index to lowercase
    b check_palindrome_loop_lowercase       // branch back to the middle of the loop to avoid overwriting r2

to_ascii_lowercase_right:
    add r3, r3, #32                         // convert character at rightmost index to lowercase
    b check_palindrome_loop_lowercase       // branch back to the middle of the loop to avoid overwriting r3


is_palindrome:
	// Switch on only the 5 rightmost LEDs
	// Write 'Palindrome detected' to UART
	mov r9, #1                              // write 1 to r9 for testing
	bl turn_on_rightmost_leds               // call turn_on_rightmost_leds
	bl print_palindrome                     // call print_palindrome
	b _exit                                 // branch to exit

turn_on_rightmost_leds:
    ldr r0, =0xff200000                     // Load address of the first LED into r0
    mov r1, #037                            // Write 37 to r1
    str r1, [r0]                            // Store r1 at the address in r0
    bx lr                                   // return from function

print_palindrome:
    push {lr}                               // save link register on stack
    ldr r0, =palindrome                     // load address of palindrome into r0
    bl print_string                         // call print_string
    pop {lr}                                // restore link register from stack
    bx lr                                   // return from function


is_no_palindrome:
	// Switch on only the 5 leftmost LEDs
	// Write 'Not a palindrome' to UART
	mov r9, #0                              // write 0 to r9 for testing
	bl turn_on_leftmost_leds                // call turn_on_leftmost_leds
	bl print_not_palindrome                 // call print_not_palindrome
	b _exit                                 // branch to exit

turn_on_leftmost_leds:
    ldr r0, =0xff200000                     // Load address of the first LED into r0
    mov r1, #-32                            // Write 1 to r1
    str r1, [r0]                            // Store r1 at the address in r0
    bx lr                                   // return from function

print_not_palindrome:
    push {lr}                               // save link register on stack
    ldr r0, =not_palindrome                 // load address of not_palindrome into r0
    bl print_string                         // call print_string
    pop {lr}                                // restore link register from stack
    bx lr                                   // return from function


print_string:
    push {lr}                               // save link register on stack
    ldr r2, =0xff201000                     // load address of UART into r2
print_string_loop:
    ldrb r3, [r0], #1                       // load current character into r3 and increment r0
    strb r3, [r2]                           // store current character at address in r2
    cmp r3, #0                              // compare current character with 0 (null byte)
    bne print_string_loop                   // if not equal, branch to start of loop
print_string_exit:
    mov r3, #10                             // move ascii newline to r3
    strb r3, [r2]                           // store newline at address in r2
    pop {lr}                                // restore link register from stack
    bx lr                                   // return from function


_exit:
	// Branch here for exit
	b .

.data
.align
	// This is the input you are supposed to check for a palindrome
	// You can modify the string during development, however you
	// are not allowed to change the name 'input'!

	// Palindromes for testing:
	input: .asciz "Grav ned den varg"
	// input: .asciz "aaA"
	// input: .asciz "Was it a car or a cat I saw"
	// input: .asciz "step on no pets"
	// input: .asciz "A9c9a"

	// Not palindromes for testing:
	// input: .asciz "First level"
	// input: .asciz "cat"
	// input: .asciz "a"

    // Strings to print
	not_palindrome: .asciz "Not a palindrome"
	palindrome: .asciz "Palindrome detected"
.end
