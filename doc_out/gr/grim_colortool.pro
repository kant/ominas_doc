;=============================================================================
; grct_slider_to_gamma
;
;
;=============================================================================
function grct_slider_to_gamma, value
 return, 10d^(value/25d - 2d)
end
;=============================================================================



;=============================================================================
; grct_gamma_to_slider
;
;
;=============================================================================
function grct_gamma_to_slider, value
 return, 25d*(alog10(value) + 2d)
end
;=============================================================================



;=============================================================================
; grct_print_gamma
;
;
;=============================================================================
pro grct_print_gamma, data
  
 widget_control, data.gamma_slider, get_value = value
 widget_control, data.gamma_label, $
                set_value = str_pad(strtrim(grct_slider_to_gamma(value), 2), 7)

end
;=============================================================================



;=============================================================================
; grct_widget_to_descriptor
;
;
;=============================================================================
function grct_widget_to_descriptor, data, cmd

 ctmod, top=top
 n_colors = cmd.n_colors

 widget_control, data.bottom_slider, get_value = value 
 cmd.bottom = value/100d * n_colors
 widget_control, data.top_slider, get_value = value
 cmd.top = value/100d * n_colors

 widget_control, data.gamma_slider, get_value = value
 cmd.gamma = grct_slider_to_gamma(value)

 widget_control, data.shade_slider, get_value = value
 cmd.shade = value/100d

 return, cmd
end
;=============================================================================



;=============================================================================
; grct_descriptor_to_widget
;
;
;=============================================================================
pro grct_descriptor_to_widget, data, cmd, noslide=noslide

 n_colors = cmd.n_colors
 noslide = keyword_set(noslide)

 if(NOT noslide) then $
        widget_control, data.bottom_slider, set_value = cmd.bottom*100d/n_colors
 if(NOT noslide) then $
        widget_control, data.top_slider, set_value = cmd.top*100d/n_colors

 if(NOT noslide) then widget_control, data.gamma_slider,$
                        set_value = grct_gamma_to_slider(cmd.gamma) 

 if(NOT noslide) then $
        widget_control, data.shade_slider, set_value = cmd.shade*100d


 ctmod, top=top, visual=visual

 widget_control, data.base, $
                   tlb_set_title='Grim color tool : ' + grim_title(/primary)
end
;=============================================================================



;=============================================================================
; grct_plot
;
;
;=============================================================================
pro grct_plot, data

 n_colors = data.cmd.n_colors

 wset, data.wnum
 colormap = compute_colormap(data.cmd)
 colormap = congrid(colormap, 100) * 255 / n_colors

 ctmod, top=top, visual=visual

 erase, ctblack()
 plot, colormap, xstyle=1, ystyle=1, pos=[0.12,0.2, 0.95,0.95], th=2, $
       col=ctwhite()



 p = convert_coord(0d,0d, /data, /to_device)
 pp = convert_coord(100d,0d, /data, /to_device)

 xs = pp[0] - p[0]

 bar = long(findgen(xs) * float(100) / float(xs))

 yy = 15

 cbar = bar # make_array(yy, val=1)

 if((visual EQ 8)) then $
  begin 
   colorbar = apply_colormap(cbar, colormap)
   tv, colorbar, p[0], 0
  end $
 else $
  begin
   red = apply_colormap(cbar, colormap, channel=0)
   grn = apply_colormap(cbar, colormap, channel=1)
   blu = apply_colormap(cbar, colormap, channel=2)
   tv, red, channel=1, p[0], 0
   tv, grn, channel=2, p[0], 0
   tv, blu, channel=3, p[0], 0
  end


 plots, [p[0], p[0], pp[0]-1, pp[0]-1, p[0]], [0, yy, yy, 0, 0], /device


end
;=============================================================================



;=============================================================================
; grct_cleanup
;
;
;=============================================================================
pro grct_cleanup, base

 widget_control, base, get_uvalue=data
 grim_rm_primary_callback, data.data_p

end
;=============================================================================



