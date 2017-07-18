;=============================================================================
; grim_set_user_data
;
;=============================================================================
pro grim_set_user_data, grim_data, tag, data

 tlp = grim_data.user_tlp
 tag_list_set, tlp, tag, data

 grim_data.user_tlp = tlp

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_get_user_data
;
;=============================================================================
function grim_get_user_data, grim_data, tag

 tlp = grim_data.user_tlp
 data = tag_list_get(tlp, tag)

 return, data
end
;=============================================================================



;=============================================================================
; grim_n_colors
;
;=============================================================================
function grim_n_colors, type

 case type of
    1: n_colors = 256
    2 : n_colors = 256
    3: n_colors = 256
    4: n_colors = 256
    5: n_colors = 256
    else : n_colors = 256
 endcase

 return, n_colors
end
;=============================================================================



;=============================================================================
; grim_get_body_by_name_single
;
;=============================================================================
function grim_get_body_by_name_single, xd_p, name

 if(NOT ptr_valid(xd_p)) then return, 0
 names = cor_name(*xd_p)
 w = where(name EQ names)
 if(w[0] NE -1) then return, (*xd_p)[w]

 return, 0
end
;=============================================================================



;=============================================================================
; grim_get_body_by_name
;
;=============================================================================
function grim_get_body_by_name, name, plane=plane

 bx = grim_get_body_by_name_single(plane.pd_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.rd_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.sd_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.sund_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.std_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.ard_p, name)
 if(keyword_set(bx)) then return, bx

 bx = grim_get_body_by_name_single(plane.cd_p, name)
 if(keyword_set(bx)) then return, bx

 return, 0
end
;=============================================================================



;=============================================================================
; grim_shade_threshold
;
;=============================================================================
function grim_shade_threshold, ptd, shade, threshold

 pp = pnt_points(ptd, /vis)
 w = where(shade GT threshold)
 
 if(w[0] EQ -1) then $
  begin
   shade = 0
   return, 0
  end

 pp = pp[*,w]
 shade = shade[w]

 return, pp
end
;=============================================================================



;=============================================================================
; grim_parse_overlay
;
;  fn:name1,name2,...
;
;=============================================================================
function grim_parse_overlay, overlay, names

 names = ''

 s = str_split(overlay, ':')
 fn = s[0]
 if(n_elements(s) GT 1) then names = strupcase(str_nsplit(s[1], ','))

 return, fn
end
;=============================================================================



;=============================================================================
; grim_cat_bodies
;
;=============================================================================
function grim_cat_bodies, plane

 bx = [*plane.pd_p, *plane.rd_p]
 w = where(obj_valid(bx))
 if(w[0] EQ -1) then return, 0
 return, bx[w]
end
;=============================================================================



;=============================================================================
; grim_get_cursor_swap
;
;=============================================================================
function grim_get_cursor_swap, grim_data

 return, test_endian()

 swap = 0
 if(grim_data.cursor_swap EQ -1) then $
  begin
   if(test_endian()) then swap = 1
  end $
 else if(grim_data.cursor_swap EQ 1) then swap = 1

 return, swap
end
;=============================================================================



;=============================================================================
; grim_wset
;
;=============================================================================
pro grim_wset, grim_data, wnum, get_info=get_info, $
    save=save, noplot=noplot


 if(grim_data.type EQ 'plot') then tvgr, wnum, get_info=get_info, $
     save=save, noplot=noplot, /silent $
 else tvim, wnum, get_info=get_info, save=save, noplot=noplot, /silent 

end
;=============================================================================



;=============================================================================
; grim_logging_callback
;
;=============================================================================
pro grim_logging_callback, data_p, message
 grim_data = *data_p 

 grim_print, grim_data, message
end
;=============================================================================



;=============================================================================
; grim_logging
;
;=============================================================================
pro grim_logging, grim_data, start=start, stop=stop
common grim_logging_block, data_p=data_p

 tag = 'GRIM_LOGGING-'+strtrim(grim_data.base,2)

 if(keyword_set(start)) then $
  begin
   data_p = ptr_new(grim_data)
   nv_message, callback='grim_logging_callback', cb_tag=tag, cb_data_p=data_p
  end $
 else $
  begin
   nv_message, cb_tag=tag, /disconnect
   if(ptr_valid(data_p)) then ptr_free, data_p
   grim_print, grim_data, ''
  end

end
;=============================================================================



;=============================================================================
; grim_menu_delim_event
;
;=============================================================================
pro grim_menu_delim_event, event
end
;=============================================================================



;=============================================================================
; grim_parse_form_entry
;
;=============================================================================
function grim_parse_form_entry, ids, tags, tag, null=null, drop=drop, $
                                            numeric=numeric, string=string

 i = (where(strupcase(tags) EQ strupcase(tag)))[0]

 if(NOT keyword_set(drop)) then $
  begin   
   widget_control, ids[i], get_value=value

   null = 1
   if(NOT keyword_set(numeric)) then $
               if((strmid(value, 0, 1))[0] EQ '-') then return, 0
   null = 0

   if((size(value, /type) EQ 7) AND (NOT keyword_set(string))) then $
                                    value = str_sep(strtrim(value,2), ' ')
  end $
 else value = widget_info(ids[i], /droplist_select)

 if(keyword_set(string)) then value = value[0]

 return, value
