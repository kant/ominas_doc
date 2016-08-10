;=============================================================================
;+
; NAME:
;	pg_put_stars
;
;
; PURPOSE:
;	Outputs star descriptors through the translators.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_put_stars, dd, sd=sd
;	pg_put_stars, dd, gd=gd
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;	trs:	String containing keywords and values to be passed directly
;		to the translators as if they appeared as arguments in the
;		translators table.  These arguments are passed to every
;		translator called, so the user should be aware of possible
;		conflicts.  Keywords passed using this mechanism take 
;		precedence over keywords appearing in the translators table.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	sds:	Star descriptors to output.
;
;	gd:	Generic descriptor.  If present, star descriptors are
;		taken from the gd.sd field.
;
;	str_*:		All star override keywords are accepted.
;
;	tr_override:	String giving a comma-separated list of translators
;			to use instead of those in the translators table.  If
;			this keyword is specified, no translators from the 
;			table are called, but the translators keywords
;			from the table are still used.  
;
;  OUTPUT:
;	NONE
;
;
; SIDE EFFECTS:
;	Translator-dependent.  The data descriptor may be affected.
;
;
; PROCEDURE:
;	CameStarra descriptors are passed to the translators.  Any star
;	keywords are used to override the corresponding quantities in the
;	output descriptors.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_put_planets, pg_put_rings, pg_put_cameras, pg_put_maps
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1998
;	
;-
;=============================================================================
pro pg_put_stars, dd, trs, sds=sds, ods=ods, gd=gd, $
@star_keywords.include
@nv_trs_keywords_include.pro
		end_keywords


 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(keyword__set(gd)) then $
  begin
   if(NOT keyword__set(sds)) then sds=gd.sds
   if(NOT keyword__set(ods)) then ods=gd.ods
  end
 if(NOT keyword__set(sds)) then nv_message, $
                                name='pg_put_stars', 'No star descriptor.'
 if(NOT keyword__set(ods)) then nv_message, $
                               name='pg_put_stars', 'No observer descriptor.'


 ;-------------------------------------------------------------------
 ; override the specified values (strt__name cannot be overridden)
 ;-------------------------------------------------------------------
 if(n_elements(str__lum) NE 0) then str_set_lum, sds, str__lum
 if(n_elements(str__sp) NE 0) then str_set_sp, sds, str__sp
 if(n_elements(str__orient) NE 0) then bod_set_orient, sds, str__orient
 if(n_elements(str__avel) NE 0) then bod_set_avel, sds, str__avel
 if(n_elements(str__pos) NE 0) then bod_set_pos, sds, str__pos
 if(n_elements(str__vel) NE 0) then bod_set_vel, sds, str__vel
 if(n_elements(str__time) NE 0) then bod_set_time, sds, str__time
 if(n_elements(str__radii) NE 0) then glb_set_radii, sds, str__radii
 if(n_elements(str__lora) NE 0) then glb_set_lora, sds, str__lora


 ;-------------------------------
 ; put descriptor
 ;-------------------------------
 dat_put_value, dd, 'STR_DESCRIPTORS', sds, trs=trs, $
@nv_trs_keywords_include.pro
                             end_keywords



end
;===========================================================================



