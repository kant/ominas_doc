;=============================================================================
; grim_set_overlay_update_flag
;
;=============================================================================
pro grim_set_overlay_update_flag, ptd, value

 if(NOT keyword_set(ptd)) then return

 nptd = n_elements(ptd)
 for i=0, nptd-1 do if(obj_valid(ptd[i])) then $
   cor_set_udata, ptd[i], 'GRIM_UPDATE_FLAG', value, /noevent

end
;=============================================================================



;=============================================================================
; grim_get_overlay_update_flag
;
;=============================================================================
function grim_get_overlay_update_flag, ptd

 if(NOT keyword_set(ptd)) then return, 0

 nptd = n_elements(ptd)
 vals = bytarr(nptd)

 for i=0, nptd-1 do vals[i] = cor_udata(ptd[i], 'GRIM_UPDATE_FLAG')

 return, vals
end
;=============================================================================



;=============================================================================
; grim_get_updated_ptd
;
;=============================================================================
function grim_get_updated_ptd, _ptd, ii=ii, clear=clear

 ii = 0

 ptd = 0
 nptd = n_elements(_ptd)

 for i=0, nptd-1 do $
  begin
   val = grim_get_overlay_update_flag(_ptd[i])
   if(val[0] EQ 1) then $
    begin
     ptd = append_array(ptd, _ptd[i])
     ii = append_array(ii, [i])
    end
  end


 if(keyword_set(clear)) then grim_set_overlay_update_flag, ptd, 0


 if(NOT keyword__set(ii)) then ii = -1			; need keyword__set here!

 return, ptd
end
;=============================================================================



;=============================================================================
; grim_get_xd
;
;=============================================================================
function grim_get_xd, grim_data, plane=plane, class

 if(class[0] EQ '') then return, obj_new()

 if(class[0] EQ 'all') then class = ['planet', 'ring', 'sun', 'star', 'camera', 'station']

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 n = n_elements(class)

 xds = 0
 for i=0, n-1 do $
  case class[i] of
   'camera'	:	$
      if(keyword_set(*plane.cd_p)) then xds = append_array(xds, *plane.cd_p)
   'planet'	:	$
      if(keyword_set(*plane.pd_p)) then xds = append_array(xds, *plane.pd_p)
   'ring'	:	$
      if(keyword_set(*plane.rd_p)) then xds = append_array(xds, *plane.rd_p)
   'sun'	:	$
      if(keyword_set(*plane.sund_p)) then xds = append_array(xds, *plane.sund_p)
   'star'	:	$
      if(keyword_set(*plane.sd_p)) then xds = append_array(xds, *plane.sd_p)
   'station'	:	$
      if(keyword_set(*plane.std_p)) then xds = append_array(xds, *plane.std_p)
   'array'	:	$
      if(keyword_set(*plane.ard_p)) then xds = append_array(xds, *plane.ard_p)
  endcase


 return, xds
end
;=============================================================================



;=============================================================================
; grim_get_overlay_ptdp
;
;=============================================================================
function grim_get_overlay_ptdp, grim_data, name, plane=plane, $
                        data=data, class=class, dep=dep, labels=labels, ii=ii, $
                        color=color, psym=psym, tlab=tlab, tshade=tshade, $
                        symsize=symsize, shade=shade, tfill=tfill, genre=genre, fast=fast

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)
 grim_initial_overlays, grim_data, plane=plane

 if(keyword_set(name)) then if(name EQ 'all') then return, *plane.overlay_ptdps

 if(NOT defined(ii)) then $
  begin
   if(keyword_set(name)) then ii = where(*plane.overlay_names_p EQ name) $
   else if(keyword_set(class)) then ii = where(*plane.overlay_classes_p EQ class) $
   else if(keyword_set(genre)) then ii = where(*plane.overlay_genres_p EQ genre)
  end
 if(ii[0] EQ -1) then return, 0
 if(keyword_set(fast)) then return, (*plane.overlay_ptdps)[ii]

 ii = ii[0]

 name = (*plane.overlay_names_p)[ii]
 class = (*plane.overlay_classes_p)[ii]
 
 dep = *(*plane.overlay_dep_p)[ii]

 if(keyword_set((*plane.overlay_labels_p)[ii])) then $
                                  labels = *(*plane.overlay_labels_p)[ii]


 color = (*plane.overlay_color_p)[ii]
 psym = (*plane.overlay_psym_p)[ii]
 symsize = (*plane.overlay_symsize_p)[ii]
 shade = (*plane.overlay_shade_p)[ii]
 tlab = (*plane.overlay_tlab_p)[ii]
 tshade = (*plane.overlay_tshade_p)[ii]
 tfill = (*plane.overlay_tfill_p)[ii]

 data_p = (*plane.overlay_data_p)[ii]
 if(ptr_valid(data_p)) then data = *data_p

 return, (*plane.overlay_ptdps)[ii]
end
;=============================================================================



;=============================================================================
; grim_get_active_overlays
;
;=============================================================================
function grim_get_active_overlays, grim_data, plane=plane, type, $
     active_indices=active_indices, inactive_indices=inactive_indices

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 active_indices = -1


 ;-------------------------------------------------------------------------
 ; if initial overlays exist and have not yet been computed for this
 ; plane and overlays are not to be initially activated, then there
 ; are no active overlays.  In that case, only continue if indices for 
 ; inactive overlays are requested.
 ;-------------------------------------------------------------------------
; if(NOT arg_present(inactive_indices)) then $
;      if(keyword_set(plane.initial_overlays_p)) then $
;                          if(NOT grim_data.activate) then return, 0

 inactive_indices = -1

 ;-------------------------------------------
 ; determine which arrays to use
 ;-------------------------------------------
 ptd = *(grim_get_overlay_ptdp(grim_data, plane=plane, type))

 if(NOT keyword_set(ptd)) then return, 0
 nptd = n_elements(ptd)

 ;--------------------------------------
 ; find requested active overlay arrays
 ;--------------------------------------
 _inactive_indices = lindgen(nptd)
 active_ptd = 0

 if(keyword_set(*plane.active_overlays_ptdp)) then $
  begin
   w = nwhere(*plane.active_overlays_ptdp, ptd)
   ww = where(w NE -1)
   if(ww[0] NE -1) then $
    begin 
     w = w[ww]
     active_ptd = (*plane.active_overlays_ptdp)[w]

     _active_indices = nwhere(ptd, active_ptd)
     _inactive_indices = complement(ptd, _active_indices)
    end 
  end

 ;-----------------------------------------
 ; remove undefined overlays
 ;-----------------------------------------
 www = where(obj_valid(ptd))

 if(www[0] EQ -1) then return, 0

 if(defined(_active_indices)) then active_indices = _active_indices
 if(defined(_inactive_indices)) then inactive_indices = _inactive_indices

 w = n_where(www, active_indices)
 if(w[0] NE -1) then $
  begin
   active_indices = active_indices[w]
   active_ptd = active_ptd[w]
  end

 w = n_where(www, inactive_indices)
 if(w[0] NE -1) then inactive_indices = inactive_indices[w]

; if((active_indices[0] EQ -1) AND (inactive_indices[0] EQ -1)) then $
;  inactive_indices = lindgen()

 return, active_ptd
end
;=============================================================================



;=============================================================================
; grim_get_all_active_overlays
;
;=============================================================================
function grim_get_all_active_overlays, grim_data, plane=plane, names=names

 if(NOT keyword_set(names)) then $
   names = ['planet_center', $
            'limb', $
            'terminator', $
            'ring', $
            'star', $
            'station', $
            'array', $
            'planet_grid', $
            'ring_grid']

 for i=0, n_elements(names)-1 do $
  ptd = append_array(ptd, grim_get_active_overlays(grim_data, plane=plane, names[i]))

 return, ptd
end
;=============================================================================



;=============================================================================
; grim_get_all_overlays
;
;=============================================================================
function grim_get_all_overlays, grim_data, plane=plane, names=names

 if(NOT keyword_set(names)) then $
   names = ['planet_center', $
            'limb', $
            'terminator', $
            'ring', $
            'star', $
            'station', $
            'array', $
            'planet_grid', $
            'ring_grid']

 for i=0, n_elements(names)-1 do $
  ptd = append_array(ptd, *(grim_get_overlay_ptdp(grim_data, plane=plane, names[i])))

 return, ptd
end
;=============================================================================



;=============================================================================
; grim_get_active_xds
;
;=============================================================================
function grim_get_active_xds, plane, class, $
     active_indices=active_indices, inactive_indices=inactive_indices

 active_indices = -1

 ;-------------------------------------------
 ; determine which arrays to use
 ;-------------------------------------------
 if(NOT keyword_set(class)) then return, *plane.active_xd_p

 case class of
  'planet' :  xd_p = plane.pd_p
  'ring' :  xd_p = plane.rd_p
  'star' :  xd_p = plane.sd_p
  'station' :  xd_p = plane.std_p
 endcase

 if(NOT keyword_set(*xd_p)) then return, 0

 ;------------------------------
 ; get the descriptors
 ;------------------------------
 inactive_indices = lindgen(n_elements(*xd_p))

 if(NOT keyword_set(*plane.active_xd_p)) then return, 0

 n_active = n_elements(*plane.active_xd_p)
 w = make_array(n_active, val=-1l)
 for i=0, n_active-1 do $
           if(cor_class((*plane.active_xd_p)[i]) EQ strupcase(class)) then w[i] = i

 ww = where(w NE -1)
 if(ww[0] EQ -1) then return, 0 
 w = w[ww]

 active_xds = (*plane.active_xd_p)[w]

 ;-------------------------------------------
 ; get the corresponding points arrays
 ;-------------------------------------------
 active_indices = nwhere(cor_name(*xd_p), cor_name(active_xds))
 inactive_indices = complement(*xd_p, active_indices)

 return, active_xds
end
;=============================================================================



;=============================================================================
; grim_update_activated
;
;=============================================================================
pro grim_update_activated, grim_data, plane=plane

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; verify that all active arrays actually exist
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 active_ptd = *plane.active_overlays_ptdp
 if(keyword_set(active_ptd)) then $
  begin
   ptdps = grim_get_overlay_ptdp(grim_data, plane=plane, 'all')
   nptdps = n_elements(ptdps)

   n_active = n_elements(active_ptd)
   mark = make_array(n_active, val=1b)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; compare each active overlay to every existing overlay point.
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   for i=0, n_active-1 do $
    begin
     for j=0, nptdps-1 do $
      begin
       ptd = *ptdps[j]
       if(keyword_set(ptd)) then $
	begin
	 w = where(*ptdps[j] EQ active_ptd[i])
	 if(w[0] NE -1) then mark[i] = 0
	end
      end
    end

   w = where(mark EQ 1)
   if(w[0] NE -1) then $
      *plane.active_overlays_ptdp = $
		rm_list_item(*plane.active_overlays_ptdp, w, only=0)    
   if(NOT keyword_set((*plane.active_overlays_ptdp)[0])) then $
					 *plane.active_overlays_ptdp = 0
  end


 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; update activations for each descriptor type
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ss = sort(*plane.active_xd_p)
 *plane.active_xd_p = (*plane.active_xd_p)[ss]
 uu = uniq(*plane.active_xd_p)
 *plane.active_xd_p = (*plane.active_xd_p)[uu]

 grim_deactivate_xd, plane, *plane.pd_p
 grim_deactivate_xd, plane, *plane.rd_p
 grim_deactivate_xd, plane, *plane.sd_p
 grim_deactivate_xd, plane, *plane.std_p


 names = *plane.overlay_names_p
 for i=0, n_elements(names)-1 do $
  begin
   name = names[i]
   class = ''
   ptdp = grim_get_overlay_ptdp(grim_data, plane=plane, name, class=class) 
   if(keyword_set(*ptdp)) then $
    begin
     active_ptd = grim_get_active_overlays(grim_data, plane=plane, name, active=active)
     if(active[0] NE -1) then grim_activate_xd, plane, pnt_assoc_xd(active_ptd) 
    end
  end 

 ss = sort(*plane.active_xd_p)
 *plane.active_xd_p = (*plane.active_xd_p)[ss]
 uu = uniq(*plane.active_xd_p)
 *plane.active_xd_p = (*plane.active_xd_p)[uu]
end
;=============================================================================