end
;=============================================================================



;=============================================================================
; grim_set_form_entry
;
;=============================================================================
pro grim_set_form_entry, ids, tags, tag, value, drop=drop, cwbutton=cwbutton, $
        sensitive=sensitive

 i = (where(tags EQ tag))[0]

 if(n_elements(sensitive) NE 0) then widget_control, ids[i], sensitive=sensitive
 if(n_elements(value) EQ 0) then return

;print, i
 if(keyword_set(drop)) then widget_control, ids[i], set_droplist_select=value $
 else if(keyword_set(cwbutton)) then $
                                widget_control, ids[i], set_value=value $
 else widget_control, ids[i], set_value = strtrim(value,2) + ' '


end
;=============================================================================



;=============================================================================
; grim_add_callback
;
;=============================================================================
pro grim_add_callback, callbacks, data_ps, callbacks_list, data_ps_list

 if(NOT keyword__set(callbacks_list)) then callbacks_list = 0

 if(n_elements(callbacks) NE n_elements(data_ps)) then $
                       nv_message, /anonymous, 'Inconsistent callback registration.'

 if(NOT keyword__set(callbacks_list[0])) then $
  begin
   callbacks_list = callbacks
   data_ps_list = data_ps
  end $ 
 else $
  begin
   callbacks_list = [callbacks_list, callbacks]
   data_ps_list = [data_ps_list, data_ps]
  end

end
;=============================================================================



;=============================================================================
; grim_rm_callback
;
;=============================================================================
pro grim_rm_callback, data_ps, callbacks_list, data_ps_list

 if(NOT keyword__set(data_ps_list[0])) then return

 w = nwhere(data_ps_list, data_ps)
 if(w[0] EQ -1) then return
 ww = complement(data_ps_list, w)

 if(ww[0] EQ -1) then $
  begin
   callbacks_list = 0
   data_ps_list = 0
  end $
 else $
  begin
   callbacks_list = callbacks_list[ww]
   data_ps_list = data_ps_list[ww]
  end


end
;=============================================================================



;=============================================================================
; grim_call_callbacks
;
;=============================================================================
pro grim_call_callbacks, _callbacks_list, _data_ps_list, event

 if(NOT keyword__set(_callbacks_list)) then _callbacks_list = 0
 if(NOT keyword__set(_data_ps_list)) then _data_ps_list = 0
 callbacks_list = _callbacks_list
 data_ps_list = _data_ps_list

 if(keyword__set(callbacks_list[0])) then $
  begin
   n = n_elements(callbacks_list)
   for i=0, n-1 do $
    begin
     callback = callbacks_list[i]
     if(NOT keyword_set(event)) then call_procedure, callback, data_ps_list[i] $
     else call_procedure, callback, data_ps_list[i], event
    end
  end


end
;=============================================================================



;=============================================================================
; grim_get_menu_id
;
;=============================================================================
function grim_get_menu_id, grim_data, desc

 menu_ids = *grim_data.menu_ids_p
 menu_desc = *grim_data.menu_desc_p

 w = where(strpos(menu_desc, desc) NE -1)
 return, menu_ids[w[0]]
end
;=============================================================================



;=============================================================================
; grim_update_menu_toggle
;
;=============================================================================
pro grim_update_menu_toggle, grim_data, name, flag

 id = grim_get_menu_id(grim_data, name)

 onoff = flag ? 'ON' : 'OFF'
 widget_control, id, get_value=s

 ss = str_ext(s, '[', ']')
 sss = strep_s(s, ss, onoff)

 widget_control, id, set_value=sss
end
;=============================================================================



;=============================================================================
; grim_get_toggle_flag
;
;=============================================================================
function grim_get_toggle_flag, grim_data, name

 flag = grim_get_user_data(grim_data, 'GRIM_TOGGLE_' + name)
 if(NOT keyword_set(flag)) then flag = 0

 return, flag
end
;=============================================================================



;=============================================================================
; grim_set_toggle_flag
;
;=============================================================================
pro grim_set_toggle_flag, grim_data, name, flag

 grim_set_user_data, grim_data, 'GRIM_TOGGLE_' + name, flag

end
;=============================================================================



;=============================================================================
; grim_compare
;
;=============================================================================
function grim_compare, x1, x2

 if((NOT keyword_set(x1)) AND (NOT keyword_set(x1))) then return, 1

 nx1 = n_elements(x1)
 nx2 = n_elements(x2)
 
 type1 = size(x1, /type)
 type2 = size(x2, /type)

 if((type1 EQ 7) XOR (type2 EQ 7)) then return, 0

 if(nx1 NE nx2) then return, 0
 if(total(x1 EQ x2) NE nx1) then return, 0

 return, 1
end
;=============================================================================

pro grim_util_include
a=!null
end


