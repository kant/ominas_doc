;=============================================================================
;+
; NAME:
;	pg_get_stations
;
;
; PURPOSE:
;	Obtains a station descriptor for the given data descriptor.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_get_stations(dd)
;	result = pg_get_stations(dd, trs)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	data descriptor
;
;	trs:	String containing keywords and values to be passed directly
;		to the translators as if they appeared as arguments in the
;		translators table.  These arguments are passed to every
;		translator called, so the user should be aware of possible
;		conflicts.  Keywords passed using this mechanism take 
;		precedence over keywords appearing in the translators table.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	std:		Input station descriptors; used by some translators.
;
;	override:	Create a data descriptor and initilaize with the 
;			given values.  Translators will not be called.
;
;	stn_*:		All station override keywords are accepted.  See
;			station_keywords.include. 
;
;			If name is specified, then only descriptors with
;			those names are returned.
;
;	verbatim:	If set, the descriptors requested using name
;			are returned in the order requested.  Otherwise, the 
;			order is determined by the translators.
;
;	tr_override:	String giving a comma-separated list of translators
;			to use instead of those in the translators table.  If
;			this keyword is specified, no translators from the 
;			table are called, but the translators keywords
;			from the table are still used.  
;
;
; RETURN:
;	Array of station descriptors, 0 if an error occurs.
;
;
; PROCEDURE:
;	If /override, then a station descriptor is created and initialized
;	using the specified values.  Otherwise, the descriptor is obtained
;	through the translators.  Note that if /override is not used,
;	values (except name) can still be overridden by specifying 
;	them as keyword parameters.  If name is specified, then
;	only descriptors corresponding to those names will be returned.
;	
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/2009
;	
;-
;=============================================================================
function pg_get_stations, dd, trs, od=od, bx=bx, std=_std, _extra=select, $
                          override=override, verbatim=verbatim, $
@stn__keywords.include
@nv_trs_keywords_include.pro
		end_keywords

 ;-----------------------------------------------
 ; add selection keywords to translator keywords
 ;-----------------------------------------------
 if(keyword_set(select)) then pg_add_selections, trs, select

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 if(NOT keyword_set(od)) then od = dat_gd(gd, dd=dd, /od)
 if(NOT keyword_set(bx)) then bx = dat_gd(gd, dd=dd, /bx)


 ;-----------------------------------------------
 ; call translators
 ;-----------------------------------------------
 std = dat_get_value(dd, 'STN_DESCRIPTORS', key1=od, key2=bx, key4=_std, key6=primary, $
                             key7=time, key8=name, trs=trs, $
@nv_trs_keywords_include.pro
	end_keywords)

 if(NOT keyword_set(std)) then return, obj_new()

 n = n_elements(std)

 ;---------------------------------------------------
 ; If name given, determine subscripts such that
 ; only values of the named objects are returned.
 ;
 ; Note that each translator has this opportunity,
 ; but this code guarantees that it is done.
 ;
 ; If stn_name is not given, then all descriptors
 ; will be returned.
 ;---------------------------------------------------
 if(keyword__set(name)) then $
  begin
   tr_names = cor_name(std)
   sub = nwhere(strupcase(tr_names), strupcase(name))
   if(sub[0] EQ -1) then return, obj_new()
   if(NOT keyword__set(verbatim)) then sub = sub[sort(sub)]
  end $
 else sub=lindgen(n)

 n = n_elements(sub)
 std = std[sub]



 ;--------------------------------------------------------
 ; update generic descriptors
 ;--------------------------------------------------------
 if(keyword_set(dd)) then dat_set_gd, dd, gd, od=od, bx=bx
 dat_set_gd, std, gd, od=od, bx=bx

 return, std
end
;===========================================================================








