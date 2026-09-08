% =========================================================
% FOOD DELIVERY ROUTE FINDING SYSTEM
% DFS, BFS and A* Search
% =========================================================

:- dynamic blocked/2.

% =========================================================
% 1. ROAD NETWORK
% =========================================================

% road(Location1, Location2, Distance).

road(kandy, peradeniya, 6).
road(kandy, katugastota, 5).
road(kandy, kundasale, 7).

road(peradeniya, pilimathalawa, 8).
road(peradeniya, gelioya, 6).

road(katugastota, mawilmada, 4).
road(katugastota, kundasale, 9).

road(kundasale, digana, 10).
road(kundasale, talwatta, 5).

road(pilimathalawa, kadugannawa, 7).

road(gelioya, gampola, 12).

road(mawilmada, matale, 15).

road(digana, teldeniya, 14).


% =========================================================
% 2. RESTAURANTS
% =========================================================

restaurant(pizza_hut, kandy).
restaurant(kfc, peradeniya).
restaurant(dominos, katugastota).
restaurant(cafe_amazon, kundasale).


% =========================================================
% 3. CUSTOMERS
% =========================================================

customer(alice, pilimathalawa).
customer(bob, digana).
customer(charlie, gampola).
customer(david, matale).


% =========================================================
% 4. BLOCKED ROADS
% =========================================================

blocked(kandy, kundasale).


% =========================================================
% 5. BIDIRECTIONAL ROAD
% =========================================================

connected(X, Y, D) :-
    road(X, Y, D).

connected(X, Y, D) :-
    road(Y, X, D).


% =========================================================
% 6. AVAILABLE ROAD
% =========================================================

road_available(X, Y, D) :-
    connected(X, Y, D),
    \+ blocked(X, Y),
    \+ blocked(Y, X).


% =========================================================
% 7. DFS
% =========================================================

dfs(Start, Goal, Path, Cost) :-
    dfs_search(Start, Goal, [Start], ReversePath, Cost),
    reverse(ReversePath, Path).


dfs_search(Goal, Goal, _, [Goal], 0).

dfs_search(Current, Goal, Visited, [Current|Path], Cost) :-

    road_available(Current, Next, Distance),

    \+ member(Next, Visited),

    dfs_search(
        Next,
        Goal,
        [Next|Visited],
        Path,
        RemainingCost
    ),

    Cost is Distance + RemainingCost.


% =========================================================
% 8. BFS
% =========================================================

bfs(Start, Goal, Path, Cost) :-

    bfs_queue(
        [[Start]],
        Goal,
        ReversePath
    ),

    reverse(ReversePath, Path),

    calculate_cost(Path, Cost).


bfs_queue([[Goal|Rest]|_], Goal, [Goal|Rest]).

bfs_queue([CurrentPath|OtherPaths], Goal, Result) :-

    CurrentPath = [Current|_],

    findall(
        [Next|CurrentPath],
        (
            road_available(Current, Next, _),
            \+ member(Next, CurrentPath)
        ),
        NewPaths
    ),

    append(
        OtherPaths,
        NewPaths,
        NewQueue
    ),

    bfs_queue(
        NewQueue,
        Goal,
        Result
    ).


% =========================================================
% 9. CALCULATE PATH COST
% =========================================================

calculate_cost([_], 0).

calculate_cost([A,B|Rest], Cost) :-

    road_available(A, B, Distance),

    calculate_cost(
        [B|Rest],
        RemainingCost
    ),

    Cost is Distance + RemainingCost.


% =========================================================
% 10. A* HEURISTIC
% =========================================================

% heuristic(Location, Goal, EstimatedDistance)

heuristic(kandy, gampola, 20).
heuristic(peradeniya, gampola, 15).
heuristic(katugastota, gampola, 25).
heuristic(kundasale, gampola, 30).

heuristic(pilimathalawa, gampola, 10).
heuristic(gelioya, gampola, 12).
heuristic(kadugannawa, gampola, 8).

heuristic(mawilmada, gampola, 30).
heuristic(matale, gampola, 35).

heuristic(digana, gampola, 35).
heuristic(teldeniya, gampola, 40).

heuristic(gampola, gampola, 0).


% =========================================================
% 11. A* SEARCH
% =========================================================

astar(Start, Goal, Path, Cost) :-

    heuristic(Start, Goal, H),

    astar_search(
        [node(Start, [Start], 0, H)],
        Goal,
        ReversePath,
        Cost
    ),

    reverse(ReversePath, Path).


