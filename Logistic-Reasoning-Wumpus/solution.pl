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

 act(Action, Knowledge) :-

	not(gameStarted),
	assert(gameStarted),

	worldSize(X,Y),
	assert(myWorldSize(X,Y)),
	assert(myPosition(1, 1, east)),
	assert(myTrail([])),
	assert(haveGold(0)),
	assert(visitedLocation([])),
	assert(stenchesLocation([])),
	assert(possibleWumpusLocation([])),
	assert(possiblePitLocation([])),
	assert(breezeLocation([])),
	assert(arrows(1)),
	assert(wumpus(1)),
	assert(deletedPitPredictions([])),
	assert(deletedWumpusPredictions([])),
	assert(loopCounter(0)),
	assert(performedAction(0)),
	act(Action, Knowledge).

act(Action, Knowledge) :- exit_if_home(Action, Knowledge). % If the agent is in the starting position and has gold or no gold after a failed search
act(Action, Knowledge) :- return_to_home_if_gold(Action, Knowledge). % If the agent found gold, he returns to the starting position
act(Action, Knowledge) :- pick_up_gold(Action, Knowledge). % If the agent found the gold (glitter) and picks it up
act(Action, Knowledge) :- wumpus_scream(Action, Knowledge). % If the agent heard Wumpus scream
act(Action, Knowledge) :- shoot_wumpus(Action, Knowledge). % If the agent is sure of the location of the Wumpus, he fires the shot
act(Action, Knowledge) :- set_in_pos_to_shoot(Action, Knowledge). % If the agent is sure of the wumpus, he positions himself
act(Action, Knowledge) :- back_off_from_stench_or_breeze(Action, Knowledge). % If the agent hits a stench or breeze, he retreats
act(Action, Knowledge) :- turn_if_wall(Action, Knowledge). % If the agent hits a wall, he turns around
act(Action, Knowledge) :- else_move_on(Action, Knowledge). % If the previous actions cannot be performed, the agent moves forward

% The agent leaves the cave if he hasn't found gold 
% and there is a stench or breeze in the starting position.
exit_if_home(Action, Knowledge) :-
	
	(stench;breeze),
	haveGold(NGolds), NGolds = 0,
	myPosition(1, 1, Orient),
	Action = exit,
	Knowledge = [].	

% The agent leaves the cave if he has found gold 
% and he is in the starting position.
exit_if_home(Action, Knowledge) :-
	
	haveGold(NGolds), NGolds > 0,
	myPosition(1, 1, Orient),
	Action = exit,
	Knowledge = [].

% The agent exits the cave if he has already been
% in the starting position a set number of times.
exit_if_home(Action, Knowledge) :-
	
	myPosition(1, 1, Orient),
	visitedLocation(Old_Location),
	loopCounter(Old_Counter), Old_Counter >= 8,
	alreadyVisited(1, 1, north, Old_Location),
	alreadyVisited(1, 1, east, Old_Location),
	Action = exit,
	Knowledge = [].

% If the agent found gold, he returns to the starting position.
return_to_home_if_gold(Action, Knowledge) :-

	haveGold(NGolds), NGolds > 0,
	myWorldSize(Max_X, Max_Y),
	myTrail(Trail),
	Trail = [ [grab,X,Y,Orient] | Trail_Tail ],
	New_Trail = [ [turnRight,X,Y,Orient] | Trail_Tail ], 
	Action = turnLeft,
	
	Knowledge = [gameStarted,
	             haveGold(NGolds),
		         myWorldSize(Max_X, Max_Y),
		         myPosition(X, Y, Orient),
		         myTrail(New_Trail)].

return_to_home_if_gold(Action, Knowledge) :-
	
	haveGold(NGolds), NGolds > 0,
	myWorldSize(Max_X, Max_Y),
	myTrail([ [Action,X,Y,Orient] | Trail_Tail ]),
	Action = moveForward,
	
	Knowledge = [gameStarted,
	             haveGold(NGolds),
		         myWorldSize(Max_X, Max_Y),
		         myPosition(X, Y, Orient),
		         myTrail(Trail_Tail)].

return_to_home_if_gold(Action, Knowledge) :- 
	
	haveGold(NGolds), NGolds > 0,
	myWorldSize(Max_X, Max_Y),
	myTrail([ [OldAct,X,Y,Orient] | Trail_Tail ]),
	((OldAct=turnLeft,Action=turnRight);(OldAct=turnRight,Action=turnLeft)),
	
	Knowledge = [gameStarted,
	             haveGold(NGolds),
		         myWorldSize(Max_X, Max_Y),
		         myPosition(X, Y, Orient),
		         myTrail(Trail_Tail)].