;=============================================================================
; grim_add_activation_callback
;
;=============================================================================
pro grim_add_activation_callback, callbacks, data_ps, top=top, no_wset=no_wset

 grim_data = grim_get_data(top, no_wset=no_wset)

 act_callbacks = *grim_data.act_callbacks_p
 act_data_ps = *grim_data.act_callbacks_data_pp

 grim_add_callback, callbacks, data_ps, act_callbacks, act_data_ps

 *grim_data.act_callbacks_p = act_callbacks
 *grim_data.act_callbacks_data_pp = act_data_ps

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_rm_activation_callback
;
;=============================================================================
pro grim_rm_activation_callback, data_ps, top=top

 grim_data = grim_get_data(top)
 if(NOT grim_exists(grim_data)) then return

 act_callbacks = *grim_data.act_callbacks_p
 act_data_ps = *grim_data.act_callbacks_data_pp

 grim_rm_callback, data_ps, act_callbacks, act_data_ps

 *grim_data.act_callbacks_p = act_callbacks
 *grim_data.act_callbacks_data_pp = act_data_ps

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_call_activation_callbacks
;
;=============================================================================
pro grim_call_activation_callbacks, plane, ptd, arg

 grim_data = grim_get_data(grnum=plane.grnum)
 grim_call_callbacks, *grim_data.act_callbacks_p, $
                           *grim_data.act_callbacks_data_pp, {ptd:ptd, arg:arg}

end
;=============================================================================



;=============================================================================
; grim_fill
;
;=============================================================================
pro grim_fill, ptd, name, color

 shade = call_function('grim_shade_'+ name, data, ptd)
 col = make_array(n_elements(shade), val=color)
 nptd = n_elements(ptd)
 for j=0, nptd-1 do $
  begin
   p = pnt_points(ptd[j], /visible)

   if(keyword_set(p)) then $
    begin
;     device, set_graphics=1
     polyfill, p[0,*], p[1,*], col=call_function('ct' + col[j], shade[j])
     device, set_graphics=3
    end
  end


end
;=============================================================================



;=============================================================================
; grim_draw_standard_points
;
;=============================================================================
pro grim_draw_standard_points, grim_data, plane, _ptd, name, data, color, tshade, shade, $
                            psym=psym, psize=symsize, plabels=plabels, label_shade=label_shade
 ptd = pnt_cull(_ptd, /nofree)
 if(NOT keyword_set(ptd)) then return

 if(NOT tshade) then shade = 1.0 $
 else shade = call_function('grim_shade_'+ name, data, ptd)
 col = make_array(n_elements(shade), val=color)

 pg_draw, ptd, col=col, shades=shade, label_color='yellow', label_shade=label_shade, $
                                    psym=psym, psize=symsize, plabels=plabels


end
;=============================================================================



;=============================================================================
; grim_draw_standard_overlays
;
;=============================================================================
pro grim_draw_standard_overlays, grim_data, plane, inactive_color, $
       update=update, mlab=mlab

  names = *plane.overlay_names_p
  for i=0, n_elements(names)-1 do $
   begin
    name = names[i]
    ptdp = grim_get_overlay_ptdp(grim_data, plane=plane, name, data=data, $
             color=color, psym=psym, symsize=symsize, shade=shade, tlab=tlab, $
             tshade=tshade, tfill=tfill, labels=labels)
    if(color NE 'hidden') then $
     if(ptr_valid(ptdp)) then $
      if(keyword_set(*ptdp)) then $
       begin
        if(keyword_set(plane.override_color) $
                  AND (strupcase(plane.override_color) NE 'NONE')) then $
                                                   color = plane.override_color

        active_ptd = grim_get_active_overlays(grim_data, plane=plane, name, $
                                 active_indices=active, inactive_indices=inactive)

        plabels = make_array(n_elements(*ptdp), val='')
        if(keyword_set(mlab) AND tlab) then plabels = labels

        if(symsize LE 0) then $
         begin
          _symsize = call_function('grim_symsize_'+ name, data)
          if(_symsize[0] NE -1) then symsize = abs(symsize)*_symsize $
          else symsize = 1
         end


        ;- - - - - - - - - - - - - - - - - - - - - - -
        ; determine which overlays to actually draw
        ;- - - - - - - - - - - - - - - - - - - - - - -
        active_ptd = 0 & active_plabels = 0
        if(active[0] NE -1) then $
         begin
          active_ptd = (*ptdp)[active]
          active_plabels = plabels[active]
         end
        if(keyword_set(update)) then $
         begin
          active_ptd = grim_get_updated_ptd(active_ptd, ii=ii, /clear)
          if(keyword_set(active_ptd)) then active_plabels = active_plabels[ii]
         end

        inactive_ptd = 0 & inactive_plabels = 0
        if(inactive[0] NE -1) then $
         begin
          inactive_ptd = (*ptdp)[inactive]
          inactive_plabels = plabels[inactive]
         end
        if(keyword_set(update)) then $
         begin
          inactive_ptd = grim_get_updated_ptd(inactive_ptd, ii=ii, /clear)
          if(keyword_set(inactive_ptd)) then inactive_plabels = inactive_plabels[ii]
         end


        ;- - - - - - - - - - - - - - -
        ; fills
        ;- - - - - - - - - - - - - - -
        if(tfill) then $
         begin
          if(keyword_set(inactive_ptd)) then grim_fill, inactive_ptd, name, inactive_color
          if(keyword_set(active_ptd)) then grim_fill, active_ptd, name, color
         end $
        ;- - - - - - - - - - - - - - -
        ; points
        ;- - - - - - - - - - - - - - -
        else $
         begin
          ;- - - - - - - - - - - - - - -
          ; inactive points
          ;- - - - - - - - - - - - - - -
          if(keyword_set(inactive_ptd)) then $
              grim_draw_standard_points, grim_data, plane, $
                 inactive_ptd, name, data, inactive_color, tshade, shade, $
                 psym=psym, psize=symsize, plabels=inactive_plabels, label_shade=0.5
 
          ;- - - - - - - - - - - - - - -
          ; active points
          ;- - - - - - - - - - - - - - -
          if(keyword_set(active_ptd)) then $
              grim_draw_standard_points, grim_data, plane, $
                 active_ptd, name, data, color, tshade, shade, $
                 psym=psym, psize=symsize, plabels=active_plabels, label_shade=1.0
         end
       end
   end


end
;=============================================================================



;=============================================================================
; grim_draw_user_points
;
;=============================================================================
pro grim_draw_user_points, grim_data, plane, tags, xmap=xmap

 user_ptd = grim_get_user_ptd(plane=plane, tags) 
 n = n_elements(tags)

 ;-------------------------------------
 ; draw each user array
 ;-------------------------------------
 for i=0, n-1 do $
  begin
   ;- - - - - - - - - - - - - - - - - -
   ; get user array
   ;- - - - - - - - - - - - - - - - - -
   user_ptd = $
     grim_get_user_ptd(plane=plane, tags[i], $
                 color=user_color, shade_fn=user_shade_fn, $
                 shade_threshold=user_shade_threshold, graphics_fn=user_graphics_fn, $
                 xgraphics=user_xgraphics, $
                 psym=user_psym, thick=user_thick, line=user_line, $
                 symsize=user_symsize)

   np = n_elements(user_ptd)
   for j=0, np-1 do $
    begin
     ;- - - - - - - - - - - - - - - - - -
     ; draw only if not hidden
     ;- - - - - - - - - - - - - - - - - -
     if(user_color[0] NE 'hidden') then $
      begin
       ;- - - - - - - - - - - - - - - - - -
       ; get shade values
       ;- - - - - - - - - - - - - - - - - -
       shade = 1d

       if(keyword_set(user_shade_fn)) then $
                shade = call_function(user_shade_fn, user_ptd[j], grim_data, plane)

       ;- - - - - - - - - - - - - - - - - - - -
       ; determine which points are visible
       ;- - - - - - - - - - - - - - - - - - - -
       if(keyword_set(user_shade_fn) AND defined(user_shade_threshold)) then $
               p = grim_shade_threshold(user_ptd[j], shade, user_shade_threshold) $
       else p = pnt_points(user_ptd[j], /visible)

       ;- - - - - - - - - - - - - - - - - - - -
       ; proceed with visible points
       ;- - - - - - - - - - - - - - - - - - - -
       if(keyword_set(p)) then $
        begin
         ;- - - - - - - - - - - - - - - - - - - -
         ; parse user color
         ;- - - - - - - - - - - - - - - - - - - -
         if((str_isnum(strtrim(user_color,2)))[0] EQ -1) then $
          begin
            ucol = ctcolor(user_color, shade)
            uxcol = ctcolor(user_color)
          end $ 
         else $
          ucol = (uxcol = long(user_color))

         ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         ; draw points using standard plotting or add to xgraphics map
         ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         if(keyword_set(user_xgraphics)) then $
                 shade = xshade(p, shade, map=xmap, color=uxcol, /getmap, /tv) $
         else $
          pg_draw, p, col=ucol, psym=user_psym, $
               thick=user_thick, line=user_line, psize=user_symsize, $
               graphics=user_graphics_fn
        end
      end
    end
  end


end
;=============================================================================



;=============================================================================
; grim_draw_user_overlays
;
;=============================================================================
pro grim_draw_user_overlays, grim_data, plane, inactive_color

 xmap = 0

 ;--------------------------------------------------
 ; draw standard plots and build xgraphics map
 ;--------------------------------------------------
 if(keyword_set(plane.user_ptd_tlp)) then $
  begin
   grim_get_active_user_overlays, plane, $
			  active_tags=active_tags, inactive_tags=inactive_tags

   if(keyword_set(active_tags)) then $
	  grim_draw_user_points, grim_data, plane, active_tags, xmap=xmap


   if(keyword_set(inactive_tags)) then $
	   grim_draw_user_points, grim_data, plane, inactive_tags, xmap=xmap
  end


 ;-------------------------------------
 ; draw xgraphics map
 ;-------------------------------------
 if(keyword_set(xmap)) then $
  begin
   xmap = bytscl(xmap, max=512)			;;;;;;;;;;;;;;;;
   for i=1, 3 do $
           tv, byte((fix(smooth(xmap[*,*,i-1],3)) + $
                     fix(tvrd(0,0, !d.x_size,!d.y_size, i)))<255), 0,0, i 
  end

end
;=============================================================================



;=============================================================================
; grim_draw_roi
;=============================================================================
pro grim_draw_roi, grim_data, plane

if(pnt_valid(plane.roi_ptd)) then $
 begin
  p = pnt_points(plane.roi_ptd)
  plots, p, psym=-3, col=ctblue()
 end

end
;=============================================================================



;=============================================================================
; grim_draw_indexed_arrays
;=============================================================================
pro grim_draw_indexed_arrays, ptdp, psym=psym

 if(NOT keyword_set(psym)) then psym = 3

 if(ptr_valid(ptdp)) then $
  begin
   for i=0, n_elements(*ptdp)-1 do $
    if(pnt_valid((*ptdp)[i])) then $
     begin
      pnt_query, (*ptdp)[i], /visible, p=p, nv=n, $
                         uname='GRIM_INDEXED_ARRAY_LABEL', udata=label
      label = strtrim(label,2)

      if(n GT 0) then $
       begin
        plots, p, col=ctred(), psym=psym

        q = convert_coord(p[0,0], p[1,0], /data, /to_device)
        xyouts, /device, q[0,0]+4, q[1,0]+4, label, align=0.5

        q = convert_coord(p[0,n-1], p[1,n-1], /data, /to_device)
        xyouts, /device, q[0,0]+4, q[1,0]+4, label, align=0.5
       end
     end
  end

end
;=============================================================================



;=============================================================================
; grim_draw_curves
;
;=============================================================================
pro grim_draw_curves, grim_data, plane
 psym = 3
 if(grim_test_map(grim_data)) then psym = -3
 grim_draw_indexed_arrays, plane.curve_ptdp, psym=psym
end
;=============================================================================



;=============================================================================
; grim_draw_tiepoints
;
;=============================================================================
pro grim_draw_tiepoints, grim_data, plane
 grim_draw_indexed_arrays, plane.tiepoint_ptdp, psym=1
end
;=============================================================================



;=============================================================================
; grim_draw_mask
;
;=============================================================================
pro grim_draw_mask, grim_data, plane

 mask = *plane.mask_p

 if(mask[0] NE -1) then $
  begin
   dim = dat_dim(plane.dd)
   p = w_to_xy(0, mask, sx=dim[0], sy=dim[1])
   plots, p, psym=6, col=ctgreen();, symsize=
   q = convert_coord(p[0,*], p[1,*], /data, /to_device)
  end

end
;=============================================================================



;=============================================================================
; grim_draw
;
;=============================================================================
pro grim_draw, grim_data, planes=planes, $
       all=all, wnum=wnum, $
       user=user, tiepoints=tiepoints, mask=mask, curves=curves, $
       label=labels, readout=readout, measure=measure, update=update, $
       nopoints=nopoints, roi=roi, $
       no_user=no_user

 if(grim_data.hidden) then return

 if(keyword_set(wnum)) then grim_wset, grim_data, wnum $
 else grim_wset, grim_data, grim_data.wnum

 if(NOT keyword_set(planes)) then planes = grim_get_plane(grim_data)


; grim_wset, grim_data, grim_data.overlay_pixmap
; erase


 nplanes = n_elements(planes)
 for jj=0, nplanes-1 do $
  begin
   plane = planes[jj]

   inactive_color = 'cyan'
   hidden = 'hidden'

   if(keyword_set(all)) then $
    begin
     roi=1 & user=1 & curves=1 & tiepoints=1 & mlab = 1 & readout = 1 & mask=1 & & measure = 1
    end

   if(keyword_set(no_user)) then user = 0

