;============================================================================
; epoch_dt
;
;============================================================================
function epoch_dt, bx, epoch_jd

 tt = bod_time(bx)				; sec. past J2000	
 t = julday(1,1,2000,12,0,0) + tt/86400.	; julian day
 dt = (epoch_jd - t) * 86400d

 return, dt
end
;============================================================================