# FLP 2019/2020 - Logicky projekt - Rubikova kocka

**Autor: Andrej Nano (xnanoa00)**

## Reprezentácia Rubikovej kocky

Pre reprezentáciu 3x3 Rubikovej kocky je možné súčasne využiť zafarbenie jednotlivých dlaždíc (tiles) alebo z nich zložených častí, ktoré tvoria kocku (cubeletes).

V projekte využívam najmä reprezentáciu pomocou cubeletes, ktorých existujú 3 typy: rohové (corner - 3 strany), hranové (edge - 2 strany) a stredové (center - 1 strana) časti kocky.

Na označenie názvov pre jednotlivé časti využívam tzv. "Singmaster" notáciu, vďaka ktorej je možné o kocke uvažovať bez znalosti zafarbenia jednotlivých dlaždíc a súčasne som pridal jasnú identifikáciu polohy pre každú dlaždicu zvlášť.

Ukážka reprezentácie:
```
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
```

## Rotácie

Rotácie predstavujú jediné možné (legálne) operácie nad modelom kocky. Súčasne aj reprezentujú prechodové funkcie medzi jednotlivými stavmi konfigurácie kocky. Práve postupnosťou rotácií je možné dosiahnuť stav kocky, kedy je poskladaná. Pre každú stranu kocky existujú 2 základné typy rotácií, rotácia v smere hodinových ručičiek (doprava z pohľadu pozorovatela) a v protichodnom smere hodinových ručičiek (doľava z pohľadu pozorovatela).

Všetky možné rotácie:
- `rf_ror/2` Right Face Rotation (Clockwise)
- `rf_rol/2` Right Face Reverse Rotation (Anticlockwise) /2
- `lf_ror/2` Left Face Rotation (Clockwise) /2
- `lf_rol/2` Left Face Reverse Rotation (Anticlockwise) /2
- `uf_ror/2` Up Face Rotation (Clockwise) /2
- `uf_rol/2` Up Face Reverse Rotation (Anticlockwise) /2
- `df_ror/2` Down Face Rotation (Clockwise) /2
- `df_rol/2` Down Face Reverse Rotation (Anticlockwise) /2
- `ff_ror/2` Front Face Rotation (Clockwise) /2
- `ff_rol/2` Front Face Reverse Rotation (Anticlockwise) /2
- `bf_ror/2` Back Face Rotation (Clockwise) /2
- `bf_rol/2` Back Face Reverse Rotation (Anticlockwise) /2

Pomenovanie predikátov vychádza z konceptuálne podobného pomenovania operácie Rotate v prostredí asemblerov.

## Cielový stav. Kedy je kocka poskladaná?

Kocka je poskladaná práve vtedy, keď všetky dlaždice na danej strane sú si rovné. Na to sa využíva v implementácií predikát `solvedCube/1`, ktorý pomocou jednoduchého testu predikátom `faceEqual(Face) :- maplist(=(_), Face).` overí rovnosť dlaždíc pre každú stranu kocky.

Pre prehladosť je v implementácií zavedený predikát určujúci ciel prehladávania stavového priestoru ako `goal(CubeState) :- solvedCube(CubeState).`

## Prehľadávanie stavového priestoru (Iterative Deepening Search)

Pre vyhľadanie správnej postupnosti rotácií (cesty medzi stavmi od počiastočného do cieľového stavu) je využitá metóda iteratívneho prehľadávania do hĺbky. Zámerom je, aby prehľadávanie začalo od najmenších ciest v stavovom priestore a nezanorovalo sa zbytočne hlboko v prípade nesprávneho výberu vetvy v stavovom priestore. Iteratívne prehľadávanie priestoru implementujú predikáty `search/3` a `ids/3`. Vzhľadom k tomu, že existuje presne 12 typov rotácií, tak vetvenie rastie exponenciálne so základom 12 v závislosti od hĺbky prehľadávania.


## Testovanie

Pre testovanie boli použité vstupné súbory v zložke `tests/`, ktoré som vytvoril pomocou postupného aplikovania rotácií na zloženú reprezentáciu kocky. Spolu bolo teda vytvorených 10 korektných konfigurácií kocky, ktoré je možné vopred známou postupnosťou krokov zložiť. Každý vstupný súbor má v názve číslicu, ktorá vyjadruje práve počet krokov potrebných na zloženie.

Meranie bolo uskutočnené pomocou zabudovaného predikátu `statistics/2` a objektom merania bolo vyhodnocovanie predikátu `ids/3`, čiže len samotného iteratívneho prehľadávania do hĺbky.

Ukážka kódu kde prebiehalo meranie:
```
statistics(runtime,[Start|_]),
ids(0, Cube, Solution),
statistics(runtime,[Stop|_]),
Runtime is Stop - Start,
```

**Výsledky merania na serveri merlin.fit.vutbr.cz:**

- `./flp20-log < tests/1-move.in`: Runtime:     <1ms
- `./flp20-log < tests/2-move.in`: Runtime:      1ms
- `./flp20-log < tests/3-move.in`: Runtime:      8ms
- `./flp20-log < tests/4-move.in`: Runtime:     48ms
- `./flp20-log < tests/5-move.in`: Runtime:   1035ms
- `./flp20-log < tests/6-move.in`: Runtime:   2254ms
- `./flp20-log < tests/7-move.in`: Runtime: 116008ms