% The agent found the gold (glitter) and picks it up.
pick_up_gold(Action, Knowledge) :-
	
	glitter,
	Action = grab,	    
	haveGold(NGolds),
	NewNGolds is NGolds + 1,
	myWorldSize(Max_X, Max_Y),
	myPosition(X, Y, Orient),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	
	Knowledge = [gameStarted,
	             haveGold(NewNGolds),
				 myWorldSize(Max_X, Max_Y),
				 myPosition(X, Y, Orient),
				 myTrail(New_Trail)].

% The agent hears the Wumpus scream and performs an action 
% based on its current location. If it is currently on the breeze,
% it rotates, and if not, it moves forward, moving to the position of the killed Wumpus.
wumpus_scream(Action, Knowledge) :-

	stench,
	scream,
	breeze,

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),
	firstElement(Trail, Elem),
    
	Elem = [OldAct,OldX,OldY,OldOrient],
	((OldAct=turnLeft,Action=turnRight,shiftOrientRight(Orient, New_Orient));
	(OldAct=turnRight,Action=turnLeft,shiftOrient(Orient, New_Orient))),
	
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	addPossibleWumpus(New_Stenches, New_Wumpus_Location),

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	addPossiblePit(New_Breeze, New_Pit_Location),

	arrows(Arrows), Arrows = 0,
	wumpus(Wumpus),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(X, Y, New_Orient), 
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(New_Stenches),
				 possibleWumpusLocation([]),
				 breezeLocation(New_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(Arrows),
				 wumpus(0),
				 deletedPitPredictions(Old_Deleted_Pit_Pred),
				 deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('wumpus_scream_breeze')].

wumpus_scream(Action, Knowledge) :-

	stench,
	scream,
	not(breeze),

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	New_Trail = [ [Action,X,Y,Orient] | Trail ],
	Action = moveForward,
	forwardStep(X, Y, Orient, New_X, New_Y),

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	addPossibleWumpus(New_Stenches, New_Wumpus_Location),

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	addPossiblePit(New_Breeze, New_Pit_Location),

	arrows(Arrows), Arrows = 0,
	wumpus(Wumpus),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(New_X, New_Y, Orient), 
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(New_Stenches),
				 possibleWumpusLocation([]),
				 breezeLocation(New_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(Arrows),
				 wumpus(0),
				 deletedPitPredictions(Old_Deleted_Pit_Pred),
				 deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('wumpus_scream')].

