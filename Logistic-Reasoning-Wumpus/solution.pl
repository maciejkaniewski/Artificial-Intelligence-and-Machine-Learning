/* -*- mode: Prolog; comment-column: 48 -*- */

/****************************************************************************
 *
 * Copyright (c) 2013 Witold Paluszynski
 *
 * I grant everyone the right to copy this program in whole or part, and
 * to use it for any purpose, provided the source is properly acknowledged.
 *
 * Udzielam kazdemu prawa do kopiowania tego programu w calosci lub czesci,
 * i wykorzystania go w dowolnym celu, pod warunkiem zacytowania zrodla.
 *
 ****************************************************************************/


/*
  This program implements a simple agent strategy for the wumpus world.
  The agent ignores all dangers of the wumpus world.
  The strategy is to go forward along the perimeter,
  turn left when reached the opposing wall,
  but first of all pick up gold if stumbled upon it,
  and exit the game if at home with gold.
  This version registers all steps on a stack, and uses it to reverse
  the actions after having found gold, thus properly returning home.

  Also demonstrates how to keep track of her own position and orientation.
  The agent assumes that the starting point is (1,1) and orientation "east".
*/

% auxiliary initial action generating rule
act(Action, Knowledge) :-

	% To avoid looping on act/2.
	not(gameStarted),
	assert(gameStarted),

	% Creating initial knowledge
	worldSize(X,Y),				%this is given
	assert(myWorldSize(X,Y)),
	assert(myPosition(1, 1, east)),		%this we assume by default
	assert(myTrail([])),
	assert(haveGold(0)),
	act(Action, Knowledge).

% standard action generating rules
% this is our agent's algorithm, the rules will be tried in order
act(Action, Knowledge) :- exit_if_home(Action, Knowledge). %if at home with gold
act(Action, Knowledge) :- go_back_step(Action, Knowledge). %if have gold elsewhere
act(Action, Knowledge) :- pick_up_gold(Action, Knowledge). %if just found gold
act(Action, Knowledge) :- turn_if_wall(Action, Knowledge). %if against the wall
act(Action, Knowledge) :- else_move_on(Action, Knowledge). %otherwise

exit_if_home(Action, Knowledge) :-
	haveGold(NGolds), NGolds > 0,
	myPosition(1, 1, Orient),
	Action = exit,				%done game
	Knowledge = [].				%irrelevant but required

go_back_step(Action, Knowledge) :-
	%%% assuming we have just found gold:
	%%% 1. our last action must have been grab
	%%% 2. our previuos action must have been moveForward
	%%% 3. so we are initiating a turnback and then return:
	%%%    (a) pop grab from the stack
	%%%    (b) replace it by an artificial turnRight we have never
	%%%        executed, but we will be reversing by turning left
	%%%    (c) execute a turnRight now which together will turn us back
	%%% 4. after that we are facing back and can execute actions in reverse
	%%% 5. because of grab we can be sure this rule is executed exactly once
	haveGold(NGolds), NGolds > 0,
	myWorldSize(Max_X, Max_Y),
	myTrail(Trail),
	Trail = [ [grab,X,Y,Orient] | Trail_Tail ],
	New_Trail = [ [turnRight,X,Y,Orient] | Trail_Tail ], %Orient is misleading here
	Action = turnLeft,
	Knowledge = [gameStarted,
	             haveGold(NGolds),
		     myWorldSize(Max_X, Max_Y),
		     myPosition(X, Y, Orient),
		     myTrail(New_Trail)].

go_back_step(Action, Knowledge) :-
	haveGold(NGolds), NGolds > 0,
	myWorldSize(Max_X, Max_Y),
	myTrail([ [Action,X,Y,Orient] | Trail_Tail ]),
	Action = moveForward,
	Knowledge = [gameStarted,
	             haveGold(NGolds),
		     myWorldSize(Max_X, Max_Y),
		     myPosition(X, Y, Orient),
		     myTrail(Trail_Tail)].

%%% backtracking a step can be moving or can be turning
go_back_step(Action, Knowledge) :- go_back_turn(Action, Knowledge).

go_back_turn(Action, Knowledge) :-
	haveGold(NGolds), NGolds > 0,
	myWorldSize(Max_X, Max_Y),
	myTrail([ [OldAct,X,Y,Orient] | Trail_Tail ]),
	%% if our previous action was a turn, we must reverse it now
	((OldAct=turnLeft,Action=turnRight);(OldAct=turnRight,Action=turnLeft)),
	Knowledge = [gameStarted,
	             haveGold(NGolds),
		     myWorldSize(Max_X, Max_Y),
		     myPosition(X, Y, Orient),
		     myTrail(Trail_Tail)].

pick_up_gold(Action, Knowledge) :-
	glitter,
	Action = grab,			    %this is easy, we are sitting on it
	haveGold(NGolds),		    %we must know how many golds we have
	NewNGolds is NGolds + 1,
	myWorldSize(Max_X, Max_Y),
	myPosition(X, Y, Orient),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ], %important to remember grab
	Knowledge = [gameStarted,
	             haveGold(NewNGolds),
		     myWorldSize(Max_X, Max_Y),
		     myPosition(X, Y, Orient),	%the position stays the same
		     myTrail(New_Trail)].

turn_if_wall(Action, Knowledge) :-
	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	againstWall(X, Y, Orient, Max_X, Max_Y),
	Action = turnLeft,			%always successful
	shiftOrient(Orient, NewOrient),		%always successful
	haveGold(NGolds),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted,
		     haveGold(NGolds),
	             myWorldSize(Max_X, Max_Y),
		     myPosition(X, Y, NewOrient),
		     myTrail(New_Trail)].

againstWall(X, Y, Orient, Max_X, Max_Y) :- X = Max_X, Y = 1,     Orient = east.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = Max_X, Y = Max_Y, Orient = north.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = 1,     Y = Max_Y, Orient = west.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = 1,     Y = 1,     Orient = south.

shiftOrient(east, north).
shiftOrient(north, west).
shiftOrient(west, south).
shiftOrient(south, east).

else_move_on(Action, Knowledge) :-
	Action = moveForward,			%this will fail on a wall
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	myPosition(X, Y, Orient),
	forwardStep(X, Y, Orient, New_X, New_Y),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Knowledge = [gameStarted,
		     haveGold(NGolds),
	             myWorldSize(Max_X, Max_Y),
		     myPosition(New_X, New_Y, Orient),
		     myTrail(New_Trail)].

forwardStep(X, Y, east,  New_X, Y) :- New_X is (X+1).
forwardStep(X, Y, south, X, New_Y) :- New_Y is (Y-1).
forwardStep(X, Y, west,  New_X, Y) :- New_X is (X-1).
forwardStep(X, Y, north, X, New_Y) :- New_Y is (Y+1).