;=============================================================================
; grim_colortool_event
;
;
;=============================================================================
pro grim_colortool_event, event

 widget_control, event.top, get_uvalue = data

 struct = tag_names(event, /struct)
 callback = 0

 ;---------------------------
 ; 'All' button
 ;---------------------------
 if(event.id EQ data.all_button) then $
  begin
   if(data.all) then data.all = 0 $
   else data.all = 1
   callback = 1
  end $

 ;---------------------------
 ; 'Auto' button
 ;---------------------------
 else if(event.id EQ data.auto_button) then $
  begin
   test = image_eq(bytscl(nv_data(data.dd)), frac=0.99999, low=1, min=min, max=max)
   top = float(max)/256 * 100
   bottom = float(min)/256 * 100

   widget_control, data.top_slider, set_value=top
   widget_control, data.bottom_slider, set_value=bottom
   data.cmd = grct_widget_to_descriptor(data, data.cmd)

   callback = 1
  end $

 ;---------------------------
 ; 'Done' button
 ;---------------------------
 else if(event.id EQ data.done_button) then $
  begin
   widget_control, data.base, /destroy
   return
  end $

 ;---------------------------
 ; table droplist
 ;---------------------------
 else if(event.id EQ data.ct_droplist) then $
  begin
   loadct, event.index, /silent
   ctmod, top=top, visual=visual
   callback = 1
  end $

 ;---------------------------
 ; draw widget
 ;---------------------------
 else if(event.id EQ data.graph) then $
  begin
   device, cursor_standard = 34
  end $

 ;---------------------------
 ; other widgets
 ;---------------------------
 else $
  begin
   cmd = grct_widget_to_descriptor(data, data.cmd)
   data.cmd = cmd
   grct_plot, data

   if(event.id EQ data.gamma_slider) then grct_print_gamma, data

   if(struct NE 'WIDGET_SLIDER') then callback = 1 $
   else if(NOT event.drag) then callback = 1
  end


 ;-------------------------------------
 ; notify callback routine
 ;-------------------------------------
 if(callback) then $
       call_procedure, data.callback, data.cmd, data.cb_data, all=data.all


 widget_control, event.top, set_uvalue=data
end
;=============================================================================



;=============================================================================
; grim_colortool_change
;
;
;=============================================================================
pro grim_colortool_change, base, cmd

 widget_control, base, get_uvalue=data

 data.cmd = cmd

 widget_control, base, set_uvalue=data

 grct_descriptor_to_widget, data, data.cmd
 grct_plot, data
 grct_print_gamma, data

end
;=============================================================================



;=============================================================================
; grct_primary_notify
;
;
;=============================================================================
pro grct_primary_notify, data_p

 grim_data = grim_get_data(/primary)
 if(grim_data.type EQ 'plot') then return

 grim_colortool_change, (*data_p).base, grim_get_cmds(grim_data)

end
;=============================================================================



;=============================================================================
; grim_colortool
;
;
;=============================================================================
pro grim_colortool, cmd, dd, callback=callback, cb_data=cb_data
common grim_colortool_block, base

 if(xregistered('grim_colortool')) then $
  begin
   grim_colortool_change, base, cmd
   return
  end


 ;-------------------------------------------------------------------
 ; get color table names and values
 ;-------------------------------------------------------------------
 loadct, get_names=ct_list
 

 ;--------------------------------------------
 ; widgets
 ;--------------------------------------------
 base = widget_base(/col)

 fns = ['Linear', 'Exponential', 'Log']

 col_base = widget_base(base, /col)
 dl_base = widget_base(col_base, /row)
 all_base = widget_base(dl_base, /nonexclusive, /frame)
 all_button = widget_button(all_base, value=' All')
 auto_button = widget_button(dl_base, value='Auto')
 ct_droplist = widget_droplist(dl_base, value=ct_list, title='Color Table:')
 row_base = widget_base(col_base, /row, /frame)


 shade_slider = widget_slider(row_base, ysize=180, /drag, max=100, /vertical, /supp)
 graph = widget_draw(row_base, xsize=220, ysize=180, /tracking, retain=2)
 slider_base = widget_base(row_base, /col, xsize=200)
 top_slider = $
          widget_slider(slider_base, title='Stretch top', xsize=200, $
                                                             max=100, /drag)

 bottom_slider = $
     widget_slider(slider_base, title='Stretch bottom', xsize=200, $
                                                             max=100, /drag)

 gamma_label = widget_label(slider_base, value='---------', /align_center)
 gamma_slider = $
            widget_slider(slider_base, title='Gamma', $
                                               xsize=200, /drag, /suppress)

 done_button = widget_button(base, value='Done')





 ;-----------------------------------------------------
 ; realize and register
 ;-----------------------------------------------------
 widget_control, base, /realize
 xmanager, 'grim_colortool', base, /no_block, cleanup='grct_cleanup'


 widget_control, graph, get_value=wnum


 ;-----------------------------------------------
 ; main data structure
 ;-----------------------------------------------
 data = { $
		;-------------------
 		; widgets
		;-------------------
		base		:	base, $
		dd		: 	dd, $
		ct_droplist	:	ct_droplist, $
		all_button	:	all_button, $
		auto_button	:	auto_button, $
		graph		:	graph, $
		top_slider	:	top_slider, $
		bottom_slider	:	bottom_slider, $
		gamma_slider	:	gamma_slider, $
		gamma_label	:	gamma_label, $
		shade_slider	:	shade_slider, $
		done_button	:	done_button, $
		wnum		:	wnum, $
		all		:	0, $
		callback	:	callback, $
		cb_data		:	cb_data, $

		;-------------------
 		; book-keeping
		;-------------------
		data_p		:	nv_ptr_new(), $
		cmd		:	cmd $
	     }

 data.data_p = nv_ptr_new(data)

 widget_control, base, set_uvalue = data

 grct_descriptor_to_widget, data, cmd
 grct_plot, data

 grim_add_primary_callback, 'grct_primary_notify', data.data_p
 grct_print_gamma, data

end
;=============================================================================
