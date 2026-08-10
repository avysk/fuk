require fukmodel.4th
require fukrand.4th

variable fox-strategy

variable fox-from-x
variable fox-from-y
\ check if fox can move into the given direction
\ the source square is in (fox-from-x, fox-from-y)
\ right-flag -- go right or left
\ top-flag -- to top or bottom
: fox-can-move? ( right-flag top-flag -- n )
  dup
  if 1 else 8 then fox-from-y @ =
  if 2drop 0 exit then
  if -1 else 1 then fox-from-y @ + swap
  dup
  if 8 else 1 then fox-from-x @ =
  if 2drop 0 exit then
  if 1 else -1 then fox-from-x @ + swap
  free-square? ;

: fox-can-move-up-right?
  -1 -1 fox-can-move? ;
: fox-can-move-up-left?
  0 -1 fox-can-move? ;
: fox-can-move-down-right?
  -1 0 fox-can-move? ;
: fox-can-move-down-left?
  0 0 fox-can-move? ;

: (store-fox-move!) ( index dx dy -- index + 1 )
  >r over ( index dx index )
  fox-dx ! ( index )
  r> over ( index dy index )
  fox-dy !
  1+ ;

\ possible fox moves, moves are stored in fox-moves array
\ the source square is (fox-from-x, fox-from-y)
: possible-fox-moves ( -- number-of-moves )
  0
  fox-can-move-up-right?
  if
    1 -1 (store-fox-move!)
  then
  fox-can-move-down-right?
  if
    1 1 (store-fox-move!)
  then
  fox-can-move-down-left?
  if
    -1 1 (store-fox-move!)
  then
  fox-can-move-up-left?
  if
    -1 -1 (store-fox-move!)
  then ;

\ perform move with given index
: apply-fox-move ( n -- )
  dup fox-dx @ fox-x @ + fox-x !
  fox-dy @ fox-y @ + fox-y ! ;

: random-fox ( -- )
  dup 0=
  if exit then
  case
    1 of 0 endof
    2 of rand2 endof
    3 of rand3 endof
    4 of rand4 endof
  endcase
  apply-fox-move -1 ;

: random-fox-top
  0
  fox-can-move-up-left?
  if -1 -1 (store-fox-move!) then
  fox-can-move-up-right?
  if 1 -1 (store-fox-move!) then
  dup 0= if
    \ there were no moves up
    fox-can-move-down-left?
    if -1 1 (store-fox-move!) then
    fox-can-move-down-right?
    if 1 1 (store-fox-move!) then
  then
  random-fox ;

variable potential-fox-x
variable potential-fox-y

: (count-mobility)
  0
  fox-can-move-up-right?
  if 1+ then
  fox-can-move-down-right?
  if 1+ then
  fox-can-move-down-left?
  if 1+ then
  fox-can-move-up-left?
  if 1+ then
  1+ ; \ can always go back

: (bypassed-cats)
  0
  5 1 do
    i cat-y @ potential-fox-y @ >=
    if 1+ then
  loop ;

: (cats-absent?) ( x y -- flag )
  -1
  5 1 do
    i swap >r \ store old flag
    >r \ store i
    2dup r> cat-absent?
    r> and
  loop
  rot rot 2drop ;

6 constant MOBILITY-WEIGHT
4 constant PROGRESS-WEIGHT
8 constant CATS-WEIGHT
3 constant EDGE-PENALTY-WEIGHT
\ Calculate heuristic for fox at potential-fox-x and potential-fox-y
: fox-heuristic-f ( -- n )
  potential-fox-x @ fox-from-x !
  potential-fox-y @ dup
  1 = if \ winning move
    drop $7FFF exit
  then
  fox-from-y !
  (count-mobility) dup
  \ now heavily penalize if cats can win in one move
  1 = if
    \ cats can win if some cat can move to the old fox square
    \ now coordinates can be out-of-board but it does not matter,
    \ since cat-absent? will return true
    fox-x @ fox-y @
    1- swap 1- swap
    2dup (cats-absent?) >r
    swap 2 + swap
    (cats-absent?) r> and
    0= if drop -10000 exit then
  then \ check for cats win-in-one
  MOBILITY-WEIGHT *
  8 potential-fox-y @ - PROGRESS-WEIGHT * +
  (bypassed-cats) dup
  \ if moves bypasses all cats, do it
  4 = if drop drop 10000 exit then
  CATS-WEIGHT * +
  potential-fox-x @ dup 1 = swap 8 = or
  if
    EDGE-PENALTY-WEIGHT -
  then ;

: (store-potential-move) ( move-index -- )
  dup fox-dx @ fox-x @ + potential-fox-x !
  fox-dy @ fox-y @ + potential-fox-y ! ;

variable (heuristic-max)
\ move fox to the square with largest heuristic function (if there are several,
\ choose randomly).
: heuristic-fox
  \ the current biggest value of heuristic is stored at return stack
  -$7FFF (heuristic-max) !
  \ we are going to keep on stack number-of-moves and in fox-moves array
  \ the moves themselves
  0 ( number of moves found )
  possible-fox-moves
  dup 1 =
  if
    drop
    apply-fox-move -1 exit
  then
    0 ?do \ iterate all possible moves
      i (store-potential-move)
      fox-heuristic-f dup ( moves-found heuristic heuristic )
      (heuristic-max) @ >
      if
        ( moves-found heuristic )
        \ we found better move than what we had before
        (heuristic-max) ! ( drop old maximum and record new )
        \ now record found move
        drop 0 i fox-dx @ i fox-dy @ (store-fox-move!)
      else
        (heuristic-max) @ =
        ( dx dy ... moves-found heuristic )
        if
          \ one more move to choose from
          i fox-dx @ i fox-dy @ (store-fox-move!)
        then \ another move with the same heuristic
      then \ check heurstic for the considered move
    loop \ all possible moves iteration
  random-fox ;


: fox-move
  fox-strategy @
  fox-x @ fox-from-x !
  fox-y @ fox-from-y !
  case
    1 of
      possible-fox-moves random-fox exit
    endof
    2 of
      random-fox-top exit
    endof
    3 of
      heuristic-fox exit
    endof
  endcase
  0 ;
