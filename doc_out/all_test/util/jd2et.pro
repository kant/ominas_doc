;============================================================================
; jd2et
;
;============================================================================
function jd2et, jd
;message, 'This routine is obsolete!!  Use spice_jed2et!!!'

 return, (jd - julday(1,1,2000,12,0,0)) * 86400d 	; sec. past J2000
end
;============================================================================
