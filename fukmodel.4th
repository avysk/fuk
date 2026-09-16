\ fox coordinates, 1-8
variable fox-x
variable fox-y

create fox-moves 1 , 1 , 1 , -1 , -1 , 1 , -1 , -1 ,

\ cats coordinates, 1-8
create cats-x 2 , 4 , 6 , 8 ,
create cats-y 1 , 1 , 1 , 1 ,

\ put on stack cell address of X coordinate of the cat with the given index, 1-4
: cat-x ( cat# -- addr ) 1- cells cats-x + ;
\ put on stack cell address of Y coordinate of the cat with the given index, 1-4
: cat-y ( cat# -- addr ) 1- cells cats-y + ;
\ put on stack cell address of dx for the fox move with the given index, 0-3
: fox-dx ( move# -- addr ) 2 * cells fox-moves + ;
\ put on stack cell address of dy for the fox move with the given index, 0-3
: fox-dy ( move# -- addr ) 2 * 1+ cells fox-moves + ;

variable selected-cat

\ check if fox is absent on given square
: fox-absent? ( x y -- flag )
  fox-y @ = swap
  fox-x @ = and
  0= ;

: init-fox ( -- )
  5 fox-x ! 8 fox-y ! ;

: init-model  ( -- ) 
  5 1 do
    i 2 * i cat-x !
    1 i cat-y !
  loop
  1 selected-cat !
  init-fox ;

\ check if on the given square there is no cat with given index (1-4)
: cat-absent? ( x y cat# -- flag )
  dup rot swap
  cat-y @ =  0=
  if 2drop true exit then
  cat-x @ = 0= ;

\ check if the given place is free (no cats, no fox)
: free-square? ( x y -- flag  )
  2dup fox-absent? 0=
  if 2drop false exit then
  5 1 do
    2dup i cat-absent? 0=
    if 2drop false unloop exit then
  loop
  2drop true ;
