/*  paint.pl - the retro paint primitives from specs/retromr_spec.pl

    A screen is a list of rows of one-character atoms:
      ' '  empty    '*'  the mouse cursor    '\u2022'  a painted point

    move_mouse(+Dir, +Screen0, -Screen)   up, down, left, right (stops at edges)
    paint_point(+Screen0, -Screen)        the cursor leaves a painted point
    draw_line(+Screen0, -Screen)          joins the two '*' marks with a line
    delete_point(+Screen0, -Screen)       removes the cursor's point
    delete_screen(+Screen0, -Screen)      clears everything
*/

:- module(paint,
          [ move_mouse/3, paint_point/2, draw_line/2,
            delete_point/2, delete_screen/2, cells/3
          ]).

dir(up, 0, -1).
dir(down, 0, 1).
dir(left, -1, 0).
dir(right, 1, 0).

%!  cells(+Screen, +Char, -Positions) is det.
cells(Screen, Ch, Ps) :-
    findall(X-Y, ( nth0(Y, Screen, Row), nth0(X, Row, Ch) ), Ps).

size(Screen, W-H) :-
    length(Screen, H),
    Screen = [R|_],
    length(R, W).

set_cell(Screen0, X-Y, Ch, Screen) :-
    nth0(Y, Screen0, Row0, RestRows),
    nth0(X, Row0, _, RestCells),
    nth0(X, Row1, Ch, RestCells),
    nth0(Y, Screen, Row1, RestRows).

move_mouse(Dir, S0, S) :-
    dir(Dir, DX, DY),
    cells(S0, '*', [X-Y|_]), !,
    size(S0, W-H),
    NX is max(0, min(W-1, X+DX)),
    NY is max(0, min(H-1, Y+DY)),
    set_cell(S0, X-Y, ' ', S1),
    set_cell(S1, NX-NY, '*', S).
move_mouse(_, S, S).

paint_point(S0, S) :-
    cells(S0, '*', Ps),
    foldl([P, A0, A]>>set_cell(A0, P, '\u2022', A), Ps, S0, S).

delete_point(S0, S) :-
    cells(S0, '*', Ps),
    foldl([P, A0, A]>>set_cell(A0, P, ' ', A), Ps, S0, S).

delete_screen(S0, S) :-
    maplist([R0, R]>>maplist([_, ' ']>>true, R0, R), S0, S).

%   Bresenham line between the first two cursor marks.
draw_line(S0, S) :-
    cells(S0, '*', [P1, P2|_]), !,
    line(P1, P2, Ps),
    foldl([P, A0, A]>>set_cell(A0, P, '\u2022', A), Ps, S0, S).
draw_line(S0, S) :- paint_point(S0, S).

line(X0-Y0, X1-Y1, Ps) :-
    DX is abs(X1-X0), DY is -abs(Y1-Y0),
    ( X0 < X1 -> SX = 1 ; SX = -1 ),
    ( Y0 < Y1 -> SY = 1 ; SY = -1 ),
    E is DX + DY,
    line_(X0, Y0, X1, Y1, DX, DY, SX, SY, E, Ps).

line_(X, Y, X, Y, _, _, _, _, _, [X-Y]) :- !.
line_(X, Y, X1, Y1, DX, DY, SX, SY, E, [X-Y|Ps]) :-
    E2 is 2*E,
    ( E2 >= DY -> E1 is E + DY, XN is X + SX ; E1 = E, XN = X ),
    ( E2 =< DX -> E3 is E1 + DX, YN is Y + SY ; E3 = E1, YN = Y ),
    line_(XN, YN, X1, Y1, DX, DY, SX, SY, E3, Ps).
