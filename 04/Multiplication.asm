// Program: multiplication
// Description: Multiplies two numbers in R0 and R1, result is stored in R2
// R2 = R1 * R0

//for (i = 0; i < R0; i++)
//{
//	R2 = R2 + R1;
//}

// Set up initial values

@R2
M=0

@i
M=0 // i = 0


// Main Loop

(LOOP)
@i
D=M
@R0
D=M-D

@STOP
D; JLE // D <= 0, R0 - i <= 0

@R1
D=M

@R2
M=M+D // R2 = R2 + R1

@i
M=M+1 // i++

@LOOP
0; JMP

(STOP)

(EL)
@EL
0; JMP



