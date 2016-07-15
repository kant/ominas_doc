;===========================================================================
;+
; NAME:
;	cam_set_poly_matrices
;
;
; PURPOSE:
;       Sets up the camera function data for the polynomial distortion model.
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cam_set_poly_matrices, cd, XX, YY, PP, QQ
;
;
; ARGUMENTS:
;  INPUT: 
;	cd:	Array (nt) of and subclass of CAMERA.
;
;       XX:     Polynominal distortion coefficients in x.
;
;       YY:     Polynominal distortion coefficients in y.
;
;       PP:     Inverse polynominal distortion coefficients in x.
;
;       QQ:     Inverse polynominal distortion coefficients in y.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================
pro cam_set_poly_matrices, cd, XX, YY, PP, QQ, noevent=noevent
@core.include

 _cd = cor_dereference(cd)


 if(ptr_valid(_cd.fn_data_p)) then nv_ptr_free, _cd.fn_data_p

 _cd.fn_data_p = nv_ptr_new([nv_ptr_new(XX), nv_ptr_new(YY), nv_ptr_new(PP), nv_ptr_new(QQ)])

 cor_rereference, cd, _cd
 nv_notify, cd, type = 0, noevent=noevent
end
;===========================================================================



