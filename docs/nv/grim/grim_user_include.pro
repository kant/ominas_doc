;=============================================================================
; grim_user_ptd_struct__define
;
;=============================================================================
pro grim_user_ptd_struct__define

 struct = $
    { grim_user_ptd_struct, $
	user_ptdp	:	ptr_new(), $
	color		:	'', $
	shade_fn	:	'', $
	psym		:	0, $
	thick		:	1, $
	line		:	1, $
	shade_threshold	:	0d, $
	graphics_fn	:	3, $
	xgraphics	:	0b, $
	symsize		:	0. $
    }


end
;=============================================================================



;=============================================================================
; grim_add_user_points
;
;=============================================================================
pro grim_add_user_points, grnum=grnum, user_ptd, tag, update=update, $
                  color=color, shade_fn=shade_fn, psym=psym, thick=thick, line=line, symsize=symsize, $
                  shade_threshold=shade_threshold, graphics_fn=graphics_fn, xgraphics=xgraphics, nodraw=nodraw, inactive=inactive, $
                  no_refresh=no_refresh, plane=plane

 if(NOT keyword_set(tag)) then tag = 'no_name'
 if(NOT keyword_set(symsize)) then symsize = 1
 if(NOT keyword_set(shade_fn)) then shade_fn = ''
 if(NOT keyword_set(shade_threshold)) then shade_threshold = 0d

 if(NOT defined(grnum)) then if(keyword_set(plane)) then grnum = plane.grnum
 grim_data = grim_get_data(grnum=grnum)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 pn = plane.pn

 n = n_elements(user_ptd)
 for i=0, n-1 do if(pnt_valid(user_ptd[i])) then cor_set_name, user_ptd[i], tag

 if(NOT keyword_set(color)) then color = 'purple' 

 if(NOT keyword_set(graphics_fn)) then graphics_fn = grim_data.default_user_graphics_fn
 if(NOT keyword_set(xgraphics)) then xgraphics = 0
 if(NOT keyword_set(psym)) then psym = grim_data.default_user_psym
 if(NOT keyword_set(thick)) then thick = grim_data.default_user_thick
 if(NOT keyword_set(line)) then line = grim_data.default_user_line

 user_struct = {grim_user_ptd_struct}
 user_struct.user_ptdp = ptr_new(user_ptd)
 user_struct.color = color
 user_struct.shade_fn = shade_fn
 user_struct.psym = psym
 user_struct.shade_threshold = shade_threshold
 user_struct.graphics_fn = graphics_fn
 user_struct.xgraphics = xgraphics
 user_struct.thick = thick
 user_struct.line = line
 user_struct.symsize = symsize

 tlp = plane.user_ptd_tlp
 if(keyword_set(update)) then $
              if((tag_list_match(tlp, tag))[0] EQ -1) then return

 tag_list_set, tlp, tag, user_struct, new=new, index=index
 plane.user_ptd_tlp = tlp
 grim_set_plane, grim_data, plane, pn=pn

 if(NOT keyword_set(inactive)) then grim_activate_user_overlay, plane, index


 if(keyword_set(nodraw)) then return

 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
; grim_user_notify
;
;=============================================================================
pro grim_user_notify, grim_data, plane=plane

 if(NOT keyword_set(plane.user_ptd_tlp)) then return
 if(NOT ptr_valid(plane.user_ptd_tlp)) then return

 names = tag_list_names(plane.user_ptd_tlp)
 n = n_elements(names)

 cd = *plane.cd_p

 nv_suspend_events

 for i=0, n-1 do $
  begin
   user_struct = tag_list_get(plane.user_ptd_tlp, names[i])
   ptd = *user_struct.user_ptdp
   nptd = n_elements(ptd)
   for j=0, nptd-1 do $
    begin
     v = pnt_vectors(ptd[j])
     if(keyword_set(v)) then $
                pnt_set_points, ptd[j], reform(inertial_to_image_pos(cd, v))
    end
  end

 nv_resume_events
end
;=============================================================================



