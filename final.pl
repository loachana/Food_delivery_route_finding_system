%roads

road(kandy, katugastota, 5.4).
road(kandy, peradeniya, 6.1).
road(kandy, tennakumbura, 7.7).
road(kandy, ampitiya, 5.2).
road(kandy, kundasale, 7.0).
road(kandy, getambe, 5.5).
road(kandy, mahaiyawa, 2.5).
road(katugastota, mahaiyawa, 2.0).


%H values
h(katugastota, 0).
h(kandy, 4.5).
h(peradeniya, 10.5).
h(tennakumbura, 10.8).
h(ampitiya, 8.2).
h(kundasale, 9.5).
h(getambe, 7.5).
h(mahaiyawa, 2.0).


:- dynamic(blocked/2).

list_blocked :-
    forall(
        blocked(A, B),
        (write(A-B), nl)
    ).


connected(A,B,D):-
    road(A,B,D), \+blocked(A,B).

connected(A,B,D):-
    road(B,A,D), \+blocked(B,A).

%DFS

dfs_path(Start, Goal, Path, Cost):-
	dfs_travel(Start, Goal, [Start], RevPath, 0, Cost),
	reverse(RevPath, Path).

dfs_travel(Node, Node, Path, Path, Cost, Cost).
dfs_travel(Current, Goal, Visited, Path, CostSoFar, Cost):-
	connected(Current, Next, StepCost),
	\+ member(Next, Visited),
	NewCost is CostSoFar + StepCost,
	dfs_travel(Next, Goal, [Next|Visited], Path, NewCost, Cost).

%BFS

bfs(Start, Goal, Path, Cost):-
	bfs_queue([[Start]], Goal, RevPath),
	reverse(RevPath, Path),
	path_cost(Path,Cost).

bfs_queue([[Goal|Rest]|_], Goal, [Goal|Rest]).
bfs_queue([[Current|Rest]|Other], Goal, Path) :-
	findall([Next,Current|Rest],
	(connected(Current, Next, _),
	\+ member(Next, [Current|Rest])),
	NewPaths),
	append(Other, NewPaths, Updated),
	bfs_queue(Updated, Goal, Path).


%path cost finder

path_cost([_],0).
path_cost([A,B|Rest],Cost):-
	connected(A,B,D),
	path_cost([B|Rest],CostRest),
	Cost is D + CostRest.


%A*
astar(Start, Goal, Path, Cost):-
	h(Start, H0),
	astar_search([[H0,0,[Start]]], Goal, RevPath, Cost),
	reverse(RevPath, Path).

astar_search([[_,Cost,[Goal|Rest]]|_], Goal, [Goal|Rest], Cost).
astar_search([[_,G,[Current|Rest]]|Others], Goal, Path, Cost):-
	findall([F2, G2,[Next,Current|Rest]],
		(connected(Current, Next, StepCost),
		\+ member(Next,[Current|Rest]),
		G2 is G + StepCost,
		h(Next,H),
		F2 is G2 + H),
		Children),
	append(Others, Children, All),
	sort(All,Sorted),
	astar_search(Sorted,Goal,Path,Cost).




%Display results

show_all_paths(Start, Goal):-
    nl, 
    write('DFS results'), nl,
	findall([Pdfs,Cdfs],dfs_path(Start, Goal, Pdfs, Cdfs), DfsPaths),
    display_paths(DfsPaths), nl,
    write('BFS results'), nl,
    findall([Pbfs,Cbfs],bfs(Start, Goal, Pbfs, Cbfs), BfsPaths),
    display_paths(BfsPaths), nl,
    write('A* results'), nl,
    findall([Pa,Ca], astar(Start, Goal, Pa, Ca), APaths),
    display_paths(APaths),

    %----------------------------------------------
    %need to study

    % Combine results from all algorithms
    append(DfsPaths, BfsPaths, TempPaths),
    append(TempPaths, APaths, AllPaths),

    % Find overall shortest path
    shortest_path(AllPaths, ShortestPath, ShortestCost),

    nl,
    write('===== OVERALL SHORTEST ROUTE ====='), nl,
    write('Path: '), write(ShortestPath), nl,
    write('Distance: '), write(ShortestCost), write(' km'), nl.

    %--------------------------------------------------




display_paths([]).
display_paths([[P,C]|Rest]) :-
	write('Path= '), write(P), nl,
	write(' cost= '), write(C), nl, nl,
	display_paths(Rest).


%-------------------------------------------------------
%need to study
% Find path with the smallest distance
shortest_path([[Path, Cost] | Rest], ShortestPath, ShortestCost) :-
    shortest_path(Rest, Path, Cost, ShortestPath, ShortestCost).

shortest_path([], Path, Cost, Path, Cost).

shortest_path([[Path, Cost] | Rest],
              CurrentPath, CurrentCost,
              ShortestPath, ShortestCost) :-

    ( Cost < CurrentCost ->
        NewPath = Path,
        NewCost = Cost
    ;
        NewPath = CurrentPath,
        NewCost = CurrentCost
    ),

    shortest_path(Rest,
                  NewPath,
                  NewCost,
                  ShortestPath,
                  ShortestCost).

%----------------------------------------------


%--------------Interface-----------------------

menu:-

    nl, write('====== Food Delivery Route Finding System ======='), nl,
    write('1. Find path: '), nl,
    write('2. Block a road: '), nl,
    write('3. Unblock a road: '), nl,
    write('4. View blocked roads: '), nl,
    write('5. Exit'), nl,
    nl, write('Enter your choice: '),
    read(Choice),
    handle(Choice).
    
handle(1):-
    nl, write('Enter start location: '),
    read(Start),
    nl, write('Enter destination: '),
    read(Goal),
    show_all_paths(Start, Goal), menu ; nl, write('invalid input'), !, nl,
    menu.

handle(2):-
    nl, write('Enter the starting location of the road to block: '),
    read(Start),
    nl, write('Enter the ending location of the road to block: '),
    read(End),
    assertz(blocked(Start, End)),
    assertz(blocked(End, Start)),
    nl, write(Start - End), write(': Road blocked successfully.'), nl,
    menu.

handle(3):-
    nl, write('Enter the starting location of the road to unblock: '),
    read(Start),
    nl, write('Enter the ending location of the road to unblock: '),
    read(End),
    retractall(blocked(Start, End)),
    retractall(blocked(End, Start)),
    nl, write(Start - End), write(': Road unblocked successfully.'), nl,
    menu.

handle(4):-
    nl, write('Blocked roads details:'), nl, nl,
    list_blocked,
    menu.

handle(5):-
    nl, write('Exiting the program. Goodbye!'), nl.

handle(_):-
    nl, write('Invalid choice. Please try again.'), nl,
    menu.