;   if(grim_test_map(grim_data)) then mlab = 0


  ;--------------------------------
  ; standard overlay points
  ;--------------------------------
  if(NOT keyword_set(nopoints)) then $
    grim_draw_standard_overlays, grim_data, plane, inactive_color, $
                                                     update=update, mlab=mlab

   ;--------------------------------
   ; user overlay points
   ;--------------------------------
   if(keyword_set(user)) then $
          grim_draw_user_overlays, grim_data, plane, inactive_color


   ;--------------------------------
   ; roi
   ;--------------------------------
   if(keyword_set(roi)) then grim_draw_roi, grim_data, plane


   ;--------------------------------
   ; curves
   ;--------------------------------
   if(keyword_set(curves)) then grim_draw_curves, grim_data, plane


   ;--------------------------------
   ; tiepoints
   ;--------------------------------
   if(keyword_set(tiepoints)) then grim_draw_tiepoints, grim_data, plane


   ;--------------------------------
   ; mask
   ;--------------------------------
   if(keyword_set(mask)) then grim_draw_mask, grim_data, plane

  end


 ;--------------------------------
 ; readout mark
 ;--------------------------------
 if(keyword_set(readout)) then $
            plots, grim_data.readout_mark, psym=7, col=ctred()


 ;--------------------------------
 ; measure mark
 ;--------------------------------
 if(keyword_set(measure)) then $
            plots, grim_data.measure_mark, psym=-4, symsize=0.5, col=ctred()


 if(keyword_set(wnum)) then grim_wset, grim_data, grim_data.wnum

; grim_wset, grim_data, grim_data.wnum
;device, set_graphics=6
; device, copy=[0,0, !d.x_size,!d.y_size, 0,0, grim_data.overlay_pixmap]
;device, set_graphics=3


end
;=============================================================================



;=============================================================================
; grim_draw_grids
;
;=============================================================================
pro grim_draw_grids, grim_data, plane=plane, no_wset=no_wset
@grim_block.include

 ;--------------------------------------------
 ; image
 ;--------------------------------------------
 if(grim_data.type NE 'plot') then $
  begin

   ;----------------------------
   ; RA/DEC grid
   ;----------------------------
   if(grim_data.grid_flag) then $
      if(keyword_set(*plane.cd_p)) then $
               plots, radec_grid(*plane.cd_p), psym=3, col=ctblue()

   ;----------------------------
   ; pixel grid
   ;----------------------------
   if(grim_data.pixel_grid_flag) then $
               plots, pixel_grid(wnum=grim_data.wnum), psym=3, col=ctpurple()

  end $
 ;--------------------------------------------
 ; plot
 ;--------------------------------------------
 else $
  begin

  end


 
end
;=============================================================================



;=============================================================================
; grim_draw_axes
;
;=============================================================================
pro grim_draw_axes, grim_data, data, plane=plane, $
                    no_context=no_context, no_wset=no_wset
@grim_block.include

 ;--------------------------------------------
 ; images
 ;--------------------------------------------
 if(grim_data.type NE 'plot') then $
  begin
;   mg = 0.03
;   plot, [0], [0], /noerase, /data, pos=[mg,mg, 1.0-mg,1.0-mg]



   ;----------------------------
   ; main window image outline
   ;----------------------------
   dim = dat_dim(plane.dd)
   xsize = dim[0]
   ysize = dim[1]

   plots, [-0.5,xsize-0.5,xsize-0.5,-0.5,-0.5], $
          [-0.5,-0.5,ysize-0.5,ysize-0.5,-0.5], line=1


   ;----------------------------
   ; optic axis 
   ;----------------------------
   cd = *plane.cd_p
   if(keyword_set(cd)) then $
    if(cor_class(cd) EQ 'CAMERA') then $
     begin
      oaxis = cam_oaxis(cd)
 
      plots, oaxis, psym=1, symsize=4, col=ctred()
     end




   ;----------------------------
   ; current plane outline
   ;----------------------------
   if(grim_get_toggle_flag(grim_data, 'PLANE_HIGHLIGHT')) then $
    begin
     image = grim_get_image(grim_data, plane=plane, /current)
     outline_pts = image_outline(image)
     plots, outline_pts, psym=3, col=ctyellow()

     if(NOT keyword_set(no_context)) then $
      if(grim_data.context_mapped) then $
       begin
        grim_wset, grim_data, grim_data.context_pixmap
        plots, outline_pts, psym=3, col=ctyellow()
        grim_wset, grim_data, grim_data.wnum
       end
    end


   ;----------------------------
   ; pixel scales
   ;----------------------------



   ;----------------------------------------------------------------------
   ; inertial axes
   ;----------------------------------------------------------------------
   grim_show_axes, grim_data, plane
  end $
 ;--------------------------------------------
 ; plots
 ;--------------------------------------------
 else $
  begin
   ;------------------------------------------
   ; axes
   ;------------------------------------------
;   plots, plane.xrange, [0,0], line=1
;   plots, [0,0], plane.yrange, line=1


  end




 ;-----------------------------------------------
 ; primary window indicator outline
 ;-----------------------------------------------
 color = 0
 if(NOT widget_info(_primary, /valid)) then _primary = grim_data.base
 if(grim_data.base EQ _primary) then color = ctred() 
 if(NOT keyword__set(no_wset)) then grim_wset, grim_data, grim_data.wnum
 plots, [0,!d.x_size-1,!d.x_size-1,0,0], [0,0,!d.y_size-1,!d.y_size-1,0], $
           th=5, /device, color=color


 ;-----------------------------------------------
 ; FOV outline
 ;-----------------------------------------------



 ;----------------------------
 ; context window outline
 ;----------------------------
 if(NOT keyword_set(no_context)) then $
  if(grim_data.context_mapped) then $
   begin
    grim_wset, grim_data, grim_data.context_pixmap
    plots, /device, col=ctblue(), $
      [0,!d.x_size-1,!d.x_size-1,0,0], [0,0,!d.y_size-1,!d.y_size-1,0], th=4
    grim_wset, grim_data, grim_data.wnum


    ;-----------------------------------------------
    ; visible region outline in context window
    ;-----------------------------------------------
    p = tr([tr([0,0]),tr([!d.x_size, !d.y_size])])
    q = convert_coord(p, /device, /to_data)
    x0 = q[0,0]
    x1 = q[0,1]
    y0 = q[1,0]
    y1 = q[1,1]

    grim_wset, grim_data, grim_data.context_pixmap
    plots, /data, col=ctred(), [x0,x1,x1,x0,x0], [y0,y0,y1,y1,y0]
    grim_wset, grim_data, grim_data.wnum
   end

 
end
;=============================================================================



;=============================================================================
; grim_cat_points
;
;=============================================================================
function grim_cat_points, grim_data, all=all, active=active, plane=plane

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ptd = [pnt_create_descriptors()]


 ;------------------------------------
 ; only active points
 ;------------------------------------
 if(keyword_set(active)) then $
  begin
   if(keyword_set(*plane.active_overlays_ptdp)) then $
                         ptd = append_array(ptd, *plane.active_overlays_ptdp)

  end $
 ;------------------------------------
 ; all points
 ;------------------------------------
 else $
  begin
   ptdps = grim_get_overlay_ptdp(grim_data, plane=plane, 'all')
   if(keyword_set(ptdps)) then $
    begin
     n = n_elements(ptdps)
     for i=0, n-1 do ptd = append_array(ptd, decrapify((*ptdps[i])[*]))
    end

   user_ptd = grim_get_user_ptd(plane=plane)
   if(keyword_set(user_ptd)) then ptd = append_array(ptd, user_ptd)
  end


 if(n_elements(ptd) EQ 1) then return, 0

 return, ptd[1:*]
end
;=============================================================================



;=============================================================================
; grim_rm_points
;
;=============================================================================
pro grim_rm_points, plane, ptdp, ii


 if(NOT ptr_valid(ptdp)) then return
 ptd = (*ptdp)[ii]
 if(NOT keyword_set(ptd)) then return

 nv_notify_unregister, ptd, 'grim_descriptor_notify'

 *ptdp = rm_list_item(*ptdp, ii, only=0)

end
;=============================================================================



;=============================================================================
; grim_match_overlays
;
;=============================================================================
function grim_match_overlays, ptd, ptd0

 return, where((pnt_desc(ptd) EQ pnt_desc(ptd0)) $
                     AND (cor_name(ptd) EQ cor_name(ptd0)) )

; this is more unique, but much slower...
 return, where(cor_match_gd(ptd, ptd0) $
                   AND (pnt_desc(ptd) EQ pnt_desc(ptd0)) $
                     AND (cor_name(ptd) EQ cor_name(ptd0)) )

end
;=============================================================================



;=============================================================================
; grim_add_new_points
;
;=============================================================================
pro grim_add_new_points, grim_data, ptdp, ptd, name, cd, plane=plane

 ptd0 = *ptdp

 for i=0, n_elements(ptd)-1 do if(pnt_valid(ptd[i])) then $
  begin
   w = grim_match_overlays(ptd[i], ptd0)
   if(w[0] EQ -1) then $
      grim_add_points, grim_data, plane=plane, ptd, name=name, cd=cd, data=data
  end

end
;=============================================================================



;=============================================================================
; grim_rm_matched_points
;
;=============================================================================
pro grim_rm_matched_points, grim_data, ptdp, ptd, plane=plane

 ptd0 = *ptdp

 for i=0, n_elements(ptd)-1 do if(pnt_valid(ptd[i])) then $
  begin
   w = grim_match_overlays(ptd[i], ptd0)
   if(w[0] NE -1) then grim_rm_points, plane, ptdp, w
  end

end
;=============================================================================



;=============================================================================
; grim_update_points
;
;=============================================================================
pro grim_update_points, grim_data, ptd0, ptd, plane=plane

 for i=0, n_elements(ptd)-1 do if(pnt_valid(ptd[i])) then $
  begin
   w = grim_match_overlays(ptd[i], ptd0)

   if(w[0] NE -1) then $
    begin
     if(n_elements(w) EQ 1) then $
      begin
       pnt_set_points, ptd0[w], pnt_points(ptd[i])
       pnt_set_flags, ptd0[w], pnt_flags(ptd[i])
      end
    end
  end

end
;=============================================================================



;=============================================================================
; grim_add_points
;
;=============================================================================
pro grim_add_points, grim_data, ptd, plane=plane, $
         name=name, cd=cd, data=data


 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)
 n = n_elements(ptd)


 ;--------------------------------------------------------------------
 ; get all points arrays for this overlay type
 ;--------------------------------------------------------------------
 ptdp = grim_get_overlay_ptdp(grim_data, name, plane=plane, $
                                       class=class, dep=dep_classes, ii=ii)
 all_ptd = *ptdp
 nall = n_elements(all_ptd)


 ;-----------------------------------------------------------------------------
 ; if points exist for this type, replace existing points and append new ones
 ;-----------------------------------------------------------------------------
 if(keyword_set(all_ptd)) then $
  begin
   for i=0, n-1 do if(obj_valid(ptd[i])) then $
    begin
     w = grim_match_overlays(ptd[i], all_ptd)

     if(w[0] EQ -1) then *ptdp = [*ptdp, ptd[i]] $
     else (*ptdp)[w] = ptd[i]
    end
  end $
 ;--------------------------------------------------------------------
 ; otherwise add all points
 ;-------------------------------------------------------------------- 
 else *ptdp = ptd

 *ptdp = pnt_cull(*ptdp, /nofree)
 ptd = *ptdp
 n = n_elements(ptd) 


 ;--------------------------------------------------------------------
 ; add labels
 ;-------------------------------------------------------------------- 
 *(*plane.overlay_labels_p)[ii] = cor_name(ptd)


 ;--------------------------------------------------------------------
 ; add data
 ;-------------------------------------------------------------------- 
 if(keyword_set(data)) then *(*plane.overlay_data_p)[ii] = data


 ;--------------------------------------------------------------------
 ; determine dependencies
 ;-------------------------------------------------------------------- 
 for i=0, n-1 do $
  begin
   dep = cd

   xd = pnt_assoc_xd(ptd[i])
   if(keyword_set(xd)) then dep = [dep, xd]

   xds_all = grim_get_xd(grim_data, plane=plane, dep_classes)
   if(keyword_set(xds_all)) then dep = [dep, xds_all]

   cor_set_udata, ptd[i], 'grim_dep', dep, /noev
   cor_set_udata, ptd[i], 'grim_name', name, /noev
  end


end
;=============================================================================



;=============================================================================
; grim_default_activations
;
;=============================================================================
pro grim_default_activations, grim_data, plane=plane

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 ;--------------------------------------------------------------------------
 ; if there's only one of a type of object, then it is automatically active
 ;--------------------------------------------------------------------------
