;=============================================================================
;+
; NAME:
;	pg_get_rings
;
;
; PURPOSE:
;	Obtains ring descriptors for the given data descriptor.  
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_get_rings(dd, od=od)
;	result = pg_get_rings(dd, od=od, trs)
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
;	rd:		Input ring descriptors; used by some translators.
;
;	pd:		Planet descriptors for primary objects.  
;
;	od:		Observer descriptors.  
;
;	gd:		Generic descriptors.  Can be used in place of od.
;
;	override:	Create a data descriptor and initilaize with the 
;			given values.  Translators will not be called.
;
;	rng_*:		All ring override keywords are accepted.  See
;			ring_keywords.include.
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
;	Ring descriptors obtained from the translators, 0 if an error occurs.
;
;
; PROCEDURE:
;	If /override, then a ring descriptor is created and initialized
;	using the specified values.  Otherwise, the descriptor is obtained
;	through the translators.  Note that if /override is not used,
;	values (except name) can still be overridden by specifying 
;	them as keyword parameters.  If name is specified, then
;	only descriptors corresponding to those names will be returned.
;	
;
;
; SEE ALSO:
;	xx, xx, xx
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1998
;	Modified:	Spitale, 8/2001
;	
;-
;=============================================================================



;===========================================================================
; pggr_select_rings
;
;
;===========================================================================
pro pggr_select_rings, dd, rd, od=od, select

 ;------------------------------------------------------------------------
 ; standard body filters
 ;------------------------------------------------------------------------
 sel = pg_select_bodies(dd, rd, od=od, select)

 ;------------------------------------------------------------------------
 ; implement any selections
 ;------------------------------------------------------------------------
 if(keyword_set(sel)) then $
  begin
   sel = unique(sel)

   w = complement(rd, sel)
   if(w[0] NE -1) then nv_free, rd[w]

   if(sel[0] EQ -1) then rd = obj_new() $
   else rd = rd[sel]
  end


end
;===========================================================================



;===========================================================================
; pg_get_rings
;
;===========================================================================
function pg_get_rings, dd, trs, rd=_rd, pd=pd, od=od, _extra=select, $
                      override=override, verbatim=verbatim, $
@rng__keywords.include
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
 if(NOT keyword_set(pd)) then pd = dat_gd(gd, dd=dd, /pd)

 ;-------------------------------------------------------------------
 ; if /override, create descriptors without calling translators
 ;-------------------------------------------------------------------
 if(keyword__set(override)) then $
  begin
   n = n_elements(name)

   if(keyword_set(dd)) then gd = dd
   rd = rng_create_descriptors(n, $
@rng__keywords.include
end_keywords)
   gd = !null

  end $
 ;-------------------------------------------------------------------
 ; otherwise, get ring descriptors from the translators
 ;-------------------------------------------------------------------
 else $
  begin
   ;-----------------------------------------------
   ; call translators
   ;-----------------------------------------------
   rd = dat_get_value(dd, 'RNG_DESCRIPTORS', key1=pd, key2=od, key4=_rd, $
                            key7=time, key8=name, trs=trs, $
@nv_trs_keywords_include.pro
	end_keywords)

   if(NOT keyword__set(rd)) then return, obj_new()

   n = n_elements(rd)

   ;---------------------------------------------------
   ; If name given, determine subscripts such that
   ; only values of the named objects are returned.
   ;
   ; Note that each translator has this opportunity,
   ; but this code guarantees that it is done.
   ;
   ; If name is not given, then all descriptors
   ; will be returned.
   ;---------------------------------------------------
   if(keyword__set(name)) then $
    begin
     tr_names = cor_name(rd)
     sub = nwhere(strupcase(tr_names), strupcase(name))
     if(sub[0] EQ -1) then return, obj_new()
     if(NOT keyword__set(verbatim)) then sub = sub[sort(sub)]
    end $
   else sub=lindgen(n)

   n = n_elements(sub)
   _rs = rd[sub]

   ;-------------------------------------------------------------------
   ; override the specified values (name cannot be overridden)
   ;-------------------------------------------------------------------
   if(defined(name)) then _name = name & name = !null
   rng_assign, rd, /noevent, $
@rng__keywords.include
end_keywords
    if(defined(_name)) then name = _name

  end


 ;--------------------------------------------------------
 ; filter rings
 ;--------------------------------------------------------
 if(NOT keyword_set(rd)) then return, obj_new()
 if(keyword_set(select)) then pggr_select_rings, dd, rd, od=od, select
 if(NOT keyword_set(rd)) then return, obj_new()

 ;--------------------------------------------------------
 ; update generic descriptors
 ;--------------------------------------------------------
 if(keyword_set(dd)) then dat_set_gd, dd, gd, pd=pd, od=od
 dat_set_gd, rd, gd, pd=pd, od=od

 return, rd
end
;===========================================================================