astar_search(
    OpenList,
    Goal,
    Path,
    Cost
) :-

    sort_nodes(OpenList, [node(Goal, Path, Cost, _)|_]),

    !.


astar_search(
    OpenList,
    Goal,
    Path,
    Cost
) :-

    sort_nodes(
        OpenList,
        [
            node(Current, CurrentPath, CurrentCost, _)
            |Rest
        ]
    ),

    findall(
        node(
            Next,
            [Next|CurrentPath],
            NewCost,
            F
        ),

        (
            road_available(
                Current,
                Next,
                Distance
            ),

            \+ member(Next, CurrentPath),

            NewCost is CurrentCost + Distance,

            heuristic(
                Next,
                Goal,
                H
            ),

            F is NewCost + H
        ),

        Children
    ),

    append(
        Rest,
        Children,
        NewOpenList
    ),

    astar_search(
        NewOpenList,
        Goal,
        Path,
        Cost
    ).


% =========================================================
% 12. SORT A* NODES BY F VALUE
% =========================================================

sort_nodes(Nodes, Sorted) :-
    predsort(compare_nodes, Nodes, Sorted).


compare_nodes(
    <,
    node(_,_,_,F1),
    node(_,_,_,F2)
) :-
    F1 < F2.

compare_nodes(
    >,
    node(_,_,_,F1),
    node(_,_,_,F2)
) :-
    F1 > F2.

compare_nodes(
    =,
    node(_,_,_,F),
    node(_,_,_,F)
).


% =========================================================
% 13. COUNT LOCATIONS IN PATH
% =========================================================

path_length(Path, Length) :-
    length(Path, Length).


% =========================================================
% 14. DISPLAY DFS RESULT
% =========================================================

show_dfs(Start, Goal) :-

    dfs(Start, Goal, Path, Cost),

    path_length(Path, Nodes),

    write('===== DFS ====='), nl,
    write('Start: '),
    write(Start),
    nl,

    write('Goal: '),
    write(Goal),
    nl,

    write('Path: '),
    write(Path),
    nl,

    write('Cost: '),
    write(Cost),
    write(' km'),
    nl,

    write('Locations visited in path: '),
    write(Nodes),
    nl.


% =========================================================
% 15. DISPLAY BFS RESULT
% =========================================================

show_bfs(Start, Goal) :-

    bfs(Start, Goal, Path, Cost),

    path_length(Path, Nodes),

    write('===== BFS ====='), nl,
    write('Start: '),
    write(Start),
    nl,

    write('Goal: '),
    write(Goal),
    nl,

    write('Path: '),
    write(Path),
    nl,

    write('Cost: '),
    write(Cost),
    write(' km'),
    nl,

    write('Locations visited in path: '),
    write(Nodes),
    nl.


% =========================================================
% 16. DISPLAY A* RESULT
% =========================================================

show_astar(Start, Goal) :-

    astar(Start, Goal, Path, Cost),

    path_length(Path, Nodes),

    write('===== A* ====='), nl,
    write('Start: '),
    write(Start),
    nl,

    write('Goal: '),
    write(Goal),
    nl,

    write('Path: '),
    write(Path),
    nl,

    write('Cost: '),
    write(Cost),
    write(' km'),
    nl,

    write('Locations visited in path: '),
    write(Nodes),
    nl.


% =========================================================
% 17. COMPARE ALL ALGORITHMS
% =========================================================

compare_algorithms(Start, Goal) :-

    write('======================================'), nl,
    write(' ROUTE FINDING ALGORITHM COMPARISON'), nl,
    write('======================================'), nl,
    nl,

    % DFS
    dfs(Start, Goal, DFSPath, DFSCost),

    write('DFS'), nl,
    write('Path: '),
    write(DFSPath),
    nl,

    write('Cost: '),
    write(DFSCost),
    write(' km'),
    nl,
    nl,

    % BFS
    bfs(Start, Goal, BFSPath, BFSCost),

    write('BFS'), nl,
    write('Path: '),
    write(BFSPath),
    nl,

    write('Cost: '),
    write(BFSCost),
    write(' km'),
    nl,
    nl,

    % A*
    astar(Start, Goal, AStarPath, AStarCost),

    write('A*'), nl,
    write('Path: '),
    write(AStarPath),
    nl,

    write('Cost: '),
    write(AStarCost),
    write(' km'),
    nl,
    nl,

    write('======================================'), nl.