;=============================================================================
; strep
;
;  Replaces a portion of a string.
;
;=============================================================================
function strep, ss, s, pos

 strput, ss, s, pos

 return, ss
end
;=============================================================================
