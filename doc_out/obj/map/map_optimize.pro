;=============================================================================
; map_optimize
;
;=============================================================================
function map_optimize, md=md0, $
	type=type, size=size, origin=origin, $
	latmin=latmin, lonmin=lonmin, radmin=radmin












 if(keyword_set(md0)) then md = nv_clone(md0) $
 else md = map_create_descriptors(1, $
			type=type, $
			size=size, $
			scale=scale, $
			origin=origin, $
			units=units, $
			center=center

 return, md
end
;=============================================================================
