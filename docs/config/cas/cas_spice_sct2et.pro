;=======================================================================================
; cas_spice_sct2et
;
;=======================================================================================
function cas_spice_sct2et, dd, times
 return, spice_sct2et(times, -82l)
end
;=======================================================================================
