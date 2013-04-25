/////////////////////////
// Christopher Brandt
// CSCI 255
// Lab 10
//
/////////////////////////
// Includes

#include <stdio.h>

/////////////////////////

int stack[8];	/*our stack for reversing the characters of the number */
int scnt=0;	/*how many items are currently on the stack */
int hchar=0, oh;

int getnch() 
{
	if (hchar) 
	{
		oh=hchar;
		hchar=0;
		return(oh);
	} 
	else
		return(getchar());
}

ungetit(int c)
{
	hchar=c;
}


// Move all values in stack down 1
// Then save value pushed onto stack 
// to stack[0]
// Increment stack counter if there
// are less than 8 items already on
// the stack
void push(int v)
{	
	int c;

	for (c = 1; c <= 7; c++)
		stack[c] = stack[c - 1];

	stack[0] = v;

	if (scnt < 8)
		scnt++;
}

int pop ()
{
	int i;
	int rv = stack[0];

	if (scnt==0) return(-1);
	scnt--;
	for (i=0; i<7; i++)
		stack[i] = stack[i+1];
	return(rv);
}

// Returns 1 multiplied
// by 10 v times
int power10(int v)
{		
	int c, iPower = 1;

	for (c = 0; c < v; c++)
		iPower *= 10; 

	return iPower;
}


// Returns the value of 
// a number scnt digits long
// as entered as ASCII
// digits 0-9 on
// the command prompt
int eatOperand()
{
	int c, iRead, iStackSize;
	int iTotal = 0;

	for (iRead = getnch(); (iRead >= '0') && (iRead <= '9'); iRead = getnch())
		push(iRead);

	// Put operator back on read buffer
	ungetit(iRead);

	iStackSize = scnt;

	for (c = 0; c < iStackSize; c++)
		iTotal += (pop() - '0') * power10(c);	

	return iTotal;
}

main ()
{
	int c, answer, operand1, operator, operand2;

	operand1 = eatOperand();
	operator = getnch();
	operand2 = eatOperand();
	c = getnch();
	switch (operator) {
		case '+':	answer = operand1 + operand2; break;
		case '-':	answer = operand1 - operand2; break;
		case '*':	answer = operand1 * operand2; break;
		case '/':	answer = operand1 / operand2; break;
	}
	printf("the answer is: %d\n", answer);
}
