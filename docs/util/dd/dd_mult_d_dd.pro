;==============================================================================
; dd_mult_dd_d
;
;==============================================================================
function dd_mult_dd_d, aa, b

 dim = size(aa, /dim)
 n = n_elements(aa)/2
 
 a0 = aa[0:n-1]
 a1 = aa[n:*]






 pp = dd_real(p1, p2)

 return, reform(pp, dim, /over)
end
;==============================================================================
