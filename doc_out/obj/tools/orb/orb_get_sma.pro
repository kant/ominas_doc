;===========================================================================
; orb_get_sma
;
;
;===========================================================================
function orb_get_sma, xd, junk
 return, (dsk_sma(xd))[0,0,*]
end
;===========================================================================
