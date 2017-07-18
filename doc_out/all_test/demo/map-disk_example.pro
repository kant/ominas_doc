;=======================================================================
;                            MAP-DISK_EXAMPLE.PRO
;
;  This example demonstrates various map projections on a disk
;  using Cassini images and kernels that area not provided in the 
;  distribution.
;
;=======================================================================
!quiet = 1

;-------------------------------
; load image
;-------------------------------
file = './data/N1460002670_1.IMG'
dd = dat_read(file, im)
ctmod
tvim, im, zoom=0.5, /order, /new


;---------------------------------------
; get geometric info 
;---------------------------------------
cd = pg_get_cameras(dd)					
pd = pg_get_planets(dd, od=cd, name='SATURN')
rd = pg_get_rings(dd, pd=pd, od=cd, '/system')
sund = pg_get_stars(dd, od=cd, name='SUN')

gd = {cd:cd, gbx:pd, dkx:rd, sund:sund}


;---------------------------------------
; rough pointing correction
;---------------------------------------
limb_ptd = pg_limb(gd=gd) & pg_hide, limb_ptd, gd=gd, /rm, bx=rd
          pg_hide, limb_ptd, /assoc, gd=gd, bx=pd, od=sund
pg_draw, limb_ptd, col=ctred()

edge_ptd = pg_edges(dd, edge=10)			
pg_draw, edge_ptd, col=ctblue()
dxy = pg_farfit(dd, edge_ptd, [limb_ptd])	
					 	
pg_repoint, dxy, 0d, gd=gd	

limb_ptd = pg_limb(gd=gd) & pg_hide, limb_ptd, gd=gd, /rm, bx=rd
          pg_hide, limb_ptd, /assoc, gd=gd, bx=pd, od=sund
tvim, im
pg_draw, limb_ptd


;------------------------------------------------------
; generate map projections
;------------------------------------------------------
sma = (dsk_sma(rd))[0,*]
map_size = [1200,300]


;md = pg_get_maps(/over, bx=rd[0], $
;	type='ORTHOGRAPHIC_DISK', $ 
;	center = [  !dpi/6d, $  		    ; center latitude 
;	    	    !dpi], $			    ; center longitude
;	size=[400,400] $
;	) 

md = pg_get_maps(/over, bx=rd[0], $
	type='RECTANGULAR_DISK', $  
	center = [  mean(sma), $		    ; center radius 
	    	    !dpi], $			    ; center longitude
	size=map_size $
	) 
map_set_units, md, map_units_disk(md, $
	resrad=(sma[1]-sma[0])/map_size[1], $		; length/pix
	reslon=2d*!dpi/map_size[0]) &$			; rad/pix


dd_map = pg_map(dd, md=md, cd=cd, bx=rd, gd=gd, map=map, $
            hide_fn='pm_rm_globe', hide_data_p=ptr_new(pd))
tvim, /new, map, title=map_type(md) + ' PROJECTION'


;------------------------------------------------------------------
; Project to a different camera perspective
;------------------------------------------------------------------
_cd = nv_clone(cd)

;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Set camera position in terms of sclat, sclon, and altitude in 
; planetary radii
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
pos_surf = tr([-30d	* !dpi/180d, $			; sclat
               0d	* !dpi/180d, $			; sclon
               750d 	* (glb_radii(pd))[0]])		; altitude
pos = bod_body_to_inertial_pos(pd, $
        glb_globe_to_body(pd, pos_surf))
bod_set_pos, _cd, pos


;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
; Point camera back at planet
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
zzz = tr([0d,0d,1d])					; Inertial z axis
yy = v_unit(bod_pos(pd)-pos) 				; Optic axis
xx = v_unit(v_cross(yy, zzz)) 				; Focal plane axes
zz = v_unit(v_cross(xx,yy)) 
bod_set_orient, _cd, [xx,yy,zz] 


_dd = pg_map(dd_map, md=_cd, cd=md, bx=rd, gd=gd, map=_im)
tvim, /new, z=0.5, _im, title=map_type(md) + ' TO CAMERA PROJECTION'


;-------------------------------------------------------------------
; Project from the original image to a different camera perspective
;-------------------------------------------------------------------
_dd = pg_map(dd, md=_cd, cd=cd, bx=rd, gd=gd, map=_im)
tvim, /new, z=0.5, _im, title='CAMERA TO CAMERA PROJECTION'


