;===========================================================================
;+
; NAME:
;	dsk_set_refl_fn
;
;
; PURPOSE:
;       Replaces the reflection function for each given disk descriptor.
;
;
; CATEGORY:
;	NV/LIB/dsk
;
;
; CALLING SEQUENCE:
;	dsk_set_refl_fn, dkd, refl_fn
;
;
; ARGUMENTS:
;  INPUT: 
;	dkd:	 Array (nt) of any subclass of DISK descriptors.
;
;	refl_fn: Array (nt) of new reflection functions.
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
pro dsk_set_refl_fn, dkd, refl_fn, noevent=noevent
@core.include
 
 _dkd = cor_dereference(dkd)

 _dkd.refl_fn=refl_fn

 cor_rereference, dkd, _dkd
 nv_notify, dkd, type = 0, noevent=noevent
end
;===========================================================================
