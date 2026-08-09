require fukmodel.4th
require fukrand.4th

\ check if fox can move into the given direction
\ right-flag -- go right or left
\ top-flag -- to top or bottom
: fox-can-move? ( right-flag top-flag -- n )
  dup
  if 1 else 8 then fox-y @ =
  if 2drop 0 exit then
  if -1 else 1 then fox-y @ + swap
  dup
  if 8 else 1 then fox-x @ =
  if 2drop 0 exit then
  if 1 else -1 then fox-x @ + swap
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

\ choose random fox move, on stack there's a number of possible moves
: random-fox ( n -- )
  possible-fox-moves dup 0=
  if exit then
  case
    1 of 0 endof
    2 of rand2 endof
    3 of rand3 endof
    4 of rand4 endof
  endcase
  dup fox-dx @ fox-x @ + fox-x !
  fox-dy @ fox-y @ + fox-y ! -1 ;
