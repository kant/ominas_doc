;===========================================================================
;+
; NAME:
;	glb_rref
;
;
; PURPOSE:
;       Returns the reference radius for each given globe descriptor.
;
;
; CATEGORY:
;	NV/LIB/GLB
;
;
; CALLING SEQUENCE:
;	mass = glb_rref(gbd)
;
;
; ARGUMENTS:
;  INPUT:
;	gbd:	 Array (nt) of any subclass of GLOBE descriptors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;       Array (nt) of reference radii associated with each given globe 
;	descriptor.
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
function glb_rref, gbd, noevent=noevent
 
 nv_notify, gbd, type = 1, noevent=noevent
 _gbd = cor_dereference(gbd)

 return, _gbd.rref
end
;===========================================================================
