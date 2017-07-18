;=======================================================================
;                            GRIM_EXAMPLE.PRO
;
;  This example file demonstrates one way to use the graphical
;  interface to ominas.  Here, we use grim in a manner very similar 
;  to the use of tvim, but the grim interface is somewhat more 
;  convenient because the viewing parameters may be changed without 
;  using tvzoom and tvmove and overlay points are automatically
;  recomputed and redrawn whenever descriptors are modified
;
;  This example file can be executed from the UNIX command line using
;
;  	ominas grim_example.pro
;
;  or from within IDL using
;
;  	@grim_example
;
;  After the example stops, later code samples in this file may be executed by
;  pasting them onto the IDL command line.
;
;
; A similar result can be obtained using the following command:
;
;  grim, 'data/n1350122987.2', z=0.5, over=['planet_center','ring','limb','terminator']
;
;=======================================================================
!quiet = 1
;-------------------------------------
; read a file using dat_read
;-------------------------------------
file = 'data/n1350122987.2'

dd = dat_read(file)


;-------------------------------------
; display the image using grim
;-------------------------------------
grim, dd, zoom=0.75, /order
;-------------------------------------
; Obtain descriptors
;-------------------------------------
cd = pg_get_cameras(dd, 'ck_in=auto')
pd = pg_get_planets(dd, od=cd, $
       name=['JUPITER', 'IO', 'EUROPA', 'GANYMEDE', 'CALLISTO'])
rd = pg_get_rings(dd, pd=pd, od=cd)
sund = pg_get_stars(dd, od=cd, name='SUN')

gd = {cd:cd, gbx:pd, dkx:rd, sund:sund}

;-------------------------------------------------------------------------
; Compute overlays
;-------------------------------------------------------------------------
limb_ptd = pg_limb(gd=gd) & pg_hide, limb_ptd, gd=gd, /rm, bx=rd
          pg_hide, limb_ptd, /assoc, gd=gd, bx=pd, od=sund
ring_ptd = pg_disk(gd=gd) & pg_hide, ring_ptd, gd=gd, bx=pd
term_ptd = pg_limb(gd=gd, od=gd.sund) & pg_hide, term_ptd, gd=gd, bx=pd, /assoc

center_ptd = pg_center(gd=gd, bx=pd)
object_ptd = [center_ptd,limb_ptd,ring_ptd,term_ptd]

;-------------------------------------------------------------------------
; draw overlays on current grim window
;
; gr_draw provides an interface to grim that is analogous to that of 
; pg_draw, the most important exception being that the relevant descriptors 
; must be specified in addition to the overlay points.  Each given curve 
; must correspond to a given descriptor.  For example, you cannot specify 
; 5 planet descriptors and only 4 limb curves.
;
;-------------------------------------------------------------------------
gr_draw, object_ptd, gd=gd
stop, '=== Auto-example complete.  Use cut & paste to continue.'


;-------------------------------------------------------------------------
;
;                    First-cut Automatic repointing 
;
;-------------------------------------------------------------------------
edge_ptd = pg_edges(dd, edge=10)
gr_draw, edge_ptd, col=ctwhite()
; pg_draw, edge_ptd				; you could also do this
dxy = pg_farfit(dd, edge_ptd, [limb_ptd[0]])
pg_repoint, dxy, 0d, axis=center_ptd[0], gd=gd


;-------------------------------------------------------------------------
;
;                    Least-squares pointing refinement 
;
;-------------------------------------------------------------------------
cvscan_ptd = pg_cvscan(dd, gd=gd, [limb_ptd[0]], edge=30, width=80, $
             model=[ptr_new(edge_model_nav_limb(zero=lzero))], mzero=[lzero] )
gr_draw, cvscan_ptd, col=ctblue()
; pg_draw, cvscan_ptd				; you could also do this


cvscan_cf = pg_cvscan_coeff(cvscan_ptd, axis=center_ptd[0], fix=2)
dxy = pg_fit([cvscan_cf], dtheta=dtheta)
pg_repoint, dxy, dtheta, axis=center_ptd[0], gd=gd

