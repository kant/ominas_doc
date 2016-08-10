;=============================================================================
;+
; NAME:
;	pg_reflection_disk
;
;
; PURPOSE:
;	Computes image coordinates of given inertial vectors reflected onto
;	surface of the given disk with respect to the given observer.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_reflection_disk(object_ptd, cd=cd, ods=ods, dkx=dkx)
;
;
; ARGUMENTS:
;  INPUT:
;	object_ptd:	Array of POINT containing inertial vectors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array (n_timesteps) of camera descriptors.
;
;	dkx:	Array (n_disks, n_timesteps) of descriptors of objects 
;		which must be a subclass of DISK.
;
;	od:	Array (n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY.  These objects are used
;		as the source from which points are projected.  If no observer
;		descriptor is given, then the camera descriptor in gd is used.
;		Only one observer is allowed.
;
;	gd:	Generic descriptor.  If given, the cd and dkx inputs 
;		are taken from the cd and dkx fields of this structure
;		instead of from those keywords.
;
;	reveal:	 Normally, disks whose opaque flag is set are ignored.  
;		 /reveal suppresses this behavior.
;
;	fov:	 If set reflection points are cropped to within this many camera
;		 fields of view.
;
;	cull:	 If set, POINT objects excluded by the fov keyword
;		 are not returned.  Normally, empty POINT objects
;		 are returned as placeholders.
;
;	all:	 If set, all points are returned, even if invalid.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;	Array (n_disks,n_objects) of POINT containing image 
;	points and the corresponding inertial vectors.
;
;
; STATUS:
;	Not tested
;
;
; SEE ALSO:
;	pg_reflection, pg_reflection_globe
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2002
;	
;-
;=============================================================================
function pg_reflection_disk, cd=cd, od=od, dkx=dkx, gd=gd, object_ptd, $
                           nocull=nocull, all_ptd=all_ptd, reveal=reveal, $
                           fov=fov, cull=cull, all=all
@pnt_include.pro


 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 pgs_gd, gd, cd=cd, dkx=dkx, od=od, sund=sund
 if(NOT keyword_set(cd)) then cd = 0 

 if(NOT keyword_set(od)) then $
  if(keyword_set(cd)) then od = cd $
  else nv_message, name='pg_reflection_disk', 'No observer descriptor.'


 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 pgs_count_descriptors, od, nd=n_observers, nt=nt
 if(n_observers GT 1) then $
    nv_message, name='pg_reflection_disk', 'Only one observer descriptor allowed.'
 pgs_count_descriptors, dkx, nd=n_disks, nt=nt1
 if(nt NE nt1) then $
                 nv_message, name='pg_reflection_disk', 'Inconsistent timesteps.'


 ;---------------------------------------------------
 ; compute reflections for each object on each disk
 ;---------------------------------------------------
 n_objects=(size(object_ptd))[1]
 _reflection_ptd = objarr(n_disks, n_objects)
 reflection_ptd = objarr(n_objects)

 obs_pos = bod_pos(od)
 for j=0, n_objects-1 do if(obj_valid(object_ptd[j])) then $
  begin
   for i=0, n_disks-1 do $
    if((bod_opaque(dkx[i,0])) OR (keyword_set(reveal))) then $
     begin
      ii = dsk_valid_edges(dkx[i,*], /all)
      if(ii[0] NE -1) then $
       begin
        xd = reform(dkx[i,ii], nt)

        ;---------------------------
        ; get object vectors
        ;---------------------------
        pnt_get, object_ptd[j], vectors=vectors, assoc_xd=assoc_xd
        if(xd NE assoc_xd) then $
         begin
          n_vectors = (size(vectors))[1]
 
          ;---------------------------------------------
          ; source and observer vectors in body frame
          ;---------------------------------------------
          v_inertial = obs_pos##make_array(n_vectors, val=1d)
          r_inertial = vectors
          r_body = bod_inertial_to_body_pos(xd, r_inertial)
          v_body = bod_inertial_to_body_pos(xd, v_inertial)

          ;---------------------------------
          ; project reflections in body frame
          ;---------------------------------
          reflection_pts = dsk_reflect(xd, v_body, r_body, hit=hit)

          ;---------------------------------------------------------------
          ; compute and store image coords of intersections
          ;---------------------------------------------------------------
          if(hit[0] NE -1) then $
           begin
            flags = bytarr(n_elements(reflection_pts[*,0]))
            points = $
                 degen(body_to_image_pos(cd, xd, reflection_pts, $
                                         inertial=inertial_pts, valid=valid))

            ;---------------------------------
            ; store points
            ;---------------------------------
            _reflection_ptd[i,j] = $
                 pnt_create_descriptors(points = points, $
;                   input = pgs_desc_suffix(dkx=dkx[i,0], gbx=gbx[0], srcd=object_ptd[j], od=od[0], cd[0]), $
                   input = pgs_desc_suffix(dkx=dkx[i,0], srcd=object_ptd[j], od=od[0], cd[0]), $
                   vectors = inertial_pts)

            ;-----------------------------------------------
            ; flag points that missed the ring as invisible
            ;-----------------------------------------------
            flags = pnt_flags(_reflection_ptd[i,j])
            hh = complement(rr[*,0,0], hit)
            if(hh[0] NE -1) then flags[hh] = flags[hh] OR PTD_MASK_INVISIBLE

            ;-----------------------------------------------------------
            ; flag invalid image points as invisible unless /all
            ;-----------------------------------------------------------
            if(NOT keyword_set(all)) then $
             if(keyword_set(valid)) then $
              begin
               invalid = complement(reflection_pts[*,0], valid)
               if(invalid[0] NE -1) then flags[invalid] = PTD_MASK_INVISIBLE
              end

            ;---------------------------------------------------------------
            ; store flags
            ;---------------------------------------------------------------
            pnt_set_flags, _shadow_ptd[i,j], flags
           end
         end
       end
     end

   ;-----------------------------------------------------
   ; take only nearest reflection points for this object
   ;-----------------------------------------------------
   reflection_ptd[j] = pnt_compress(_reflection_ptd[*,j])
   pnt_set_desc, reflection_ptd[j], 'disk_reflection'
;   if(NOT keyword__set(all_ptd)) then $
;    begin
;     sp = pnt_cull(_reflection_ptd[*,j])
;     if(keyword__set(sp)) then $
;      begin
;;       if(n_elements(sp) EQ 1) then reflection_ptd[j] = sp $
;;       else reflection_ptd[j] = pg_nearest_points(object_ptd[j], sp) 
;      end
;   end
  end

 ;-------------------------------------------------------------------------
 ; by default, remove empty POINT objects and reform to one dimension 
 ;-------------------------------------------------------------------------
 if(NOT keyword__set(nocull)) then reflection_ptd = pnt_cull(reflection_ptd)


 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(fov)) then $
  begin
   pg_crop_points, reflection_ptd, cd=cd[0], slop=slop
   if(keyword_set(cull)) then reflection_ptd = pnt_cull(reflection_ptd)
  end


 return, reflection_ptd
end
;=============================================================================
