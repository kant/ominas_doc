;==============================================================================
; cas_psf
;
;==============================================================================
function cas_psf, inst

 case inst of
  'CAS_ISSNA' :	return, 1.3d
  'CAS_ISSWA' :	return, 1.8d
 endcase

end
;==============================================================================