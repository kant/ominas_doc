;=============================================================================
; gauss1d
;
;=============================================================================
function gauss1d, x, sig

 U = (x/sig)^2 
 return, exp(-0.5*U)
end
;=============================================================================
