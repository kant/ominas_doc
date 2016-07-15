;=============================================================================
; dat_compress_data_mask
;
;=============================================================================
function dat_compress_data_mask, _dd, data

 if(NOT ptr_valid(_dd.compress_data_p)) then _dd.compress_data_p = nv_ptr_new(0)

 s = size(data)

 mask = where(data NE 0)

 cdata = 0
 if(mask[0] NE -1) then cdata = data[mask]
 *_dd.compress_data_p = {size:s, mask:mask}

 return, cdata
end
;=============================================================================