; if(keyword__set(*plane.pd_p)) then $
;   if(n_elements(*plane.pd_p) EQ 1) then grim_activate, plane, *plane.pd_p

; if(keyword__set(*plane.rd_p)) then $
;   if(n_elements(*plane.rd_p) EQ 1) then grim_activate, plane, *plane.rd_p

; if(keyword__set(*plane.sd_p)) then $
;   if(n_elements(*plane.sd_p) EQ 1) then grim_activate, plane, *plane.sd_p


end
;=============================================================================



;=============================================================================
; grim_clear_overlay_points
;
;=============================================================================
pro grim_clear_overlay_points, ptdp, active_ptdp
@pnt_include.pro

 if(NOT keyword_set(*active_ptdp)) then return
 if(NOT keyword_set(*ptdp)) then return

 n_active = n_elements(*active_ptdp)

 for i=0, n_active-1 do $
  begin
   w = where(*ptdp EQ (*active_ptdp)[i])
   if(w[0] NE -1) then grim_rm_points, plane, ptdp, w[0]

;;   if(w[0] NE -1) then *ptdp = rm_list_item(*ptdp, w[0], only=0)
;;   if(NOT keyword_set(*ptdp[0])) then *ptdp = 0
  end

end
;=============================================================================



;=============================================================================
; grim_clear_active_overlays
;
;=============================================================================
pro grim_clear_active_overlays, grim_data, plane

 ;------------------------------------------
 ; make active overlay points invisible
 ;------------------------------------------
 names = *plane.overlay_names_p
 for i=0, n_elements(names)-1 do $
  grim_clear_overlay_points, $
     grim_get_overlay_ptdp(grim_data, plane=plane, names[i]), $
                                                  plane.active_overlays_ptdp

 ;------------------------------------------
 ; clear active overlay arrays
 ;------------------------------------------
 *plane.active_overlays_ptdp = 0


end
;=============================================================================



;=============================================================================
; grim_frame_overlays
;
;=============================================================================
pro grim_frame_overlays, grim_data, plane, ptd, slop=slop, xy=xy

 if(NOT keyword_set(slop)) then slop = 0.1
 
 ;--------------------------------
 ; compute corners
 ;--------------------------------
 pp = pnt_points(/cat, /vis, ptd)
 npp = n_elements(pp)/2

 xmin = min(pp[0,*])
 xmax = max(pp[0,*])
 ymin = min(pp[1,*])
 ymax = max(pp[1,*])

 dx = xmax - xmin
 dy = ymax - ymin

 xslop = dx*slop
 yslop = dy*slop

 xmin = xmin - xslop
 xmax = xmax + xslop
 ymin = ymin - yslop
 ymax = ymax + yslop


 ;--------------------------------
 ; compute new tvim params
 ;--------------------------------
 offset = [xmin, ymin]

 if(keyword_set(xy)) then $
      zoom = [!d.x_size/abs(xmin-xmax), !d.y_size/abs(ymin-ymax)] $
 else zoom = !d.x_size/abs(xmin-xmax) < !d.y_size/abs(ymin-ymax)

 tvim, offset=offset, zoom=zoom, /inherit, /silent

 cx = !d.x_size/2
 cy = !d.y_size/2
 q = convert_coord(cx, cy, /device, /to_data)
 p = 0.5d*[xmin+xmax, ymin+ymax]
 tvim, doffset=(p-q)[0:1], /inherit, /silent


end
;=============================================================================



;=============================================================================
; grim_hide_overlays
;
;=============================================================================
pro grim_hide_overlays, grim_data, no_refresh=no_refresh, bm=bm

 if(grim_data.hidden) then $
  begin
   grim_data.hidden = 0
   bm = grim_hide_bitmap()
  end $
 else $
  begin
   grim_data.hidden = 1
   bm = grim_unhide_bitmap()
  end

 widget_control, grim_data.hide_button, set_value=bm

 grim_set_data, grim_data, grim_data.base
 if(NOT keyword_set(no_refresh)) then grim_refresh, grim_data, /use_pixmap, /noglass

end
;=============================================================================



;=============================================================================
; grim_clear_objects
;
;=============================================================================
pro grim_clear_objects, grim_data, all=all, $
     cd=cd, pd=pd, rd=rd, sd=sd, std=std, sund=sund, planes=planes

 if(NOT keyword_set(planes)) then planes = grim_get_plane(grim_data)
 n = n_elements(planes)

 for i=0, n-1 do $
  begin
   ;----------------------------------
   ; clear descriptors
   ;----------------------------------
   if((keyword_set(all)) OR (keyword_set(cd))) then $
     grim_rm_descriptor, grim_data, plane=planes[i], planes[i].cd_p
   if((keyword_set(all)) OR (keyword_set(pd))) then $
     grim_rm_descriptor, grim_data, plane=planes[i], planes[i].pd_p
   if((keyword_set(all)) OR (keyword_set(rd))) then $
     grim_rm_descriptor, grim_data, plane=planes[i], planes[i].rd_p
   if((keyword_set(all)) OR (keyword_set(sd))) then $
     grim_rm_descriptor, grim_data, plane=planes[i], planes[i].sd_p
   if((keyword_set(all)) OR (keyword_set(std))) then $
     grim_rm_descriptor, grim_data, plane=planes[i], planes[i].std_p
   if((keyword_set(all)) OR (keyword_set(sund))) then $
     grim_rm_descriptor, grim_data, plane=planes[i], planes[i].sund_p

   if(keyword_set(all)) then *planes[i].active_xd_p = 0

   ;----------------------------------
   ; clear points arrays
   ;----------------------------------
   names = *planes[i].overlay_names_p
   for j=0, n_elements(names)-1 do $
    begin
     name = names[j]
     ptdp = grim_get_overlay_ptdp(grim_data, plane=planes[i], name, class=class)

     if(keyword_set(all)) then $
                *(grim_get_overlay_ptdp(grim_data, plane=planes[i], name)) = 0
    end

   if(keyword_set(all)) then *planes[i].active_overlays_ptdp = 0

   if(keyword_set(all)) then ptr_free, planes[i].user_ptd_tlp	; Need to free all the pointers!!
   if(keyword_set(all)) then planes[i].user_ptd_tlp = ptr_new()
  end

 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_place_readout_mark
;
;=============================================================================
pro grim_place_readout_mark, grim_data, p

 ;------------------------
 ; erase old mark
 ;------------------------
; grim_refresh, grim_data, /use_pixmap
; q = convert_coord(grim_data.readout_mark[0], grim_data.readout_mark[1], $
;                                                           /data, /to_device)
; grim_display, grim_data, /use_pixmap, $
;                     pixmap_box_center=q[0:1], pixmap_box_side=10


 ;------------------------
 ; add new mark
 ;------------------------
 grim_data.readout_mark = p


 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_place_measure_mark
;
;=============================================================================
pro grim_place_measure_mark, grim_data, p

 ;------------------------
 ; erase old mark
 ;------------------------
; q = convert_coord(grim_data.measure_mark[0], grim_data.measure_mark[1], $
;                                                           /data, /to_device)
; grim_display, grim_data, /use_pixmap, $
;                pixmap_box_center=q[0:1], pixmap_box_side=10


 ;------------------------
 ; add new mark
 ;------------------------
 grim_data.measure_mark = p


 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_get_indexed_array
;
;=============================================================================
function grim_get_indexed_array, plane, name
 fields = tag_names(plane)
 ii_ptdp = where(fields EQ name+'_PTDP')
 return, plane.(ii_ptdp)
end
;=============================================================================



;=============================================================================
; grim_indexed_array_fname
;
;=============================================================================
function grim_indexed_array_fname, grim_data, plane, name, basename=basename
 if(NOT keyword_set(basename)) then basename = cor_name(plane.dd)
 return, grim_data.workdir + '/' + basename + '.' + strlowcase(name) + '_ptd'
end
;=============================================================================



;=============================================================================
; grim_write_indexed_arrays
;
;=============================================================================
pro grim_write_indexed_arrays, grim_data, plane, name, fname=fname

 if(NOT keyword_set(fname)) then $
                fname = grim_indexed_array_fname(grim_data, plane, name)

 tie_ptd = *plane.tiepoint_ptdp
 ptdp = grim_get_indexed_array(plane, name)
 ptd = *ptdp

 w = where(pnt_valid(ptd))
 if(w[0] NE -1) then pnt_write, fname, ptd[w] $
 else $
  begin
   ff = findfile(fname)
   if(keyword_set(ff)) then file_delete, fname, /quiet
  end

end
;=============================================================================



;=============================================================================
; grim_read_indexed_arrays
;
;=============================================================================
pro grim_read_indexed_arrays, grim_data, plane, name, fname=fname

 if(NOT keyword_set(fname)) then $
                fname = grim_indexed_array_fname(grim_data, plane, name)

 ff = (findfile(fname))[0]
 if(keyword_set(ff)) then ptd = pnt_read(ff) $
 else ptd = 0

 ptdp = grim_get_indexed_array(plane, name)

 w = where(pnt_valid(ptd))
 if(w[0] EQ -1) then return
 n = n_elements(w)

 for i=0, n-1 do $
  begin
   label = cor_udata(ptd[i], 'GRIM_INDEXED_ARRAY_LABEL')
   if(NOT keyword_set(label)) then label = strtrim(i,2)
   grim_add_indexed_array, ptdp, pnt_points(ptd[i]), label=label
  end


end
;=============================================================================



;=============================================================================
; grim_unique_array_label
;
;=============================================================================
function grim_unique_array_label, ptdp

 ptd = *ptdp
 if(NOT keyword_set(ptd)) then return, 0
 nptd = n_elements(ptd)

 ii = make_array(nptd, val=-1)
 for i=0, nptd-1 do if(keyword_set(ptd[i])) then $
                ii[i] = cor_udata(ptd[i], 'GRIM_INDEXED_ARRAY_LABEL')

 diff = set_difference(ii, lindgen(max(ii)+1))
 if(diff[0] EQ -1) then return, nptd

 return, min(diff)
end
;=============================================================================



;=============================================================================
; grim_add_indexed_array
;
;=============================================================================
pro grim_add_indexed_array, ptdp, p, ptd=ptd, $
           nointerp=nointerp, spacing=spacing, flags=flags, label=label

 if(NOT keyword_set(spacing)) then spacing = 1
 np = n_elements(p)/2

 ;-----------------------------------------
 ; interpolate 
 ;-----------------------------------------
 pp = p
 if(np GT 1) then $
  begin
   q1 = convert_coord(/device, /to_data, 0, 0)
   q2 = convert_coord(/device, /to_data, 1, 1)
   sample = abs(q1[0]-q2[0])*spacing

   if(NOT keyword_set(nointerp)) then pp = p_sample(p, sample) $
   else pp = p
 
   if(NOT keyword_set(p)) then return
  end

 ;-----------------------------------------
 ; set up array pointer
 ;-----------------------------------------
 if(NOT keyword_set(label)) then label = grim_unique_array_label(ptdp)

 ptd = pnt_create_descriptors(points=pp, $
        uname='GRIM_INDEXED_ARRAY_LABEL', $
        udata=label)


 ;------------------------------------------------------------------------
 ; add the array
 ;------------------------------------------------------------------------
; *ptdp = [*ptdp, ptd]
 *ptdp = append_array(*ptdp, ptd)

 if(defined(flags)) then pnt_set_flags, ptd, flags

end
;=============================================================================



;=============================================================================
; grim_select_array_by_box
;
;
;=============================================================================
function grim_select_array_by_box, grim_data, ptd, cx, cy, plane=plane
@pnt_include.pro

 ii = -1

 ;---------------------------------
 ; get get data coords of corners
 ;---------------------------------
 corners = convert_coord(cx, cy, /device, /to_data)

 ;-------------------------------------
 ; scan arrays
 ;-------------------------------------
 for i=0, n_elements(ptd)-1 do $
  if(pnt_valid(ptd[i])) then $
   begin
    pts = pnt_points(ptd[i])

    if(keyword_set(pts)) then $
     begin
      w = where((max(pts[0,*]) LE max(corners[0,*])) $
                    AND (min(pts[0,*]) GE min(corners[0,*])) $
                       AND (max(pts[1,*]) LE max(corners[1,*])) $
                          AND (min(pts[1,*]) GE min(corners[1,*])))
      if(w[0] NE -1) then ii = [ii, i]
     end
   end

 nii = n_elements(ii)
 if(nii GT 1) then ii = ii[1:*]

 return, ii
end
;=============================================================================



;=============================================================================
; grim_select_array_by_point
;
;=============================================================================
function grim_select_array_by_point, grim_data, ptd, p, all=all, plane=plane

