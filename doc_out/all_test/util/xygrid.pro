;==================================================================================
; xygrid
;
;==================================================================================
pro xygrid, nx, ny, x=x, y=y

 x = dindgen(nx)#make_array(ny, val=1d)
 y = dindgen(ny)##make_array(nx, val=1d)

end
;==================================================================================
