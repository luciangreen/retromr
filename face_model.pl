/*  face_model.pl - turn a few face landmarks into an animation model

    Input (from the browser, in image pixels):
      eyeL, eyeR, mouth  : [X, Y]
      mouthW             : mouth width            (optional)
      chin               : [X, Y]                 (optional)

    Output: the geometry retromr animates
      roll               head tilt in radians (eye line angle)
      eyeDist            distance between the eyes
      eyes               [[X,Y],[X,Y]] eye centres
      eyeRX, eyeRY       eyelid ellipse radii
      mouth              [X, Y]
      mouthW             mouth width (sanity-checked against the eyes)
      jaw                {cx, cy, rx, ry}: the moving lower face, an ellipse
                         from the lip line down past the chin
      maxOpen            how far the jaw may drop, in pixels
      down               [DX, DY] unit vector "down the face"
      pivot              [X, Y] neck point the head sways around
*/

:- module(face_model, [face_model/2, default_landmarks/3]).

face_model(L, M) :-
    point(L, eyeL, EL),
    point(L, eyeR, ER),
    point(L, mouth, Mo),
    EL = [LX, LY], ER = [RX, RY], Mo = [MX, MY],
    EyeDist0 is sqrt((RX-LX)**2 + (RY-LY)**2),
    EyeDist is max(EyeDist0, 4),
    Roll is atan2(RY-LY, RX-LX),
    DX is -sin(Roll), DY is cos(Roll),               % unit vector down the face
    (   get_dict(mouthW, L, W0), number(W0), W0 > 0.45*EyeDist, W0 < 1.6*EyeDist
    ->  MW = W0
    ;   MW is 0.9*EyeDist
    ),
    (   get_dict(chin, L, [CX0, CY0]), number(CX0), number(CY0),
        ChinD is (CX0-MX)*DX + (CY0-MY)*DY, ChinD > 0.3*EyeDist, ChinD < 2.0*EyeDist
    ->  ChinDist = ChinD
    ;   ChinDist is 0.8*EyeDist
    ),
    %   jaw ellipse: from just above the lip line to a little below the chin
    Top is -0.08*MW,
    Bottom is ChinDist + 0.18*EyeDist,
    Mid is (Top + Bottom) / 2,
    JCX is MX + DX*Mid, JCY is MY + DY*Mid,
    JRY is (Bottom - Top) / 2,
    JRX is 0.95*MW,
    MaxOpen is 0.30*MW,
    PX is MX + DX*(ChinDist + 0.5*EyeDist),
    PY is MY + DY*(ChinDist + 0.5*EyeDist),
    ERX is 0.24*EyeDist, ERY is 0.13*EyeDist,
    M = _{ roll:Roll, eyeDist:EyeDist, eyes:[EL, ER],
           eyeRX:ERX, eyeRY:ERY, mouth:Mo, mouthW:MW,
           jaw:_{cx:JCX, cy:JCY, rx:JRX, ry:JRY},
           maxOpen:MaxOpen, down:[DX, DY], pivot:[PX, PY] }.

point(L, K, [X, Y]) :-
    get_dict(K, L, [X0, Y0]),
    X is float(X0), Y is float(Y0).

%!  default_landmarks(+Width, +Height, -Landmarks) is det.
%   A guess for a centred portrait photo, used when nothing better is known.
default_landmarks(W, H, _{eyeL:[LX, EY], eyeR:[RX, EY], mouth:[MX, MY], mouthW:MW}) :-
    S is min(W, H*0.8),
    MX is W/2,
    LX is MX - 0.17*S, RX is MX + 0.17*S,
    EY is H*0.42,
    MY is H*0.42 + 0.36*S,
    MW is 0.3*S.
