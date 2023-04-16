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
	assert(performedAction(0)),
	act(Action, Knowledge).

act(Action, Knowledge) :- exit_if_home(Action, Knowledge). % if at home with gold
act(Action, Knowledge) :- return_to_home_if_gold(Action, Knowledge). % if have gold elsewhere return home
act(Action, Knowledge) :- pick_up_gold(Action, Knowledge). % if just found gold
act(Action, Knowledge) :- wumpus_scream(Action, Knowledge). % if wumpus killed and screamd
act(Action, Knowledge) :- shoot_wumpus(Action, Knowledge). % if wumpus found shoot him
act(Action, Knowledge) :- back_off_from_stench_or_breeze(Action, Knowledge). % if stench/breeze take step back
act(Action, Knowledge) :- turn_if_wall(Action, Knowledge). % if against the wall
act(Action, Knowledge) :- else_move_on(Action, Knowledge). % if location not visited move forward
act(Action, Knowledge) :- turn_left(Action, Knowledge). % otherwise turn left to point to another direction


/**
 * Agent finishes the game if:
 * [1] hasn't gold
 * [2] is on the starting position
 * [3] there is stench or breeeze
 */
exit_if_home(Action, Knowledge) :-
	
	(stench;breeze),
	haveGold(NGolds), NGolds = 0,
	myPosition(1, 1, Orient),
	Action = exit,
	Knowledge = [].	

/**
 * Agent finishes the game if:
 * [1] has gold
 * [2] is on the starting position
 */
exit_if_home(Action, Knowledge) :-
	
	haveGold(NGolds), NGolds > 0,
	myPosition(1, 1, Orient),
	Action = exit,
	Knowledge = [].	

/**
 * Agent returns to home if:
 * [1] has gold
 * [2] last performed action is 'grab'
 * Initiate a turnback and then return:
 * (a) pop `grab` from the stack
 * (b) replace it by an artificial turnRight we have never
 *	   executed, but we will be reversing by turning left
 * (c) execute a turnRight now which together will turn us back
 * (d) after that we are facing back and can execute actions in reverse
 */
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

/**
 * Agent picks up gold if:
 * [1] there is glitter on his location
 * Increment gold value by 1
 */
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

wumpus_scream(Action, Knowledge) :-

	stench,
	scream,

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	(breeze -> Action = turnLeft, shiftOrient(Orient, New_Orient), New_X = X, New_Y = Y; Action = moveForward, forwardStep(X, Y, Orient, New_X, New_Y), New_Orient = Orient),
	
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
	wumpus(Wumpus), Wumpus > 0,

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	Knowledge = [gameStarted,
					haveGold(NGolds),
					myWorldSize(Max_X, Max_Y), 
					myPosition(New_X, New_Y, New_Orient), 
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
					performedAction('wumpus_scream')].
				

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

	((length(Old_Wumpus_Location, 1));(length(New_Wumpus_Location_Tmp, 1))), % If there is only one location
	forwardStep(X, Y, Orient, Tmp_X, Tmp_Y), % Simulate move forward
	((listsEqual([[Tmp_X, Tmp_Y]], Old_Wumpus_Location)); (listsEqual([[Tmp_X, Tmp_Y]], New_Wumpus_Location_Tmp))),% Check if facing wumpus

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
				 wumpus(Wumpus),
				 deletedPitPredictions(New_Deleted_Pit_Pred),
				 deletedWumpusPredictions(New_Deleted_Wumpus_Pred),
				 performedAction('shoot_wumpus')].


back_off_from_stench_or_breeze(Action, Knowledge) :-

	(stench;breeze),
	not(predicateStep(Step)),

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	addPossibleWumpus(New_Stenches, New_Wumpus_Location),

	length(New_Wumpus_Location, 1), % If there is only one possible location
	[[X_Wumpus, Y_Wumpus]] = New_Wumpus_Location, % Extract coordinates
	abs(X_Wumpus - X) =:= 1, % If distance is 1 to wumpus
	(((X_Wumpus - X )=:= 1) -> Action = turnRight, shiftOrientRight(Orient, NewOrient) ; Action = turnLeft,shiftOrient(Orient, NewOrient)),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	addPossiblePit(New_Breeze, New_Pit_Location),

	arrows(Arrows), Arrows > 0,
	wumpus(Wumpus), Wumpus > 0,

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

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
					performedAction('set_in_pos_to_shoot_1')].

