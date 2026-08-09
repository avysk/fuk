\ fox coordinates, 1-8
variable fox-x
variable fox-y

create fox-moves 1 , 1 , 1 , -1 , -1 , 1 , -1 , -1 ,

\ cats coordinates, 1-8
create cats-x 2 , 4 , 6 , 8 ,
create cats-y 1 , 1 , 1 , 1 ,

\ put on stack cell address of X coordinate of the cat with the given index, 1-4
: cat-x ( n1 -- n2 ) 1- cells cats-x + ;
\ put on stack cell address of Y coordinate of the cat with the given index, 1-4
: cat-y ( n1 -- n2 ) 1- cells cats-y + ;
\ put on stack cell adress of dx for the fox move with the given index, 0-3
: fox-dx ( n1 -- n2 ) 2 * cells fox-moves + ;
\ put on stack cell adress of dy for the fox move with the given index, 0-3
: fox-dy ( n1 -- n2 ) 2 * 1+ cells fox-moves + ;

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
: move-cat ( n right-flag -- -1 )
  >r
  drop -1 \ we are going to leave on stack "proceed to fox move" true value
  selected-cat @ dup cat-y swap cat-x ( cat-y cat-x )
  dup @ r> if 1+ else 1- then ( cat-y cat-x new-xc ) swap !
  dup @ 1+ swap !
  adjust-selection ;
