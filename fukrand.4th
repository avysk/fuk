require asmz80.4th
code (rreg@) ( -- u )
  push bc
  ld a, r
  ld c, a
  ld b, 0
  next
end-code

\ Return kinda random 7-bit value (0 <= r <= 127) based on Z80 R register
\ Z80 docs say that only bits 0-6 in it are updated
: rreg@
  (rreg@) $7F and ;

: rand2 ( -- u )
  rreg@ 2 mod ;

: rand3 ( -- u )
  begin
    rreg@ dup
    125 >
  while
    drop
  repeat
  3 mod ;

: rand4 ( -- u )
  rreg@ 4 mod ;