back_off_from_stench_or_breeze(Action, Knowledge) :-

	(stench;breeze),
	not(predicateStep(Step)),

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),
	addStench(X,Y,Old_Stenches, New_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),
	addPossibleWumpus(New_Stenches, New_Wumpus_Location),

	length(New_Wumpus_Location, 1), % If there is only one possible location
	[[X_Wumpus, Y_Wumpus]] = New_Wumpus_Location, % Extract coordinates
	abs(Y_Wumpus - Y) =:= 1, % If distance is 1 to wumpus
	(((Y_Wumpus - Y)=:= 1) -> Action = turnRight, shiftOrientRight(Orient, NewOrient) ; Action = turnLeft,shiftOrient(Orient, NewOrient)),

	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	breezeLocation(Old_Breeze),
	addBreeze(X,Y,Old_Breeze, New_Breeze),

	possiblePitLocation(Old_Pit_Location),
	addPossiblePit(New_Breeze, New_Pit_Location),

	arrows(Arrows), Arrows > 0,
	wumpus(Wumpus), Wumpus > 0,

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

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
					performedAction('set_in_pos_to_shoot_2')].

/**
 * Agent permorms back off sequence if:
 * [1] there is stench or breeze on his location
 * Initiate following sequence:
 * (a) turnLeft
 * (b) turnLeft
 * (c) moveForward
 */
back_off_from_stench_or_breeze(Action, Knowledge) :-

	wumpus(Wumpus),
	(stench, Wumpus > 0;breeze),
	not(predicateStep(Step)),

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	Action = turnLeft,			%always successful
	shiftOrient(Orient, NewOrient),		%always successful
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

	arrows(Arrows),
	wumpus(Wumpus),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

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
				 performedAction('back_off_from_stench_or_breeze_1/3'),
				 predicateStep(1)].


back_off_from_stench_or_breeze(Action, Knowledge) :-

	wumpus(Wumpus),
	(stench;breeze),
	predicateStep(Step), Step == 1,

	haveGold(NGolds),
	
	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	Action = turnLeft,
	shiftOrient(Orient, NewOrient),
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

	arrows(Arrows),
	wumpus(Wumpus),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

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
				 performedAction('back_off_from_stench_or_breeze_2/3'),
				 predicateStep(2)].
		
back_off_from_stench_or_breeze(Action, Knowledge) :-

	wumpus(Wumpus),
	(stench;breeze),
	predicateStep(Step), Step == 2,

	haveGold(NGolds),

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	myTrail(Trail),

	Action = moveForward,
	forwardStep(X, Y, Orient, New_X, New_Y),
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

	arrows(Arrows),
	wumpus(Wumpus),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

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
				 performedAction('back_off_from_stench_or_breeze_3/3')].

turn_if_wall(Action, Knowledge) :-
	
	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	againstWall(X, Y, Orient, Max_X, Max_Y),
	Action = turnLeft,
	shiftOrient(Orient, NewOrient),
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

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y),
				 myPosition(X, Y, NewOrient),
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
				 performedAction('turn_if_wall')].

else_move_on(Action, Knowledge) :-
	
	Action = moveForward,
	haveGold(NGolds),
	myWorldSize(Max_X,Max_Y),
	myPosition(X, Y, Orient),
	forwardStep(X, Y, Orient, New_X, New_Y),
	myTrail(Trail),
	New_Trail = [ [Action,X,Y,Orient] | Trail ],

	visitedLocation(Old_Location),
	not(alreadyVisited(X, Y, Orient, Old_Location)),

	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),

	breezeLocation(Old_Breeze),

	possiblePitLocation(Old_Pit_Location),

	validatePrediction(Old_Wumpus_Location, Old_Stenches, New_Location, New_Wumpus_Location, Deleted_W),
	validatePrediction(Old_Pit_Location, Old_Breeze, New_Location, New_Pit_Location, Deleted_P),

	not(notDangerous(X, Y, Orient, New_Wumpus_Location, New_Pit_Location)),

	arrows(Arrows),
	wumpus(Wumpus),

	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),
	addDeletedPred(Deleted_W, Old_Deleted_Wumpus_Pred, New_Deleted_Wumpus_Pred),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	addDeletedPred(Deleted_P, Old_Deleted_Pit_Pred, New_Deleted_Pit_Pred), 

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
				 performedAction('else_move_on')].

turn_left(Action, Knowledge) :-

	myPosition(X, Y, Orient),
	myWorldSize(Max_X,Max_Y),
	Action = turnLeft,
	shiftOrient(Orient, NewOrient),
	haveGold(NGolds),
	myTrail(Trail),
	((X = 1, Y = 1, Orient = east)-> New_Trail = [] ; New_Trail = [ [Action,X,Y,Orient] | Trail ]),

	visitedLocation(Old_Location),
	addLocation(X,Y, Old_Location, New_Location),

	stenchesLocation(Old_Stenches),

	possibleWumpusLocation(Old_Wumpus_Location),

	breezeLocation(Old_Breeze),

	possiblePitLocation(Old_Pit_Location),

	arrows(Arrows),
	wumpus(Wumpus),

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	deletedWumpusPredictions(Old_Deleted_Wumpus_Pred),

	Knowledge = [gameStarted,
				 haveGold(NGolds),
				 myWorldSize(Max_X, Max_Y),
				 myPosition(X, Y, NewOrient),
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
				 performedAction('turn_left')].
				
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = Max_X, Y = Y, Orient = east.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = X, Y = Max_Y, Orient = north.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = 1, Y = Y, Orient = west.
againstWall(X, Y, Orient, Max_X, Max_Y) :- X = X, Y = 1, Orient = south.
			