d2min = 100
 ii = -1


 ;-----------------------------------------------------
 ; compute distance from p to each array
 ;-----------------------------------------------------
 for i=0, n_elements(ptd)-1 do $
  if(pnt_valid(ptd[i])) then $
   begin
    pts = pnt_points(ptd[i])
    n = n_elements(pts)/2

    q = (convert_coord(/data, /to_device, p[0], p[1]))[0:1,*]
    cq = (convert_coord(/data, /to_device, pts[0,*], pts[1,*]))[0:1,*]

    qq = q#make_array(n,val=1d) 

    d2 = (qq[0,*]-cq[0,*])^2 + (qq[1,*]-cq[1,*])^2

    ;- - - - - - - - - - - - - - - - - - - - -
    ; remove lowest numbered array in range
    ;- - - - - - - - - - - - - - - - - - - - -
    w = where(d2 LE d2min)
    if(w[0] NE -1) then ii = [ii, i]
   end

 nii = n_elements(ii)
 if(nii GT 1) then ii = ii[1:*]

 return, ii
end
;=============================================================================



;=============================================================================
; grim_select_array
;
;=============================================================================
function grim_select_array, grim_data, plane=plane, ptd, p

d2min = 9

 ;---------------------------------------------
 ; remove array under initial cursor point
 ;---------------------------------------------
 ii = grim_select_array_by_point(grim_data, ptd, p, all=all, plane=plane)
 if(ii[0] NE -1) then return, ii

 ;-----------------------------------------------------------------------------
 ; if nothing removed by the initial click, get user-defined box on image
 ;-----------------------------------------------------------------------------

 ;- - - - - - - - - - - - - - -
 ; drag box
 ;- - - - - - - - - - - - - - -
 q = (convert_coord(/data, /to_device, p[0], p[1]))[0:1,*]
 box = tvrec(/restore, p0=q, col=ctyellow())

 cx = box[0,*]
 cy = box[1,*]
 d2 = (cx[0] - cx[1])^2 + (cy[0] - cy[1])^2 

 ;- - - - - - - - - - - - - - - - - - - - - - - -
 ; select overlays inside box, if dragged
 ;- - - - - - - - - - - - - - - - - - - - - - - -
 box = 1
 if(d2 LE d2min) then box = 0

 if(box) then $
  begin
   ii = grim_select_array_by_box(grim_data, ptd, cx, cy, plane=plane)
   if(ii[0] NE -1) then return, ii
  end

 return, -1
end
;=============================================================================



;=============================================================================
; grim_rm_indexed_array
;
;=============================================================================
pro grim_rm_indexed_array, grim_data, plane=plane, name, p, all=all

 ptdp = grim_get_indexed_array(plane, name)

 if(keyword__set(all)) then $
  begin
   nv_free, *ptdp
   *ptdp = obj_new()
  end $
 else $
  begin
   ii = grim_select_array(grim_data, plane=plane, *ptdp, p)
   if(ii[0] NE -1) then $
    begin
     nv_free, (*ptdp)[ii]
*ptdp = rm_list_item(*ptdp, ii, only=obj_new())
;     (*ptdp)[ii] = obj_new()
    end
  end


 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_add_tiepoint
;
;=============================================================================
pro grim_add_tiepoint, grim_data, p, plane=plane, nointerp=nointerp, spacing=spacing, $
         no_sync=no_sync, flags=flags

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(plane=plane)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 grim_add_indexed_array, $
        plane.tiepoint_ptdp, p, nointerp=nointerp, spacing=spacing, flags=flags, ptd=ptd

 grim_set_plane, grim_data, plane, pn=plane.pn	
 grim_set_data, grim_data, grim_data.base


 if(NOT keyword_set(no_sync)) then grim_push_indexed_array, grim_data, ptd, 'TIEPOINT'
end
;=============================================================================



;=============================================================================
; grim_add_curve
;
;=============================================================================
pro grim_add_curve, grim_data, p, plane=plane, nointerp=nointerp, spacing=spacing, $
         no_sync=no_sync, flags=flags

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(plane=plane)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 grim_add_indexed_array, $
     plane.curve_ptdp, p, nointerp=nointerp, spacing=spacing, flags=flags, ptd=ptd

 grim_set_plane, grim_data, plane, pn=plane.pn	
 grim_set_data, grim_data, grim_data.base


 if(NOT keyword_set(no_sync)) then grim_push_indexed_array, grim_data, ptd, 'CURVE'
end
;=============================================================================



;=============================================================================
; grim_rm_tiepoint
;
;=============================================================================
pro grim_rm_tiepoint, grim_data, p, all=all, plane=plane, nosync=nosync

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)
 grim_rm_indexed_array, grim_data, plane=plane, 'TIEPOINT', p, all=all

 if(NOT keyword_set(no_sync)) then $
                   grim_push_indexed_array, grim_data, ptd, 'TIEPOINT', /rm
end
;=============================================================================



;=============================================================================
; grim_rm_curve
;
;=============================================================================
pro grim_rm_curve, grim_data, p, all=all, plane=plane, nosync=nosync

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)
 grim_rm_indexed_array, grim_data, plane=plane, 'CURVE', p, all=all

 if(NOT keyword_set(no_sync)) then $
                grim_push_indexed_array, grim_data, ptd, 'CURVE', /rm
end
;=============================================================================



;=============================================================================
; grim_set_roi
;
;=============================================================================
pro grim_set_roi, grim_data, roi, p, plane=plane

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(plane=plane)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 *plane.roi_p = roi
 flags = bytarr(n_elements(p)/2)
 pnt_set_points, plane.roi_ptd, p
 pnt_set_flags, plane.roi_ptd, flags

 if(grim_data.type EQ 'plot') then $
  begin
   dat = dat_data(plane.dd)

   ddx = dat[0,*]
   px = p[0,*]

   w = where((ddx GE floor(min(px))) AND (ddx LE ceil(max(px))))
   nw = n_elements(w)

   roi = lindgen(nw) + fix(min(px))
  end


 *plane.roi_p = roi

 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base


end
;=============================================================================



;=============================================================================
; grim_add_mask
;
;=============================================================================
pro grim_add_mask, grim_data, p, plane=plane, replace=replace, subscript=subscript
@pnt_include.pro

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data(plane=plane)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 p = round(p)

 mask = *plane.mask_p

 dim = dat_dim(plane.dd)

 if(keyword_set(subscript)) then sub = p $
 else sub = xy_to_w(0, p, sx=dim[0], sy=dim[1])


 if((mask[0] EQ -1) OR keyword_set(replace)) then mask = sub $
 else mask = [mask, sub]

; mask = mask[unique(mask)]
 *plane.mask_p = mask
 

 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_copy_mask
;
;=============================================================================
pro grim_copy_mask, grim_data, plane, planes

 n = n_elements(planes)
 
 for i=0, n-1 do $
  begin
   *planes[i].mask_p =*plane.mask_p
   grim_set_plane, grim_data, planes[i], pn=pn
  end

 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_copy_indexed_array
;
;=============================================================================
pro grim_copy_indexed_array, grim_data, plane, planes, name

 ptdp = grim_get_indexed_array(plane, 'CURVE')

 n = n_elements(planes)
 nptd = n_elements(*ptdp)
 
 for i=0, n-1 do $
  begin
   ptdp_i = grim_get_indexed_array(planes[i], 'CURVE')

   pn = planes[i].pn
   nv_free, *ptdp_i
   
   *ptdp_i = objarr(nptd)
   for j=0, nptd-1 do (*ptdp_i)[j] = nv_clone((*ptdp)[j])

   grim_set_plane, grim_data, planes[i], pn=pn
  end

 grim_set_data, grim_data, grim_data.base

end
;=============================================================================



;=============================================================================
; grim_copy_tiepoint
;
;=============================================================================
pro grim_copy_tiepoint, grim_data, plane, planes
 grim_copy_indexed_array, grim_data, plane, planes, 'TIEPOINT'
end
;=============================================================================



;=============================================================================
; grim_copy_curve
;
;=============================================================================
pro grim_copy_curve, grim_data, plane, planes
 grim_copy_indexed_array, grim_data, plane, planes, 'CURVE'
end
;=============================================================================



;=============================================================================
; grim_get_tiepoint_indices
;
;=============================================================================
function grim_get_tiepoint_indices, grim_data, plane=plane
@pnt_include.pro

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 ptdp = grim_get_indexed_array(plane, 'TIEPOINT')
 ii = where(ptr_vaid(*ptdp))

 return, ii
end
;=============================================================================



;=============================================================================
; grim_replace_tiepoints
;
;=============================================================================
pro grim_replace_tiepoints, grim_data, ii, p, plane=plane

 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 ptdp = grim_get_indexed_array(plane, 'TIEPOINT')
 nii = n_element(ii)
 for i=0, nii-1 do pnt_set_points, (*ptdp)[ii[i]], p[*,i]

 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_image_to_surface
;
;=============================================================================
function grim_image_to_surface, grim_data, plane, image_pts, $
                      body_pts=near_pts, $
                      far_pts=surf_pts_far, names=names, bx=bx;, valid=valid
@grim_block.include
@pnt_include.pro


 cd = *plane.cd_p
 surf_pts = 0

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; map
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 if(grim_test_map(grim_data)) then $
  begin
   map_pts = map_image_to_map(cd, image_pts, valid=valid)
   if(valid[0] NE -1) then $
    begin
     surf_pts = map_to_surface(cd, 0, map_pts[*,valid])
     names = make_array(n_elements(valid), val=cor_name(cd))
    end
  end $
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; otherwise test all bodies
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 else $
  begin
   bx = grim_cat_bodies(plane)
   nbx = n_elements(bx)

   raytrace, image_pts, cd=cd, bx=bx, hit_indices=ii, $
                 range_matrix=dist, hit_matrix=near_pts, far_matrix=far_pts
   w = -1

   bx = bx[ii]
   w = where(ii NE -1)
   nw = n_elements(w)

   if(w[0] NE -1) then $
    begin
     names = cor_name(bx[w])
     surf_pts = body_to_surface(bx[w], near_pts[w,*])
     surf_pts_far = body_to_surface(bx[w], far_pts[w,*])
    end


;   ;- - - - - - - - - - - - - - - - - - - - - - - - -
;   ; any unaccounted for points go to the sky
;   ;- - - - - - - - - - - - - - - - - - - - - - - - -
;   w = complement(ii, valid)
;   if(w[0] NE -1) then $
;    begin
;     names[w] = 'SKY'
;     surf_pts[w,*] = image_to_radec(cd, image_pts[*,w])
;    end

  end 


 return, surf_pts
end
;=============================================================================



;=============================================================================
; grim_surface_to_image
;
;=============================================================================
function grim_surface_to_image, grim_data, plane, surf_pts, names, valid=valid
@grim_block.include
@pnt_include.pro

 cd = *plane.cd_p
 image_pts = 0

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; map 
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 if(grim_test_map(grim_data)) then $
  begin
   name = cor_name(cd)   
   w = where(names EQ name)

   if(w[0] NE -1) then $
    begin
     image_pts = surface_to_image(cd, 0, surf_pts[w,*])
    end
  end $
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; non-map 
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 else $
  begin
   bx = grim_cat_bodies(plane)
   all_names = cor_name(bx)

   for k=0, n_elements(all_names)-1 do $
    begin
     w = where(names EQ all_names[k])
     if(w[0] NE -1) then $
	 image_pts = surface_to_image(cd, bx[k], surf_pts[w,*], body_pts=body_pts)
     r = bod_inertial_to_body_pos(bx[k], bod_pos(cd))
    end

;   ;- - - - - - - - - - - - - - - - - - - - - - - - -
;   ; sky points 
;   ;- - - - - - - - - - - - - - - - - - - - - - - - -
;   w = where(names EQ 'SKY')
;   if(w[0] NE -1) then image_pts[*,w] = radec_to_image(cd, surf_pts[w,*])
  end

 return, image_pts
end
;=============================================================================



;=============================================================================
; grim_sync_indexed_array
;
;=============================================================================
pro grim_sync_indexed_array, grim_data, plane, ptd, _grim_data, _plane, _ptdp
@grim_block.include
@pnt_include.pro

 if(NOT obj_valid(ptd[0])) then return 

 pts = pnt_points(ptd)

 ;------------------------------------------
 ; convert array to surface points
 ;------------------------------------------
 surf_pts = $
   grim_image_to_surface(grim_data, plane, pts, names=names, far=surf_pts_far)
 if(NOT keyword_set(surf_pts)) then return

 ;------------------------------------------
 ; convert surface points to image points
 ;------------------------------------------
 _pts = grim_surface_to_image(_grim_data, _plane, surf_pts, names, valid=valid)
 if(keyword_set(surf_pts_far)) then $
   far_pts = grim_surface_to_image(_grim_data, _plane, surf_pts_far, names)


 ;------------------------------------------
 ; add points
 ;------------------------------------------
 label = strtrim(grim_data.grnum,2) + '.' + $
                     strtrim(plane.pn,2) + '.' + $
                            strtrim(cor_udata(ptd, 'GRIM_INDEXED_ARRAY_LABEL'),2)
 if(keyword_set(_pts)) then $
  begin
   grim_add_indexed_array, _ptdp, _pts, label=label
   if(keyword_set(far_pts)) then $
       grim_add_indexed_array, _ptdp, far_pts, label='-'+label, spacing=8
  end

