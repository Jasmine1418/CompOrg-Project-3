.data
	data: .space 1001
	output: .asciiz "\n"
	notvalid: .asciiz "NaN"
	comma: .asciiz ","
  
.text

Main :
	li $v0,8	
	la $a0,data	#reads user input 
	li $a1, 1001	
	syscall
	
	jal Subprogram1 #jumps to label 
  
continue1:
	j print #jumps to print function

#creates spaces and other such things to make the stack work
Subprogram1:
	sub $sp, $sp,4 
	sw $a0, 0($sp) 
	lw $t0, 0($sp) 
	addi $sp,$sp,4 # moves the stack pointer up
	move $t6, $t0 # stores the begining of the input into $t6

#checks if the bit is an invalid character or not
start:
	li $t2,0 
	li $t7, -1 
	lb $s0, ($t0) # loads the bit that $t0 is pointing to
	beq $s0, 0, insubstring
	beq $s0, 10, insubstring 
	beq $s0, 44, invalidloop 

	beq $s0, 9, skip 
	beq $s0, 32, skip 
	move $t6, $t0 #store the first non-space/tab character
	j loop # jumps to the beginning of the loop function

#move the $t0 to the next element of the array
skip:
	addi $t0,$t0,1 
	j start 
  
loop:
	lb $s0, ($t0) # loads the bit that $t0 is pointing to
	beq $s0, 0,next
	beq $s0, 10, next  	
	addi $t0,$t0,1 #move the $t0 to the next element of the array	
	beq $s0, 44, substring 

#checks to see if the bit meets all the conditions required for my specific ID
check:
	bgt $t2,0,invalidloop #checks to see if there were any spaces or tabs in between valid characters
	beq $s0, 9,  gap 
	beq $s0, 32, gap 
	ble $s0, 47, invalidloop 
	ble $s0, 57, vaild 
	ble $s0, 64, invalidloop 
	ble $s0, 80, vaild	
	ble $s0, 96, invalidloop
	ble $s0, 112, vaild 	
	bge $s0, 113, invalidloop 
  
gap:
	addi $t2,$t2,-1 #keeps track of spaces/tabs
	j loop

#keeps track of how many valid characters are in the substring
vaild:
	addi $t3, $t3,1 
	mul $t2,$t2,$t7 #if there was a space before a this valid character it will change $t2 to a positive number
	j loop #jumps to the beginning of loop	

invalidloop:
	lb $s0, ($t0) # loads the bit that $t0 is pointing to
	beq $s0, 0, insubstring# check if the bit is null
	beq $s0, 10, insubstring #checks if the bit is a new line 	
	addi $t0,$t0,1 #move the $t0 to the next element of the array	
	beq $s0, 44, insubstring #check if bit is a comma
	
	
	j invalidloop #jumps to the beginning of loop

insubstring:
	
  addi $t1,$t1,1 #keeps track of the amount substring 	
	sub $sp, $sp,4# creates space in the stack
	#stores what was in $t6 into the stack
	
	move $t6,$t0  # store the pointer to the bit after the comma
	lb $s0, ($t0) # loads the bit that $t0 is pointing to
	beq $s0, 0, continue1
	beq $s0, 10, continue1 
	beq $s0,44, invalidloop 
	li $t3,0 
	li $t2,0 
	j start

#if there was a space before a this valid character it will change $t2 to a positive number
substring:
	mul $t2,$t2,$t7 
  
next:
	bgt $t2,0,insubstring #checks to see if there were any spaces or tabs in between valid characters
	bge $t3,5,insubstring #checks to see if there are more than 4 for characters
	addi $t1,$t1,1  	
	sub $sp, $sp,4 # creates space in the stack
	sw $t6, 0($sp) #stores what was in $t6 into the stack
	move $t6,$t0  # store the pointer to the bit after the comma
	lw $t4,0($sp) 
	li $s1,0 #sets $s1 to 0 
	jal Subprogram2
	lb $s0, ($t0) 
	beq $s0, 0, continue1 # check if the bit is null
	beq $s0, 10, continue1 #checks if the bit is a new line 
	beq $s0,44, invalidloop #checks if the next bit is a comma
	li $t2,0 #resets my space/tabs checker back to zero
	j start

#check how many charcter are left to convert and decreases the amount of characters left to convert
Subprogram2:
	beq $t3,0,finish 
	addi $t3,$t3,-1 
	lb $s0, ($t4)
	
	addi $t4,$t4,1	
	j Subprogram3 
  
continue:
	sw $s1,0($sp)	
	j Subprogram2

Subprogram3:
	move $t8, $t3	#stores the amount of characters left to use as an exponent
	li $t9, 1	# $t9 represents 30 to a certian power and set equal to 1
	ble $s0, 57, num #sorts the bit to the apporiate function
	ble $s0, 80, upper
	ble $s0, 112, lower

#converts interger bits
num:
	sub $s0, $s0, 48	 
	beq $t3, 0, combine	
	li $t9, 30		
	j exp

#converts uppercase bits
upper:
	sub $s0, $s0, 55 
	beq $t3, 0, combine 
	li $t9, 30
	j exp

#converts lowercase bits
lower:
	sub $s0, $s0, 87 
	beq $t3, 0, combine 
	li $t9, 30
	j exp

#raises my base to a certain exponent by muliplying itself repeatly
exp:
	ble $t8, 1, combine	
	mul $t9, $t9, 30 	
	addi $t8, $t8, -1	# decreasing the exponent
	j exp
  
combine:
	mul $s2, $t9, $s0	#multiplied the converted bit and my base raised to a power
	
	add $s1,$s1,$s2		# adding the coverted numbers together 
	j continue


finish : jr $ra	#jumps back to substring

#getting the amount of space needed to move the stack pointer to the beginning of the stack
print:
	mul $t1,$t1,4 
	add $sp, $sp $t1 
		
done:	
	sub $t1, $t1,4	#keeping track of amount of elements left
	sub $sp,$sp,4 

		
	lw $s7, 0($sp)	#storing that element into $s7
	
	beq $s7,-1,invalidprint #checks to see if element is invalid
	
	
	li $v0, 1
	lw $a0, 0($sp) #prints element
	syscall
  
com:
	beq $t1, 0,Exit #if there are now elements left it terminates the program
	li $v0, 4
	la $a0, comma #prints a comma
	syscall
	j done
  
invalidprint:
	
	li $v0, 4
	
	la $a0, notvalid #prints a nonvaild input
	syscall	
	j com #jumps to print a comma
	
	
Exit:
	li $v0, 10
	syscall