;=============================================================================
; grim_update_user_points
;
;=============================================================================
pro grim_update_user_points, plane=plane, grnum=grnum, user_ptd, tag, $
                  color=color, shade_fn=shade_fn, psym=psym, thick=thick, line=line, symsize=symsize, $
                  shade_threshold=shade_threshold, graphics_fn=graphics_fn, xgraphics=xgraphics, nodraw=nodraw, $
                  no_refresh=no_refresh

 if(NOT keyword_set(grnum)) then if(keyword_set(plane)) then grnum = plane.grnum
 grim_data = grim_get_data(grnum=grnum)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 if(NOT keyword_set(plane.user_ptd_tlp)) then return
 if(NOT ptr_valid(plane.user_ptd_tlp)) then return


 user_struct = tag_list_get(plane.user_ptd_tlp, tag)

 if(arg_present(color)) then user_struct.color = color
 if(arg_present(shade_fn)) then user_struct.shade_fn = shade_fn
 if(arg_present(psym)) then user_struct.psym = psym
 if(arg_present(shade_threshold)) then user_struct.shade_threshold = shade_threshold
 if(arg_present(graphics_fn)) then user_struct.graphics_fn = graphics_fn
 if(arg_present(xgraphics)) then user_struct.xgraphics = xgraphics
 if(arg_present(thick)) then user_struct.thick = thick
 if(arg_present(line)) then user_struct.line = line
 if(arg_present(symsize)) then user_struct.symsize = symsize

 tlp = plane.user_ptd_tlp
 tag_list_set, tlp, tag, user_struct, new=new, index=index
 plane.user_ptd_tlp = tlp
 grim_set_plane, grim_data, plane, pn=pn


 if(keyword_set(nodraw)) then return
 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, /use_pixmap

end
;=============================================================================



;=============================================================================
; grim_rm_user_points
;
;=============================================================================
pro grim_rm_user_points, grim_data, tag, plane=plane, grnum=grnum

 if(NOT keyword_set(plane)) then $
  begin
   grim_data = grim_get_data(grnum=grnum)
   plane = grim_get_plane(grim_data)
  end

 if(NOT keyword_set(plane.user_ptd_tlp)) then return
 if(NOT ptr_valid(plane.user_ptd_tlp)) then return

 for i=0, n_elements(tag)-1 do tag_list_rm, plane.user_ptd_tlp, tag[i]


end
;=============================================================================



;=============================================================================
; grim_test_active_user_ptd
;
;=============================================================================
function grim_test_active_user_ptd, plane, tag, prefix=prefix

 if(NOT keyword_set(*plane.active_user_tags_p)) then return, 0

 w = tag_list_match(*plane.active_user_tags_p, tag, prefix=prefix)
 if(w[0] NE -1) then return, 1

 return, 0
end
;=============================================================================



;=============================================================================
; grim_get_user_ptd
;
;=============================================================================
function grim_get_user_ptd, grnum=grnum, tag, prefix=prefix, $
           plane=plane, color=color, shade_fn=shade_fn, $
           xgraphics=xgraphics, graphics_fn=graphics_fn, $
           shade_threshold=shade_threshold, psym=psym, thick=thick, $
           line=line, symsize=symsize, $
           tags=tags, active=active

