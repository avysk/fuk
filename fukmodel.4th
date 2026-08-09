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
