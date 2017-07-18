;=============================================================================
; grim_blank
;
;=============================================================================
function grim_blank, xsize, ysize
 return, bytarr(xsize, ysize)
end
;=============================================================================



;=============================================================================
; grim_init
;
;=============================================================================
function grim_init, dd, dd0=dd0, zoom=zoom, wnum=wnum, grnum=grnum, filter=filter,$
           retain=retain, user_callbacks=user_callbacks, $
           user_psym=user_psym, user_graphics_fn=user_graphics_fn, user_thick=user_thick, user_line=user_line, $
           cursor_swap=cursor_swap, cmd=cmd, $
           path=path, save_path=save_path, load_path=load_path, fov=fov, clip=clip, $
           cam_trs=cam_trs, plt_trs=plt_trs, rng_trs=rng_trs, str_trs=str_trs, stn_trs=stn_trs, arr_trs=arr_trs, $
           sun_trs=sun_trs, hide=hide, type=type, $
	   cam_select=cam_select, plt_select=plt_select, rng_select=rng_select, $
	   sun_select=sun_select, str_select=str_select, stn_select=stn_select, arr_select=arr_select, $
           color=color, xrange=xrange, yrange=yrange, position=position, npoints=npoints, $
           thick=thick, nsum=nsum, xtitle=xtitle, ytitle=ytitle, $
           psym=psym, cursor_modes=cursor_modes, $
           symsize=symsize, nhist=nhist, maintain=maintain, workdir=workdir, $
           compress=compress, extensions=extensions, max=max, beta=beta, $
           visibility=visibility, channel=channel, title=title, slave_overlays=slave_overlays, $
           render_sample=render_sample, render_pht_min=render_pht_min, $
           overlays=overlays, activate=activate
@grim_block.include

  if(NOT keyword_set(dd0)) then dd0 = obj_new()
  if(NOT keyword_set(nhist)) then nhist = 1

  beta = keyword_set(beta)
  activate = keyword_set(activate)

  if(NOT keyword_set(user_psym)) then user_psym = 3
  if(NOT keyword_set(user_graphics_fn)) then user_graphics_fn = 3
  if(NOT keyword_set(user_thick)) then user_thick = 1
  if(NOT keyword_set(user_line)) then user_line = 0
  if(NOT keyword_set(slave_overlays)) then slave_overlays = 0
  if(NOT defined(cursor_swap)) then cursor_swap = -1
  if(NOT keyword_set(overlays)) then overlays = ''

  if(NOT keyword_set(cursor_modes)) then cursor_modes_p = ptr_new(0) $
  else cursor_modes_p = ptr_new(cursor_modes)

  if(NOT keyword_set(npoints)) then npoints = 0
  if(NOT keyword_set(fov)) then fov = 0.
  if(NOT keyword_set(clip)) then clip = 0.
  if(NOT keyword_set(filter)) then filter = ''

  if(keyword_set(path)) then load_path = (save_path = path)
  if(NOT keyword_set(load_path)) then load_path = ''
  if(NOT keyword_set(save_path)) then save_path = ''
  if(NOT keyword_set(workdir)) then workdir = './'

  if(NOT keyword_set(cam_select)) then cam_select = ''
  if(NOT keyword_set(plt_select)) then plt_select = ''
  if(NOT keyword_set(rng_select)) then rng_select = ''
  if(NOT keyword_set(str_select)) then str_select = ''
  if(NOT keyword_set(stn_select)) then stn_select = ''
  if(NOT keyword_set(arr_select)) then arr_select = ''
  if(NOT keyword_set(sun_select)) then sun_select = ''

  if(NOT keyword_set(cam_trs)) then cam_trs = ''
  if(NOT keyword_set(plt_trs)) then plt_trs = ''
  if(NOT keyword_set(rng_trs)) then rng_trs = ''
  if(NOT keyword_set(str_trs)) then str_trs = ''
  if(NOT keyword_set(stn_trs)) then stn_trs = ''
  if(NOT keyword_set(arr_trs)) then arr_trs = ''
  if(NOT keyword_set(sun_trs)) then sun_trs = ''

  if(NOT keyword_set(color)) then color = ctwhite()
  if(NOT keyword_set(thick)) then thick = 1
  if(NOT keyword_set(nsum)) then nsum = 0
  if(NOT keyword_set(psym)) then psym = -3l
  if(NOT keyword_set(symsize)) then symsize = 1.
 
  if(NOT keyword_set(title)) then title = ''
  if(NOT keyword_set(xtitle)) then xtitle = ''
  if(NOT keyword_set(ytitle)) then ytitle = ''

  ;----------------------
  ; main data structure
  ;----------------------
