%:-dynamic test_n/1.

test_s2a(retromr) :-

	retractall(num_s2a(_)),
	assertz(num_s2a(1)),

	retractall(vars_s2a(_)),
	assertz(vars_s2a([])),

	retractall(vars_base_s2a(_)),
	assertz(vars_base_s2a('A')),

	retractall(character_breakdown_mode(_)),
	assertz(character_breakdown_mode(off)),

 test_spec_to_algorithm(retromr).
 
/*
move mouse
paint point
draw line
delete point
delete screen
*/

s2a_tests([

[1,open,
[
[[input,[['A',["up",[
[' ',' ',' '],
[' ','*',' '],
[' ',' ',' ']
]]]]],[output,[['B',[
[' ','*',' '],
[' ',' ',' '],
[' ',' ',' ']
]]]]],

[[input,[['A',["down",[
[' ',' ',' '],
[' ','*',' '],
[' ',' ',' ']
]]]]],[output,[['B',[
[' ',' ',' '],
[' ',' ',' '],
[' ','*',' ']
]]]]],

[[input,[['A',["left",[
[' ',' ',' '],
['*',' ',' '],
[' ',' ',' ']
]]]]],[output,[['B',[
[' ','*',' '],
[' ',' ',' '],
[' ',' ',' ']
]]]]],

[[input,[['A',["right",[
[' ',' ',' '],
[' ','*',' '],
[' ',' ',' ']
]]]]],[output,[['B',[
[' ',' ',' '],
[' ',' ','*'],
[' ',' ',' ']
]]]]],
,character_breakdown_mode=off,
"algorithm(In_vars,Out_var) :-\nalgorithm([[['C1','C2'],[output,[['C2','C1']]]]],[[[[1,1],[[1,2]]],[[1,2],[[1,1]]]]],In_vars,Out_var)."
],

[2,write,
[
[[input,[['A',["paint",[
[' ',' ',' '],
[' ','*',' '],
[' ',' ',' ']
]]]]],[output,[['B',[
[' ',' ',' '],
[' ','•',''],
[' ',' ',' ']
]]]]],

[[input,[['A',["paint",[
['*',' ',' '],
[' ',' ',' '],
[' ',' ',' ']
]]]]],[output,[['B',[
['•',' ',' '],
[' ','',''],
[' ',' ',' ']
]]]]],

[[input,[['A',["paint",[
[' ','*',' '],
[' ',' ',' '],
[' ',' ',' ']
]]]]],[output,[['B',[
[' ','•',' '],
[' ',' ',''],
[' ',' ',' ']
]]]]],


[3,write,
[
[[input,[['A',["draw line",[
[' ',' ',' '],
['*',' ','*'],
[' ',' ',' ']
]]]]],[output,[['B',[
[' ',' ',' '],
['•','•','•'],
[' ',' ',' ']
]]]]],

[[input,[['A',["draw line",[
[' ','*',' '],
[' ',' ',' '],
[' ','*',' ']
]]]]],[output,[['B',[
[' ',' ',' '],
[' ',' ',' '],
[' ',' ',' ']
]]]]],

[[input,[['A',["draw line",[
[' ',' ','*'],
[' ',' ',' '],
['*','• ',' ']
]]]]],[output,[['B',[
[' ',' ','•'],
[' ','•',' '],
['•',' ',' ']
]]]]],

[4,write,
[
[[input,[['A',["delete point",[
[' ',' ',' '],
['*',' ',' '],
[' ',' ',' ']
]]]]],[output,[['B',[
[' ',' ',' '],
[' ',' ',' '],
[' ',' ',' ']
]]]]],

[[input,[['A',["delete point",[
[' ',' ',' '],
[' ',' ',' '],
[' ','*',' ']
]]]]],[output,[['B',[
[' ',' ',' '],
[' ',' ',' '],
[' ',' ',' ']
]]]]],

[[input,[['A',["delete point",[
[' ',' ','*'],
[' ',' ',' '],
['*','• ',' ']
]]]]],[output,[['B',[
[' ',' ','•'],
[' ','•',' '],
['•',' ',' ']
]]]]],
,character_breakdown_mode=off,
"algorithm(In_vars,Out_var) :-\nalgorithm([[['C1','C2'],[output,[['C2','C1']]]]],[[[[1,1],[[1,2]]],[[1,2],[[1,1]]]]],In_vars,Out_var)."
],

[4,write,
[
[[input,[['A',["delete screen",[
[' ',' ',' '],
['*',' ',' '],
[' ',' ',' ']
]]]]],[output,[['B',[
[' ',' ',' '],
[' ',' ',' '],
[' ',' ',' ']
]]]]],

[[input,[['A',["delete screen",[
[' ',' ',' '],
[' ',' ',' '],
[' ','*',' ']
]]]]],[output,[['B',[
[' ',' ',' '],
[' ',' ',' '],
[' ',' ',' ']
]]]]],

[[input,[['A',["delete screen",[
[' ',' ','*'],
[' ',' ',' '],
['*','• ',' ']
]]]]],[output,[['B',[
[' ',' ',' '],
[' ',' ',' '],
[' ',' ',' ']
]]]]],
,character_breakdown_mode=off,
"algorithm(In_vars,Out_var) :-\nalgorithm([[['C1','C2'],[output,[['C2','C1']]]]],[[[[1,1],[[1,2]]],[[1,2],[[1,1]]]]],In_vars,Out_var)."
],

]).

test_spec_to_algorithm1(N) :-

	(catch(algs(Algs),_,false)->
	findall(_,(member(Alg,Algs),
	retractall(algs(Alg))),_);
	true),
	retractall(algs(_)),
	assertz(algs([])),

s2a_tests(Tests),
member([N,Predicate_name,S,
character_breakdown_mode=CBM,Alg2],
Tests),

	
	
((	%retractall(test_n(_)),
	%assertz(test_n(N)),

	string_concat(Predicate_name,N,Predicate_name1),
	%catch(call_with_time_limit(10,
	(spec_to_algorithm(Predicate_name1,S,CBM,Alg1))
	%)%,
    %time_limit_exceeded,
    %fail)

,writeln1(S)
,writeln1(Alg1)
%,trace

,string_concat(Predicate_name,Rest,Alg2),
string_concat(Predicate_name1,Rest,Alg21)
,Alg21=Alg1
)->R=success;R=fail),
 writeln([R,N,spec_to_algorithm,test]),
 
 writeln([Predicate_name1,not,Predicate_name,above]),!.

/*

Necessary to load before running s2a each time:

retractall(vars_table_s2a(_)),                                               assertz(vars_table_s2a([])),                                                    ['spec_to_algorithm'].
*/

test_spec_to_algorithm(retromr) :-
/*
	retractall(num_s2a(_)),
	assertz(num_s2a(1)),

	retractall(vars_s2a(_)),
	assertz(vars_s2a([])),

	retractall(vars_base_s2a(_)),
	assertz(vars_base_s2a('A')),
*/
	(catch(algs(Algs),_,false)->
	findall(_,(member(Alg,Algs),
	retractall(algs(Alg))),_);
	true),
	retractall(algs(_)),
	assertz(algs([])),

s2a_tests(Tests),

findall([N,R],(member([N,Predicate_name,S,
character_breakdown_mode=CBM,Alg2],
Tests),

	
	
((	%retractall(test_n(_)),
	%assertz(test_n(N)),

	string_concat(Predicate_name,N,Predicate_name1),
	%catch(call_with_time_limit(10,
	(spec_to_algorithm(Predicate_name1,S,CBM,Alg1))
	%)%,
    %time_limit_exceeded,
    %fail)

%,writeln1(S)
%,writeln1(Alg1)
%,trace

,string_concat(Predicate_name,Rest,Alg2),
string_concat(Predicate_name1,Rest,Alg21)
,Alg21=Alg1
)->R=success;R=fail),
 writeln([R,N,spec_to_algorithm,test]),
 nl),R1),
 findall(N,member([N,success],R1),R_success),
 writeln("Successful Tests:"),
 writeln(R_success),
 findall(N,member([N,fail],R1),R_fail),
 writeln("Failed Tests:"),
 writeln(R_fail),!.


