require agon.4th

\ MODEL
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

\ check if fox is absent on given square
: fox-absent? ( x y -- n )
  fox-y @ = swap
  fox-x @ = and
  0= ;

: init-fox 5 fox-x ! 8 fox-y ! ;

: init-model init-fox ;

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
15 constant BORDER

\ the size of one square on the board.
55 constant SQUARE-SIZE

\ coordiane of horizontal or vertical line with given index (0-8)
: line-coordinate ( index -- coord )
SQUARE-SIZE 1+ ( + 1 for intermediate lines ) * 1+ ( for outline )
BORDER + ;

\ coordinates of top left corner of the square with given coordinates,
\ square coordinates start at one
: square-tl-corner ( xb yb -- xs ys )
swap 1- line-coordinate 1+
swap 1- line-coordinate 1+ ;

\ coordinates of bottom right corner of the square with given coordinates,
\ square coordinates start at one
: square-br-corner ( xb yb -- xs ys )
swap line-coordinate 1-
swap line-coordinate 1- ;

\ coordinates of a center of the square with given coordinates,
\ square coordinates start at one
: square-center ( xb yb - xc yc )
  square-tl-corner SQUARE-SIZE 2 / dup rot ( xb h h yb )
  + rot rot + swap ;

\ draw a filled square at the given coordinates.
: draw-square ( xb yb -- )
  2dup
  square-tl-corner
  moveto
  square-br-corner
  box ;

\ draw the outline of the board.
variable board-min
variable board-max
0 line-coordinate board-min !
8 line-coordinate board-max !
: draw-board-outline ( -- )
  board-min @ dup over moveto
  board-max @ ( min max ) 2dup line
  dup dup line
  over line
  dup line ;

\ draw horizontal lines of the board.
: draw-horizontal-lines ( -- )
  9 1 do
    i line-coordinate dup board-min @ swap moveto
    board-max @ swap line
  loop ;

\ draw vertical lines of the board.
: draw-vertical-lines ( -- )
  9 1 do
    i line-coordinate dup board-min @ moveto
    board-max @ line
  loop ;

\ draw the piece, given coordinates of the square it is index
: draw-piece ( xb yb -- )
  square-center 2dup 2dup 2dup 2dup 2dup moveto
  SQUARE-SIZE 2 / 5 - +
  \ filled circle
  25EMIT $9D emit emit-xy
  0 gcol
  moveto
  SQUARE-SIZE 2 / 5 - +
  circle
  moveto
  SQUARE-SIZE 2 / 9 - +
  circle ;

\ draw squares and pieces, so after piece move the picture is correct
: redraw-pieces
  9 1 do
    9 1 do
      i j 2dup + 2 mod if 3 else 7 then gcol
      draw-square
    loop
  loop
  1 gcol
  fox-x @ fox-y @ draw-piece
  5 1 do
    8 gcol
    i cat-x @ i cat-y @ draw-piece
  loop
  15 gcol ;

\ draw the board.
: draw-board ( -- )
  0 mode
  23EMIT 0EMIT $C0 emit 0EMIT \ switch off scaling
  15 gcol
  draw-board-outline
  draw-horizontal-lines
  draw-vertical-lines
  redraw-pieces ;
