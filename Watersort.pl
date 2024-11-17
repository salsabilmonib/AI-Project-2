:- include('KB.pl').

% Initial state (from KB.pl)
bottle(1, C1, C2, s0) :- bottle1(C1, C2).
bottle(2, C1, C2, s0) :- bottle2(C1, C2).
bottle(3, C1, C2, s0) :- bottle3(C1, C2).

% Successor-state axiom for the destination bottle
bottle(B1, C1New, C2New, result(pour(B2, B1), S)) :-
    % Check that the current bottle is the destination bottle
    bottle(B1, C1Dest, C2Dest, S), % State of the destination bottle in the previous situation
    bottle(B2, C1Src, C2Src, S),   % State of the source bottle in the previous situation

    % Ensure the source bottle is not empty
    (C1Src \= e ; C2Src \= e),

    % Determine the color being poured
    (C1Src \= e -> PouredColor = C1Src ; PouredColor = C2Src),

    % Update the destination bottle
    (C1Dest = e, C2Dest = e -> (C1New = e, C2New = PouredColor); % Completely empty destination
     C1Dest = e, C2Dest = PouredColor -> (C1New = PouredColor, C2New = C2Dest)).

% Successor-state axiom for the source bottle
bottle(B2, C1New, C2New, result(pour(B2, B1), S)) :-
    % Check that the current bottle is the source bottle
    bottle(B2, C1Src, C2Src, S), % State of the source bottle in the previous situation

    % Ensure the source bottle is not empty
    (C1Src \= e ; C2Src \= e),

    % Update the source bottle
    (C1Src \= e -> (C1New = e, C2New = C2Src); % Top layer is removed
     C1New = e, C2New = e).                    % Bottom layer is removed

% Unchanged bottles remain the same
bottle(B, C1, C2, result(pour(B2, B1), S)) :-
    % If the current bottle is not involved in the action
    bottle(B, C1, C2, S), 
    B \= B1, % Not the destination
    B \= B2. % Not the source




% Goal state: One bottle is empty, and the other two are fully filled with distinct colors
goal(S) :-
    % Ensure one bottle is empty
    (bottle(1, e, e, S), bottle(2, C2, C2, S), bottle(3, C3, C3, S), C2 \= C3);
    (bottle(2, e, e, S), bottle(1, C1, C1, S), bottle(3, C3, C3, S), C1 \= C3);
    (bottle(3, e, e, S), bottle(1, C1, C1, S), bottle(2, C2, C2, S), C1 \= C2).


depth_limited_search(Limit, Solution) :-
    call_with_depth_limit(goal(Solution), Limit, Result),
    Result \= depth_limit_exceeded.


% Iterative deepening search
iterative_deepening_search(Solution) :-
    between(1, inf, Limit),
    depth_limited_search(Solution, Limit),
    !.

% Result of applying action A in state S0 is a new state S
result(A, S0, result(A, S0)).

print_state(S) :-
    bottle(1, C1, C2, S), write('Bottle 1: '), write((C1, C2)), nl,
    bottle(2, C1, C2, S), write('Bottle 2: '), write((C1, C2)), nl,
    bottle(3, C1, C2, S), write('Bottle 3: '), write((C1, C2)), nl.