shiftOrient(east, north).
shiftOrient(north, west).
shiftOrient(west, south).
shiftOrient(south, east).

shiftOrientRight(north, east).
shiftOrientRight(west, north).

forwardStep(X, Y, east,  New_X, Y) :- New_X is (X+1).
forwardStep(X, Y, south, X, New_Y) :- New_Y is (Y-1).
forwardStep(X, Y, west,  New_X, Y) :- New_X is (X-1).
forwardStep(X, Y, north, X, New_Y) :- New_Y is (Y+1).

addStench(X, Y, Old_Stenches, New_Stenches) :- ((stench, \+ member([X, Y], Old_Stenches))) -> New_Stenches = [[X, Y] | Old_Stenches]; New_Stenches = Old_Stenches.
addBreeze(X, Y, Old_Breeze, New_Breeze) :- ((breeze, \+ member([X, Y], Old_Breeze))) -> New_Breeze = [[X, Y] | Old_Breeze]; New_Breeze = Old_Breeze.
addLocation(X, Y, Old_Location, New_Location) :- not((member([X, Y], Old_Location))) -> New_Location = [[X, Y] | Old_Location]; New_Location = Old_Location.
addDeletedPred(Deleted, Old_Pred, New_Pred) :- append(Deleted, Old_Pred, New_Pred).

alreadyVisited(X, Y, Orient, VisitedLocation) :- forwardStep(X, Y, Orient, Next_X, Next_Y), member([Next_X, Next_Y], VisitedLocation).
notDangerous(X, Y, Orient, Wumpus, Pit) :- forwardStep(X, Y, Orient, Next_X, Next_Y), ((member([Next_X, Next_Y], Wumpus));(member([Next_X, Next_Y], Pit))).

addPossibleWumpus(New_Stenches, New_Wumpus_Location) :- 
	
	calculatePossibleDangerLocation(New_Stenches, Tmp),
	(findDuplicate(Tmp, Duplicate) -> New_Wumpus_Location = [Duplicate] ; findCommonCoords(Tmp, New_Wumpus_Location)).

addPossiblePit(New_Breeze, New_Pit_Location) :- 

	deletedPitPredictions(Old_Deleted_Pit_Pred),
	calculatePossibleDangerLocation(New_Breeze, Tmp),
	removeCommonElements(Tmp,Old_Deleted_Pit_Pred, New_Pit_Location).

validatePrediction(Old_Wumpus_Pit_Location, Old_Breeze_Stenches, Visited_Location, New_Wumpus_Pit_Location, Deleted_Res) :-

	firstElement(Visited_Location, Tmp1), [Xtmp, Ytmp] = Tmp1,
	((Xtmp = 1, Ytmp = 1)-> true, Tmp2 = []; calculatePossibleDangerLocation([Tmp1], Tmp2)),
	findall(Element, (member(Element, Tmp2), member(Element, Old_Wumpus_Pit_Location)),  Deleted),
	(isEmpty(Deleted) ->true, New_Wumpus_Pit_Location = Old_Wumpus_Pit_Location; member(Tmp1, Old_Breeze_Stenches) -> true, New_Wumpus_Pit_Location = Old_Wumpus_Pit_Location ; removeCommonElements(Old_Wumpus_Pit_Location, Deleted ,New_Wumpus_Pit_Location), Deleted_Res = Deleted).

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
	findall([H|T],member([H|T],[C1,C2,C3,C4]),AdjacentCoords), % Remove empty entries
    findall(Element, (member(Element, AdjacentCoords), member(Element, Vistited_Location)),  CommonCoords),
    ((CommonCoords = []) -> append([[X,Y]], RestResult, Result) ; (member(CommonCoords, Stenches) -> append([[X,Y]], RestResult, Result) ; Result = RestResult)),
    findCommonCoords(Rest, RestResult).

findDuplicate([], _) :- fail.
findDuplicate([H|T], H) :- member(H, T).
findDuplicate([_|T], Dup) :- findDuplicate(T, Dup).

removeCommonElements([], _, []).
removeCommonElements([X|Rest], List2, Result) :- member(X, List2), !, removeCommonElements(Rest, List2, Result).
removeCommonElements([X|Rest], List2, [X|Result]) :- removeCommonElements(Rest, List2, Result).

listsEqual([], []).
listsEqual([X|Xs], [Y|Ys]) :- X = Y, listsEqual(Xs, Ys).

firstElement([X|_], X).

isEmpty([]).