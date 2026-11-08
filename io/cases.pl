% The predicates whose inputs and outputs are recorded in io/ios.txt (see io/ios_engine.pl).
:- ios_engine:load_repo(face_model).
:- ios_engine:load_repo(paint).

io_title('retromr').

io_cases([move_mouse, paint_point, draw_line, delete_point, delete_screen, face_model, default_landmarks]).

% a W x H screen with '*' at the given cells (and some painted dots for delete_screen)
screen(W, H, Stars, Dots, Rows) :-
    numlist(1, H, Ys), numlist(1, W, Xs),
    maplist([Y, Row]>>maplist([X, C]>>( memberchk(X-Y, Stars) -> C = '*' ; memberchk(X-Y, Dots) -> C = '•' ; C = ' ' ), Xs, Row), Ys, Rows).
cell(K, Salt, W, H, X-Y) :- num(K, Salt, 1, W, X), num(K, Salt + 1, 1, H, Y).
size(K, W, H) :- num(K, 10, 3, 5, W), num(K, 11, 3, 4, H).

io_input(move_mouse, K, [Dir, S]) :- pick(K, 1, [up, down, left, right], Dir), size(K, W, H), cell(K, 2, W, H, C), screen(W, H, [C], [], S).
io_input(paint_point, K, [S]) :- size(K, W, H), cell(K, 3, W, H, C), screen(W, H, [C], [], S).
io_input(draw_line, K, [S]) :- size(K, W, H), cell(K, 4, W, H, A), cell(K, 6, W, H, B), screen(W, H, [A, B], [], S).
io_input(delete_point, K, [S]) :- size(K, W, H), cell(K, 7, W, H, C), cell(K, 8, W, H, D), screen(W, H, [C], [D], S).
io_input(delete_screen, K, [S]) :- size(K, W, H), cell(K, 9, W, H, C), cell(K, 12, W, H, D), screen(W, H, [C], [D], S).
io_input(face_model, K, [L]) :-
    num(K, 13, 60, 140, LX), num(K, 14, 80, 120, LY), num(K, 15, 60, 140, D), num(K, 16, -40, 40, Tilt), num(K, 17, 70, 110, Down),
    RX is LX + D, RY is LY + Tilt, MX is (LX + RX) // 2, MY is (LY + RY) // 2 + Down,
    L0 = _{eyeL:[LX, LY], eyeR:[RX, RY], mouth:[MX, MY]},
    pick(K, 18, [none, 5, 60, 80], W), pick(K, 19, [none, none, chin], Chin),
    ( W == none -> L1 = L0 ; L1 = L0.put(mouthW, W) ),
    ( Chin == none -> L = L1 ; CY is MY + 90, L = L1.put(chin, [MX, CY]) ).
io_input(default_landmarks, K, [W, H]) :- num(K, 20, 200, 800, W), num(K, 21, 300, 900, H).

io_run(move_mouse, [Dir, S], S1) :- move_mouse(Dir, S, S1).
io_run(paint_point, [S], S1) :- paint_point(S, S1).
io_run(draw_line, [S], S1) :- draw_line(S, S1).
io_run(delete_point, [S], S1) :- delete_point(S, S1).
io_run(delete_screen, [S], S1) :- delete_screen(S, S1).
% the face model, numbers rounded to 4 places
io_run(face_model, [L], M) :- face_model(L, M0), rounded(M0, M).
io_run(default_landmarks, [W, H], L) :- default_landmarks(W, H, L0), rounded(L0, L).

rounded(X, Y) :- float(X), !, Y is round(X * 10000) / 10000.
rounded(X, Y) :- is_dict(X), !, dict_pairs(X, T, Ps), maplist([K-V, K-W]>>rounded(V, W), Ps, Qs), dict_pairs(Y, T, Qs).
rounded(X, Y) :- is_list(X), !, maplist(rounded, X, Y).
rounded(X, X).