% The agent checks whether he is in a position 
% from which if he shoots, he kills Wumpus and shoots.	
shoot_wumpus(Action, Knowledge) :-

	stench,

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	Action = shoot,

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	addPossibleWumpus(New_Stenches, New_Wumpus_Location_Tmp),

	((length(Old_Wumpus_Location, 1));(length(New_Wumpus_Location_Tmp, 1))),
	forwardStep(X, Y, Orient, Tmp_X, Tmp_Y),
	((listsEqual([[Tmp_X, Tmp_Y]], Old_Wumpus_Location)); (listsEqual([[Tmp_X, Tmp_Y]], New_Wumpus_Location_Tmp))),

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	addPossiblePit(New_Breeze, New_Pit_Location_Tmp),

	arrows(Arrows), Arrows > 0,
	wumpus(Wumpus), Wumpus > 0,

	validatePrediction(New_Wumpus_Location_Tmp, New_Stenches, New_Location, New_Wumpus_Location, Deleted_W),
	validatePrediction(New_Pit_Location_Tmp, New_Breeze, New_Location, New_Pit_Location, Deleted_P),

	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
	addDeletedPred(Deleted_W, Old_Deleted_Wumpus_Pred, New_Deleted_Wumpus_Pred),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	addDeletedPred(Deleted_P, Old_Deleted_Pit_Pred, New_Deleted_Pit_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(X, Y, Orient), 
				 myTrail(Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(New_Stenches),
				 possibleWumpusLocation(New_Wumpus_Location),
				 breezeLocation(New_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(0),
				 wumpus(0),
				 deletedPitPredictions(New_Deleted_Pit_Pred),
				 deletedWumpusPredictions(New_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('shoot_wumpus')].

% The agent positions himself so that he is facing the wumpus. 
% Various options for setting the agent are considered.
set_in_pos_to_shoot(Action, Knowledge) :-

	(stench;breeze),

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	arrows(Arrows), Arrows > 0,
	wumpus(Wumpus), Wumpus > 0,

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	((Wumpus > 0, stench) -> addPossibleWumpus(New_Stenches, New_Wumpus_Location) ; true, New_Wumpus_Location = Old_Wumpus_Location),

	length(New_Wumpus_Location, 1),
	[[X_Wumpus, Y_Wumpus]] = New_Wumpus_Location,
	abs(Y_Wumpus - Y) =:= 1, abs(X_Wumpus - X) =:= 0,

	(((Y_Wumpus - Y ) =:= 1, Orient = west) -> Action = turnRight, shiftOrientRight(Orient, NewOrient) ; 
	 ((Y_Wumpus - Y ) =:= -1, Orient = west) -> Action = turnLeft, shiftOrient(Orient, NewOrient); false),
	
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	((breeze) -> addPossiblePit(New_Breeze, New_Pit_Location); true, New_Pit_Location = Old_Pit_Location),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(X, Y, NewOrient), 
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(New_Stenches),
				 possibleWumpusLocation(New_Wumpus_Location),
				 breezeLocation(New_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(Arrows),
				 wumpus(Wumpus),
				 deletedPitPredictions(Old_Deleted_Pit_Pred),
				 deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('set_in_pos_to_shoot_WY')].

set_in_pos_to_shoot(Action, Knowledge) :-

	(stench;breeze),

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	arrows(Arrows), Arrows > 0,
	wumpus(Wumpus), Wumpus > 0,

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	((Wumpus > 0, stench) -> addPossibleWumpus(New_Stenches, New_Wumpus_Location) ; true, New_Wumpus_Location = Old_Wumpus_Location),

	length(New_Wumpus_Location, 1),
	[[X_Wumpus, Y_Wumpus]] = New_Wumpus_Location,
	abs(Y_Wumpus - Y) =:= 1, abs(X_Wumpus - X) =:= 0,
	(((Y_Wumpus - Y ) =:= 1, Orient = east) -> Action = turnLeft, shiftOrient(Orient, NewOrient) ;
	 ((Y_Wumpus - Y ) =:= -1, Orient = east) -> Action = turnRight, shiftOrientRight(Orient, NewOrient); false),
	
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	((breeze) -> addPossiblePit(New_Breeze, New_Pit_Location); true, New_Pit_Location = Old_Pit_Location),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(X, Y, NewOrient), 
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(New_Stenches),
				 possibleWumpusLocation(New_Wumpus_Location),
				 breezeLocation(New_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(Arrows),
				 wumpus(Wumpus),
				 deletedPitPredictions(Old_Deleted_Pit_Pred),
				 deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('set_in_pos_to_shoot_EY')].

set_in_pos_to_shoot(Action, Knowledge) :-

	(stench;breeze),

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	arrows(Arrows), Arrows > 0,
	wumpus(Wumpus), Wumpus > 0,

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	((Wumpus > 0, stench) -> addPossibleWumpus(New_Stenches, New_Wumpus_Location) ; true, New_Wumpus_Location = Old_Wumpus_Location),

	length(New_Wumpus_Location, 1),
	[[X_Wumpus, Y_Wumpus]] = New_Wumpus_Location,
	abs(X_Wumpus - X) =:= 1, abs(Y_Wumpus - Y) =:= 0,

	(((X_Wumpus - X ) =:= 1, Orient = north) -> Action = turnRight, shiftOrientRight(Orient, NewOrient) ; 
	 ((X_Wumpus - X ) =:= -1, Orient = north) -> Action = turnLeft, shiftOrient(Orient, NewOrient); false),
	
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	((breeze) -> addPossiblePit(New_Breeze, New_Pit_Location); true, New_Pit_Location = Old_Pit_Location),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(X, Y, NewOrient), 
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(New_Stenches),
				 possibleWumpusLocation(New_Wumpus_Location),
				 breezeLocation(New_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(Arrows),
				 wumpus(Wumpus),
				 deletedPitPredictions(Old_Deleted_Pit_Pred),
				 deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('set_in_pos_to_shoot_NX')].

set_in_pos_to_shoot(Action, Knowledge) :-

	(stench;breeze),
	not(predicateStep(Step)),

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	arrows(Arrows), Arrows > 0,
	wumpus(Wumpus), Wumpus > 0,

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	((Wumpus > 0, stench) -> addPossibleWumpus(New_Stenches, New_Wumpus_Location) ; true, New_Wumpus_Location = Old_Wumpus_Location),

	length(New_Wumpus_Location, 1),
	[[X_Wumpus, Y_Wumpus]] = New_Wumpus_Location,
	abs(X_Wumpus - X) =:= 1, abs(Y_Wumpus - Y) =:= 0,

	(((X_Wumpus - X ) =:= 1, Orient = south) -> Action = turnLeft, shiftOrient(Orient, NewOrient) ; 
	 ((X_Wumpus - X ) =:= -1, Orient = south) -> Action = turnRight, shiftOrientRight(Orient, NewOrient); false),
	
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	((breeze) -> addPossiblePit(New_Breeze, New_Pit_Location); true, New_Pit_Location = Old_Pit_Location),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(X, Y, NewOrient), 
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(New_Stenches),
				 possibleWumpusLocation(New_Wumpus_Location),
				 breezeLocation(New_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(Arrows),
				 wumpus(Wumpus),
				 deletedPitPredictions(Old_Deleted_Pit_Pred),
				 deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('set_in_pos_to_shoot_SX')].
				

% The agent performs a sequence of moves that allows it to go back from the breeze or stench. 
% This sequence takes different forms depending on the conditions. 
% When a Wupums is killed, the agent no longer retreats from the stench field.
back_off_from_stench_or_breeze(Action, Knowledge) :-

	wumpus(Wumpus),
	(stench, Wumpus > 0;breeze),
	not(predicateStep(Step)),

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	Action = turnLeft,
	shiftOrient(Orient, NewOrient),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	arrows(Arrows),
	wumpus(Wumpus),

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	((Wumpus > 0, stench) -> addPossibleWumpus(New_Stenches, New_Wumpus_Location_Tmp) ; true, New_Wumpus_Location_Tmp = Old_Wumpus_Location),

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	((breeze) -> addPossiblePit(New_Breeze, New_Pit_Location_Tmp); true, New_Pit_Location_Tmp = Old_Pit_Location),

	validatePrediction(New_Wumpus_Location_Tmp, New_Stenches, New_Location, New_Wumpus_Location, Deleted_W),
	validatePrediction(New_Pit_Location_Tmp, New_Breeze, New_Location, New_Pit_Location, Deleted_P),

	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
	addDeletedPred(Deleted_W, Old_Deleted_Wumpus_Pred, New_Deleted_Wumpus_Pred),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	addDeletedPred(Deleted_P, Old_Deleted_Pit_Pred, New_Deleted_Pit_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(X, Y, NewOrient), 
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(New_Stenches),
				 possibleWumpusLocation(New_Wumpus_Location),
				 breezeLocation(New_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(Arrows),
				 wumpus(Wumpus),
				 deletedPitPredictions(New_Deleted_Pit_Pred),
				 deletedWumpusPredictions(New_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('back_off_from_stench_or_breeze_1/3'),
				 predicateStep(1)].


back_off_from_stench_or_breeze(Action, Knowledge) :-

	(stench;breeze),
	predicateStep(Step), Step == 1,

	haveGold(NGolds),
	
	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	Action = turnLeft,
	shiftOrient(Orient, NewOrient),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	arrows(Arrows),
	wumpus(Wumpus),

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	((Wumpus > 0, stench) -> addPossibleWumpus(New_Stenches, New_Wumpus_Location) ; true, New_Wumpus_Location = Old_Wumpus_Location),

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	((breeze) -> addPossiblePit(New_Breeze, New_Pit_Location); true, New_Pit_Location = Old_Pit_Location),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
	   			 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(X, Y, NewOrient), 
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(New_Stenches),
				 possibleWumpusLocation(New_Wumpus_Location),
				 breezeLocation(New_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(Arrows),
				 wumpus(Wumpus),
				 deletedPitPredictions(Old_Deleted_Pit_Pred),
				 deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('back_off_from_stench_or_breeze_2/3'),
				 predicateStep(2)].
		
back_off_from_stench_or_breeze(Action, Knowledge) :-

	(stench;breeze),
	predicateStep(Step), Step == 2,

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	Action = moveForward,
	forwardStep(X, Y, Orient, New_X, New_Y),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	arrows(Arrows),
	wumpus(Wumpus),

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),
	
	possibleWumpusLocation(Old_Wumpus_Location),
	((Wumpus > 0, stench) -> addPossibleWumpus(New_Stenches, New_Wumpus_Location) ; true, New_Wumpus_Location = Old_Wumpus_Location),

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	((breeze) -> addPossiblePit(New_Breeze, New_Pit_Location); true, New_Pit_Location = Old_Pit_Location),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(New_X, New_Y, Orient), 
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(New_Stenches),
				 possibleWumpusLocation(New_Wumpus_Location),
				 breezeLocation(New_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(Arrows),
				 wumpus(Wumpus),
				 deletedPitPredictions(Old_Deleted_Pit_Pred),
				 deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('back_off_from_stench_or_breeze_3/3'),
				 predicateStep(3)].

% The agent turns to the right or left depending on whether there is a wall 
% in that direction and there is no danger there and the location has not been visited by him yet.
back_off_from_stench_or_breeze(Action, Knowledge) :-

	wumpus(Wumpus),
	predicateStep(Step), Step == 3,

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	arrows(Arrows),
	wumpus(Wumpus),

	visitedLocation(Old_Location),

	stenchesLocation(Old_Stenches),
	possibleWumpusLocation(Old_Wumpus_Location),

	breezeLocation(Old_Breeze),
	possiblePitLocation(Old_Pit_Location),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	shiftOrient(Orient, OLeft),
	shiftOrientRight(Orient, ORight),

	(((againstWall(X, Y, OLeft, Max_X, Max_Y)), not(isDangerous(X, Y, ORight, Old_Wumpus_Location, Old_Pit_Location)), not(alreadyVisited(X, Y, ORight, Old_Location))) -> (Action = turnRight,New_Orient = ORight) ; 
	((againstWall(X, Y, ORight, Max_X, Max_Y)), not(isDangerous(X, Y, OLeft, Old_Wumpus_Location, Old_Pit_Location)), not(alreadyVisited(X, Y, OLeft, Old_Location))) -> (Action = turnLeft , New_Orient = OLeft) ; false),
	
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y), 
				 myPosition(X, Y, New_Orient), 
				 myTrail(New_Trail),
				 visitedLocation(Old_Location),
				 stenchesLocation(Old_Stenches),
				 possibleWumpusLocation(Old_Wumpus_Location),
				 breezeLocation(Old_Breeze),
				 possiblePitLocation(Old_Pit_Location),
				 arrows(Arrows),
				 wumpus(Wumpus),
				 deletedPitPredictions(Old_Deleted_Pit_Pred),
				 deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('back_off_from_danger_righ_or_left')].
					
% The agent turns left when he is facing a wall and there is a wall to his right.
turn_if_wall(Action, Knowledge) :-

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	
	againstWall(X, Y, Orient, Max_X, Max_Y),
	shiftOrient(Orient, New_Orient),
	
	shiftOrientRight(Orient, ORight),
	againstWall(X, Y, ORight, Max_X, Max_Y),
	
	Action = turnLeft,

	haveGold(NGolds),
	myTrail(Trail),
	((X = 1, Y = 1)-> New_Trail = [] ; New_Trail = [ [Action,X,Y,Orient] | Trail ]),

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	possibleWumpusLocation(Old_Wumpus_Location),
	breezeLocation(Old_Breeze),
	possiblePitLocation(Old_Pit_Location),

	arrows(Arrows),
	wumpus(Wumpus),

	validatePrediction(Old_Wumpus_Location, Old_Stenches, New_Location, New_Wumpus_Location, Deleted_W),
	validatePrediction(Old_Pit_Location, Old_Breeze, New_Location, New_Pit_Location, Deleted_P),

	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
	addDeletedPred(Deleted_W, Old_Deleted_Wumpus_Pred, New_Deleted_Wumpus_Pred),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	addDeletedPred(Deleted_P, Old_Deleted_Pit_Pred, New_Deleted_Pit_Pred), 

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
					haveGold(NGolds),
					myWorldSize(Max_X, Max_Y),
					myPosition(X, Y, New_Orient),
					myTrail(New_Trail),
					visitedLocation(New_Location),
					stenchesLocation(Old_Stenches),
					possibleWumpusLocation(Old_Wumpus_Location),
					breezeLocation(Old_Breeze),
					possiblePitLocation(Old_Pit_Location),
					arrows(Arrows),
					wumpus(Wumpus),
					deletedPitPredictions(Old_Deleted_Pit_Pred),
					deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
					loopCounter(New_Counter),
					performedAction('turn_if_wall_front_and_right')].

% The agent turns right when he is facing a wall and there is a wall to his left.
turn_if_wall(Action, Knowledge) :-

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	
	shiftOrientRight(Orient, New_Orient),
	againstWall(X, Y, Orient, Max_X, Max_Y),
	
	shiftOrient(Orient, OLeft),
	againstWall(X, Y, OLeft, Max_X, Max_Y),
	
	Action = turnRight,
	
	haveGold(NGolds),
	myTrail(Trail),
	((X = 1, Y = 1)-> New_Trail = [] ; New_Trail = [ [Action,X,Y,Orient] | Trail ]),

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	possibleWumpusLocation(Old_Wumpus_Location),
	breezeLocation(Old_Breeze),
	possiblePitLocation(Old_Pit_Location),

	arrows(Arrows),
	wumpus(Wumpus),

	validatePrediction(Old_Wumpus_Location, Old_Stenches, New_Location, New_Wumpus_Location, Deleted_W),
	validatePrediction(Old_Pit_Location, Old_Breeze, New_Location, New_Pit_Location, Deleted_P),

	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
	addDeletedPred(Deleted_W, Old_Deleted_Wumpus_Pred, New_Deleted_Wumpus_Pred),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	addDeletedPred(Deleted_P, Old_Deleted_Pit_Pred, New_Deleted_Pit_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y),
				 myPosition(X, Y, New_Orient),
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(Old_Stenches),
				 possibleWumpusLocation(Old_Wumpus_Location),
				 breezeLocation(Old_Breeze),
				 possiblePitLocation(Old_Pit_Location),
				 arrows(Arrows),
				 wumpus(Wumpus),
				 deletedPitPredictions(Old_Deleted_Pit_Pred),
				 deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('turn_if_wall_front_and_left')].

