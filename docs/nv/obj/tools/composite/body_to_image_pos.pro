;=============================================================================
;+
; NAME:
;       body_to_image_pos
;
;
; PURPOSE:
;       Transforms vectors in body coordinates to image coordinates
;
;
; CATEGORY:
;       NV/LIB/TOOLS/COMPOSITE
;
;
; CALLING SEQUENCE:
;       result = body_to_image_pos(cd, bx, v, inertial=inertial)
;
;
; ARGUMENTS:
;  INPUT:
;             cd:       Array of nt camera or map descriptors.
;
;             bx:       Array of nt object descriptors, subclass of BODY.
;
;              v:       Array (nv x 3 x nt) of position vectors.
;
;  OUTPUT:
;	NONE
;
; KEYWORDS:
;  INPUT:
;	NONE
;
;  OUTPUT:
;       inertial:       Array (nv x 3 x nt) of Vectors in inertial coordinates.
;
;	valid:	Indices of valid output points.
;
;
; RETURN:
;       An array (2 x nv x nt) of points in image coordinates.
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function body_to_image_pos, cd, bx, v, inertial=inertial, valid=valid

 class = (cor_class(cd))[0]

 case class of 
  'MAP' : return, surface_to_image(cd, bx, valid=valid, $
	            body_to_surface(bx, v))

  'CAMERA' : $
	begin
	 fn=cam_fn_body_to_image(cd)
	 if fn then rimage=call_function(fn, cd, bx, v) else begin
	   inertial = bod_body_to_inertial_pos(bx, v)
	   bodinertial=bod_inertial_to_body_pos(cd, inertial)
	   focal=cam_body_to_focal(cd,bodinertial)
	   rimage=cam_focal_to_image(cd,focal)
	 endelse
	 return,rimage
;	 return, cam_focal_to_image(cd, $
;		   cam_body_to_focal(cd, $
;		     bod_inertial_to_body_pos(cd, inertial)))
	end

  else :
 endcase


end
;==========================================================================
