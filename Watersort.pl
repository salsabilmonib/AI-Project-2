:- include('KBTest.pl').

bottle(1, T1, D1, s0) :- bottle1(T1, D1).
bottle(2, T2, D2, s0) :- bottle2(T2, D2).
bottle(3, T3, D3, s0) :- bottle3(T3, D3).


bottle(B, C1, C2, result(pour(B1, B2), S)) :-
    B \= B1, 
    B \= B2, 
    bottle(B, C1, C2, S). 


bottle(B2, C1New, C2New, result(pour(B1, B2), S)) :-
    bottle(B1, T, _, S),
    bottle(B2, TD, BD, S),
    ((TD == e; TD == T, BD == e) -> (TD == e -> C1New = T, C2New = BD; TD == T, BD == e -> C1New = TD, C2New = T); false).


bottle(B1, C1New, C2New, result(pour(B1, B2), S)) :-
    bottle(B1, T, B, S),
    bottle(B2, TD, BD, S),
    ((TD == e; TD == T, BD == e) -> (B == e -> C1New = e, C2New = e; C1New = B, C2New = e); false).


validatePour(pour(B1, B2), S) :-
    (B1 = 1; B1 = 2; B1 = 3),
    (B2 = 1; B2 = 2; B2 = 3),
    B1 \= B2,
    bottle(B1, T, _, S),
    T \= e,
    bottle(B2, TD, BD, S),
    (TD == e; TD == T, BD == e). 


goalCheck(S) :-
    bottle(1, T1, B1, S), (T1 == e, B1 == e ; T1 \= e, T1 == B1),
    bottle(2, T2, B2, S), (T2 == e, B2 == e ; T2 \= e, T2 == B2),
    bottle(3, T3, B3, S), (T3 == e, B3 == e ; T3 \= e, T3 == B3). 


goal(S) :-
    between(1, 10, Limit),
    dls(s0, S, Limit),
    goalCheck(S),
    !.


dls(S, SF, Limit) :-
    (goalCheck(S) -> SF = S; 
     Limit > 0,               
     validatePour(A, S),
     NewS = result(A, S),
     NewLimit is Limit - 1,
     dls(NewS, SF, NewLimit)).