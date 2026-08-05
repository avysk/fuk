require agon.4th

\ MODEL
\ fox coordinates, 1-8
variable fox-x
variable fox-y

\ cats coordinates, 1-8
create cats-x 1 , 3 , 5 , 7 ,
create cats-y 1 , 1 , 1 , 1 ,

\ put on stack cell address of X coordinate of the cat with the given index, 1-4
: cat-x ( n1 -- n2 ) 1- cells cats-x + ;
\ put on stack cell address of Y coordinate of the cat with the given index, 1-4
: cat-y ( n1 -- n2 ) 1- cells cats-y + ;

: init-cats
  5 1 do
    i 2 * 1- i cat-x !
    1 i cat-y !
  loop ;

\ check if fox is absent on given square
: fox-absent? ( x y -- n )
  fox-y @ = swap
  fox-x @ = and
  0= ;

: init-fox 4 fox-x ! 8 fox-y ! ;

: init-model init-cats init-fox ;

\ check if on the given square there is no cat with given index (1-4)
: cat-absent? ( x y n1 -- n2 )
  dup rot swap ( x n1 y n1 )
  cat-y @ = ( x n1 f )
  rot rot ( f x n1 )
  cat-x @ = and 0= ;

\ check if the given place is free (no cats, no fox)
: free-square ( x y -- n )
  2dup fox-absent? ( x y flag )
  5 1 do
    rot rot ( flag x y )
    2dup i ( flag x y x y index )
    cat-absent? ( flag x y cat-flag )
    >r rot r> ( x y flag cat-flag )
    and ( x y new-flag )
  loop
  >r 2drop r> ;

\ check if cat can move up-left
: cat-can-move-left? ( n1 -- n2 )
  dup cat-x @ swap cat-y @ ( x y )
  dup 8 = if 2drop 0 exit then
  over 1 = if 2drop 0 exit then
  swap 1- swap 1+
  free-square ;

\ check if cat can move up-right
: cat-can-move-right? ( n1 -- n2 )
  dup cat-x @ swap cat-y @ ( x y )
  dup 8 = if 2drop 0 exit then
  over 8 = if 2drop 0 exit then
  swap 1+ swap 1+
  free-square ;

\ the distance between origin and the bottom left corner of the boards,
\ both horizontally and vertically.
: border ( -- n ) 30 ;

\ the size of one square on the board.
: square-size ( -- n ) 120 ;

\ the horizontal (or vertical) coordinate of the fartherst from the origin corner
\ of the given square.
: square-corner ( n -- m )
  square-size * border + ;

\ the horizontal (or vertical) coordinate of the top right corner of the board.
: far-corner ( -- n )
  8 square-corner ;

\ draw a black square at the given coordinates.
: draw-black-square ( x y -- )
  over over
  moveto
  swap square-size +
  swap square-size +
  3 gcol
  box ;

\ draw the outline of the board.
: draw-board-outline ( -- )
  0 mode
  border border moveto
  border far-corner line
  far-corner far-corner line
  far-corner border line
  border border line ;

\ draw horizontal lines of the board.
: draw-horizontal-lines ( -- )
  8 1 do
    border i square-corner moveto
    far-corner i square-corner line
  loop ;

\ draw vertical lines of the board.
: draw-vertical-lines ( -- )
  8 1 do
    i square-corner border moveto
    i square-corner far-corner line
  loop ;

\ draw the board.
: draw-board ( -- )
  8 0 do \ previous vertical coordinate
    4 0 do \ previous horizontal coordinate
      i 2 * j 2 mod + square-corner j square-corner draw-black-square
    loop
  loop ;