; if(NOT keyword_set(tag)) then tag = 'no_name'

 if(NOT keyword_set(plane)) then $
  begin
   grim_data = grim_get_data(grnum=grnum)
   plane = grim_get_plane(grim_data)
  end

 if(NOT keyword_set(plane.user_ptd_tlp)) then return, 0
 if(NOT ptr_valid(plane.user_ptd_tlp)) then return, 0

 if(NOT keyword_set(tag)) then tag = (*plane.user_ptd_tlp).name

 n = n_elements(tag)

 user_ptd = 0
 for i=0, n-1 do $
  begin
   user_struct = tag_list_get(plane.user_ptd_tlp, tag[i], prefix=prefix)

   nu = n_elements(user_struct)
   if(keyword_set(user_struct)) then $
    if((NOT keyword_set(active)) OR $
        grim_test_active_user_ptd(plane, tag[i], prefix=prefix)) then $
     begin
      if(NOT keyword_set(user_ptd)) then $
       begin
        for j=0, nu-1 do $
            if(keyword_set(*user_struct[j].user_ptdp)) then $
                    user_ptd = append_array(user_ptd, *user_struct[j].user_ptdp)
        color = user_struct.color
        shade_fn = user_struct.shade_fn
        psym = user_struct.psym
        shade_threshold = user_struct.shade_threshold
        graphics_fn = user_struct.graphics_fn
        xgraphics = user_struct.xgraphics
        thick = user_struct.thick
        line = user_struct.line
        symsize = user_struct.symsize
        tags = tag[i]
       end $
      else $
       begin
        _user_ptd = objarr(nu)
;        for j=0, nu-1 do _user_ptd[j] = *user_struct[j].user_ptdp
        for j=0, nu-1 do _user_ptd[j] = (*user_struct[j].user_ptdp)[0]
        user_ptd = [user_ptd, _user_ptd]
        color = [color, user_struct.color]
        shade_fn = [shade_fn, user_struct.shade_fn]
        psym = [psym, user_struct.psym]
        shade_threshold = [shade_threshold, user_struct.shade_threshold]
        graphics_fn = [graphics_fn, user_struct.graphics_fn]
        xgraphics = [xgraphics, user_struct.xgraphics]
        thick = [thick, user_struct.thick]
        line = [line, user_struct.line]
        symsize = [symsize, user_struct.symsize]
        tags = [tags, tag[i]]
       end
     end
  end

 return, user_ptd
end
;=============================================================================



;=============================================================================
; grim_get_active_user_overlays
;
;=============================================================================
pro grim_get_active_user_overlays, plane, $
                         active_tags=active_tags, inactive_tags=inactive_tags

 if(NOT ptr_valid(plane.user_ptd_tlp)) then return

 tags = (*plane.user_ptd_tlp).name
 nuser = n_elements(tags)

 active_indices = -1
 inactive_indices = lindgen(nuser)
 inactive_tags = tags[inactive_indices]
 

 if(NOT keyword__set(*plane.active_user_tags_p)) then return
 active_user_tags = *plane.active_user_tags_p

 w = nwhere(tags, active_user_tags)
 if(w[0] EQ -1) then return

 active_indices = w
 inactive_indices = complement(tags, active_indices)

 inactive_tags = ''
 if(active_indices[0] NE -1) then active_tags = tags[active_indices]
 if(inactive_indices[0] NE -1) then inactive_tags = tags[inactive_indices]

end
;=============================================================================



;=============================================================================
; grim_trim_user_overlays
;
;=============================================================================
pro grim_trim_user_overlays, grim_data, plane=plane, region

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ptd = grim_get_user_ptd(plane=plane)
 if(keyword_set(ptd)) then pg_trim, 0, ptd, region

end
;=============================================================================



;=============================================================================
; grim_activate_user_overlay
;
;=============================================================================
pro grim_activate_user_overlay, plane, indices

 if(indices[0] EQ -1) then return
 if(NOT ptr_valid(plane.user_ptd_tlp)) then return

 tags = (*plane.user_ptd_tlp).name
 active_user_tags = *plane.active_user_tags_p
 given_user_tags = tags[indices]

 ;---------------------------------------------
 ; determine which user_ptd are already active
 ;---------------------------------------------
 n = n_elements(given_user_tags)
 w = [-1]
 ww = lindgen(n)

 if(keyword__set(active_user_tags)) then $
  begin
   w = nwhere(given_user_tags, active_user_tags)
   ww = complement(indices, w)
  end

 ;---------------------------------------------
 ; activate inactive user_ptd
 ;---------------------------------------------
 if(ww[0] NE -1) then $
  begin
   if(NOT keyword__set(active_user_tags)) then $
                              *plane.active_user_tags_p = given_user_tags[ww] $
   else *plane.active_user_tags_p = [active_user_tags, given_user_tags[ww]]
  end


