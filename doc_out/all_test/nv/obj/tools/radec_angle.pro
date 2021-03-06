;=============================================================================
;+
; NAME:
;       radec_angle
;
;
; PURPOSE:
;	Computes angles between vectors specified in the radec system.
;
;
; CATEGORY:
;       NV/LIB/TOOLS
;
;
; CALLING SEQUENCE:
;       angle = radec_angle(radec1, radec2)
;
;
; ARGUMENTS:
;  INPUT:
;	radec1:	Array (nv,3,nt) giving the radec representation of the 
;		first vector.
;
;	radec2:	Array (nv,3,nt) giving the radec representation of the 
;		second vector.
;
;  OUTPUT:  NONE
;
;
; KEYOWRDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;       Array (nv,nt) of angles between the input vectors.
;
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function radec_angle, radec1, radec2

 return, v_angle(bod_radec_to_body(bod_inertial(), radec1), $
                 bod_radec_to_body(bod_inertial(), radec2))
end
;===================================================================================
