% FLP 2019/2020
% Logicky projekt
% Rubikova kocka
% Author: Andrej Nano (xnanoa00)

% ------------------- INPUT PARSING -------------------

/** cte radky ze standardniho vstupu, konci na LF nebo EOF */
read_line(L,C) :-
	get_char(C),
	(isEOFEOL(C), L = [], !;
		read_line(LL,_),% atom_codes(C,[Cd]),
		[C|LL] = L).

/** testuje znak na EOF nebo LF */
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).

read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
	  read_lines(LLs), Ls = [L|LLs]
	).


/** rozdeli radek na podseznamy */
split_line([],[[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T,S1).
split_line([32|T], [[]|S1]) :- !, split_line(T,S1).    % aby to fungovalo i s retezcem na miste seznamu
split_line([H|T], [[H|G]|S1]) :- split_line(T,[G|S1]). % G je prvni seznam ze seznamu seznamu G|S1

/** vstupem je seznam radku (kazdy radek je seznam znaku) */
split_lines([],[]).
split_lines([L|Ls],[H|T]) :- split_lines(Ls,T), split_line(L,H).


% ------------------- Rubik's cube parsing and internal representation -------------------

% parse cube into internal representation as individual cubeletes /2
parse_cubeletes(
  [
    [[U18, U19, U20]],  % -- Layer 1
    [[U10, U11, U12]],  % -- Layer 2
    [[ U1,  U2,  U3]],  % -- Layer 3 ...

    [[ F1,  F2,  F3],   [ R3, R12, R20],  [B20, B19, B18],  [L18, L10,  L1]],
    [[ F4,  F5,  F6],   [ R6, R14, R23],  [B23, B22, B21],  [L21, L13,  L4]],
    [[ F7,  F8,  F9],   [ R9, R17, R26],  [B26, B25, B24],  [L24, L15,  L7]],

    [[ D7,  D8,  D9]],
    [[D15, D16, D17]],
    [[D24, D25, D26]]
  ],
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ]
).

% convert between internal cubeletes representation into the readable flat format /2
cubeletes_to_print_format(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    [U18, U19, U20],
    [U10, U11, U12],
    [U1, U2, U3],
    [[F1, F2, F3], [R3, R12, R20], [B20, B19, B18], [L18, L10, L1]],
    [[F4, F5, F6], [R6, R14, R23], [B23, B22, B21], [L21, L13, L4]],
    [[F7, F8, F9], [R9, R17, R26], [B26, B25, B24], [L24, L15, L7]],
    [D7,  D8, D9],
    [D15, D16, D17],
    [D24, D25, D26]
  ]
).


% print numbers in a list as a sequence without any whitespace or other symbols /2
print_row([]).
print_row([Tile | Rest]) :- write(Tile), print_row(Rest).

% print whole cube /1
print_cube([U1, U2, U3, [F1, R1, B1, L1], [F2, R2, B2, L2], [F3, R3, B3, L3], D1, D2, D3]) :-
  print_row(U1), nl,
  print_row(U2), nl,
  print_row(U3), nl,
  print_row(F1), write(' '), print_row(R1), write(' '), print_row(B1), write(' '), print_row(L1), nl,
  print_row(F2), write(' '), print_row(R2), write(' '), print_row(B2), write(' '), print_row(L2), nl,
  print_row(F3), write(' '), print_row(R3), write(' '), print_row(B3), write(' '), print_row(L3), nl,
  print_row(D1), nl,
  print_row(D2), nl,
  print_row(D3), nl.


% ------ TYPES OF MOVEMENT (ROTATIONS) ----

% Right Face Rotation (Clockwise) /2
rf_ror(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [3, 6, 9, 12, 14, 17, 20, 23, 26]
    [U1, F1, L1],
    [U2, F2],
    [F9, D9, R9], % *
    [F4, L4],
    [F5],
    [D17, R17], % *
    [F7, L7, D7],
    [F8, D8],
    [D26, R26, B26], % *
    [U10, L10],
    [U11],
    [F6, R6], % *
    [L13],
    [R14], % * [stays fixed]
    [L15, D15],
    [D16],
    [R23, B23], % *
    [U18, B18, L18],
    [U19, B19],
    [F3, R3, U3], % *
    [B21, L21],
    [B22],
    [R12, U12], % *
    [B24, L24, D24],
    [B25, D25],
    [R20, U20, B20] % *
  ]
).