% The agent turns right when encountered a wall.
turn_if_wall(Action, Knowledge) :-

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),

	shiftOrientRight(Orient, New_Orient),
	againstWall(X, Y, Orient, Max_X, Max_Y),

	Action = turnRight,

	haveGold(NGolds),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	possibleWumpusLocation(Old_Wumpus_Location),
	breezeLocation(Old_Breeze),
	possiblePitLocation(Old_Pit_Location),

	arrows(Arrows),
	wumpus(Wumpus),

	validatePrediction(Old_Wumpus_Location, Old_Stenches, New_Location, New_Wumpus_Location, Deleted_W),
	validatePrediction(Old_Pit_Location, Old_Breeze, New_Location, New_Pit_Location, Deleted_P),

	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
	addDeletedPred(Deleted_W, Old_Deleted_Wumpus_Pred, New_Deleted_Wumpus_Pred),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	addDeletedPred(Deleted_P, Old_Deleted_Pit_Pred, New_Deleted_Pit_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter),

	Knowledge = [gameStarted,
					haveGold(NGolds),
					myWorldSize(Max_X, Max_Y),
					myPosition(X, Y, New_Orient),
					myTrail(New_Trail),
					visitedLocation(New_Location),
					stenchesLocation(Old_Stenches),
					possibleWumpusLocation(Old_Wumpus_Location),
					breezeLocation(Old_Breeze),
					possiblePitLocation(Old_Pit_Location),
					arrows(Arrows),
					wumpus(Wumpus),
					deletedPitPredictions(Old_Deleted_Pit_Pred),
					deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
					loopCounter(New_Counter),
					performedAction('turn_if_wall')].