end
;=============================================================================



;=============================================================================
; grim_push_indexed_array
;
;=============================================================================
pro grim_push_indexed_array, grim_data, ptd, name, rm=rm
@grim_block.include
@pnt_include.pro

 if(NOT keyword_set(_all_tops)) then return

 plane = grim_get_plane(grim_data)
 
 top = _top
 tops = _all_tops
 ntops = n_elements(tops)

 full_name = name+'_SYNCING'

 ;-------------------------------------------------
 ; project arrays in other planes and windows
 ;-------------------------------------------------
 for i=0, ntops-1 do $
  begin
   _grim_data = grim_get_data(tops[i])
   _planes = grim_get_plane(_grim_data, /all)

   for ii=0, n_elements(_planes)-1 do $
    if((tops[i] NE top) OR (_planes[ii].pn NE plane.pn)) then $
     begin
       if(grim_get_toggle_flag(_grim_data, full_name) $
                   OR grim_get_toggle_flag(grim_data, full_name)) then $
        begin
         _ptdp = grim_get_indexed_array(_planes[ii], name)
         if(NOT keyword_set(rm)) then $
   	         grim_sync_indexed_array, $
   			 grim_data, plane, ptd, _grim_data, _planes[ii], _ptdp 
        end
     end
   if(tops[i] NE top) then grim_refresh, _grim_data, /use_pixmap
  end

 grim_data = grim_get_data(top)

end
;=============================================================================



;=============================================================================
; grim_rm_mask_by_point
;
;=============================================================================
function grim_rm_mask_by_point, grim_data, p, plane=plane, pp=pp
@pnt_include.pro

d2min = 100
 mask = *plane.mask_p
 if(mask[0] EQ -1) then return, -1

 dim = dat_dim(plane.dd)
 mp = w_to_xy(0, mask, sx=dim[0], sy=dim[1])

 ;-----------------------------------------------------
 ; compute distance from p to each mask point
 ;-----------------------------------------------------
 n = n_elements(mask)

 q = (convert_coord(/data, /to_device, p[0], p[1]))[0:1,*]
 tq = (convert_coord(/data, /to_device, mp[0,*], mp[1,*]))[0:1,*]

 qq = q#make_array(n,val=1d) 

 d2 = (qq[0,*]-tq[0,*])^2 + (qq[1,*]-tq[1,*])^2


 ;-------------------------------------------------------
 ; remove lowest-numbered mask point that's within range
 ;-------------------------------------------------------
 w = where(d2 LE d2min)
 if(w[0] EQ -1) then return, -1

 mask = rm_list_item(mask, w, only=-1)
 pp = mp[*,w[0]]

 *plane.mask_p = mask
 grim_set_plane, grim_data, plane, pn=plane.pn
 grim_set_data, grim_data, grim_data.base

 return, 0
end
;=============================================================================



;=============================================================================
; grim_rm_mask_by_box
;
;
;=============================================================================
pro grim_rm_mask_by_box, grim_data, cx, cy, plane=plane, pp=pp
@pnt_include.pro

 ;---------------------------------
 ; get get data coords of corners
 ;---------------------------------
 corners = convert_coord(cx, cy, /device, /to_data)


 ;-------------------------------------
 ; scan mask points
 ;-------------------------------------
 mask = *plane.mask_p
 dim = dat_dim(plane.dd)
 pts = w_to_xy(0, mask, sx=dim[0], sy=dim[1])

 npts = n_elements(mask)
 if(npts GT 0) then $
  begin
   w = where((pts[0,*] LE max(corners[0,*])) AND (pts[0,*] GE min(corners[0,*])) $
              AND (pts[1,*] LE max(corners[1,*])) AND (pts[1,*] GE min(corners[1,*])))
   if(w[0] NE -1) then $
    begin
     mask = rm_list_item(mask, w, only=-1)
     pp = pts[*,w]
    end
  end


 *plane.mask_p = mask


end
;=============================================================================



;=============================================================================
; grim_rm_mask
;
;
;=============================================================================
pro grim_rm_mask, grim_data, p, all=all, plane=plane, pp=pp

d2min = 9
 if(NOT keyword__set(plane)) then plane = grim_get_plane(grim_data)

 mask = *plane.mask_p
 if(mask[0] EQ -1) then return

 if(keyword__set(all)) then $
  begin
   *plane.mask_p = -1
   grim_set_plane, grim_data, plane, pn=plane.pn
   grim_set_data, grim_data, grim_data.base
   return
  end

 ;---------------------------------------------
 ; remove mask point under initial cursor point
 ;---------------------------------------------
 stat = grim_rm_mask_by_point(grim_data, p, plane=plane, pp=pp)


 ;-----------------------------------------------------------------------------
 ; if nothing removed by the initial click, get user-defined box on image
 ;-----------------------------------------------------------------------------
 if(stat EQ -1) then $
  begin
   ;- - - - - - - - - - - - - - -
   ; drag box
   ;- - - - - - - - - - - - - - -
   q = (convert_coord(/data, /to_device, p[0], p[1]))[0:1,*]
   box = tvrec(/restore, p0=q, col=ctyellow())

   cx = box[0,*]
   cy = box[1,*]
   d2 = (cx[0] - cx[1])^2 + (cy[0] - cy[1])^2 
 
   ;- - - - - - - - - - - - - - - - - - - - - - - -
   ; select overlays inside box, if dragged
   ;- - - - - - - - - - - - - - - - - - - - - - - -
   box = 1
   if(d2 LE d2min) then box = 0

   if(box) then grim_rm_mask_by_box, grim_data, cx, cy, plane=plane, pp=pp
  end



end
;=============================================================================



;=============================================================================
; grim_get_object_overlays
;
;  Returns all overlay arrays associated with the given xd.
;
;=============================================================================
function grim_get_object_overlays, grim_data, plane, xd

 class = strlowcase(cor_class(xd))
 ptdp = grim_get_overlay_ptdp(grim_data, plane=plane, 'all')

 ptd = 0
 for i=0, n_elements(ptdp)-1 do $
  begin
   ptd0 = *ptdp[i]
   if(keyword_set(ptd0)) then $
    begin
     for j=0, n_elements(ptd0)-1 do $
      begin
       assoc_xd = pnt_assoc_xd(ptd0[j])
       if(obj_valid(assoc_xd)) then $
         if(assoc_xd EQ xd) then ptd = append_array(ptd, ptd0[j])
      end
    end
  end

 return, ptd
end
;=============================================================================



;=============================================================================
; grim_deactivate_xd
;
;=============================================================================
pro grim_deactivate_xd, plane, xds

 if(NOT keyword_set(xds)) then return
 if(NOT keyword_set(*plane.active_xd_p)) then return

 ;---------------------------------------------
 ; determine which xds are already active
 ;---------------------------------------------
 w = nwhere(*plane.active_xd_p, xds)

 ;---------------------------------------------
 ; deactivate active objects
 ;---------------------------------------------
 if(w[0] NE -1) then $
  begin
    *plane.active_xd_p = rm_list_item(*plane.active_xd_p, w, only=0)
    if(NOT keyword_set((*plane.active_xd_p)[0])) then *plane.active_xd_p = 0
  end

end
;=============================================================================



;=============================================================================
; grim_deactivate_overlay
;
;=============================================================================
pro grim_deactivate_overlay, grim_data, plane, ptd, xds=xds, assoc_xds=assoc_xds, pptd=pptd, $
      no_callback=no_callback

 if(NOT keyword_set(*plane.active_overlays_ptdp)) then return
 if(NOT keyword_set(ptd)) then return

 ;---------------------------------------------
 ; determine which ptdp are already active
 ;---------------------------------------------
 nptd = n_elements(ptd)

 w = [-1]
 ww = lindgen(nptd)

 w = nwhere(*plane.active_overlays_ptdp, ptd)
 ww = complement(ptd, w)

 ;---------------------------------------------
 ; deactivate active objects
 ;---------------------------------------------
 if(w[0] NE -1) then $
  begin
    *plane.active_overlays_ptdp = $
                  rm_list_item(*plane.active_overlays_ptdp, w, only=0)
    if(NOT keyword__set((*plane.active_overlays_ptdp)[0])) then $
                                              *plane.active_overlays_ptdp = 0
  end

 ;--------------------------------------------------------------------
 ; If xds given, deactivate all overlays for a each descriptor.
 ; Note the recursive call.
 ;--------------------------------------------------------------------
 pptd = ptd
 if(keyword_set(xds)) then $
  begin
   nxds = n_elements(xds)
   for i=0, nxds-1 do $
    begin
     pptd = grim_get_object_overlays(grim_data, plane, xds[i])
     grim_deactivate_overlay, grim_data, plane, pptd
    end
  end

 ;--------------------------------------------------------------------
 ; If assoc_xds given, deactivate all overlays projected from the same xd 
 ; as the array with the given xd was.
 ; Note the recursive call.
 ;--------------------------------------------------------------------
; if(keyword_set(assoc_xds)) then $
;   for i=0, n_elements(assoc_xds)-1 do grim_deactivate_overlay, grim_data, plane, assoc_xds[i]
 

 ;-----------------------------------
 ; contact activation callbacks
 ;-----------------------------------
 if(NOT keyword_set(no_callback)) then $
                         grim_call_activation_callbacks, plane, ptd, 'DEACTIVATE'


end
;=============================================================================



;=============================================================================
; grim_activate_xd
;
;=============================================================================
pro grim_activate_xd, plane, xds

 if(NOT keyword_set(xds)) then return

 w = where(obj_valid(xds))
 if(w[0] EQ -1) then return
 xds = xds[w]

 ;---------------------------------------------
 ; determine which xds are already active
 ;---------------------------------------------
 nxd = n_elements(xds)

 w = [-1]
 ww = lindgen(nxd)

 if(keyword_set(*plane.active_xd_p)) then $
  begin
   w = nwhere(xds, *plane.active_xd_p)
   ww = complement(xds, w)
  end

 ;---------------------------------------------
 ; activate inactive objects
 ;---------------------------------------------
 if(ww[0] NE -1) then $
  begin
   if(NOT keyword_set(*plane.active_xd_p)) then $
                                         *plane.active_xd_p = xds[ww] $
   else *plane.active_xd_p = [*plane.active_xd_p, xds[ww]]
  end

 
end
;=============================================================================



;=============================================================================
; grim_deactivate_all_xds
;
;=============================================================================
pro grim_deactivate_all_xds, plane

 grim_deactivate_xd, plane, *plane.pd_p
 grim_deactivate_xd, plane, *plane.rd_p
 grim_deactivate_xd, plane, *plane.sd_p
 grim_deactivate_xd, plane, *plane.std_p

end
;=============================================================================



;=============================================================================
; grim_activate_all_xds
;
;=============================================================================
pro grim_activate_all_xds, plane

 grim_activate_xd, plane, *plane.pd_p
 grim_activate_xd, plane, *plane.rd_p
 grim_activate_xd, plane, *plane.sd_p
 grim_activate_xd, plane, *plane.std_p

end
;=============================================================================



;=============================================================================
; grim_activate_overlay
;
;=============================================================================
pro grim_activate_overlay, grim_data, plane, ptd, xds=xds, pptd=pptd, $
      no_callback=no_callback

 if(NOT keyword_set(ptd)) then return

 ;---------------------------------------------
 ; determine which ptd are already active
 ;---------------------------------------------
 nptd = n_elements(ptd)

 w = [-1]
 ww = lindgen(nptd)

 if(keyword_set(*plane.active_overlays_ptdp)) then $
  begin
   w = nwhere(ptd, *plane.active_overlays_ptdp)		; which active
   ww = complement(ptd, w)				; which inactive
  end

 ;---------------------------------------------
 ; activate inactive overlays
 ;---------------------------------------------
 if(ww[0] NE -1) then $
  begin
   if(NOT keyword_set(*plane.active_overlays_ptdp)) then $
                                     *plane.active_overlays_ptdp = ptd[ww] $
   else *plane.active_overlays_ptdp = [*plane.active_overlays_ptdp, ptd[ww]]
  end

 ;--------------------------------------------------------------------
 ; If xds given, activate all overlays for each descriptor.  
 ; Note the recursive call.
 ;--------------------------------------------------------------------
 pptd = ptd
 if(keyword_set(xds)) then $
  begin
   nxds = n_elements(xds)
   for i=0, nxds-1 do $
    begin
     pptd = grim_get_object_overlays(grim_data, plane, xds[i])
     grim_activate_overlay, grim_data, plane, pptd
    end
  end


 ;-----------------------------------------------------
 ; cull out any invalid activations
 ;-----------------------------------------------------
 *plane.active_overlays_ptdp = pnt_cull(*plane.active_overlays_ptdp, /nofree)
 

 ;-----------------------------------
 ; contact activation callbacks
 ;-----------------------------------
 if(NOT keyword_set(no_callback)) then $
                         grim_call_activation_callbacks, plane, ptd, 'ACTIVATE'