% Right Face Reverse Rotation (Anticlockwise) /2
rf_rol(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [3, 6, 9, 12, 14, 17, 20, 23, 26]
    [U1, F1, L1],
    [U2, F2],
    [B20, U20, R20],
    [F4, L4],
    [F5], % F center
    [U12, R12],
    [F7, L7, D7],
    [F8, D8],
    [U3, R3, F3],
    [U10, L10],
    [U11], % U center
    [B23, R23],
    [L13], % L center
    [R14], % R center (stays fixed)
    [L15, D15],
    [D16], % D center
    [R6, F6],
    [U18, B18, L18],
    [U19, B19],
    [B26, R26, D26],
    [B21, L21],
    [B22], % B center
    [R17, D17],
    [B24, L24, D24],
    [B25, D25],
    [R9, D9, F9]
  ]
).

% Left Face Rotation (Clockwise) /2
lf_ror(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [1, 4, 7, 10, 13, 15, 18, 21, 24]
    [B18, U18, L18],
    [U2, F2],
    [U3, F3, R3],
    [U10, L10],
    [F5], % F center
    [F6, R6],
    [U1, L1, F1],
    [F8, D8],
    [F9, R9, D9],
    [B21, L21],
    [U11], % U center
    [U12, R12],
    [L13], % L center (stays fixed)
    [R14], % R center
    [L4, F4],
    [D16], % D center
    [R17, D17],
    [B24, D24, L24],
    [U19, B19],
    [U20, R20, B20],
    [D15, L15],
    [B22], % B center
    [R23, B23],
    [D7, L7, F7],
    [B25, D25],
    [R26, B26, D26]
  ]
).

% Left Face Reverse Rotation (Anticlockwise) /2
lf_rol(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [1, 4, 7, 10, 13, 15, 18, 21, 24]
    [F7, D7, L7],
    [U2, F2],
    [U3, F3, R3],
    [D15, L15],
    [F5], % F center
    [F6, R6],
    [D24, L24, B24],
    [F8, D8],
    [F9, R9, D9],
    [F4, L4],
    [U11], % U center
    [U12, R12],
    [L13], % L center (stays fixed)
    [R14], % R center
    [L21, B21],
    [D16], % D center
    [R17, D17],
    [F1, U1, L1],
    [U19, B19],
    [U20, R20, B20],
    [U10, L10],
    [B22], % B center
    [R23, B23],
    [U18, L18, B18],
    [B25, D25],
    [R26, B26, D26]
  ]
).

% Up Face Rotation (Clockwise) /2
uf_ror(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [1, 2, 3, 10, 11, 12, 18, 19, 20]
    % 1 .. 26
    [U3, R3, F3],
    [U12, R12],
    [U20, R20, B20],
    [F4, L4],
    [F5], % F center
    [F6, R6],
    [F7, L7, D7],
    [F8, D8],
    [F9, R9, D9],
    [U2, F2],
    [U11], % U center (stays fixed)
    [U19, B19],
    [L13], % L center
    [R14], % R center
    [L15, D15],
    [D16], % D center
    [R17, D17],
    [U1, L1, F1],
    [U10, L10],
    [U18, B18, L18],
    [B21, L21],
    [B22], % B center
    [R23, B23],
    [B24, L24, D24],
    [B25, D25],
    [R26, B26, D26]
  ]
).

% Up Face Reverse Rotation (Anticlockwise) /2
uf_rol(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [1, 2, 3, 10, 11, 12, 18, 19, 20]
    % 1 .. 26
    [U18, L18, B18], % *
    [U10, L10],% *
    [U1, L1, F1],% *
    [F4, L4],
    [F5],
    [F6, R6],
    [F7, L7, D7],
    [F8, D8],
    [F9, R9, D9],
    [U19, B19],% *
    [U11], % *
    [U2, F2],% *
    [L13],
    [R14],
    [L15, D15],
    [D16],
    [R17, D17],
    [U20, R20, B20],% *
    [U12, R12],% *
    [U3, F3, R3],% *
    [B21, L21],
    [B22],
    [R23, B23],
    [B24, L24, D24],
    [B25, D25],
    [R26, B26, D26]
  ]
).

% Down Face Rotation (Clockwise) /2
df_ror(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [7, 8, 9, 15, 16, 17, 24, 25, 26]
    % 1 .. 26
    [U1, F1, L1],
    [U2, F2],
    [U3, F3, R3],
    [F4, L4],
    [F5],
    [F6, R6],
    [L24, B24, D24], % *
    [L15, D15], % *
    [L7, F7, D7], % *
    [U10, L10],
    [U11],
    [U12, R12],
    [L13],
    [R14],
    [B25, D25], % *
    [D16], % * (stays fixed)
    [F8, D8], % *
    [U18, B18, L18],
    [U19, B19],
    [U20, R20, B20],
    [B21, L21],
    [B22],
    [R23, B23],
    [R26, B26, D26], % *
    [R17, D17], % *
    [F9, R9, D9] % *
  ]
).

