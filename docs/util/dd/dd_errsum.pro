;==============================================================================
; dd_errsum
;
;  See Hida et al. 2000
;
;==============================================================================
function dd_errsum, x, y, e=e

 s = x + y
 e = y - (s-x)

 return, s
end
;==============================================================================
