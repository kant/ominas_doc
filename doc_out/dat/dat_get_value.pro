;=============================================================================
;+
; NAME:
;	dat_get_value
;
;
; PURPOSE:
;	Calls input translators, supplying the given keyword, and builds 
;	a list of returned descriptors.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	xds = dat_get_value(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptors.  Must all have the same instrument 
;			string.
;
;	keyword:	Keyword to pass to translators, describing the
;			requested quantity.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	trs:		Transient argument string.
;
;	tr_disable:	If set, dat_get_value returns without performing 
;			any action.
;
;	tr_override:	Comma-delimited list of translators to use instead
;			of those stored in dd.
;
;	tr_first:	If set, dat_get_value returns after the first
;			successful translator.
;
;	tr_nosort:	By default, outpur descriptors are sorted to remove
;			those with duplicate names, retaining only the first
;			descriptor of a given name for each input data 
;			descriptor.  /tr_nosort disables this action.
;
;  OUTPUT: 
;	status:		0 if at least one translator call was successful, 
;			-1 otherwise.
;
;
; RETURN: 
;	Array of descriptors returned from all successful translator calls.
;	Descriptors are returned in the same order that the corresponding 
;	translators were called.  Each translator may produce multiple 
;	descriptors.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;=============================================================================
function dat_get_value, dd, keyword, status=status, trs=trs, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
                             end_keywords
@core.include

; on_error, 1
 _dd = cor_dereference(dd)
 ndd = n_elements(dd)

 status = -1
 xds = 0

 if(keyword_set(tr_disable)) then return, 0

 ;--------------------------------------------
 ; record any transient keyvals
 ;--------------------------------------------
 _dd[0] = dat_add_transient_keyvals(_dd[0], trs)

 ;--------------------------------------------
 ; build translators list
 ;--------------------------------------------
 if(NOT keyword_set(tr_override)) then $
  begin
   if(NOT ptr_valid(_dd[0].input_translators_p)) then $
    begin
     nv_message, /con, name='dat_get_value', $
	    'No input translator available for '+keyword+'.'
     return, 0
    end
   translators = *_dd[0].input_translators_p
  end $
 else translators = $
	   nv_match(*_dd[0].input_translators_p, str_nsplit(tr_override, ','))
 n = n_elements(translators)


 ;----------------------------------------------------------------
 ; call all translators, building a list of returned values
 ;----------------------------------------------------------------
 n_total = 0
 nmax = 0
 chunk_n = 20

 for i=0, n-1 do $
  begin
   _dd.last_translator = [i,0]#make_array(ndd, val=1)
   cor_rereference, dd, _dd
   xd = call_function(translators[i], dd, keyword, values=xds, stat=stat, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
		    end_keywords)

   ;--------------------------------------
   ; add values to list
   ;--------------------------------------
   if(stat EQ 0) then $
    begin
     xds = append_array(xds, xd)
     if(keyword_set(tr_first)) then i=n
    end
  end
 nxds = n_elements(xds)

 ;----------------------------------------------------------------
 ; sort xds
 ;----------------------------------------------------------------
 result = 0
 if(keyword_set(xds)) then $
  begin
   status = 0
   if(NOT keyword_set(tr_nosort)) then $
    for i=0, ndd-1 do $
     begin
      w = where(cor_assoc_xd(xds) EQ dd[i])
      nw = n_elements(w)
      if(w[0] NE -1) then $
       begin
        names = cor_name(xds[w])
        ss = sort(names)
        uu = uniq(names[ss])

        ii = lindgen(nxds)
        ii = ii[w[ss[uu]]]
        ii = ii[sort(ii)]

        result = append_array(result, xds[ii])
       end
     end $
    else result = xds
  end

 return, result
end
;===========================================================================
