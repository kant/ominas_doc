;=============================================================================
;+
; NAME:
;	pg_hide_globe
;
;
; PURPOSE:
;	Hides the given points with respect to each given globe and observer.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_hide_globe, object_ptd, cd=cd, od=od, gbx=gbx
;	pg_hide_globe, object_ptd, gd=gd, od=od
;
;
; ARGUMENTS:
;  INPUT:
;	object_ptd:	Array of POINT containing inertial vectors.
;
;	hide_ptd:	Array (n_disks, n_timesteps) of POINT 
;			containing the hidden points.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array (n_timesteps) of camera descriptors.
;
;	gbx:	Array (n_globes, n_timesteps) of descriptors of objects 
;		which must be a subclass of GLOBE.
;
;	od:	Array (n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY.  These objects are used
;		as the observer from which points are hidden.  If no observer
;		descriptor is given, the camera descriptor is used.
;
;	gd:	Generic descriptor.  If given, the cd and gbx inputs 
;		are taken from the cd and gbx fields of this structure
;		instead of from those keywords.
;
;	reveal:	 Normally, objects whose opaque flag is set are ignored.  
;		 /reveal suppresses this behavior.
;
;	cat:	If set, the hide_ptd points are concatentated into a single
;		POINT.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; SIDE EFFECTS:
;	The flags arrays in object_ptd are modified.
;
;
; PROCEDURE:
;	For each object in object_ptd, hidden points are computed and
;	PTD_MASK_INVISIBLE in the POINT is set.  No points are
;	removed from the array.
;
;
; EXAMPLE:
;	The following command hides all points which are behind the planet as
;	seen by the camera:
;
;	pg_hide_globe, object_ptd, cd=cd, gbx=pd
;
;	In this call, pd is a planet descriptor, and cd is a camera descriptor.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_hide, pg_hide_disk, pg_hide_limb
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
pro pg_hide_globe, cd=cd, od=od, gbx=gbx, gd=gd, _point_ptd, hide_ptd, $
              reveal=reveal, compress=compress, cat=cat
@pnt_include.pro

 hide = keyword_set(hide_ptd)
 if(NOT keyword_set(_point_ptd)) then return

 ;----------------------------------------------------------
 ; if /compress, assume all point_ptd have same # of points
 ;----------------------------------------------------------
;stop
;compress=1
; if(keyword_set(compress)) then point_ptd = pnt_compress(_point_ptd) $
; else 
point_ptd = _point_ptd

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 pgs_gd, gd, cd=cd, gbx=gbx, od=od
 if(NOT keyword_set(cd)) then cd = 0 

 if(NOT keyword_set(gbx)) then return

 ;-----------------------------
 ; default observer is camera
 ;-----------------------------
 if(NOT keyword_set(od)) then od=cd

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 nt = n_elements(od)
 pgs_count_descriptors, gbx, nd=n_globes, nt=nt1
 if(nt NE nt1) then nv_message, name='pg_hide_globe', 'Inconsistent timesteps.'



 ;------------------------------------
 ; hide object points for each planet
 ;------------------------------------
 n_objects = n_elements(point_ptd)
 if(hide) then hide_ptd = objarr(n_objects, n_globes)

 obs_pos = bod_pos(od)
 for j=0, n_objects-1 do if(obj_valid(point_ptd[j])) then $
  for i=0, n_globes-1 do $
   if((bod_opaque(gbx[i,0])) OR (keyword_set(reveal))) then $
    begin
     xd = reform(gbx[i,*], nt)

     Rs = bod_inertial_to_body_pos(xd, obs_pos)

     pnt_get, point_ptd[j], p=p, vectors=vectors, flags=flags
     object_pts = bod_inertial_to_body_pos(xd, vectors)

     w = glb_hide_points(xd, Rs, object_pts)

     if(w[0] NE -1) then $
      begin
       _flags = flags
       _flags[w] = _flags[w] OR PTD_MASK_INVISIBLE
       pnt_set_flags, point_ptd[j], _flags
      end

     if(hide) then $
      begin
       hide_ptd[j,i] = nv_clone(point_ptd[j])

       pnt_get, point_ptd[j], desc=desc, inp=inp

       ww = complement(flags, w)
       _flags = flags
       if(ww[0] NE -1) then _flags[ww] = _flags[ww] OR PTD_MASK_INVISIBLE

       pnt_set, hide_ptd[j,i], desc=desc+'-hide_globe', $
            input=inp+pgs_desc_suffix(gbx=gbx[i,0], od=od[0], cd[0]), flags=_flags
      end
    end


 ;---------------------------------------------------------
 ; if desired, concatenate all hide_ptd for each object
 ;---------------------------------------------------------
 if(hide AND keyword_set(cat)) then $
  begin
   for j=0, n_objects-1 do hide_ptd[j,0] = pnt_compress(hide_ptd[j,*])
   if(n_globes GT 1) then $
    begin
     nv_free, hide_ptd[*,1:*]
     hide_ptd = hide_ptd[*,0]
    end
  end


; ;----------------------------------------------------------
; ; if /compress, expand result
; ;----------------------------------------------------------
; if(keyword_set(compress)) then $
;  begin
;   pnt_uncompress, point_ptd, _point_ptd, i=ww
;   pnt_uncompress, hide_ptd, _hide_ptd, i=w
;  end $
; else point_ptd = _point_ptd


end
;=============================================================================
