;===========================================================================
;+
; NAME:
;	pt
;
; PURPOSE:
;	Abbreviation for the nv_ptr_new() function
;
; CATEGORY:
;       UTIL/ABBREV
;-
;===========================================================================
function pt, x
 return, nv_ptr_new(x)
end
;===========================================================================