:- include('KB.pl').

% Initial state (from KBTest.pl)
bottle(1, T1, D1, s0) :- bottle1(T1, D1).
bottle(2, T2, D2, s0) :- bottle2(T2, D2).
bottle(3, T3, D3, s0) :- bottle3(T3, D3).

% Unchanged bottle
bottle(B, C1, C2, result(pour(B1, B2), S)) :-
    B \= B1, 
    B \= B2, 
    bottle(B, C1, C2, S).

% Destination bottle
bottle(B2, C1New, C2New, result(pour(B1, B2), S)) :-
    bottle(B1, T, B, S),
    bottle(B2, TD, BD, S),
    (T \= e -> PouredColor = T; PouredColor = B),
    ((TD == e, BD == PouredColor; TD == e, BD == e) -> 
        (BD == e -> C1New = PouredColor, C2New = PouredColor; 
         BD == PouredColor, TD == e -> C1New = PouredColor, C2New = BD); 
    false).

% Source bottle
bottle(B1, C1New, C2New, result(pour(B1, B2), S)) :-
    bottle(B1, T, B, S),
    bottle(B2, TD, BD, S),
    (T \= e -> PouredColor = T; PouredColor = B),
    ((TD == e, BD == PouredColor; TD == e, BD == e) -> 
        (T == e -> C1New = e, C2New = e; 
         C1New = e, C2New = B); 
    false).

% Validate a pouring action
validatePour(pour(B1, B2), S) :-
    (B1 = 1; B1 = 2; B1 = 3),
    (B2 = 1; B2 = 2; B2 = 3),
    B1 \= B2,
    bottle(B1, T, B, S),
    (T \= e; B \= e),
    (T \= e -> PouredColor = T; PouredColor = B),
    bottle(B2, TD, BD, S),
    ((TD == e, BD == e) ; (TD == e, BD == PouredColor)).

% Debugging: Display the state of all bottles
debugState(S) :-
    bottle(1, T1, B1, S),
    bottle(2, T2, B2, S),
    bottle(3, T3, B3, S),
    format('bottle1(~w, ~w), bottle2(~w, ~w), bottle3(~w, ~w)~n',
           [T1, B1, T2, B2, T3, B3]).

% Check if the goal state is achieved
goalCheck(S) :-
    bottle(1, T1, B1, S), (T1 == e, B1 == e ; T1 \= e, T1 == B1),
    bottle(2, T2, B2, S), (T2 == e, B2 == e ; T2 \= e, T2 == B2),
    bottle(3, T3, B3, S), (T3 == e, B3 == e ; T3 \= e, T3 == B3).

% Search for a goal state within a depth limit
goal(S) :-
    between(1, 10, Limit),
    dls(s0, S, Limit, []), % Pass an empty list as the visited states
    goalCheck(S),
    !.

% Depth-limited search with state tracking
dls(S, SF, Limit, Visited) :-
    \+ member(S, Visited),  % Avoid revisiting states
    debugState(S),          % Debug: Show the state at each step
    (goalCheck(S) -> SF = S; 
     Limit > 0,               
     validatePour(A, S),
     NewS = result(A, S),
     NewLimit is Limit - 1,
     dls(NewS, SF, NewLimit, [S|Visited])). % Add the current state to the visited list
