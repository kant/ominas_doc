;==============================================================================
; orb_lon_to_anom
;
;
;==============================================================================
function orb_lon_to_anom, xd, lon, frame_bd, ap=ap, lan=lan
 return, orb_arg_to_anom(xd, $
           orb_lon_to_arg(xd, lon, frame_bd, lan=lan), frame_bd, ap=ap)
end
;==============================================================================