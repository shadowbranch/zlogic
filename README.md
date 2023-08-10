# zlogic
Perl program that allows you to simulate a CPU

Zlogic 1.0   User's Guide for CS201

1. Introduction.

	Zlogic will allow you to simulate logic circuits.  You design binary functions, not by drawing them, but by typing in the equations that govern the behavior of the system.  For example, a SR latch has the state equation Q(t+1) = S+R'Q(t).  We can easily simulate this, as we shall see a little later.

2. Getting Started.

	After logging in to your account, change directories to the zlogic directory with 

cd zlogic

and launch the program with the command

./zlogic

You should see a message and smiley face prompt :) appear.  You are ready to begin entering equations.

3. Entering Variables

	Let's create a memory element from an SR latch called A.  Enter its equation by typing

A = S+R'*A

Notice that we had to put * between S' and A to show multiplication.  This is required because we may have longer variable names.  In other words, if we type

W = ABC

this tells zlogic to create a variable W that is equal to variable ABC, not A*B*C.  You may use numbers, letters, or the underscore character (_) to name variables.  Do not use the underscore to begin or end a variable name, however.  These names are reserved for system use.  You may use prime (') for complements, and parentheses to change ordering in the usual way.  If a variable is constant, you may enter

x = 0

for example.  The only limit to the number of variable you can have is the size of the memory available.  
	Eventually we will want to run our virtual machine, so it is important that every variable that occurs on the right side of an equation be defined somewhere.  In our latch example, we still need to define R and S, so type in

R = 0
S = 0

4. Peeking at Variables

	To see what you've entered so far, type

peek

This requests the details on all the variables you've entered.  Since there may be quite a few, you can be more specific.  Try the following requests.

peek R
peek R S
peek A

The number in parentheses beside the variable name is the current value of the variable.  They begin initialized to 0.

5. Clocked Variables
	
	You may have noticed something about A.  It has a colon beside the equal sign when you peek at it.  This is because the program noticed that the same variable (A) appears both on the left and right sides of the equals sign.  These kinds of variables must be clocked, and are designated with := for your convenience.  You can clock other variables if you like, by typing

x := y+ z

instead of 

x = y + z

Be warned, however, that clocking a variable prevents it from changing except at clock ticks.  In general, you shouldn't clock a variable without a good reason. 

6. Stepping the Program

	We are ready to try to run our small SR latch to see if it works.  You can step the program once simply by hitting the enter key at a prompt.  You can then peek at variables to see if they've changed.  In our case, since everything is zero, nothing should change when we step.  Try it.
	To make it more interesting, let's turn on the Set input to the latch.  Type

S = 1

and step the program.  If you peek at A now, you should see that it has become one (set).  Turn S off with 

S = 0

and step again.  Peeking reveals that although S is off now, A still remembers that it is a 1. This is what a latch is supposed to do!  You can reset A to zero with 

R = 1

stepping, and then 

R = 0

The latch should now remember that it's zero, no matter how many times you step.
	To make it more interesting, let's add another latch, and have the two pass values back and forth.  Type in

B = A' + A*B

Notice that B's equation is also of the form Q = R+S'Q, where A' is Set and A is reset.  Can you guess what will happen when you step the program?

7. Watching Variables

	Because you often want to check on variables after stepping, there is another command to help us out.  Type

watch A B

and hit the enter key a few times.  Notice that the values of those two variables is printed out each time.  Now try

watch

and do the same thing.  See how it works?  Most of Zlogic's commands work this way.
	
8. Mistakes  and Modifications

	Sometimes you type something in wrong, or just want to change it.  This is no problem.  If you want to kill it altogether, type 

kill S

for example.  If you type

kill

you'll get rid of everything, so be careful.
	Let's try hooking the two latches together.  First we'll zero them out with

clear A B

which clears them back to zero.  Now type 

S = B'
R = B

Can you guess what this will do?  Try a few steps, watching A and B.  Not very interesting?  Try setting A to one with 

set A

Now try a few steps.  Can you explain what's going on?  Draw a circuit diagram to help.

9. The Display

	Remember the LCD display we designed in class?  Now you get to use it.  As a primitive first demonstration, let's hook up the display to the A and B latches with 

_DA0 = A
_DA1 = B

The two variables are built in to the program (which is why they have leading underscores--to keep them separate from your variables).  They turn on the pieces of the figure 8 display.  They are numbered from top to bottom, left to right, and there are actually two of them A and B.  The B display variables are named _DB0, _DB1, ..., _DB6.  
	Before we can see the display, we have to turn it on with 

display on

Now try stepping a few times.  If you can't figure out what's going on, try setting

_DA2 = A
_DA3 = B
_DA4 = 1
_DA5 = 1
_DA6 = 1

or some other combination.
	If you want to see the values of all the display variables at once, zlogic has a handy shortcut to typing

watch _DA0 _DA1 _DA2 _DA3 _DA4 _DA5 _DA6

The shortcut consists of substituting the final number with an underscore

watch _DA_

Zlogic will list the values of all such variables in a compact form with the zero element at the left.  It will be a good idea, when you have variables treated in parallel, to name them A0, A1, etc so that you can take advantage of this feature.

10. Quitting

	In the unlikely event that you want to go back to your normal life, type 

quit

and you will be back at the Unix shell prompt.

Appendix I  Command Catalog

clear <list>
Clears the specified variables to zero.  If no argument is specified, it clears all of them.

display <on|off>
Turns the figure-8 displays on and off.

<enter>
Typing the enter key at the prompt steps once and prints all watch variables, as well as the display if it is turned on.

key <digit><digit>
Simulates the function of two keypads.  The command key 01 sets the A keypad to 0 and the B keypad to 1.  The values are kept in the _KA_ and _KB_ variables.

kill
Deletes the specified variable so.  If no argument is specified, it deletes all of them.

load <file>
Loads information from the file you specify.  This may be a previously saved file, or one you've edited.  When creating such files, be sure to save in text format.  Lines beginning with # are treated as comments.

macro <name>
Shows the definition of the macro named. 

nest <number>
Sets the maximum nesting level to a number between 5 and 50.  This is used to stop infinite loops.  The tron command shows nesting levels during computation.

peek
Peeks at the definition and value of the specified variables.  If no list is specified, it peeks at all variables.

run <name> <number>
Steps until the specified variable becomes zero or until the number of steps specified have elapsed.

save <file>
saves all current information to the file you specify

set <list>
Sets the specified variables to zero.  If no argument is specified, it set all of them.

step <number>
Executes the specified number of steps, or one if none is specified.

troff
Turns debugging mode off.

tron
Turns debugging mode on.  This will show in gruesome detail the computation of each variable.  Can be turned off at any time with the troff command

truth <name>
Creates a truth table for the specified variable, based on its definition.  Warning: this function works by changing the values of the variables.  Don't count on them being the same afterwards.

quit	
exits the program

watch <list>
Sets the list of variables to be watched after an <enter> induced step.  If no list is specified, all variables are watched.

Appendix II   Macros

You can avoid mistakes by encapsulating wisdom into macros.  For example, suppose you need a bunch of 2x4 Decoders.  You can either figure out what all the variable substitutions are yourself, or do it via macro.  It would look like this:

[2x4DEC, a, b| a'*b',a'*b,a*b',a*b]

The whole thing is enclosed in square brackets.  Inside, the name of the macro is first, followed by the input variables.  A vertical line (shift-backslash) separates the inputs from the outputs, which are listed in order and separated by commas.  
	Examples of using macros.

z = [2x4DEC-0, x, y] 
 
Specifies that z is the zero-function output of a 2x4 decoder with inputs x and y.  This will simplify to x'*y' during computation, which you can verify if you tron it.

w = [2x4DEC-3, x'+y, z]

simplifies to 

w = (x'+y)*z'

The advantage of using macros is that you can see what kind of function you are implementing.  The only down side is that it slows zlogic down somewhat.