% The agent moves forward.
else_move_on(Action, Knowledge) :-
	
	Action = moveForward,
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	myPosition(X, Y, Orient),
	forwardStep(X, Y, Orient, New_X, New_Y),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	visitedLocation(Old_Location),

	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),

	breezeLocation(Old_Breeze),

	possiblePitLocation(Old_Pit_Location),

	validatePrediction(Old_Wumpus_Location, Old_Stenches, New_Location, New_Wumpus_Location, Deleted_W),
	validatePrediction(Old_Pit_Location, Old_Breeze, New_Location, New_Pit_Location, Deleted_P),

	arrows(Arrows),
	wumpus(Wumpus),

	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
	addDeletedPred(Deleted_W, Old_Deleted_Wumpus_Pred, New_Deleted_Wumpus_Pred),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	addDeletedPred(Deleted_P, Old_Deleted_Pit_Pred, New_Deleted_Pit_Pred),

	loopCounter(Old_Counter),
	isAgentOnExit(Old_Counter, New_Counter), 

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y),
				 myPosition(New_X, New_Y, Orient),
				 myTrail(New_Trail),
				 visitedLocation(New_Location),
				 stenchesLocation(Old_Stenches),
				 possibleWumpusLocation(New_Wumpus_Location),
				 breezeLocation(Old_Breeze),
				 possiblePitLocation(New_Pit_Location),
				 arrows(Arrows),
				 wumpus(Wumpus),
				 deletedPitPredictions(New_Deleted_Pit_Pred),
				 deletedWumpusPredictions(New_Deleted_Wumpus_Pred),
				 loopCounter(New_Counter),
				 performedAction('else_move_on')].

