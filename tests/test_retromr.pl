/*  tests/test_retromr.pl

    Run from the repository folder:
        swipl -g run_tests -t halt tests/test_retromr.pl
*/

:- use_module(library(plunit)).
:- use_module('../face_model').
:- use_module('../paint').

:- begin_tests(face_model).

test(upright_face) :-
    face_model(_{eyeL:[100, 100], eyeR:[200, 100], mouth:[150, 190]}, M),
    abs(M.roll) < 1.0e-9,
    abs(M.eyeDist - 100) < 1.0e-9,
    abs(M.mouthW - 90) < 1.0e-9,          % no width given: 0.9 x eye distance
    abs(M.maxOpen - 27) < 1.0e-9,
    M.jaw.cy > 190,                        % the jaw hangs below the mouth
    M.pivot = [_, PY], PY > M.jaw.cy.

test(tilted_face) :-
    face_model(_{eyeL:[100, 100], eyeR:[200, 150], mouth:[130, 220], mouthW:80}, M),
    M.roll > 0.4,
    M.down = [DX, _], DX < 0,              % "down the face" leans left when the head tilts right
    abs(M.mouthW - 80) < 1.0e-9.

test(silly_width_is_corrected) :-
    face_model(_{eyeL:[0, 0], eyeR:[100, 0], mouth:[50, 90], mouthW:5}, M),
    abs(M.mouthW - 90) < 1.0e-9.

test(chin_used) :-
    face_model(_{eyeL:[0, 0], eyeR:[100, 0], mouth:[50, 90], chin:[50, 200]}, M),
    M.jaw.ry > 60.

test(default_landmarks) :-
    default_landmarks(400, 500, L),
    face_model(L, M),
    M.eyeDist > 0.

:- end_tests(face_model).

%   The paint examples from specs/retromr_spec.pl.
:- begin_tests(paint).

test(up) :-
    move_mouse(up, [[' ',' ',' '],[' ','*',' '],[' ',' ',' ']], S),
    S == [[' ','*',' '],[' ',' ',' '],[' ',' ',' ']].
test(down) :-
    move_mouse(down, [[' ',' ',' '],[' ','*',' '],[' ',' ',' ']], S),
    S == [[' ',' ',' '],[' ',' ',' '],[' ','*',' ']].
test(left) :-                         % the spec's "left" grid is garbled; this is the intended move
    move_mouse(left, [[' ',' ',' '],[' ','*',' '],[' ',' ',' ']], S),
    S == [[' ',' ',' '],['*',' ',' '],[' ',' ',' ']].
test(right) :-
    move_mouse(right, [[' ',' ',' '],[' ','*',' '],[' ',' ',' ']], S),
    S == [[' ',' ',' '],[' ',' ','*'],[' ',' ',' ']].
test(edge_stops) :-
    move_mouse(left, [[' ',' ',' '],['*',' ',' '],[' ',' ',' ']], S),
    S == [[' ',' ',' '],['*',' ',' '],[' ',' ',' ']].

test(paint_centre) :-
    paint_point([[' ',' ',' '],[' ','*',' '],[' ',' ',' ']], S),
    S == [[' ',' ',' '],[' ','\u2022',' '],[' ',' ',' ']].
test(paint_corner) :-
    paint_point([['*',' ',' '],[' ',' ',' '],[' ',' ',' ']], S),
    S == [['\u2022',' ',' '],[' ',' ',' '],[' ',' ',' ']].

test(line_across) :-
    draw_line([[' ',' ',' '],['*',' ','*'],[' ',' ',' ']], S),
    S == [[' ',' ',' '],['\u2022','\u2022','\u2022'],[' ',' ',' ']].
test(line_down) :-                    % the spec expects a blank screen here, which looks like a slip
    draw_line([[' ','*',' '],[' ',' ',' '],[' ','*',' ']], S),
    S == [[' ','\u2022',' '],[' ','\u2022',' '],[' ','\u2022',' ']].
test(line_diagonal) :-
    draw_line([[' ',' ','*'],[' ',' ',' '],['*',' ',' ']], S),
    S == [[' ',' ','\u2022'],[' ','\u2022',' '],['\u2022',' ',' ']].

test(delete_point) :-
    delete_point([[' ',' ',' '],['*',' ',' '],[' ',' ',' ']], S),
    S == [[' ',' ',' '],[' ',' ',' '],[' ',' ',' ']].
test(delete_screen) :-
    delete_screen([[' ',' ','*'],[' ','\u2022',' '],['*','\u2022',' ']], S),
    S == [[' ',' ',' '],[' ',' ',' '],[' ',' ',' ']].

:- end_tests(paint).
