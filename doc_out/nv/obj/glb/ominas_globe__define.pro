;=============================================================================
; ominas_globe::init
;
;=============================================================================
function ominas_globe::init, ii, crd=crd0, bd=bd0, sld=sld0, gbd=gbd0, $
@glb__keywords.include
end_keywords
@core.include
 
 void = self->ominas_solid::init(ii, crd=crd0, bd=bd0, sld=sld0, $
@sld__keywords.include
end_keywords)
 if(keyword_set(gbd0)) then struct_assign, gbd0, self

 self.abbrev = 'GLB'
 self.tag = 'GBD'
 if(keyword_set(lref)) then self.lref=decrapify(lref[ii])

 ;----------------------------------------
 ; ellipsoid parameters
 ;----------------------------------------
 self.type = 'ELLIPSOID'
 if(keyword_set(radii)) then self.radii = radii[*,ii]
 if(keyword_set(lora)) then self.lora = decrapify(lora[ii])

 ;----------------------------------------
 ; higher-order shape parameters
 ;----------------------------------------
 if(keyword_set(rref)) then self.rref = rref[ii]

 if(keyword_set(J)) then $
  begin
   _nj = n_elements(J[*,ii])
   nj = n_elements(self.J)
   if(_nj GT nj) then $
    begin
     nv_message, /con, 'Warning -- J contains more terms than allowed, truncating.'
     J = J[0:nj-1,ii]
    end
   _nj = n_elements(J[*,ii])
   self.J[0:_nj-1] = J[*,ii]
  end


 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_globe__define
;
;
; PURPOSE:
;	Class structure fo the GLOBE class.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	sld:	SOLID class descriptor.  
;
;		Methods: glb_solid, glb_set_solid
;
;
;	type:	String giving the type.  ELLIPSOID, FACET, or HARMONIC.
;		Currently only ellipsoids are supported.
;
;
;		Methods: glb_type, glb_set_type
;
;	lref:	Longitude reference note.  Used to describe the longitude
;		reference system.
;
;		Methods: glb_lref, glb_set_lref
;
;
;	radii:	3-element array giving the ellipsoid radii.
;
;		Methods: glb_radii, glb_set_radii
;
;
;	lora:	Longitude of first ellipsoid radius.
;
;		Methods: glb_lora, glb_set_lora
;
;
;	rref:	Reference radius.
;
;		Methods: glb_rref, glb_set_rref
;
;
;	J:	Array (nj) giving the zonal harmonics.  Indices in the 
;		array correspond to the standard harmonic orders, i.e.,
;		J[2] is J2.
;
;		Methods: glb_j, glb_set_j
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
;=============================================================================
pro ominas_globe__define

 nj = glb_nj()

 struct = $
    { ominas_globe, inherits ominas_solid, $
	type:		 '', $			; ELLIPSOID, FACET, or HARMONIC

	lref:	 	 '', $			; longitude reference note

	;----------------------------------------
	; ellipsoid parameters
	;----------------------------------------
	radii:		 dblarr(3), $		; triaxial ellipsoid radii
	lora:		 0d, $			; east longitude of first
						; ellipsoid radius.  

	;----------------------------------------
	; dynamical parameters
	;----------------------------------------
	rref:		0d, $			; reference radius
	J:		dblarr(nj) $		; Zonal grav. harmonics
;	S:	tesseral harmonics not implemented.
;	C:

    }

end
;===========================================================================