% Checking if the agent is facing the wall
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = Max_X, Y = Y, Orient = east.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = X, Y = Max_Y, Orient = north.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = 1, Y = Y, Orient = west.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = X, Y = 1, Orient = south.

% Change orientation for rotation to the left		
shiftOrient(east, north).
shiftOrient(north, west).
shiftOrient(west, south).
shiftOrient(south, east).

% Change orientation for rotation to the right
shiftOrientRight(north, east).
shiftOrientRight(west, north).
shiftOrientRight(south, west).
shiftOrientRight(east, south).

% Change the coordinates after moving forward
forwardStep(X, Y, east,  New_X, Y) :- New_X is (X+1).
forwardStep(X, Y, south, X, New_Y) :- New_Y is (Y-1).
forwardStep(X, Y, west,  New_X, Y) :- New_X is (X-1).
forwardStep(X, Y, north, X, New_Y) :- New_Y is (Y+1).

% Adding to the list of discovered stenches, breezes and locations
addStench(X, Y, Old_Stenches, New_Stenches) :- ((stench, \+ member([X, Y], Old_Stenches))) -> New_Stenches = [[X, Y] | Old_Stenches]; New_Stenches = Old_Stenches.
addBreeze(X, Y, Old_Breeze, New_Breeze) :- ((breeze, \+ member([X, Y], Old_Breeze))) -> New_Breeze = [[X, Y] | Old_Breeze]; New_Breeze = Old_Breeze.
addLocation(X, Y, Old_Location, New_Location) :- not((member([X, Y], Old_Location))) -> New_Location = [[X, Y] | Old_Location]; New_Location = Old_Location.
addDeletedPred(Deleted, Old_Pred, New_Pred) :- append(Deleted, Old_Pred, New_Pred).

