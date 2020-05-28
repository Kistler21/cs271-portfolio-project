TITLE Designing Low-Level I/O Procedures     (Project06.asm)

; Author: Michael Kistler
; Last Modified: 3/15/20
; OSU email address: kistlerm@oregonstate.edu
; Course number/section: CS 271/400
; Project Number: 06                Due Date: 3/15/20
; Description: The pograms introduces the program and tells the user what it will do. It the prompts the user to enter 10 signed integers.
;	The program validates the user's input and converts the inputted string into the corresponding number. The program then displays what numbers
;	the user entered, the sum of the numbers, and the average of the numbers. The program contains its own low-level I/O procedures for converting
;	from strings to numbers and from numbers to strings.

INCLUDE Irvine32.inc

ARRAYSIZE = 10			; Number of integers to be entered by user
PLUSASCII = 43			; ASCII code of the + symbol
MINUSASCII = 45			; ASCII code of the - symbol
ZEROASCII =	48			; ASCII code of 0
NINEASCII = 57			; ASCII code of 9
POSMAX = 2147483647		; Max value for positive signed 32 bit integer
NEGMAX = 2147483648		; Max value for negative signed 32 bit integer

; This macro displays a prompt and then gets the user’s keyboard input into a memory location
getString	MACRO	promptAddress, stringAddress, stringLength
	; Save registers
	push	edx
	push	ecx
	; Display the prompt
	mov		edx, promptAddress
	call	WriteString
	; Get the user's input
	mov		edx, stringAddress
	mov		ecx, stringLength
	call	ReadString
	; Restore registers
	pop		ecx
	pop		edx
ENDM

; This macro prints the string which is stored in a specified memory location.
displayString	MACRO	stringAddress
	; Save registers
	push	edx
	; Display the string
	mov		edx, stringAddress
	call	WriteString
	; Restore registers
	pop		edx
ENDM

; This macro will zero fill a string
zeroFill	MACRO	stringAddress, stringLength
	LOCAL	stringLoop
	; Save registers
	push	eax
	push	ecx
	push	edi
	; Set registers for loop
	mov		edi, stringAddress
	mov		ecx, stringLength
	mov		al, 0
	cld
stringLoop:
	stosb
	loop	stringLoop
	; Restore registers
	pop		edi
	pop		ecx
	pop		eax
ENDM

.data
userIntegers	DWORD	ARRAYSIZE DUP(?)		; Array that will store intgers entered by user
sum				DWORD	?						; Sum of the values in the array
intro1			BYTE	"Designing Low-Level I/O Procedures", 0
intro2			BYTE	"Programmed by Michael Kistler", 0
prompt1			BYTE	"Please enter a signed number: ", 0
prompt2			BYTE	"Please try again: ", 0
errorMessage	BYTE	"ERROR:  You did not enter a signed number or your number was too big.", 0
instructions1	BYTE	"Please provide 10 signed decimal integers.", 0
instructions2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0
instructions3	BYTE	"After you have finished inputting the raw numbers I will display a list", 0
instructions4	BYTE	"of the integers, their sum, and their average value.", 0
sumPrompt		BYTE	"The sum of these numbers is: ", 0
averagePrompt	BYTE	"The rounded average is: ", 0
listPrompt		BYTE	"You entered the following numbers:", 0
seperator		BYTE	", ", 0
outro1			BYTE	"Thanks for playing!", 0

.code
main PROC

	push	OFFSET intro1			; Pass intro strings, instructions strings by reference
	push	OFFSET intro2
	push	OFFSET instructions1
	push	OFFSET instructions2
	push	OFFSET instructions3
	push	OFFSET instructions4
	call	introduction			; Introducde the program

	push	OFFSET userIntegers		; Pass userIntegers, prompts by referece, array size by value
	push	OFFSET prompt1
	push	OFFSET prompt2
	push	OFFSET errorMessage
	push	ARRAYSIZE
	call	fillArray				; Fill the array with user input

	push	OFFSET userIntegers		; Pass array, prompt, seperator by reference, pass array size by value
	push	ARRAYSIZE
	push	OFFSET listPrompt
	push	OFFSET seperator
	call	displayList				; Display numbers entered by user

	push	OFFSET userIntegers		; Pass array, prompt, sum by reference, pass array size by value
	push	ARRAYSIZE
	push	OFFSET sumPrompt
	call	displaySum				; Display the sum to the user

	push	OFFSET userIntegers		; Pass array, prompt by reference, pass size of array by value
	push	ARRAYSIZE
	push	OFFSET averagePrompt
	call	displayAverage			; Display the average to the user

	push	OFFSET outro1			; Pass outro1 by reference
	call	outro					; Display goodbye message

	exit	; exit to operating system