% Down Face Reverse Rotation (Anticlockwise) /2
df_rol(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [7, 8, 9, 15, 16, 17, 24, 25, 26]
    % 1 .. 26
    [U1, F1, L1],
    [U2, F2],
    [U3, F3, R3],
    [F4, L4],
    [F5],
    [F6, R6],
    [R9, F9, D9], % *
    [R17, D17], % *
    [R26, B26, D26], % *
    [U10, L10],
    [U11],
    [U12, R12],
    [L13],
    [R14],
    [F8, D8], % *
    [D16], % * (stays fixed)
    [B25, D25], % *
    [U18, B18, L18],
    [U19, B19],
    [U20, R20, B20],
    [B21, L21],
    [B22],
    [R23, B23],
    [L7, F7, D7], % *
    [L15, D15], % *
    [B24, L24, D24] % *
  ]
).

% Front Face Rotation (Clockwise) /2
ff_ror(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [1, 2, 3, 4, 5, 6, 7, 8, 9]
    % 1 .. 26
    [L7, F7, D7], % *
    [L4, F4], % *
    [L1, F1, U1], % *
    [F8, D8], % *
    [F5], % * (stays fixed)
    [F2, U2], % *
    [F9, D9, R9], % *
    [F6, R6], % *
    [F3, U3, R3], % *
    [U10, L10],
    [U11],
    [U12, R12],
    [L13],
    [R14],
    [L15, D15],
    [D16],
    [R17, D17],
    [U18, B18, L18],
    [U19, B19],
    [U20, R20, B20],
    [B21, L21],
    [B22],
    [R23, B23],
    [B24, L24, D24],
    [B25, D25],
    [R26, B26, D26]
  ]
).

% Front Face Reverse Rotation (Anticlockwise) /2
ff_rol(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [1, 2, 3, 4, 5, 6, 7, 8, 9]
    % 1 .. 26
    [R3, F3, U3], % *
    [R6, F6], % *
    [R9, F9, D9], % *
    [F2, U2], % *
    [F5], % * (stays fixed)
    [F8, D8], % *
    [F1, U1, L1], % *
    [F4, L4], % *
    [F7, D7, L7], % *
    [U10, L10],
    [U11],
    [U12, R12],
    [L13],
    [R14],
    [L15, D15],
    [D16],
    [R17, D17],
    [U18, B18, L18],
    [U19, B19],
    [U20, R20, B20],
    [B21, L21],
    [B22],
    [R23, B23],
    [B24, L24, D24],
    [B25, D25],
    [R26, B26, D26]
  ]
).

% Back Face Rotation (Clockwise) /2
bf_ror(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [18, 19, 20, 21, 22, 23, 24, 25, 26]
    % 1 .. 26
    [U1, F1, L1],
    [U2, F2],
    [U3, F3, R3],
    [F4, L4],
    [F5],
    [F6, R6],
    [F7, L7, D7],
    [F8, D8],
    [F9, R9, D9],
    [U10, L10],
    [U11],
    [U12, R12],
    [L13],
    [R14],
    [L15, D15],
    [D16],
    [R17, D17],
    [R20, B20, U20], % *
    [R23, B23], % *
    [R26, D26, B26], % *
    [B19, U19], % *
    [B22], % * (stays fixed)
    [D25, B25], % *
    [B18, U18, L18], % *
    [B21, L21], % *
    [D24, B24, L24] % *
  ]
).

% Back Face Reverse Rotation (Anticlockwise) /2
bf_rol(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ],
  [
    % Change [18, 19, 20, 21, 22, 23, 24, 25, 26]
    % 1 .. 26
    [U1, F1, L1],
    [U2, F2],
    [U3, F3, R3],
    [F4, L4],
    [F5],
    [F6, R6],
    [F7, L7, D7],
    [F8, D8],
    [F9, R9, D9],
    [U10, L10],
    [U11],
    [U12, R12],
    [L13],
    [R14],
    [L15, D15],
    [D16],
    [R17, D17],
    [L24, B24, D24], % *
    [L21, B21], % *
    [L18, U18, B18], % *
    [B25, D25], % *
    [B22], % * (stays fixed)
    [U19, B19], % *
    [B26, D26, R26], % *
    [B23, R23], % *
    [U20, B20, R20] % *
  ]
).


