;===========================================================================
; detect_vgr_rss.pro
;
;===========================================================================
function detect_vgr_rss, dd

 label = dat_header(dd) 

 w = where(strpos(label, 'VG1 RSS') NE -1)
 if(w[0] NE -1) then return, 'VGR_RSS'
 w = where(strpos(label, 'VG2 RSS') NE -1)
 if(w[0] NE -1) then return, 'VGR_RSS'


 return, ''
end
;===========================================================================
