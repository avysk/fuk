require files.4th
require agon.4th

create vdu-buf 512 allot

variable Vdu-fid

: emit-buffer ( addr len -- )
  bounds do
    i c@ emit
  loop ;

: lvdu ( addr len -- )
  r/o open-file
  -38 ?throw
  vdu-fid !
  begin
    vdu-buf 512 vdu-fid @
    read-file
    throw
    dup
  while
    vdu-buf swap emit-buffer
  repeat
  drop
  vdu-fid @ close-file throw ;