end
;=============================================================================



;=============================================================================
; grim_activate_all_overlays
;
;=============================================================================
pro grim_activate_all_overlays, grim_data, plane

 if(NOT keyword_set(*plane.overlay_ptdps)) then return

 n = n_elements(*plane.overlay_ptdps)
 for i=0, n-1 do grim_activate_overlay, grim_data, plane, *(*plane.overlay_ptdps)[i]

 if(ptr_valid(plane.user_ptd_tlp)) then $
  begin
   ww = lindgen(n_elements(*plane.user_ptd_tlp))
   grim_activate_user_overlay, plane, ww
  end

 grim_update_activated, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
; grim_deactivate_all_overlays
;
;=============================================================================
pro grim_deactivate_all_overlays, grim_data, plane

 if(NOT keyword_set(*plane.overlay_ptdps)) then return

 n = n_elements(*plane.overlay_ptdps)
 for i=0, n-1 do grim_deactivate_overlay, grim_data, plane, *(*plane.overlay_ptdps)[i]

 if(ptr_valid(plane.user_ptd_tlp)) then $
  begin
   ww = lindgen(n_elements(*plane.user_ptd_tlp))
   grim_deactivate_user_overlay, plane, ww
  end

 grim_update_activated, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
; grim_invert_active_overlays
;
;=============================================================================
pro grim_invert_active_overlays, grim_data, plane, ptd, xds=xds

 if(NOT keyword_set(ptd)) then return

 ;------------------------------------------------------
 ; determine which ptdp are currently active/inactive
 ;------------------------------------------------------
 nptd = n_elements(ptd)

 w = [-1]
 ww = lindgen(nptd)

 if(keyword_set(*plane.active_overlays_ptdp)) then $
  begin
   w = nwhere(ptd, *plane.active_overlays_ptdp)	; active
   ww = complement(ptd, w)			; inactive
  end

 ;---------------------------------------------
 ; deactivate active objects
 ;---------------------------------------------
 if(w[0] NE -1) then grim_deactivate_overlay, grim_data, plane, ptd[w]

 ;---------------------------------------------
 ; activate previously inactive objects
 ;---------------------------------------------
 if(ww[0] NE -1) then grim_activate_overlay, grim_data, plane, ptd[ww]

 
 ;-----------------------------------------------------
 ; update object-referenced activation lists
 ;-----------------------------------------------------
 grim_update_activated, grim_data, plane=plane


end
;=============================================================================



;=============================================================================
; grim_invert_all_overlays
;
;=============================================================================
pro grim_invert_all_overlays, grim_data, plane

 if(NOT keyword_set(*plane.overlay_ptdps)) then return

 n = n_elements(*plane.overlay_ptdps)
 for i=0, n-1 do $
    grim_invert_active_overlays, grim_data, plane, *(*plane.overlay_ptdps)[i]

 grim_invert_active_user_overlays, plane

end
;=============================================================================



;=============================================================================
; grim_nearest_overlay
;
;=============================================================================
function grim_nearest_overlay, plane, p, object_ptd, mm=mm

 if(NOT keyword_set(object_ptd)) then return, -1

d2min = 25

 n = n_elements(object_ptd)
 mins = make_array(n, val=1d20)

 q = (convert_coord(p[0], p[1], /data, /to_device))[0:1]

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; find minimum distance to each object
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 for i=0, n-1 do if(obj_valid(object_ptd[i])) then $
  begin
   pts = pnt_points(object_ptd[i], /visible)
   desc = pnt_desc(object_ptd[i])
   npts = n_elements(pts)/2
   if(npts GT 0) then $
    begin
     pp = (convert_coord(pts[0,*], pts[1,*], /data, /to_device))[0:1,*]
     qq = q#make_array(npts,val=1d) 
     d2 = (qq[0,*]-pp[0,*])^2 + (qq[1,*]-pp[1,*])^2
     mins[i] = min(d2)
    end $
   else mins[i] = 1d20
  end

 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 ; return closest in-range object
 ;- - - - - - - - - - - - - - - - - - - - - - - - -
 mm = min(mins)
 ww = where(mins EQ mm)
 if(mm LE d2min) then return, ww     


 return, -1
end
;=============================================================================



;=============================================================================
; grim_enclosed_overlays
;
;=============================================================================
function grim_enclosed_overlays, corners, object_ptd, mm=mm

 if(NOT keyword__set(object_ptd)) then return, -1

 n = n_elements(object_ptd)

 ;-------------------------------------------
 ; find minimum distance to each object
 ;-------------------------------------------
 ww = -1
 for i=0, n-1 do if(obj_valid(object_ptd[i])) then $
  begin
   pts = pnt_points((object_ptd)[i], /visible)
   npts = n_elements(pts)/2
   if(npts GT 0) then $
    begin
     xmin = make_array(npts, val=min(corners[0,*]))
     xmax = make_array(npts, val=max(corners[0,*]))
     ymin = make_array(npts, val=min(corners[1,*]))
     ymax = make_array(npts, val=max(corners[1,*]))

     w = where((pts[0,*] GT xmax) OR (pts[0,*] LT xmin) $
                   OR (pts[1,*] GT ymax) OR (pts[1,*] LT ymin))
     if(w[0] EQ -1) then ww = [ww, i]
    end
  end

 if(n_elements(ww) GT 1) then ww = ww[1:*]

 return, ww
end
;=============================================================================



;=============================================================================
; grim_remove_by_point
;
;=============================================================================
function grim_remove_by_point, plane, p0, clicks=clicks, user=user

d2min = 25

 ;---------------------------------
 ; get get data coords of point
 ;---------------------------------
 p = convert_coord(p0[0], p0[1], /device, /to_data)

 ;---------------------------------------------------------------------
 ; compute distance from p to each overlay point for each object type
 ;---------------------------------------------------------------------
 if(NOT keyword_set(user)) then $
  begin
   ww = -1 & mm = 1d20
   found = 1

   names = *plane.overlay_names_p
   for i=0, n_elements(names)-1 do $
    begin
     _name = names[i]
;     ptd = grim_get_active_overlays(grim_data, plane=plane, _name)
     ptdp = grim_get_overlay_ptdp(grim_data, plane=plane, _name)
     _ww = grim_nearest_overlay(plane, p, *ptdp, mm=_mm)
     if(_ww[0] NE -1) then if(_mm LT mm) then $
      begin
       name = _name
       mm = _mm
       ww = _ww
      end
    end

   ;------------------------------------------------------------------
   ; activate or deactivate objects
   ;------------------------------------------------------------------
   if(keyword_set(name)) then $
    begin
     ptdp = grim_get_overlay_ptdp(grim_data, plane=plane, name, class=class)
     xd = grim_get_xd(grim_data, plane=plane, class)
     nd = n_elements(xd)
     nptd = n_elements(*ptdp)/nd
     ww_xd = ww / nptd

     fn_overlay = 'grim_activate_overlay'

     ptdp = grim_get_overlay_ptdp(grim_data, plane=plane, name, class=class)
     xd = 0

;     if((clicks EQ 2) AND (ww_xd[0] NE -1)) then $
;                        xd = (grim_get_xd(grim_data, plane=plane, class))[ww_xd[0]]
;here, we'd like to remove the associated xd, as well as all its points
; not yet implemented, though

     if(ww[0] NE -1) then grim_rm_points, plane, ptdp, ww[0]

     return, 0
    end
  end

 ;--------------
 ; user points
 ;--------------
 if(keyword_set(user)) then $
  begin
   if(ptr_valid(plane.user_ptd_tlp)) then $
    begin
     all_tags = (*plane.user_ptd_tlp).name
     user_ptd = grim_get_user_ptd(all_tags, plane=plane)
     ww_usr = grim_nearest_overlay(plane, p, user_ptd)

     if(ww_usr[0] NE -1) then $
      begin
       grim_clear_user_overlays, plane, all_tags[ww_usr]
       return, 0
      end
    end 
  end

 grim_update_activated, grim_data, plane=plane

 return, -1
end
;=============================================================================



;=============================================================================
; grim_activate_by_point
;
;=============================================================================
function grim_activate_by_point, grim_data, plane, p0, $
                    deactivate=deactivate, clicks=clicks, invert=invert

d2min = 25

 ;---------------------------------
 ; get get data coords of point
 ;---------------------------------
 p = convert_coord(p0[0], p0[1], /device, /to_data)

 ;---------------------------------------------------------------------
 ; compute distance from p to each overlay point for each object type
 ;---------------------------------------------------------------------
 ww = -1 & mm = 1d20
 found = 1

 names = *plane.overlay_names_p
 for i=0, n_elements(names)-1 do $
  begin
   _name = names[i]
   ptdp = grim_get_overlay_ptdp(grim_data, plane=plane, _name)
   _ww = grim_nearest_overlay(plane, p, *ptdp, mm=_mm)
   if(_ww[0] NE -1) then if(_mm LT mm) then $
    begin
     ptd = (*ptdp)[_ww]
     name = _name
     mm = _mm
     ww = _ww
    end
  end


 ;------------------------------------------------------------------
 ; activate or deactivate objects
 ;------------------------------------------------------------------
 if(keyword_set(ptd)) then $
  begin
   active_ptd = *plane.active_overlays_ptdp
   w = -1
   if(keyword_set(active_ptd)) then w = where(active_ptd EQ ptd[0])
   active = (w[0] NE -1) ? 1 : 0

   xd = 0
   if(clicks EQ 2) then xd = pnt_assoc_xd(ptd)

   fn_overlay = keyword_set(deactivate) ? $
                            'grim_deactivate_overlay' : 'grim_activate_overlay'

   if(keyword_set(invert)) then $
       fn_overlay = active ? 'grim_deactivate_overlay' : 'grim_activate_overlay'


   call_procedure, fn_overlay, grim_data, plane, ptd, xd=xd, pptd=pptd
   grim_set_overlay_update_flag, pptd, 1

   return, 0
  end

 ;--------------
 ; user points
 ;--------------
 if(ptr_valid(plane.user_ptd_tlp)) then $
  begin
   all_tags = (*plane.user_ptd_tlp).name
   user_ptd = grim_get_user_ptd(all_tags, plane=plane)
   ww_usr = grim_nearest_overlay(plane, p, user_ptd)

   if(ww_usr[0] NE -1) then $
    begin
     if(keyword__set(deactivate)) then grim_deactivate_user_overlay, plane, ww_usr $
     else grim_activate_user_overlay, plane, ww_usr
     return, 0
    end
  end 

 return, -1
end
;=============================================================================



;=============================================================================
; grim_trim_overlays
;
;=============================================================================
pro grim_trim_overlays, grim_data, plane=plane, region

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 names = *plane.overlay_names_p
 for i=0, n_elements(names)-1 do $
  begin
   name = names[i]
   ptd = *(grim_get_overlay_ptdp(grim_data, plane=plane, name))
   if(keyword_set(ptd)) then pg_trim, 0, pnt_cull(ptd, /nofree), region
  end

end
;=============================================================================



;=============================================================================
; grim_select_overlay_points
;
;=============================================================================
pro grim_select_overlay_points, grim_data, plane=plane, region, deselect=deselect
@pnt_include.pro

 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 names = *plane.overlay_names_p
 for i=0, n_elements(names)-1 do $
  begin
   name = names[i]
   ptd = *(grim_get_overlay_ptdp(grim_data, plane=plane, name))
   if(keyword_set(ptd)) then $
    begin
     ptd = pnt_cull(ptd, /nofree)
     if(NOT keyword_set(deselect)) then $
                      pg_trim, 0, ptd, region, mask=PTD_MASK_SELECT $
     else pg_trim, 0, ptd, region, mask=PTD_MASK_SELECT, /off
    end
  end

end
;=============================================================================



;=============================================================================
; grim_remove_by_box
;
;=============================================================================
pro grim_remove_by_box, plane, cx, cy, stat=stat, user=user

 stat = 1

 ;---------------------------------
 ; get get data coords of corners
 ;---------------------------------
 corners = convert_coord(cx, cy, /device, /to_data)


 ;-------------------------------------
 ; scan overlays for inclusion in box
 ;-------------------------------------

 ;- - - - - - - - - - - - -
 ; standard overlays
 ;- - - - - - - - - - - - -
 if(NOT keyword_set(user)) then $
  begin
   names = *plane.overlay_names_p
   for i=0, n_elements(names)-1 do $
    begin
     stat = 0
     name = names[i]
     ptdp = grim_get_overlay_ptdp(grim_data, plane=plane, name, class=class)
     ww = grim_enclosed_overlays(corners, *ptdp)
     if(ww[0] NE -1) then $
      begin
       xd = grim_get_xd(grim_data, plane=plane, class)
       nd = n_elements(xd)
       nptd = n_elements(*ptdp)/nd
       ww_xd = ww / nptd

       fn_overlay = 'grim_activate_overlay'

       xd = 0
       if(ww_xd[0] NE -1) then $
                        xd = (grim_get_xd(grim_data, plane=plane, class))[ww_xd[0]]
       if(ww[0] NE -1) then grim_rm_points, plane, ptdp, ww
      end

    end
  end


 ;- - - - - - - - - - - - -
 ; user overlays
 ;- - - - - - - - - - - - -
 if(keyword_set(user)) then $
  begin
   if(ptr_valid(plane.user_ptd_tlp)) then $
    begin
     stat = 0
     all_tags = (*plane.user_ptd_tlp).name
     user_ptd = grim_get_user_ptd(all_tags, plane=plane)
     ww_usr = grim_enclosed_overlays(corners, user_ptd)

     if(ww_usr[0] NE -1) then $
                        grim_clear_user_overlays, plane, all_tags[ww_usr]
    end
  end

 grim_update_activated, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