end
;=============================================================================



;=============================================================================
; grim_deactivate_user_overlay
;
;=============================================================================
pro grim_deactivate_user_overlay, plane, indices

 if(indices[0] EQ -1) then return
 if(NOT ptr_valid(plane.user_ptd_tlp)) then return

 tags = (*plane.user_ptd_tlp).name
 active_user_tags = *plane.active_user_tags_p
 if(NOT keyword__set(active_user_tags)) then return
 given_user_tags = tags[indices]

 ;---------------------------------------------
 ; determine which user_ptd are already active
 ;---------------------------------------------
 n = n_elements(given_user_tags)
 w = [-1]
 ww = lindgen(n)

 w = nwhere(active_user_tags, given_user_tags)
 ww = complement(indices, w)

 ;---------------------------------------------
 ; activate inactive user_ptd
 ;---------------------------------------------
 if(w[0] NE -1) then $
  begin
    *plane.active_user_tags_p = $
                  rm_list_item(*plane.active_user_tags_p, w, only='')
    if(NOT keyword__set((*plane.active_user_tags_p)[0])) then $
                                                *plane.active_user_tags_p = ''
  end


end
;=============================================================================



;=============================================================================
; grim_clear_user_overlays
;
;=============================================================================
pro grim_clear_user_overlays, plane, tags

 ;------------------------------------------
 ; get tags of active user overlays
 ;------------------------------------------
; grim_get_active_user_overlays, plane, active_tags=active_tags
; if(NOT keyword__set(active_tags)) then return

 ;------------------------------------------
 ; remove active user overlays
 ;------------------------------------------
 n = n_elements(tags)
 for i=0, n-1 do tag_list_rm, plane.user_ptd_tlp, tags[i]

; if(NOT keyword__set((*plane.user_ptd_tlp)[0])) then ptr_free, plane.user_ptd_tlp

 ;------------------------------------------
 ; clear active user overlay array
 ;------------------------------------------
; *plane.active_user_tags_p = ''


end
;=============================================================================



;=============================================================================
; grim_clear_active_user_overlays
;
;=============================================================================
pro grim_clear_active_user_overlays, plane

 ;------------------------------------------
 ; get tags of active user overlays
 ;------------------------------------------
 grim_get_active_user_overlays, plane, active_tags=active_tags
 if(NOT keyword__set(active_tags)) then return

 ;------------------------------------------
 ; remove active user overlays
 ;------------------------------------------
 n = n_elements(active_tags)
 for i=0, n-1 do tag_list_rm, plane.user_ptd_tlp, active_tags[i]

; if(NOT keyword__set((*plane.user_ptd_tlp)[0])) then ptr_free, plane.user_ptd_tlp

 ;------------------------------------------
 ; clear active user overlay array
 ;------------------------------------------
 *plane.active_user_tags_p = ''


end
;=============================================================================



;=============================================================================
; grim_invert_active_user_overlays
;
;=============================================================================
pro grim_invert_active_user_overlays, plane

 if(NOT ptr_valid(plane.user_ptd_tlp)) then return

 ;---------------------------------------------------------
 ; determine which ptdp are currently active/inactive
 ;---------------------------------------------------------

 tags = (*plane.user_ptd_tlp).name
 active_user_tags = *plane.active_user_tags_p

 nptd = n_elements(tags)

 w = [-1]
 ww = lindgen(nptd)

 if(keyword__set(active_user_tags)) then $
  begin
   w = nwhere(tags, active_user_tags)		; active
   ww = complement(tags, w)			; inactive
  end

 ;---------------------------------------------
 ; deactivate active objects
 ;---------------------------------------------
 if(w[0] NE -1) then grim_deactivate_user_overlay, plane, w

 ;---------------------------------------------
 ; activate previously inactive objects
 ;---------------------------------------------
 if(ww[0] NE -1) then grim_activate_user_overlay, plane, ww

 
end
;=============================================================================

pro grim_user_include
a=!null
end