% Checks if an agent has already been to a given location
alreadyVisited(X, Y, Orient, VisitedLocation) :- forwardStep(X, Y, Orient, Next_X, Next_Y), member([Next_X, Next_Y], VisitedLocation).

% Checks whether it is dangerous in a given location
isDangerous(X, Y, Orient, Wumpus, Pit) :- forwardStep(X, Y, Orient, Next_X, Next_Y), ((member([Next_X, Next_Y], Wumpus));(member([Next_X, Next_Y], Pit))).

% Checks if the agent is in the starting position and increments the counter
isAgentOnExit(Old_Counter, New_Counter) :- (myPosition(1,1,Orient) -> New_Counter is Old_Counter + 1 ; New_Counter = Old_Counter).

% Based on the collected information, the possible Wumpus positions are calculated
addPossibleWumpus(New_Stenches, New_Wumpus_Location) :- 
	
	calculatePossibleDangerLocation(New_Stenches, Tmp),
	(findDuplicate(Tmp, Duplicate) -> New_Wumpus_Location = [Duplicate] ; findCommonCoords(Tmp, New_Wumpus_Location)).

% Based on the collected information, the possible pits positions are calculated
addPossiblePit(New_Breeze, New_Pit_Location) :- 

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	calculatePossibleDangerLocation(New_Breeze, Tmp),
	removeCommonElements(Tmp,Old_Deleted_Pit_Pred, New_Pit_Location).

% As the agent explores the world, the calculated predictions of dangerous places are verified
validatePrediction(Old_Wumpus_Pit_Location, Old_Breeze_Stenches, Visited_Location, New_Wumpus_Pit_Location, Deleted_Res) :-

	firstElement(Visited_Location, Tmp1), [Xtmp, Ytmp] = Tmp1,
	((Xtmp = 1, Ytmp = 1)-> true, Tmp2 = []; calculatePossibleDangerLocation([Tmp1], Tmp2)),
	findall(Element, (member(Element, Tmp2), member(Element, Old_Wumpus_Pit_Location)),  Deleted),
	(isEmpty(Deleted) ->true, New_Wumpus_Pit_Location = Old_Wumpus_Pit_Location; member(Tmp1, Old_Breeze_Stenches) -> true, New_Wumpus_Pit_Location = Old_Wumpus_Pit_Location ; removeCommonElements(Old_Wumpus_Pit_Location, Deleted ,New_Wumpus_Pit_Location), Deleted_Res = Deleted).