main ENDP


;Procedure to introduce the program.
;receives: addresses of intro strings, addresses of instructions strings
;returns: none
;preconditions: none
;registers changed: none
introduction	PROC
	push	ebp
	mov		ebp, esp

	; Introduce the pogram and give a description of what the program will do
	displayString	[ebp+28]			; Address of intro1 passes
	call	Crlf
	displayString	[ebp+24]			; Address of intro2 passed
	call	Crlf
	call	Crlf
	displayString	[ebp+20]			; Address of instructions1 passed
	call	Crlf
	displayString	[ebp+16]			; Address of instructions2 passed
	call	Crlf
	displayString	[ebp+12]			; Address of instructions3 passed
	call	Crlf
	displayString	[ebp+8]				; Address of instructions4 passed
	call	Crlf
	call	Crlf

	; Restore registers and return
	pop		ebp
	ret		24
introduction	ENDP


;Procedure to read a string from the user and convert it to a number.
;receives: address where number will be stored, addresses of prompt and error strings
;returns: number entered by user
;preconditions: none
;registers changed: none
ReadVal	PROC
	push	ebp
	mov		ebp, esp

	; Create local variables
	sub		esp, 4						; Will store 1 if the number is negative
	sub		esp, 20						; Local string to store input from user

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	esi

	; Get the string
	lea				edi, [ebp-24]
	zeroFill		edi, 20
	getString		[ebp+16], edi, 20	; Address of prompt1, local string, and length of string passed
	jmp		validate

tryAgain:
	displayString	[ebp+8]				; Address of errorMessage passed
	call	Crlf
	lea		edi, [ebp-24]
	zeroFill		edi, 20
	getString		[ebp+12], edi, 20	; Address of prompt2, local string, and length of string passed
	
validate:
	; Validate the input
	; Set up the registers for loop
	mov		ecx, eax					; Number of characters entered by user in ecx
	lea		esi, [ebp-24]				; Address of local string in esi
	mov		ebx, [ebp+20]				; Addres of place to store number in ebx
	mov		edx, 0
	mov		[ebx], edx					; Set place to store number to 0
	mov		DWORD PTR [ebp-4], edx		; Set local sign check to 0
	mov		edx, 1						; Used for checking first character
	cld
counter:
	lodsb
	cmp		edx, 1
	jne		checkIfNum

	; Check if the first character is + or - symbol
	mov		dl, MINUSASCII
	cmp		al, dl
	jne		notNegative
	mov		DWORD PTR [ebp-4], 1		; Set local sign check to 1
	mov		edx, 0						; Prevents another sign from being valid
	loop	counter
notNegative:
	mov		dl, PLUSASCII
	cmp		al, dl
	jne		checkIfNum
	loop	counter

checkIfNum:
	; Check if the current character is a number
	mov		dl, ZEROASCII
	cmp		al, dl
	jb		invalidInput
	mov		dl, NINEASCII
	cmp		al, dl
	ja		invalidInput

	; Calculate which number the character is and add to number
	push	ecx
	mov		ecx, 0
	mov		cl, al						; Current character in ecx
	mov		eax, [ebx]					; Number in eax
	mov		ebx, 10
	mul		ebx							; Move all numbers one place to left
	mov		ebx, ZEROASCII
	sub		ecx, ebx
	add		eax, ecx					; Add current character
	pop		ecx
	mov		ebx, [ebp+20]				; Address of number in ebx
	mov		[ebx], eax					; Put calculated number in proper place

	; Check if the number is out of bounds
	cmp		DWORD PTR [ebp-4], 1		; Check if local sign check is 1
	je		checkNegative
	mov		edx, POSMAX
	cmp		[ebx], edx
	ja		invalidInput
	jmp		validInput