% Unification of moves /2
move(CurrentState, NextState):- rf_ror(CurrentState, NextState).
move(CurrentState, NextState):- rf_rol(CurrentState, NextState).
move(CurrentState, NextState):- lf_ror(CurrentState, NextState).
move(CurrentState, NextState):- lf_rol(CurrentState, NextState).
move(CurrentState, NextState):- ff_ror(CurrentState, NextState).
move(CurrentState, NextState):- ff_rol(CurrentState, NextState).
move(CurrentState, NextState):- bf_ror(CurrentState, NextState).
move(CurrentState, NextState):- bf_rol(CurrentState, NextState).
move(CurrentState, NextState):- uf_ror(CurrentState, NextState).
move(CurrentState, NextState):- uf_rol(CurrentState, NextState).
move(CurrentState, NextState):- df_ror(CurrentState, NextState).
move(CurrentState, NextState):- df_rol(CurrentState, NextState).


% Test for equal tiles on the whole face (test all for equality)
% face_equal/1
face_equal(Face) :- maplist(=(_), Face).

% Test if cube in the current state is solved (test tiles for each face)
% solved_cube/1
solved_cube(
  [
    [U1, F1, L1],       % 1     U,F,L corner
    [U2, F2],           % 2     U,F edge
    [U3, F3, R3],       % 3     U,F,R corner
    [F4, L4],           % 4     F,L edge
    [F5],               % 5     F center
    [F6, R6],           % 6     F,R edge
    [F7, L7, D7],       % 7     F,L,D corner
    [F8, D8],           % 8     F,D edge
    [F9, R9, D9],       % 9     F,R,D corner
    [U10, L10],         % 10    U,L edge
    [U11],              % 11    U center
    [U12, R12],         % 12    U,R edge
    [L13],              % 13    L center
    [R14],              % 14    R center
    [L15, D15],         % 15    L,D edge
    [D16],              % 16    D center
    [R17, D17],         % 17    R,D edge
    [U18, B18, L18],    % 18    U,B,L corner
    [U19, B19],         % 19    U,B edge
    [U20, R20, B20],    % 20    U,R,B corner
    [B21, L21],         % 21    B,L edge
    [B22],              % 21    B center
    [R23, B23],         % 23    R,B edge
    [B24, L24, D24],    % 24    B,L,D corner
    [B25, D25],         % 25    B,D edge
    [R26, B26, D26]     % 26    R,B,D corner
  ]):-
    face_equal([ U1,  U2,  U3, U10, U11, U12, U18, U19, U20]),
    face_equal([ F1,  F2,  F3,  F4,  F5,  F6,  F7,  F8,  F9]),
    face_equal([ L1,  L4,  L7, L10, L13, L15, L18, L21, L24]),
    face_equal([ R3,  R6,  R9, R12, R14, R17, R20, R23, R26]),
    face_equal([B18, B19, B20, B21, B22, B23, B24, B25, B26]),
    face_equal([ D7,  D8,  D9, D15, D16, D17, D24, D25, D26]).

% set a search task goal (i.e. the solved state)
% goal/1
goal(CubeState) :- solved_cube(CubeState).

% Depth Limited Search
% search to a given depth limit
% search/3
search(Depth, CubeState, [CubeState]) :-
  Depth == 0,
  goal(CubeState).
search(Depth, CubeState, [CubeState | PrevStates]) :-
  Depth > 0,
  move(CubeState, NextState),
  Depth1 is Depth-1,
  search(Depth1, NextState, PrevStates).

% Iterative Deepening Search
% if solution not found, increase depth limit and repeat
% ids/3
ids(Depth, InitialCubeState, Solution) :- search(Depth, InitialCubeState, Solution).
ids(Depth, InitialCubeState, Solution) :- Depth1 is Depth+1, ids(Depth1, InitialCubeState, Solution).

% print out the sequence of states that lead to the solution (solved state)
% print_solution/1
print_solution([]).
print_solution([CubeState | PrevStates]) :-
  cubeletes_to_print_format(CubeState, PrintCube),
  print_cube(PrintCube), nl,
  print_solution(PrevStates).

start :-
  prompt(_, ''),
  read_lines(LL),
  split_lines(LL,S),
  parse_cubeletes(S, Cube),
  ids(0, Cube, Solution),
  print_solution(Solution),
  halt.