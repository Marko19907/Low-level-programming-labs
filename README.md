# Low-Level Programming labs

This repository contains all the labs for the low-level programming course at NTNU (TDT4258). 

## [Lab 1: Assembly programming](/lab_1)

* [x] Create a palindrome checker in assembly.
* [x] Use the ARMv7 ISA and [CPUlator](https://cpulator.01xz.net/?sys=arm-de1soc) to run the program.
* [x] Must be case insensitive and ignore spaces.
  * [x]  A valid palindrome can only be a single word, sentence (words separated  by spaces), numbers, or alphanumeric.
  Examples of valid palindromes: “level”, “8448”, “step on no pets”, “My gym”, “Was it a car or a cat  I saw”.
  Examples of strings that are not a palindrome: “Palindrome”,  “First level”
* [x] The shortest palindrome is at least 2 characters long.
* [x] The valid characters are as follows: ‘a-z’, ‘A-Z’, ‘0-9’ and ‘ ’ (space).
  Special characters will not be used in test inputs.
* [x] Implement the algorithm in a high-level language (C, Rust, or Python) as you would write assembly code to get the correct control flow.
  * [x] Written in Rust and available [here](/lab_1/src/bin).
* [x] The program will display the output in two different ways:
  * [x] **Light up the red LEDs**: If the output is not a palindrome, light up the five leftmost LEDs. If the output is a palindrome, light up the five rightmost LEDs.
  * [x] **Write to the JTAG UART**: If the output is not a palindrome, write “Not a palindrome” to the JTAG UART. If the output is a palindrome, write “Palindrome detected” to the JTAG UART box.
* [x] This lab includes an optional task: **Write numbers 0 to 100 to the JTAG UART box**. 

## [Lab 2: CPU cache simulator](/lab_2)
* [x] Implement a CPU cache simulator in C with the following requirements:
* [x] The simulator should be able to simulate a direct-mapped cache and a fully associative cache.
* [x] The simulator should support both unified and split caches.
  * [x] Unified caches have a single cache for both instructions and data (Von Neumann architecture) while split caches have separate caches for instructions and data (Harvard architecture).
* [x] Fixed parameters:
  * [x] 32-bit address space
  * [x] 64-byte cache line size
  * [x] FIFO replacement policy for the associative caches
* [x] Variable parameters:
  * [x] Cache size in bytes or kilobytes and only accepting powers of two between 128 bytes and 4096 bytes
  * [x] Cache mapping, direct-mapped or fully associative
  * [x] Cache organization, unified or split
* [x] Expected results:
  * [x] The simulator should output:
    * [x] The number of accesses to the cache
    * [x] The number of cache hits
    * [x] The hit rate
    * [x] Any other information you find relevant
* [x] Trace files:
  * [x] Memory trace `mem_trace.txt` files are provided in the lab repository.
    * These will be used to test the simulator.
    * The trace files contain a sequence of memory accesses, one per line.
    * Each line contains a 32-bit hexadecimal memory address and a single character indicating the type of access, either `I` for instruction or `D` for data.
* [x] Must be able to run on Linux.

## [Lab 3: Tetris on a Raspberry Pi in C](https://github.com/Marko19907/Raspberry-Pi-Tetris)

Extracted to [this repository](https://github.com/Marko19907/Raspberry-Pi-Tetris) since it was a big project.