checkNegative:
	mov		edx, NEGMAX
	cmp		[ebx], edx
	jna		validInput

	; Make the user enter a new number if the input is invalid or go to next character
invalidInput:
	jmp		tryAgain
validInput:
	mov		edx, 0						; Prevents another sign from being valid
	loop	counter

	; Negate the number if it is negative
	cmp		DWORD PTR [ebp-4], 1		; Check if local sign check is 1
	jne		return
	mov		eax, [ebx]					; Number in eax
	neg		eax
	mov		[ebx], eax					; Negated value put back in proper place

return:
	; Restore registers and return
	pop		esi
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	mov		esp, ebp					; Destroy locals
	pop		ebp
	ret		16
ReadVal	ENDP


;Procedure to read a string from the user and convert it to a number.
;receives: Number to convert to string
;returns: none
;preconditions: none
;registers changed: none
WriteVal	PROC
	push	ebp
	mov		ebp, esp

	; Create two local strings and local variable
	sub		esp, 4						; Local variable that will store if the number is negative
	sub		esp, 20						; Local string where number will be converted
	sub		esp, 20						; Local string that will be used to reverse the string above

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	esi

	; Zero fill local strings
	lea		edi, [ebp-24]
	zeroFill		edi, 20
	lea		edi, [ebp-44]
	zeroFill		edi, 20

	; Determine if the number is negative
	mov		eax, [ebp+8]				; Number to convert in eax
	test	eax, -1						; Sign flag will be set if num is negative
	jns		checkZero
	mov		DWORD PTR [ebp-4], 1		; Set local variable to 1
	neg		eax

checkZero:
	; Special case if number is 0
	cmp		eax, 0
	jne		convertToString
	lea		edi, [ebp-44]				; Address of local string in edi
	cld
	mov		al, ZEROASCII
	stosb
	jmp		display

convertToString:
	; Convert the number into it's string representation
	lea		edi, [ebp-24]				; Address of local string in edi
	mov		ecx, 0						; Counter for length of string
	cld
numberLoop:
	cmp		eax, 0
	jna		addSign						; Loop until number is no longer greater than zero
	; Get last number off of number using division
	mov		edx, 0
	mov		ebx, 10
	div		ebx							; Last number in edx, rest of number in eax
	push	eax
	mov		eax, edx					; Last number in al

	; Add ASCII code of zero to al to get correct ASCII code and put in string
	mov		bl, ZEROASCII
	add		al, bl
	stosb
	pop		eax
	add		ecx, 1
	jmp		numberLoop

addSign:
	; Check if the number needs a negative sign
	cmp		DWORD PTR [ebp-4], 1		; Check if number is negative
	jne		reverseString
	mov		al, MINUSASCII
	stosb
	add		ecx, 1

reverseString:
	; Reverse the string
	lea		esi, [ebp-24]				; Address of first local string in esi
	lea		edi, [ebp-44]				; Address of second local string in edi
	add		esi, ecx
	dec		esi							
reverse:
	std									; Get characters from forst string starting from end
	lodsb
	cld									; Place characters in second string in normal order
	stosb
	loop	reverse

display:
	lea		esi, [ebp-44]
	displayString	esi					; Address of string passed

	; Restore registers and return
	pop		esi
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	mov		esp, ebp					; Destroy locals
	pop		ebp
	ret		4
WriteVal	ENDP


;Procedure to fill an array with numbers entered by user.
;receives: address of array, addresses of prompt and error strings, size of array
;returns: filled array
;preconditions: none
;registers changed: none
fillArray	PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ecx
	push	edi

	; Fill array with user inputted integers
	mov		edi, [ebp+24]				; Address of array in edi
	mov		ecx, [ebp+8]				; Size of array in ecx as loop control
fill:									; Loop for filling array
	push	edi							; Pass current spot in array, prompts by reference
	push	[ebp+20]
	push	[ebp+16]
	push	[ebp+12]
	call	ReadVal						; Get input from user
	add		edi, 4						; Move address in esi to next array element
	loop	fill

	call	Crlf

	; Restore registers and return
	pop		edi
	pop		ecx
	pop		eax
	pop		ebp
	ret		20
fillArray	ENDP