% For each item in the list of stenches and breezes found, 
% the possible positions of the Wumpus and holes are calculated
calculatePossibleDangerLocation([], []).
calculatePossibleDangerLocation([[X,Y]|Rest], Result) :-
	
	myWorldSize(Max_X,Max_Y),
	visitedLocation(Vistited_Location),
    X1 is X - 1, Y1 is Y,
    X2 is X + 1, Y2 is Y,
    X3 is X, Y3 is Y + 1,
    X4 is X, Y4 is Y - 1,
    (X1 >= 1, X1 =< Max_X, Y1 >= 1, Y1 =< Max_Y, [X1,Y1] \= [1,1] -> C1 = [X1,Y1] ; C1 = []),
    (X2 >= 1, X2 =< Max_X, Y2 >= 1, Y2 =< Max_Y, [X2,Y2] \= [1,1] -> C2 = [X2,Y2] ; C2 = []),
    (X3 >= 1, X3 =< Max_X, Y3 >= 1, Y3 =< Max_Y, [X3,Y3] \= [1,1] -> C3 = [X3,Y3] ; C3 = []),
    (X4 >= 1, X4 =< Max_X, Y4 >= 1, Y4 =< Max_Y, [X4,Y4] \= [1,1] -> C4 = [X4,Y4] ; C4 = []),
    calculatePossibleDangerLocation(Rest, RestResult),
    append([C1,C2,C3,C4], RestResult, ResultTmp),
	findall([H|T],member([H|T],ResultTmp),ResultTmp2),
	removeCommonElements(ResultTmp2, Vistited_Location, Result).
	
% On the basis of predictions and information about the world, 
% incorrect predictions regarding the location of dangers are excluded.
findCommonCoords([], []).
findCommonCoords([[X,Y]|Rest], Result) :-
	
	myWorldSize(Max_X,Max_Y),
	myPosition(X_Pos, Y_Pos, Orient),
	visitedLocation(Vistited_Location),
	stenchesLocation(Stenches),
    X1 is X - 1, Y1 is Y,
    X2 is X + 1, Y2 is Y,
    X3 is X, Y3 is Y + 1,
    X4 is X, Y4 is Y - 1,
    (X1 >= 1, X1 =< Max_X, Y1 >= 1, Y1 =< Max_Y, [X1,Y1] \= [1,1], [X1,Y1] \= [X_Pos, Y_Pos] -> C1 = [X1,Y1] ; C1 = []),
    (X2 >= 1, X2 =< Max_X, Y2 >= 1, Y2 =< Max_Y, [X2,Y2] \= [1,1], [X2,Y2] \= [X_Pos, Y_Pos] -> C2 = [X2,Y2] ; C2 = []),
    (X3 >= 1, X3 =< Max_X, Y3 >= 1, Y3 =< Max_Y, [X3,Y3] \= [1,1], [X3,Y3] \= [X_Pos, Y_Pos] -> C3 = [X3,Y3] ; C3 = []),
    (X4 >= 1, X4 =< Max_X, Y4 >= 1, Y4 =< Max_Y, [X4,Y4] \= [1,1], [X4,Y4] \= [X_Pos, Y_Pos] -> C4 = [X4,Y4] ; C4 = []),
	findall([H|T],member([H|T],[C1,C2,C3,C4]),AdjacentCoords),
    findall(Element, (member(Element, AdjacentCoords), member(Element, Vistited_Location)),  CommonCoords),
    ((CommonCoords = []) -> append([[X,Y]], RestResult, Result) ; (member(CommonCoords, Stenches) -> append([[X,Y]], RestResult, Result) ; Result = RestResult)),
    findCommonCoords(Rest, RestResult).

% Finds and returns a duplicate in a list
findDuplicate([], _) :- fail.
findDuplicate([H|T], H) :- member(H, T).
findDuplicate([_|T], Dup) :- findDuplicate(T, Dup).

% Removes common list items
removeCommonElements([], _, []).
removeCommonElements([X|Rest], List2, Result) :- member(X, List2), !, removeCommonElements(Rest, List2, Result).
removeCommonElements([X|Rest], List2, [X|Result]) :- removeCommonElements(Rest, List2, Result).

% Checks whether the lists are identical
listsEqual([], []).
listsEqual([X|Xs], [Y|Ys]) :- X = Y, listsEqual(Xs, Ys).

% Returns the first element of the list
firstElement([X|_], X).

% Checks if the list is empty
isEmpty([]).