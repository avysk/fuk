\ fox coordinates, 1-8
variable fox-x
variable fox-y

\ cats coordinates, 1-8
create cats-x 2 , 4 , 6 , 8 ,
create cats-y 1 , 1 , 1 , 1 ,

\ put on stack cell address of X coordinate of the cat with the given index, 1-4
: cat-x ( n1 -- n2 ) 1- cells cats-x + ;
\ put on stack cell address of Y coordinate of the cat with the given index, 1-4
: cat-y ( n1 -- n2 ) 1- cells cats-y + ;

variable selected-cat

\ check if fox is absent on given square
: fox-absent? ( x y -- n )
  fox-y @ = swap
  fox-x @ = and
  0= ;

: init-fox 5 fox-x ! 8 fox-y ! ;

: init-model
  5 1 do
    i 2 * i cat-x !
    1 i cat-y !
  loop
  1 selected-cat !
  init-fox ;

\ check if on the given square there is no cat with given index (1-4)
: cat-absent? ( x y n1 -- n2 )
  dup rot swap ( x n1 y n1 )
  cat-y @ = ( x n1 f )
  rot rot ( f x n1 )
  cat-x @ = and 0= ;

\ check if the given place is free (no cats, no fox)
: free-square? ( x y -- n )
  2dup fox-absent? ( x y flag )
  5 1 do
    rot rot ( flag x y )
    2dup i ( flag x y x y index )
    cat-absent? ( flag x y cat-flag )
    >r rot r> ( x y flag cat-flag )
    and ( x y new-flag )
  loop
  >r 2drop r> ;

\ check if cat can move down-left
: cat-can-move-left? ( n1 -- n2 )
  dup cat-x @ swap cat-y @ ( x y )
  dup 8 = if 2drop 0 exit then
  over 1 = if 2drop 0 exit then
  swap 1- swap 1+
  free-square? ;

\ check if cat can move down-right
: cat-can-move-right? ( n1 -- n2 )
  dup cat-x @ swap cat-y @ ( x y )
  dup 8 = if 2drop 0 exit then
  over 8 = if 2drop 0 exit then
  swap 1+ swap 1+
  free-square? ;

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

\ possible fox moves
: possible-fox-moves ( -- dx dy ... number-of-moves )
  0
  fox-can-move-up-right?
  if
    1 -1 rot 1+
  then
  fox-can-move-down-right?
  if
    1 1 rot 1+
  then
  fox-can-move-down-left?
  if
    -1 1 rot 1+
  then
  fox-can-move-up-left?
  if
    -1 -1 rot 1+
  then ;

\ check if cat can move at all
: cat-can-move? ( n -- b )
  dup cat-can-move-left?
  swap cat-can-move-right?
  or ;

: (next-cat) ( n1 -- n2 )
  1+ dup 5 =
  if drop 1 then ;

\ move selection to the first cat that can move
: adjust-selection
  selected-cat @
  4 0 do
    dup cat-can-move?
    if
      selected-cat !
      unloop exit
    then
    (next-cat)
  loop
  drop
  -1 selected-cat ! ;

\ move cat left or right, and down
: move-cat ( right-flag -- )
  >r
  selected-cat @ dup cat-y swap cat-x ( cat-y cat-x )
  dup @ r> if 1+ else 1- then ( cat-y cat-x new-xc ) swap !
  dup @ 1+ swap !
  adjust-selection ;