;Procedure to display an array.
;receives: address of array to print, size of array, address of string to explain print, address of seperator between printed nums
;returns: none
;preconditions: none
;registers changed: none
displayList	PROC
	push	ebp
	mov		ebp, esp
	push	ecx
	push	esi

	; Print messgae saying which list is printing
	displayString	[ebp+12]			; Pass address of message
	call	Crlf

	; Print array
	mov		esi, [ebp+20]				; Address of list in esi
	mov		ecx, [ebp+16]				; Size of array in ecx for loop control
display:
	push	[esi]						; Pass current value in array
	call	WriteVal
	
	; Check if the seperator is needed
	cmp		ecx, 1
	je		noSeperator
	displayString	[ebp+8]				; Pass address of seperator

noSeperator:
	add		esi, 4						; Next element in array
	loop	display
	call	Crlf

	; Restore registers and return
	pop		esi
	pop		ecx
	pop		ebp
	ret		16
displayList	ENDP


;Procedure to calculate the sum of an array.
;receives: address of array, size of array, address of place to store sum
;returns: sum
;preconditions: array is filled with numbers
;registers changed: none
calculateSum	PROC
	push	ebp
	mov		ebp, esp
	push	eax
	push	ebx
	push	ecx
	push	esi
	push	edi

	; Calculate the sum
	; Set up resisters for loop
	mov		ecx, [ebp+12]				; Size of array in ecx
	mov		esi, [ebp+16]				; Address of array in esi
	mov		eax, 0						; Set sum to 0
summation:
	mov		ebx, [esi]					; Current array element in eax
	add		eax, ebx					; Add current array element to sum
	add		esi, 4
	loop	summation
	
	mov		edi, [ebp+8]				; Address of place to store sum in edi
	mov		[edi], eax					; Move sum to proper location

	; Restore registers and return
	pop		edi
	pop		esi
	pop		ecx
	pop		ebx
	pop		eax
	pop		ebp
	ret		12
calculateSum	ENDP


;Procedure to calculate and display the sum of an array.
;receives: address of array, size of array, address of string to explain print
;returns: sum
;preconditions: array is filled with numbers
;registers changed: none
displaySum	PROC
	push	ebp
	mov		ebp, esp
	sub		esp, 4						; Created local variable for sum
	push	edi

	; Calculate sum
	push	[ebp+16]					; Pass array and local sum by reference, pass array size by value
	push	[ebp+12]
	lea		edi, [ebp-4]				; Local sum in edi
	push	edi
	call	calculateSum

	; Display the sum to the user
	displayString	[ebp+8]				; Pass prompt
	push	DWORD PTR [ebp-4]			; Pass sum
	call	WriteVal		
	call	Crlf

	; Restore registers and return
	pop		edi
	mov		esp, ebp					; Destroy local
	pop		ebp
	ret		12
displaySum	ENDP


;Procedure to calculate and display the average of an array.
;receives: address of array, amount of numbers, address of string to explain print
;returns: none
;preconditions: array is filled with numbers
;registers changed: none
displayAverage	PROC
	push	ebp
	mov		ebp, esp
	sub		esp, 4						; Created local variable for sum
	push	eax
	push	ebx
	push	edx

	; Calculate the sum
	push	[ebp+16]					; Pass array and local sum by reference, pass array size by value
	push	[ebp+12]
	lea		esi, [ebp-4]				; Local sum in edi
	push	esi
	call	calculateSum

	; Calculate average
	mov		eax, DWORD PTR [ebp-4]		; Sum in eax
	cdq									; Sign extend eax into edx
	mov		ebx, [ebp+12]				; Number of elements in ebx
	idiv	ebx							; Quotient in eax

	; Display the average to the user
	displayString	[ebp+8]				; Pass prompt
	push	eax							; Pass average
	call	WriteVal		
	call	Crlf

	; Restore registers and return
	pop		edx
	pop		ebx
	pop		eax
	mov		esp, ebp					; Destroy local
	pop		ebp
	ret		12
displayAverage	ENDP


;Procedure to say goodbye.
;receives: address of outro string
;returns: none
;preconditions: none
;registers changed: none
outro	PROC
	push	ebp
	mov		ebp, esp

	; Say goodbye
	call	Crlf
	displayString	[ebp+8]			; Address of outro1 passed
	call	Crlf

	; Restore registers and return
	pop		ebp
	ret		4
outro	ENDP

END main
