//////////////////////////
//			//
// Project Submission	//
//			//
//////////////////////////

// Partner 1: Aleksandar Jeremic
// Partner 2: Praveen Swaminathan

//////////////////////////
//			//
//	main		//
//                    	//
//////////////////////////

main:	lda x4, symbol
	ldur x0, [x4, #0]
	bl FindTail
	addi x2, x1, #24
	stur x2, [sp, #0]
	bl Partition
	ldur x0, [sp, #0]
	lda x5, encode
	ldur x1, [x5, #0]
CheckSymbol:
	ldur x2, [x1, #0]
	subs xzr, x2, xzr
	b.ge KeepEncode
	stop

KeepEncode:
	stur x1, [sp, #0]
	bl Encode
	ldur x1, [sp, #0]
	addi x1, x1, #8
	b CheckSymbol
	
////////////////////////
//                    //
//   FindTail         //
//                    //
////////////////////////
FindTail:
	// input:
	// x0: address of (pointer to) the first symbol of symbol array
	// output:
	// x1: address of (pointer to) the first symbol of symbol array
	// local variable:
	// x9: value of -1
	// x10: values stored in array
	//Make stack
	SUBI SP,SP, #32
	STUR FP, [SP, #0]
	STUR LR, [SP, #8]
	STUR x0, [SP, #16]
	ADDI FP, SP, #24

	ADD x1, x0, xzr //assign address of last symbol to x1 for return
	LDUR x10, [x0, #16] //load *(pt+2) into register x10
	SUBI x9, XZR, #1 //initialize value of -1 in reg X9
	CMP x10, x9 //compare if -1 is equal to *(pt+2)
	B.EQ FTdone //if it's equal branch to done
	ADDI x0, x0, #16 //if not equal, then move the pointer two elements up
	BL FindTail //and branch back to the beginning of the function

FTdone:
	//deallocate all memory
	LDUR FP, [SP, #0]
	LDUR LR, [SP, #8]
	LDUR x0, [SP, #16]
	ADDI SP, SP, #32
	br lr //branch back to main

FindMidpoint:
    //Prologue
    SUBI SP, SP, #16        // Allocate space on stack
    STUR FP, [SP, #0]       // Save frame pointer
    STUR LR, [SP, #8]       // Save link register
    ADDI FP, SP, #8         // Update frame pointer

    // Check if head + 2 == tail
    ADDI X10, X0, #16       // X10 = head + 16 (8 bytes per long * 2 positions)
    SUBS X26, X10, X1        // Compare head + 2 with tail
    CBZ X26,retend         // If head + 2 == tail, return tail

    // Check if left_sum <= right_sum
    SUBS XZR, X2, X3
    B.LE LEQ                // If left_sum <= right_sum, go to LEQ

update_tail:
    // tail -= 2
    // right_sum += *(tail + 1)
    SUBI X1, X1, #16        // tail -= 2 positions (8 bytes per long * 2 positions)
    LDUR X12, [X1, #8]      // Load *(tail + 1) into X12
    ADD X3, X3, X12         // right_sum += *(tail + 1)
    B recurse               // Go to recursive call

LEQ:
    // head += 2
    // left_sum += *(head + 1)
    ADDI X0, X0, #16        // head += 2 positions (8 bytes per long * 2 positions)
    LDUR X13, [X0, #8]      // Load *(head + 1) into X13
    ADD X2, X2, X13         // left_sum += *(head + 1)

recurse:
    // Recursive call
    BL FindMidpoint

retend:
    // Return tail
	ADD X4, X1, XZR

endall:
    // Epilogue
    LDUR LR, [SP, #8]       // Restore link register
    LDUR FP, [SP, #0]       // Restore frame pointer
    ADDI SP, SP, #16        // Deallocate stack space
    BR LR                   // Return from function



////////////////////////
//                    //
//   Partition        //
//                    //
////////////////////////
Partition:
	// input:
	// x0: address of (pointer to) the first symbol of the symbol array 'start'
	// x1: address of (pointer to) the last symbol of the symbol array 'end'
	// x2: address of the first attribute of the current binary tree node 'node'
	
	// first add to the Stack pointer and save stuff
	// store for all the values we end up switching to recall partition

	SUBI SP,SP, #96
	STUR FP,[SP,#0]
	STUR LR, [SP,#8]
	STUR X0, [SP,#16]
	STUR X1, [SP,#24]
	STUR X2, [SP,#32]
	STUR X9, [SP,#40]
	STUR X12, [SP,#48]
	STUR X13, [SP,#56]
	STUR X26, [SP,#64]
	STUR X4, [SP,#72]


	ADDI FP, SP, #88


	// X9 will be the value that 'node' points to it will originally store the 
	//start value

	//then we store this value into the address in x2 which is like putting start into the
	// address that node points to

	LDUR X9, [X0, #0]
	STUR X0, [X2, #0]

	//we load the value from x1 which is end into register x10 this is loading 'end' into X10

	//we then add one long as the increment *(node +1) and then store 'end' into the 
	// register which holds *(node+1)

	STUR X1, [X2,#8]
	

	//checking if start == end

	SUB X25, X0,X1
	CBZ X25, equal

else:
	// lets assume 'leftsum' is held in X12
	// lets assume 'rightsum' is held in X13
	// lets assume 'midpoint' is returned in X14
	// lets assume 'offset' is held in X19
	// lets assume 'leftnode' is held in X20
	// lets assume 'rightnode' is held in X21
	// lets assume most of the values we load are held in X22

	//loading *(start+1) so we can load it into leftsum 'X12'
	LDUR X12, [X0, #8]


	// loading *(end+1) so we can load it into the rightsum 'X13'

	LDUR X13, [X1, #8]


	// find the midpoint


	ADD X2, X12,XZR
	ADD X3, X13,XZR

	//FindMidpoint(start, end, left sum, right sum)

	BL FindMidpoint

	//STUR X4, [SP,#72]
	LDUR LR, [SP,#8]
	LDUR X0, [SP,#16]
	LDUR X1, [SP,#24]
	LDUR X2, [SP,#32]
	LDUR X12, [SP,#48]
	LDUR X13, [SP,#56]
	LDUR X26, [SP,#64]

	// offset = midpoint - start - 1

	SUB X19, X4, X0
	SUBI X19, X19, #8    //should this be a one? or an 8?

	// leftnode 'X20' = node 'X2' + 4
	// rightnode 'X21' = node 'X2' + 4 + offset 'X19'*4

	ADDI X20, X2, #32

	ADDI X21, X2, #32
	LSL X19,X19 #2
	ADD X21, X21, X19
	LSR X19,X19 #2
	ADD X7, X21,XZR //checking how offset works and what its values are this is currently right node

	ADD X8, X19,XZR // this is offsets value not times 4

	//store left node 'X20' into node+2
	//store right node 'X21' into node+3

	STUR X20, [X2, #16]
	STUR X21, [X2, #24]
	///new
	STUR X1, [SP,#24]
	STUR X4, [SP,#72]
	STUR X21, [SP,#80]
	//partition(start, midpoint-2,leftnode)

	SUBI X1, X4, #16
	ADD X2,XZR,X20

	BL Partition

	LDUR X4, [SP,#72]
	LDUR X21, [SP,#80]

	//ADD X7, X1,XZR

	//LDUR X4, [SP,#72]
	LDUR LR, [SP,#8]
	LDUR X0, [SP,#16]
	LDUR X1, [SP,#24]
	LDUR X2, [SP,#32]


	//partition(midpoint,end,right_node)
	ADD X0, X4, XZR
	//ADD X1,
	ADD X2,X21,XZR


	BL Partition
	//LDUR LR, [SP,#8]
	//LDUR X0, [SP,#16]
	//LDUR X1, [SP,#24]
	//LDUR X2, [SP,#32]
	//LDUR X4, [SP,#72]

	B end


equal:
	SUBI X10,XZR,#1
	STUR X10, [X2, #16]
	STUR X10, [X2, #24]


end:

	
	LDUR FP,[SP,#0]
	LDUR LR, [SP,#8]
	LDUR X0, [SP,#16]
	LDUR X1, [SP,#24]
	LDUR X2, [SP,#32]
	LDUR X9, [SP,#40]
	LDUR X12, [SP,#48]
	LDUR X13, [SP,#56]
	LDUR X26, [SP,#64]
	LDUR X4, [SP,#72]
	SUBI FP, SP, #80
	ADDI SP,SP, #96


	br lr

	
////////////////////////
//                    //
//   IsContain        //
//                    //
////////////////////////
IsContain:
	// input:
	// x0: address of (pointer to) the first symbol of the sub-array
	// x1: address of (pointer to) the last symbol of the sub-array
	// x2: symbol to look for

	// output:
	// x3: 1 if symbol is found, 0 otherwise

	//local variables:
	// x9: the value stored at the address of the moving start pointer
	// x10: to hold moving start pointer value

	ADD x10, xzr, x0 // set x10 to initial address of x0
loop: 
	CMP x10, x1 //compare the address of the start and end pointers
	B.GT notFound //if the while condition is not satisfied, branch to return 0
	LDUR x9, [x10, #0] //load value at address of start pointer
	CMP x9, x2 //compare that value with the symbol value
	B.EQ found //if the values are equal, then the value is found in the sub-tree, and will branch to return 1
	ADDI x10, x10, #16 //after the if statement, move the start pointer to the next symbol
	B loop //loop again (while loop)

found: //return 1, function end
	ADDI x3, xzr, #1
	br lr

notFound: //return 0, function end
	ADDI x3, xzr, #0
	br lr



////////////////////////
//                    //
//   Encode           //
//                    //
////////////////////////

Encode:	
	// input:
	// x0: the address of (pointer to) the binary tree node 
	// x2: symbols to encode

	//local variables:
	// x9: left_node address 
	// x10: right_node address
	// x11: value of 1 (stagnant)

	//Stack made for encode function
	SUBI SP, SP, #48
	STUR FP, [SP, #0]
	STUR LR, [SP, #8]
	ADDI FP, SP, #40
	ADDI x11, xzr, #1

	LDUR x9, [x0, #16] //node+2 (in the tree array this represent the left address) **PROBLEM HERE, mem alignment issue
	LDUR x10, [x0, #24]//node +3 (in the tree array this represent the right address)

	STUR x9, [SP, #24] //x9 and x10 (left node and right node addresses, are stored after each iteration)
	STUR x10, [SP, #32]

	CMP x9, x10 //compare if equal. if equal then branch to endEncode, if not continue
	B.EQ endEncode

	//start is x0, end is x1, x2 is symbol (x2 does not change) for isContain
	//start of left node is *left_node *(x9), end of left of node is *(x9+8)
	STUR x0, [SP, #16]
	//loading start and end pointers from the left node x9's address (start is +0, end is +8)
	LDUR x0, [x9, #0]
	LDUR x1, [x9, #8]

	//after storing x0, and changing it to the necessary values for isContain, can now branch (x1 does not need to be stored as it changes everytime)
	bl IsContain
	//restoring x0 (node address of encode)
	LDUR x0, [SP, #16]
	//restoring LR (changed because of bl isContain)
	LDUR LR, [SP, #8]
	//RESTORE X9 and X10 (left/right node addresses) to og values (changed in isContain)
	LDUR x9, [SP, #24]
	LDUR x10, [SP, #32]

	//comparing x3 to 1, if not equal to one, print1 and branch
	CMPI x3, #1
	B.NE print1

print0:	
	//print 0 to console
	putint xzr 
	//prepare for encode recursion
	STUR x0, [SP, #16] //storing x0 (x9 and x10 were already stored above, x0 was not stored after loading again after isContain)
	ADD x0, x9, xzr
	//x0 is set to the address of the left node, x2 does not change 
	BL Encode 
	B endEncode

print1: 
	//print 1 to console
	putint x11
	//prepare for encode recursion
	STUR x0, [SP, #16] //storing x0 (x9 and x10 were already stored above)
	ADD x0, x10, xzr
	//x0 is set to the address of the right node, x2 does not change 
	BL Encode
	B endEncode
	
endEncode:
	//deallocate memory
	LDUR FP, [SP, #0]
	LDUR LR, [SP, #8]
	LDUR x0, [SP, #16] 
	LDUR x9, [SP, #24]
	LDUR x10, [SP, #32]
	ADDI SP, SP, #48
	br lr //branch back to call


	
	

