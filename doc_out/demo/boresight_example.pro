;=======================================================================
;                            BORESIGHT_EXAMPLE.PRO
;
;  This example file navigates a narrow-angle image using a wide-angle
;  image.
;
;  This example file can be executed from the UNIX command line using
;
;  	ominas boresight_example.pro
;
;  or from within IDL using
;
;  	@boresight_example
;
;=======================================================================
!quiet = 1

;=======================================================================
; load and display images
;=======================================================================
file_nac = './data/n1354897340.1'
file_wac = './data/w1354897340.1'

dd_nac = dat_read(file_nac, im_nac)
dd_wac = dat_read(file_wac, im_wac)

ctmod
tvim, im_nac, zoom=0.45, /order, /new
w_nac = !d.window

tvim, im_wac, zoom=0.45, /order, /new
w_wac = !d.window

;=======================================================================
; get descriptors
;=======================================================================
cd_nac = pg_get_cameras(dd_nac)
cd_wac = pg_get_cameras(dd_wac)

pd_nac = pg_get_planets(dd_nac, od=cd_nac, name=['JUPITER'])
pd_wac = pg_get_planets(dd_wac, od=cd_wac, name=['JUPITER'])

gd_nac = {cd:cd_nac, gbx:pd_nac}
gd_wac = {cd:cd_wac, gbx:pd_wac}

;=======================================================================
; Compute initial limbs
;=======================================================================
limb_ps_nac = pg_limb(gd=gd_nac) 
limb_ps_wac = pg_limb(gd=gd_wac) 

tvim, w_nac
pg_draw, limb_ps_nac

tvim, w_wac
pg_draw, limb_ps_wac

;=======================================================================
; Roughly navigate the wide-angle frame
;
;  The coarse fit is adequate for this example; in real life, you'll
;  need a very precise fit for this application so you'll need to 
;  do a limb scan as demonstrated in jupiter.example.
;
;=======================================================================
tvim, w_wac

edge_ps = pg_edges(dd_wac, edge=10)
pg_draw, edge_ps
dxy = pg_farfit(dd_wac, edge_ps, [limb_ps_wac])
pg_repoint, dxy, 0d, gd=gd_wac

limb_ps_wac = pg_limb(gd=gd_wac) 
tvim, im_wac
pg_draw, limb_ps_wac

;=======================================================================
; Use boresight to correct nac navigation
;
;  Here, pg_repoint is used without any image offsets.  Instead, we
;  give it the corrected WAC camera descriptor and a rotation matrix
;  to correct for misalignments between the cameras.
; 
;=======================================================================
pg_repoint, gd=gd_nac, bore_cd=cd_wac, bore_rot=cas_mx_wac_to_nac()

limb_ps_nac = pg_limb(gd=gd_nac) 
tvim, w_nac, im_nac
pg_draw, limb_ps_nac








