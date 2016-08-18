;=============================================================================
;+
; NAME:
;	dat_lookup_translators
;
;
; PURPOSE:
;	Looks up the names of the data input and output tranlators in
;	the translators table.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	dat_lookup_translators, instrument, input_translators, output_translators
;
;
; ARGUMENTS:
;  INPUT:
;	instrument:	Instrument string from dat_detect_instrument.
;
;  OUTPUT:
;	input_translators:	Array giving the names of the input translator 
;				functions.
;
;	output_translators:	Array giving the names of the output translator 
;				functions.
;
;	input_keyvals:	Array giving the keyword/value pairs the from the 
;			translators table, for each input translator.
;
;	output_keyvals:	Array giving the keyword/value pairs the from the 
;			translators table, for each output translator.
;
;
; KEYWORDS:
;  INPUT: 
;	silent:	If set, messages are suppressed.
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
; 	Written by:	Spitale
;	
;-
;=============================================================================
pro dat_lookup_translators, instrument, $
       input_translators, output_translators, input_keyvals, output_keyvals, $
        tab_translators=tab_translators, silent=silent
@nv_block.common
@core.include


 marker='-'
 input_translators = ''
 output_translators = ''

 ;=====================================================
 ; read the translators table if it doesn't exist
 ;=====================================================
 if(NOT keyword_set(*nv_state.tr_table_p)) then $
   dat_read_config, 'NV_TRANSLATORS', $
              nv_state.tr_table_p, nv_state.translators_filenames_p
 table = *nv_state.tr_table_p
 if(NOT keyword_set(table)) then return


 ;==============================================================
 ; lookup the instrument string
 ;==============================================================
 input_translator = ''
 output_translator = ''

 instruments = table[*,0]
 w0 = (where(instruments EQ instrument))[0]

 ;-----------------------------------------
 ; if instrument not found, try DEFAULT
 ;-----------------------------------------
 if(w0[0] EQ -1) then $
     w0 = (where(instruments EQ 'DEFAULT'))[0]


 ;================================================================
 ; extract all given translators and keyvals for this instrument
 ;================================================================
 if(w0 NE -1) then $
  begin
   w1 = w0
   wn = where(instruments[w0:*] NE marker)
   wc = where(instruments[w0:*] EQ marker)
   if(wc[0] NE -1) then $
    begin
;     if(wn[0] EQ -1) then w1 = w0 + n_elements(wc) $
;     else w1 = w0 + wn[1]-1
     if(n_elements(wn) GT 1) then w1 = w0 + wn[1]-1 $
     else w1 = w0 + n_elements(wc)
    end

   input_translators = table[w0:w1,1]
   output_translators = table[w0:w1,2]

   s = size(table)
   nfields = s[2]
   if(nfields GT 3) then keyvals = table[w0:w1,3:nfields-1]

  end $
 else return
 

 ;================================
 ; filter out any place markers
 ;================================
 w = where(input_translators NE marker)
 if(w[0] EQ -1) then input_translators = '' $
 else $
  begin
   input_translators = input_translators[w]
   if(keyword_set(keyvals)) then input_keyvals = strtrim(keyvals[w,*],2)
  end

 w = where(output_translators NE marker)
 if(w[0] EQ -1) then output_translators = '' $
 else $
  begin
   output_translators = output_translators[w]
   if(keyword_set(keyvals)) then output_keyvals = strtrim(keyvals[w,*],2)
  end


end
;===========================================================================
