/*  retromr.pl - web server for retromr, the talking photo

    Start:   swipl retromr.pl
    Use:     http://localhost:8082

    retromr talks through newos:
      * if the newos repository is next to this one (../newos), its
        engine is loaded directly and shares newos's memory;
      * otherwise it calls a running newos server at NEWOS_URL
        (default http://localhost:8081/api/chat).
    The speech module is newos's web/tts.js (a copy is bundled here
    for when newos is not alongside).

    API
      GET  /api/face        the saved photo, landmarks and animation model
      POST /api/face        {image: dataURL, landmarks, width, height}
      POST /api/face/clear  forget the photo (the close box)
      POST /api/model       {landmarks}  -> animation model only
      POST /api/chat        {text} -> {reply, speak}
*/

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_client)).

:- use_module(face_model).

:- dynamic app_dir/1, newos_mode/1, face/4.

:- prolog_load_context(directory, Dir),
   retractall(app_dir(_)),
   asserta(app_dir(Dir)).

:- multifile user:file_search_path/2.
user:file_search_path(retromr_web, Dir) :-
    app_dir(App),
    directory_file_path(App, web, Dir).

:- http_handler(root(.),              http_reply_file(retromr_web('index.html'), []), []).
:- http_handler(root(static), serve_static, [prefix]).
:- http_handler(root(newos/'tts.js'), serve_tts, []).
:- http_handler(root(api/face),       api_face, [methods([get, post])]).
:- http_handler(root(api/face/clear), api_face_clear, [method(post)]).
:- http_handler(root(api/model),      api_model, [method(post)]).
:- http_handler(root(api/chat),       api_chat, [method(post)]).

server :-
    (   getenv('PORT', P), atom_number(P, Port) -> true ; Port = 8082 ),
    server(Port).

server(Port) :-
    load_newos,
    load_face,
    http_server(http_dispatch, [port(Port)]),
    newos_mode(Mode),
    format("~nretromr is running at http://localhost:~w  (newos: ~w)~n~n", [Port, Mode]).

%   ---- newos ---------------------------------------------------------------

newos_dir(D) :-
    (   getenv('NEWOS_DIR', D0) -> true
    ;   app_dir(A), directory_file_path(A, '../newos', D0)
    ),
    absolute_file_name(D0, D).

load_newos :-
    retractall(newos_mode(_)),
    newos_dir(D),
    directory_file_path(D, 'nl_engine.pl', F),
    exists_file(F),
    catch(( use_module(F), nl_engine:nl_init ), E,
          ( print_message(warning, E), fail )), !,
    assertz(newos_mode(local)).
load_newos :-
    assertz(newos_mode(http)).

newos_url(U) :-
    (   getenv('NEWOS_URL', U0) -> U = U0 ; U = 'http://localhost:8081/api/chat' ).

newos_chat(Text, Reply, Speak) :-
    newos_mode(local), !,
    nl_engine:chat(Text, Reply, Info),
    get_dict(speak, Info, Speak).
newos_chat(Text, Reply, Speak) :-
    newos_url(U),
    catch(http_post(U, json(_{text:Text}), Out, [json_object(dict), timeout(20)]), _, fail),
    is_dict(Out),
    get_dict(reply, Out, Reply), !,
    (   get_dict(speak, Out, Speak) -> true ; Speak = Reply ).
newos_chat(_, Reply, Reply) :-
    Reply = "I can't reach newos right now. Start it with swipl newos.pl, and I'll be able to talk.".

serve_tts(Request) :-
    newos_dir(D),
    directory_file_path(D, 'web/tts.js', F),
    (   exists_file(F)
    ->  File = F
    ;   app_dir(A), directory_file_path(A, 'web/tts.js', File)
    ),
    http_reply_file(File, [unsafe(true)], Request).

%   ---- the face ----------------------------------------------------------------

face_file(F) :- app_dir(A), directory_file_path(A, 'data/face.pl', F).

load_face :-
    retractall(face(_, _, _, _)),
    face_file(F),
    (   exists_file(F)
    ->  catch(setup_call_cleanup(open(F, read, In),
                                 ( read_term(In, T, []),
                                   ( T = face(I, L, W, H), string(I) -> assertz(face(I, L, W, H)) ; true ) ),
                                 close(In)), _, true)
    ;   true
    ).

save_face :-
    face_file(F),
    file_directory_name(F, Dir), make_directory_path(Dir),
    (   face(I, L, W, H)
    ->  setup_call_cleanup(open(F, write, Out),
                           ( writeq(Out, face(I, L, W, H)), write(Out, '.'), nl(Out) ),
                           close(Out))
    ;   ( exists_file(F) -> delete_file(F) ; true )
    ).

api_face(Request) :-
    memberchk(method(get), Request), !,
    (   face(I, LS, W, H)
    ->  atom_json_dict(LS, L, []),
        model_for(L, M),
        reply_json_dict(_{image:I, landmarks:L, model:M, width:W, height:H})
    ;   reply_json_dict(_{image:null})
    ).
api_face(Request) :-
    http_read_json_dict(Request, In),
    get_dict(image, In, I0), atom_string(I0, I),
    sub_string(I, 0, 11, _, "data:image/"),
    get_dict(landmarks, In, L),
    ( get_dict(width, In, W) -> true ; W = 0 ),
    ( get_dict(height, In, H) -> true ; H = 0 ),
    atom_json_dict(LS, L, [as(string)]),
    retractall(face(_, _, _, _)),
    assertz(face(I, LS, W, H)),
    save_face,
    model_for(L, M),
    reply_json_dict(_{ok:true, model:M}).

api_face_clear(_) :-
    retractall(face(_, _, _, _)),
    save_face,
    reply_json_dict(_{ok:true}).

api_model(Request) :-
    http_read_json_dict(Request, In),
    get_dict(landmarks, In, L),
    model_for(L, M),
    reply_json_dict(_{model:M}).

model_for(L, M) :-
    (   catch(face_model(L, M0), _, fail) -> M = M0 ; M = null ).

%   ---- talking ----------------------------------------------------------------

api_chat(Request) :-
    http_read_json_dict(Request, In),
    (   get_dict(text, In, T0) -> atom_string(T0, Text) ; Text = "" ),
    newos_chat(Text, Reply, Speak),
    reply_json_dict(_{reply:Reply, speak:Speak}).

serve_static(Request) :-
    (   memberchk(path_info(P0), Request) -> true ; P0 = '' ),
    (   atom_concat('/', P, P0) -> true ; P = P0 ),
    \+ sub_atom(P, _, _, _, '..'),
    app_dir(A),
    atomic_list_concat([A, '/web/', P], F),
    exists_file(F), !,
    http_reply_file(F, [unsafe(true)], Request).
serve_static(Request) :-
    http_404([], Request).

:- initialization(server).
