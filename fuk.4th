require agon.4th
require fukfox.4th
require fukmodel.4th
require fukcat.4th

8 constant LEFT
21 constant RIGHT
113 constant KEY_Q

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
: draw-piece ( selected-flag xb yb -- )
  square-center ( selected-flag xs ys )
  2dup 2dup ( selected-flag xs ys xs ys xs ys )
  moveto ( selected-flag xs ys xs ys )
  SQUARE-SIZE 2 / 5 - +
  \ filled circle
  25EMIT $9D emit emit-xy ( selected-flag xs ys )
  rot if 10 else 0 then gcol ( xs ys )
  2dup 2dup 2dup ( xs ys xs ys xs ys xs ys )
  moveto
  SQUARE-SIZE 2 / 5 - +
  circle
  moveto
  SQUARE-SIZE 2 / 9 - +
  circle ;

\ draw squares and pieces, so after piece move the picture is correct
: redraw-pieces ( -- )
  vwait
  9 1 do
    9 1 do
      i j 2dup + 2 mod if 3 else 7 then gcol
      draw-square
    loop
  loop
  1 gcol
  0 fox-x @ fox-y @ draw-piece
  5 1 do
    8 gcol
    selected-cat @ i =
    i cat-x @ i cat-y @ draw-piece
  loop
  15 gcol ;

\ draw the board.
: draw-board ( -- )
  0 mode
  23EMIT 0EMIT $C0 emit 0EMIT \ switch off scaling
  vwait
  15 gcol
  draw-board-outline
  draw-horizontal-lines
  draw-vertical-lines ;

\ clear status message
: clear-status
  0 gcol 480 40 moveto 630 50 box ;

\ switch to display at status area
: prepare-for-status
  5 emit 480 40 moveto ;

: game-loop
  begin
    begin
    0 \ 0 for "do not terminate the loop"; "move-cat" will replace it with -1
      key case
        KEY_Q of drop 0 mode 15 col 15 gcol exit endof
        BL of
          selected-cat dup @ 4 mod 1+ swap ! adjust-selection
          redraw-pieces
        endof
        LEFT of selected-cat @ cat-can-move-left?
          if 0 move-cat then
        endof
        RIGHT of selected-cat @ cat-can-move-right?
          if 1 move-cat then
        endof
      endcase
    until
    redraw-pieces
    clear-status
    ( fox move is supposed to put true value on stack if it some move was done )
    random-fox
    0 =
    if
      prepare-for-status
      10 gcol ." Cats won!"
      drop
      key drop
      0 mode 15 gcol 15 col exit
    then
    adjust-selection
    redraw-pieces
    selected-cat @ -1 =
    fox-y @ 1 =
    or
    if
      prepare-for-status
      9 gcol ." Fox won!"
      key drop
      0 mode 15 gcol 15 col exit
    then
  again ;

: game
  init-model
  draw-board
  redraw-pieces
  game-loop ;