;  grim_data = {grim_data_struct, $
  grim_data = { $
	;---------------
	; widgets
	;---------------
		base			: 0l, $
		shortcuts_base		: 0l, $
		shortcuts_base1		: 0l, $
		shortcuts_base2		: 0l, $
		shortcuts_base3		: 0l, $
		shortcuts_base4		: 0l, $
		shortcuts_base5		: 0l, $
		shortcuts_base6		: 0l, $
		shortcuts_base7		: 0l, $
		shortcuts_base8		: 0l, $
		shortcuts_base9		: 0l, $
		color_button		: 0l, $
		settings_button		: 0l, $
		crop_button		: 0l, $
		next_button		: 0l, $
		previous_button		: 0l, $
		jumpto_text		: 0l, $
		refresh_button		: 0l, $
		hide_button		: 0l, $
		toggle_image_button	: 0l, $
		toggle_image_overlays_button	: 0l, $
		entire_button		: 0l, $
		view_previous_button	: 0l, $
		tracking_button		: 0l, $
		render_button		: 0l, $
		undo_button		: 0l, $
		redo_button		: 0l, $
		undo_menu_id		: 0l, $
		redo_menu_id		: 0l, $
		activate_all_button	: 0l, $
		deactivate_all_button	: 0l, $
		guideline_button	: 0l, $
		identify_button		: 0l, $
		pixel_grid_button	: 0l, $
		grid_button		: 0l, $
		remove_xd_button	: 0l, $
		axes_button		: 0l, $
		header_button		: 0l, $
		notes_button		: 0l, $
		repeat_button		: 0l, $
		sub_base		: 0l, $
		modes_base		: 0l, $
		select_button		: 0l, $
		context_button		: 0l, $
		footprint_button	: 0l, $
		mbar			: 0l, $
		menu			: 0l, $
		help_menu		: 0l, $
		draw_base		: 0l, $
		draw			: 0l, $
		context_draw		: 0l, $
		context_base		: 0l, $
		axes_draw		: 0l, $
		axes_base		: 0l, $
		message_base		: 0l, $
		xy_label		: 0l, $
		label			: 0l, $
		menu_ids_p		: ptr_new(), $
		menu_desc_p		: ptr_new(), $
		map_items_p		: ptr_new(), $
		od_map_items_p		: ptr_new(), $
		readout_top		: 0l, $
		readout_text		: 0l, $
		header_text		: -1l, $
		header_base		: -1l, $
		notes_text		: -1l, $
		notes_base		: -1l, $
		help_text		: -1l, $
		help_base		: -1l, $
	;---------------
	; bookkeeping
	;---------------
		base_xsize		: 0l, $
		base_ysize		: 0l, $

		activate		: activate, $
		beta			: beta, $
		npoints			: npoints, $
		nhist			: nhist, $
		ref_comb		: 'Average', $
		type			: type, $	; 'image', 'plot', 'map'
		user_tlp		: ptr_new(), $
		retain			: retain, $
		maintain		: maintain, $
		compress		: compress, $
		extensions		: extensions, $
		cursor_swap		: cursor_swap, $
		zoom			: zoom, $
		mode			: '', $
		mode_data_p		: ptr_new(0), $
		grid_flag		: 0, $
		pixel_grid_flag		: 0, $
		guideline_flag		: 0, $
		guideline_pixmaps	: [0l,0l], $
		guideline_save_xy	: [-1d,-1d], $
		axes_flag		: 0, $
		readout_mark		: dblarr(2), $
		measure_mark		: dblarr(2,2), $
		selected		: 0, $
		scale_wnum		: 0, $
		wnum			: 0, $
		pixmap			: -1, $
		redraw_pixmap		: -1, $
		overlay_pixmap		: -1, $
		context_wnum		: 0, $
		context_pixmap		: 0, $
		context_mapped		: 0, $
		axes_wnum		: 0, $
		mag_redraw_pixmap	: 0, $
		mag_pixmap		: 0, $
		mag_last_x0		: -1l, $
		mag_last_y0		: -1l, $
		grnum			: -1l, $
		act_callbacks_p		: ptr_new(''), $
		act_callbacks_data_pp	: ptr_new(0), $
		rf_callbacks_p		: ptr_new(''), $
		rf_callbacks_data_pp	: ptr_new(0), $
		pn_callbacks_p		: ptr_new(''), $
		pn_callbacks_data_pp	: ptr_new(0), $
		tv_rp			: ptr_new(0), $
		tv_gp			: ptr_new(0), $
		tv_bp			: ptr_new(0), $
		hidden			: 0, $		; all overlays hidden?
		tracking		: 1, $		
		min_p			: ptr_new(0), $
		max_p			: ptr_new(0), $
		default_user_graphics_fn	: user_graphics_fn, $
		default_user_psym	: user_psym, $
		default_user_thick	: user_thick, $
		default_user_line	: user_line, $
		repeat_fn		: '', $
		repeat_event_p		: ptr_new(0), $ 
		cursor_modes_p		: cursor_modes_p, $
		workdir			: workdir, $
		tvd_init_p		: ptr_new(0), $
		dd_map_p		: ptr_new(0), $
		md_map_p		: ptr_new(0), $
		dd0			: dd0, $
		data_xy_p		: ptr_new(0), $		; data coords of viewport indices

		slave_overlays		: slave_overlays, $

		misc_data_p		: ptr_new(0), $

		cam_select     		: cam_select, $
		plt_select     		: plt_select, $
		rng_select     		: rng_select, $
		str_select     		: str_select, $
		stn_select     		: stn_select, $
		arr_select     		: arr_select, $
		sun_select     		: sun_select, $

	;---------------
	; planes
	;---------------
		n_planes	: 0, $			; # of image planes
							;  active + inactive
		planes_p	: ptr_new(0), $		; Image planes
		pl_flags_p	: ptr_new(0), $		; Plane flags
							;  0 - inactive
							;  1 - active
							;  2 - blank
		pn		: 0, $			; current plane number

		def_cam_trs	: cam_trs, $
		def_plt_trs	: plt_trs, $
		def_rng_trs	: rng_trs, $
		def_str_trs	: str_trs, $
		def_stn_trs	: stn_trs, $
		def_arr_trs	: arr_trs, $
		def_sun_trs	: sun_trs, $

		def_load_path	: load_path, $
		def_save_path	: save_path, $
		def_filter	: filter, $

		def_fov		: fov, $
		def_clip	: clip, $
		def_hide	: hide, $

		def_color	: color[0], $
		def_psym	: psym[0], $
		def_symsize	: symsize[0], $
		def_thick	: thick[0], $
		def_nsum	: nsum[0], $

		def_title	: title[0], $
		def_xtitle	: xtitle[0], $
		def_ytitle	: ytitle[0] $
	     }

  ;---------------------
  ; planes
  ;---------------------
  grim_add_planes, grim_data, dd, $
     xrange=xrange, yrange=yrange, position=position, xtitle=xtitle, ytitle=ytitle, max=max, $
                    color=color, thick=thick, visibility=visibility, channel=channel, $
                       render_sample=render_sample, render_pht_min=render_pht_min, $
                          overlays=overlays, cmd=cmd

 ;----------------------
 ; common block
 ;----------------------
 if(n_elements(_selected) EQ 0) then _selected = -1

 return, grim_data
end
;=============================================================================



;=============================================================================
; grim_exists
;
;=============================================================================
function grim_exists, grim_data
 if(NOT keyword_set(grim_data)) then return, 0
 return, ptr_valid(grim_data.planes_p)
end
;=============================================================================



;=============================================================================
; grim_grnum_to_top
;
;=============================================================================
function grim_grnum_to_top, grnum
common grnum_block, tops
 return, tops[grnum]
end
;=============================================================================



;=============================================================================
; grim_get_data
;
;=============================================================================
function grim_get_data, top, grnum=grnum, plane=plane, $
         dead=dead, primary=primary, no_wset=no_wset
@grim_block.include

 if(keyword_set(plane)) then grnum = plane.grnum

 if(defined(grnum)) then top = grim_grnum_to_top(grnum)
 if((NOT keyword_set(top)) AND (NOT keyword_set(_top))) then return, 0

 
 if(NOT keyword_set(top)) then top = _top $
 else _top = top
 if(NOT keyword_set(_primary)) then _primary = _top


 if(keyword_set(primary)) then top = _primary
 if(NOT widget_info(top, /valid_id)) then return, 0

 widget_control, top, get_uvalue=grim_data
 if(NOT keyword_set(dead)) then $
       if(NOT keyword_set(no_wset)) then grim_wset, grim_data, grim_data.wnum

 return, grim_data
end
;=============================================================================



;=============================================================================
; grim_set_data
;
;=============================================================================
pro grim_set_data, grim_data, top, primary=primary
@grim_block.include

 if(NOT keyword_set(top)) then top = _top $
 else _top = top
 if(NOT keyword_set(_primary)) then _primary = _top


 if(keyword_set(primary)) then top = _primary

; if(NOT widget_info(top, /valid)) then return
 widget_control, top, set_uvalue=grim_data

end
;=============================================================================



;=============================================================================
; grim_set_primary
;
;=============================================================================
pro grim_set_primary, top
@grim_block.include

 if(keyword__set(_primary)) then old_primary = _primary

 if(old_primary EQ top) then return

 _primary = top

 ;-----------------------------------
 ; erase old primary frame
 ;-----------------------------------
; if(widget_info(old_primary, /valid_id)) then $
 if(widget_info(old_primary, /managed)) then $
  begin
   grim_data = grim_get_data(old_primary)
   grim_refresh, /use_pixmap, /no_objects, /no_image, grim_data, /noglass
  end

 ;-----------------------------------
 ; set new primary and draw frame
 ;-----------------------------------
 grim_data = grim_get_data(_primary)
 _top = _primary
 grim_set_ct, grim_data
 grim_refresh, /no_image, /no_objects, grim_data, /noglass

 grim_call_primary_callbacks

end
;=============================================================================



;=============================================================================
; grim_set_mode_data
;
;=============================================================================
pro grim_set_mode_data, grim_data, data

 if(keyword_set(grim_data.mode_data_p)) then *grim_data.mode_data_p = data 

end
;=============================================================================



;=============================================================================
; grim_add_primary_callback
;
;=============================================================================
pro grim_add_primary_callback, callbacks, data_ps
@grim_block.include

 grim_add_callback, callbacks, data_ps, _pm_callbacks, _pm_data_ps
end
;=============================================================================



;=============================================================================
; grim_rm_primary_callback
;
;=============================================================================
pro grim_rm_primary_callback, data_ps
@grim_block.include

 grim_rm_callback, data_ps, _pm_callbacks, _pm_data_ps
end
;=============================================================================



;=============================================================================
; grim_call_primary_callbacks
;
;=============================================================================
pro grim_call_primary_callbacks
@grim_block.include

 grim_call_callbacks, _pm_callbacks, _pm_data_ps

end
;=============================================================================



;=============================================================================
; grim_add_plane_callback
;
;=============================================================================
pro grim_add_plane_callback, callbacks, data_ps, top=top, no_wset=no_wset

 grim_data = grim_get_data(top, no_wset=no_wset)

 pn_callbacks = *grim_data.pn_callbacks_p
 rf_data_ps = *grim_data.pn_callbacks_data_pp

 grim_add_callback, callbacks, data_ps, pn_callbacks, rf_data_ps

 *grim_data.pn_callbacks_p = pn_callbacks
 *grim_data.pn_callbacks_data_pp = rf_data_ps

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_rm_plane_callback
;
;=============================================================================
pro grim_rm_plane_callback, data_ps, top=top

 grim_data = grim_get_data(top)
 if(NOT grim_exists(grim_data)) then return

 pn_callbacks = *grim_data.pn_callbacks_p
 rf_data_ps = *grim_data.pn_callbacks_data_pp

 grim_rm_callback, data_ps, pn_callbacks, rf_data_ps

 *grim_data.pn_callbacks_p = pn_callbacks
 *grim_data.pn_callbacks_data_pp = rf_data_ps

 grim_set_data, grim_data, grim_data.base
end
;=============================================================================



;=============================================================================
; grim_call_plane_callbacks
;
;=============================================================================
pro grim_call_plane_callbacks, grim_data

 grim_call_callbacks, *grim_data.pn_callbacks_p, *grim_data.pn_callbacks_data_pp

end
;=============================================================================



;=============================================================================
; grim_get_selected
;
;=============================================================================
function grim_get_selected
@grim_block.include

 if(_selected[0] EQ -1) then return, 0

 n = n_elements(_selected)

 dead = bytarr(n)
 for i=0, n-1 do if(NOT widget_info(_selected[i], /valid_id)) then dead[i] = 1

 w = where(dead EQ 0)
 if(w[0] NE -1) then return, _selected[w]

 return, 0
end
;=============================================================================



;=============================================================================
; grim_select
;
;=============================================================================
pro grim_select, grim_data
@grim_block.include

 grim_data.selected = NOT grim_data.selected

 if(grim_data.selected) then $
  begin
   widget_control, grim_data.select_button, set_value=grim_select_bitmap()
   if(_selected[0] EQ -1) then _selected = grim_data.base $
   else _selected = [_selected, grim_data.base]
   grim_print, grim_data, 'Image selected.'
  end $
 else $
  begin
   widget_control, grim_data.select_button, set_value=grim_unselect_bitmap()
   w = where(_selected EQ grim_data.base)
   if(w[0] NE -1) then _selected = rm_list_item(_selected, w[0], only=-1)
   grim_print, grim_data, 'Image deselected.'
  end

end
;=============================================================================



;=============================================================================
; grim_identify
;
;=============================================================================
pro grim_identify, grim_data

 print, '!'

end
;=============================================================================



;=============================================================================
; grim_grnum_create
;
;=============================================================================
function grim_grnum_create, top
common grnum_block, tops

 if(NOT defined(tops)) then tops = -1


 grnum = (min(where(tops EQ -1)))[0]
 if(grnum EQ -1) then $
  begin
   grnum = n_elements(tops) 
   tops = [tops, top] 
  end $
 else tops[grnum] = top
 

 return, grnum
end
;=============================================================================



;=============================================================================
; grim_grnum_destroy
;
;=============================================================================
pro grim_grnum_destroy, grnum
common grnum_block, tops

 tops[grnum] = -1

end
;=============================================================================



;=============================================================================
; grim_top_to_grnum
;
;=============================================================================
function grim_top_to_grnum, top, new=new

 if(keyword_set(new)) then return, grim_grnum_create(top)

 grim_data = grim_get_data(top)
 return, grim_data.grnum
end
;=============================================================================



;=============================================================================
; grim_jump_to_plane
;
;=============================================================================
pro grim_jump_to_plane, grim_data, pn, valid=valid, nosync=nosync

 if(NOT keyword_set(grim_data)) then grim_data = grim_get_data()

 ;-----------------------------------
 ; verify valid plane
 ;-----------------------------------
 valid = 0
 flags = *grim_data.pl_flags_p

 if(pn GE n_elements(flags)) then return
 if(flags[pn] EQ 0) then return
 valid = 1

 ;-----------------------------------
 ; change to next valid plane
 ;-----------------------------------
 grim_data.pn = pn

 grim_set_data, grim_data
 grim_call_plane_callbacks, grim_data
 if(NOT keyword_set(nosync)) then grim_sync_planes, grim_data
end
;=============================================================================



;=============================================================================
; grim_sync_planes
;
;=============================================================================
pro grim_sync_planes, grim_data, norefresh=norefresh
@grim_block.include

 if(NOT keyword_set(_all_tops)) then return

 plane = grim_get_plane(grim_data)
 pn = plane.pn 

 top = _top
 tops = _all_tops
 ntops = n_elements(tops)

 ;-------------------------------------------------
 ; project arrays in other planes and windows
 ;-------------------------------------------------
 for i=0, ntops-1 do if(tops[i] NE top) then $
  begin
   _grim_data = grim_get_data(tops[i])

   if(grim_data.type NE 'plot') then $
    if(grim_get_toggle_flag(_grim_data, 'PLANE_SYNCING')) then $
     if(_grim_data.n_planes NE 1) then $
      begin
       grim_jump_to_plane, _grim_data, pn, /nosync 
       grim_refresh, _grim_data
      end
  end

 grim_data = grim_get_data(top)
end
;=============================================================================

pro grim_data_include
a=!null
end