; grim_activate_by_box
;
;=============================================================================
pro grim_activate_by_box, grim_data, plane, cx, cy, deactivate=deactivate

 ;---------------------------------
 ; get get data coords of corners
 ;---------------------------------
 corners = convert_coord(cx, cy, /device, /to_data)


 ;-------------------------------------
 ; scan overlays for inclusion in box
 ;-------------------------------------

 ;- - - - - - - - - - - - -
 ; standard overlays
 ;- - - - - - - - - - - - -
 names = *plane.overlay_names_p
 for i=0, n_elements(names)-1 do $
  begin
   name = names[i]
   ptdp = grim_get_overlay_ptdp(grim_data, plane=plane, name, class=class)
   ww = grim_enclosed_overlays(corners, *ptdp)
   if(ww[0] NE -1) then $
    begin
     fn_overlay = 'grim_activate_overlay'
     if(keyword_set(deactivate)) then fn_overlay = 'grim_deactivate_overlay'

     ptdp = grim_get_overlay_ptdp(grim_data, plane=plane, name, class=class)
     if(ww[0] NE -1) then $
      begin
       ptd = (*ptdp)[ww]
       grim_set_overlay_update_flag, ptd, 1
       call_procedure, fn_overlay, grim_data, plane, ptd, xd=xd
      end
    end

  end

 ;- - - - - - - - - - - - -
 ; user overlays
 ;- - - - - - - - - - - - -
 if(ptr_valid(plane.user_ptd_tlp)) then $
  begin
   all_tags = (*plane.user_ptd_tlp).name
   user_ptd = grim_get_user_ptd(all_tags, plane=plane)
   ww_usr = grim_enclosed_overlays(corners, user_ptd)

   if(ww_usr[0] NE -1) then $
    begin
     if(keyword_set(deactivate)) then grim_deactivate_user_overlay, plane, ww_usr $
     else grim_activate_user_overlay, plane, ww_usr
    end
  end

end
;=============================================================================



;=============================================================================
; grim_activate_select
;
;=============================================================================
pro grim_activate_select, grim_data, plane, p0, deactivate=deactivate, clicks=clicks, ptd=ptd

d2min = 9

 ;---------------------------------------------
 ; select overlay under initial cursor point
 ;---------------------------------------------
 stat = grim_activate_by_point(grim_data, plane, p0, deactivate=deactivate, clicks=clicks)

 ;-----------------------------------------------------------------------------
 ; if nothing selected by the initial click, get user-defined box on image
 ;-----------------------------------------------------------------------------
 if(stat EQ -1) then $
  begin
   ;- - - - - - - - - - - - - - -
   ; drag box
   ;- - - - - - - - - - - - - - -
   box = tvrec(/restore, p0=p0, col=ctgreen())

   cx = box[0,*]
   cy = box[1,*]
   d2 = (cx[0] - cx[1])^2 + (cy[0] - cy[1])^2 
 
   ;- - - - - - - - - - - - - - - - - - - - - - - -
   ; select overlays inside box, if dragged
   ;- - - - - - - - - - - - - - - - - - - - - - - -
   box = 1
   if(d2 LE d2min) then box = 0

   if(box) then grim_activate_by_box, grim_data, plane, cx, cy, deactivate=deactivate
  end

 grim_update_activated, grim_data, plane=plane
end
;=============================================================================



;=============================================================================
; grim_remove_overlays
;
;=============================================================================
pro grim_remove_overlays, plane, p0, clicks=clicks, stat=stat, user=user

d2min = 9

 ;---------------------------------------------
 ; select overlay under initial cursor point
 ;---------------------------------------------
 stat = grim_remove_by_point(plane, p0, clicks=clicks, user=user)

 ;-----------------------------------------------------------------------------
 ; if nothing selected by the initial click, get user-defined box on image
 ;-----------------------------------------------------------------------------
 if(stat EQ -1) then $
  begin
   ;- - - - - - - - - - - - - - -
   ; drag box
   ;- - - - - - - - - - - - - - -
   box = tvrec(/restore, p0=p0, col=ctblue())

   cx = box[0,*]
   cy = box[1,*]
   d2 = (cx[0] - cx[1])^2 + (cy[0] - cy[1])^2 
 
   ;- - - - - - - - - - - - - - - - - - - - - - - -
   ; select overlays inside box, if dragged
   ;- - - - - - - - - - - - - - - - - - - - - - - -
   box = 1
   if(d2 LE d2min) then box = 0

   if(box) then grim_remove_by_box, plane, cx, cy, stat=stat, user=user
  end

end
;=============================================================================



;=============================================================================
; grim_create_overlay
;
;=============================================================================
pro grim_create_overlay, grim_data, plane, name, class=class, dep_classes=dep_classes, dep_overlays, $
                   color=color, psym=psym, symsize=symsize, shade=shade, $
                   tlab=tlab, tshade=tshade, tfill=tfill, genre=genre



 if(grim_test_map(grim_data, plane=plane)) then psym = abs(psym)

 if(NOT defined(symsize)) then symsize = 1.
 if(NOT defined(shade)) then shade = 1.
  
 *plane.overlay_names_p = append_array(*plane.overlay_names_p, name)
 *plane.overlay_classes_p = append_array(*plane.overlay_classes_p, [class])
 *plane.overlay_genres_p = append_array(*plane.overlay_genres_p, [genre])
 *plane.overlay_dep_p = append_array(*plane.overlay_dep_p, ptr_new(dep_classes))
 *plane.overlay_labels_p = append_array(*plane.overlay_labels_p, ptr_new(''))
 *plane.overlay_ptdps = append_array(*plane.overlay_ptdps, ptr_new(0))

 *plane.overlay_color_p = append_array(*plane.overlay_color_p, color)
 *plane.overlay_symsize_p = append_array(*plane.overlay_symsize_p, [symsize])
 *plane.overlay_shade_p = append_array(*plane.overlay_shade_p, [shade])
 *plane.overlay_psym_p = append_array(*plane.overlay_psym_p, psym)
 *plane.overlay_tlab_p = append_array(*plane.overlay_tlab_p, [tlab])
 *plane.overlay_tshade_p = append_array(*plane.overlay_tshade_p, [tshade])
 *plane.overlay_tfill_p = append_array(*plane.overlay_tfill_p, [tfill])
 *plane.overlay_data_p = append_array(*plane.overlay_data_p, [ptr_new(0)])

end
;=============================================================================



;=============================================================================
; grim_create_overlays
;
;=============================================================================
pro grim_create_overlays, grim_data, plane

   grim_create_overlay, grim_data, plane, $
	'ring_grid', $
		class='ring', $
		dep_classes=['sun', 'planet'], $
		genre='curve', $
		col='orange', psym=3, tlab=0, tfill=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'planet_grid', $
		class='planet', $
		dep_classes=['sun', 'ring'], $
		genre='curve', $
		col='green', psym=3, tlab=0, tfill=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'station', $
		class='station', $
		dep_classes=['station', 'planet', 'sun', 'ring'], $
		genre='point', $
		col='yellow', psym=1, tlab=1, tfill=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'array', $
		class='array', $
		dep_classes=['array', 'planet', 'sun', 'ring'], $
		genre='curve', $
		col='blue', psym=-3, tlab=1, tfill=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'limb', $
		class='planet', $
		dep_classes=['sun', 'ring'], $
		genre='curve', $
		col='yellow', psym=-3, tlab=0, tfill=0, shade=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'terminator', $
		class='planet', $
		dep_classes=['sun', 'ring'], $
		genre='curve', $
		col='red', psym=-3, tlab=0, tfill=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'ring', $
		class='ring', $
		dep_classes=['sun', 'planet'], $
		genre='curve', $
		col='orange', psym=-3, tlab=0, tfill=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'planet_center', $
		class='planet', $
		dep_classes=['sun'], $
		genre='point', $
		col='white',    psym=1, tlab=1, tfill=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'star', $
		class='star', $
		dep_classes=['planet', 'ring'], $
		genre='point', $
		col='white',  psym=6, tlab=0, tfill=0, symsize=1, tshade=0

   grim_create_overlay, grim_data, plane, $
	'shadow', $
		class='', $
		dep_classes=['planet', 'ring', 'sun'], $
		genre='curve', $
		col='blue', psym=-3, tlab=0, tfill=0, tshade=1

   grim_create_overlay, grim_data, plane, $
	'reflection', $
		class='', $
		dep_classes=['planet', 'ring', 'sun'], $
		genre='curve', $
		col='blue', psym=-3, tlab=0, tfill=0, tshade=1


end
;=============================================================================



;=============================================================================
; grim_hide
;
;=============================================================================
pro grim_hide, grim_data, plane, ptd, gd=gd

 cd = cor_dereference_gd(gd, /cd)
 pd = cor_dereference_gd(gd, /pd)
 rd = cor_dereference_gd(gd, /rd)
 sund = cor_dereference_gd(gd, name='SUN')

 if(keyword__set(rd)) then $
        pg_hide, ptd, cd=cd, dkx=rd, od=od, bx=rd, gbx=pd
 grim_message

 if(keyword__set(sund)) then $
;     pg_hide, ptd, cd=cd, bx=pds, od=sund, /assoc
     pg_hide, ptd, cd=cd, bx=pd, od=sund
 grim_message


end
;=============================================================================



;=============================================================================
; grim_overlay
;
;=============================================================================
pro grim_overlay, grim_data, name, plane=plane, dep=dep, ptd=ptd, source_ptd=source_ptd, $
                                   obj_name=obj_name, temp=temp


 if(grim_data.slave_overlays) then plane = grim_get_plane(grim_data, pn=0)
 if(NOT keyword_set(plane)) then plane = grim_get_plane(grim_data)

 ptdp = grim_get_overlay_ptdp(grim_data, name, plane=plane, class=class, data=data) 
 fn = 'grim_compute_' + name

 ;--------------------------------------------------
 ; if the dependencies are given, then just update
 ;  existing arrays
 ;--------------------------------------------------
 if(keyword_set(dep)) then $
  begin
   grim_suspend_events 

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; recompute the overlay points
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   gd = cor_create_gd(dep, /explicit)
   if(cor_test_gd(gd, 'MD')) then $
                       gd = cor_create_gd(gd=gd, cd=gd.md, od=*plane.od_p)

   _ptd = call_function(fn, gd=gd, $
           map=grim_test_map(grim_data), clip=plane.clip, hide=plane.hide, $
           active_ptd=source_ptd, data=data, $
           npoints=grim_data.npoints)
   _ptd = pnt_cull(_ptd)

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; update the existing overlay array
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   grim_update_points, grim_data, plane=plane, ptd, _ptd

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; add any new arrays
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   grim_add_new_points, grim_data, plane=plane, ptdp, _ptd, name, gd.cd

   grim_resume_events
   return
  end


 ;---------------------------------------------------------
 ; otherwise create new arrays
 ;---------------------------------------------------------
 grim_suspend_events 

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; make sure relevant descriptors are loaded
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 grim_load_descriptors, grim_data, name, plane=plane, $
       cd=cd, pd=pd, rd=rd, sund=sund, sd=sd, ard=ard, std=std, od=od, gd=gd
 if(NOT keyword_set(cd)) then return

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; compute overlay arrays
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 active_xds = *plane.active_xd_p
 if(keyword_set(obj_name)) then $
  begin
   xds = cor_cat_gd(gd)
   w = nwhere(cor_name(xds), obj_name)
   if(w[0] EQ -1) then return
   active_xds = xds[w]
  end

 ptd = call_function(fn, gd=gd, data=data, $
          map=grim_test_map(grim_data), clip=plane.clip, hide=plane.hide, $
          active_xds=active_xds, active_ptd=*plane.active_overlays_ptdp, $
          npoints=grim_data.npoints)
 ptd = pnt_cull(ptd)

 w = where(pnt_valid(ptd))
 if(w[0] EQ -1) then return


 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 ; add overlays
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - -
 if(NOT keyword_set(temp)) then $
   grim_add_points, grim_data, plane=plane, ptd, name=name, cd=cd, data=data

 grim_resume_events

end
;=============================================================================

pro grim_overlays_include
a=!null
end

