require fukmodel.4th

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
