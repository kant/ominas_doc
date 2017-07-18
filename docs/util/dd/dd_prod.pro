;==============================================================================
; dd_prod
;
;==============================================================================
function dd_prod, xx, yy

 dim = size(xx, /dim)
 n = n_elements(xx)/2
 
 x1 = xx[0:n-1]
 x2 = xx[n:*]

 y1 = yy[0:n-1]
 y2 = yy[n:*]

 
 result = dblarr(dim)

 result[0:n-1] = x1*y1 + x2*y2
 result[n:*] = x1*y2 + x2*y1

 return, result
end
;==============================================================================
