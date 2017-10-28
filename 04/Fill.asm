// Program: "Fill: a program that does some basic I/O effects"


///////////////////////
// Wait Loop
///////////////////////

(LOOP)

// FILL COLOR

@KBD
D=M

@BLACK
D; JNE

// R1 = 0
@R1
M=0
@COLOR_END
0;JMP

(BLACK)
// R1 = -1
@R1
M=-1

(COLOR_END)

// END FILL COLOR

///////////////////////
// Fill BLACK / WHITE
///////////////////////

// (512 * 256) / 16 = 8192

// n = 8192
@8192
D=A
@n
M=D

// i = 0
@0
D=A
@i
M=D

// offset = 0
@offset
M=0

//
// Fill Loop
//

(FILL_LOOP)

// n - i
@n
D=M
@i
D=D-M

// if n - i = 0, jumps to FILL_LOOP
@END 
D; JEQ

// loop body, fills line(register) to black

// addr = SCREEN + offset
@SCREEN
D=A
@offset
D=D+M
@addr
M=D

// D = 255
@R1
D=M

// addr = 255
@addr
A=M
M=D


// i++
@i
M=M+1

// offset = offset + 16
@1
D=A
@offset
M=M+D

@FILL_LOOP
0; JMP

(END)

@LOOP
0; JMP



