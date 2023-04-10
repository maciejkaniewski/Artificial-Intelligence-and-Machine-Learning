/* -*- mode: Prolog; comment-column: 48 -*- */

/****************************************************************************
 *
 * Copyright (c) 2012 Witold Paluszynski
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
  The strategy is to go forward, and turn left if bumped into a wall.
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
	assert(stenchesLocation([])),
	assert(breezeLocation([])),
	assert(temp(0)),
	act(Action, Knowledge).

% standard action generating rules
% this is our agent's algorithm, the rules will be tried in order
act(Action, Knowledge) :- turn_if_wall(Action, Knowledge).
act(Action, Knowledge) :- else_move_on(Action, Knowledge).

turn_if_wall(Action, Knowledge) :-
	
	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	againstWall(X, Y, Orient, Max_X, Max_Y),
	Action = turnLeft,			%always successful
	shiftOrient(Orient, NewOrient),		%always successful
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	Knowledge = [gameStarted,
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(X, Y, NewOrient), 
				 myTrail(New_Trail),
				 stenchesLocation(New_Stenches),
				 breezeLocation(New_Breeze),
				 temp('turn_if_wall')].

else_move_on(Action, Knowledge) :-
	
	Action = moveForward,			%this will fail on a wall
	myWorldSize(Max_X,Max_Y),
	myPosition(X, Y, Orient),
	forwardStep(X, Y, Orient, New_X, New_Y),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	Knowledge = [gameStarted,
				 myWorldSize(Max_X, Max_Y),
				 myPosition(New_X, New_Y, Orient),
				 myTrail(New_Trail),
				 stenchesLocation(New_Stenches),
				 breezeLocation(New_Breeze),
				 temp('else_move_on')].


againstWall(X, Y, Orient, Max_X, Max_Y) :- X = Max_X, Y = 1,     Orient = east.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = Max_X, Y = Max_Y, Orient = north.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = 1,     Y = Max_Y, Orient = west.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = 1,     Y = 1,     Orient = south.

shiftOrient(east, north).
shiftOrient(north, west).
shiftOrient(west, south).
shiftOrient(south, east).

forwardStep(X, Y, east,  New_X, Y) :- New_X is (X+1).
forwardStep(X, Y, south, X, New_Y) :- New_Y is (Y-1).
forwardStep(X, Y, west,  New_X, Y) :- New_X is (X-1).
forwardStep(X, Y, north, X, New_Y) :- New_Y is (Y+1).

addStench(X, Y, Old_Stenches, New_Stenches) :- ((stench, \+ member([X, Y], Old_Stenches))) -> New_Stenches = [[X, Y] | Old_Stenches]; New_Stenches = Old_Stenches.
addBreeze(X, Y, Old_Breeze, New_Breeze) :- ((breeze, \+ member([X, Y], Old_Breeze))) -> New_Breeze = [[X, Y] | Old_Breeze]; New_Breeze = Old_Breeze.