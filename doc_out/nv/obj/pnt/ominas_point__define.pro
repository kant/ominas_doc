;=============================================================================
; ominas_point::init
;
;=============================================================================
function ominas_point::init, ii, crd=crd0, ptd=ptd0, $
@point__keywords.include
end_keywords
@core.include
 
 void = self->ominas_core::init(ii, crd=crd0, $
@core__keywords.include
end_keywords)
 if(keyword_set(ptd0)) then struct_assign, ptd0, self

 self.abbrev = 'PNT'

 ;-----------------------
 ; desc
 ;-----------------------
 if(keyword_set(desc)) then self.desc = desc[ii]

 ;-----------------------
 ; input
 ;-----------------------
 if(keyword_set(input)) then self.input = input[ii]

 ;-----------------------
 ; points
 ;-----------------------
 if(keyword_set(points)) then $
  begin
   self.points_p = nv_ptr_new(points[*,*,ii])

   dim = size(points, /dim)
   ndim = n_elements(dim)
   nv = (nt = 1)
   if(ndim GT 1) then nv = dim[1]
   if(ndim GT 2) then nt = dim[2]
  end

 ;-----------------------
 ; vectors
 ;-----------------------
 if(keyword_set(vectors)) then $
  begin
   self.vectors_p = nv_ptr_new(vectors[*,*,ii])

   dim = size(vectors, /dim)
   ndim = n_elements(dim)
   nvv = (ntv = 1)
   nvv = dim[0]
   if(ndim GT 2) then ntv = dim[2]

   if(NOT keyword_set(nv)) then $
    begin
     nv = nvv
     nt = ntv
    end $
   else if((nvv NE nv) OR (ntv NE nt)) then $
                 nv_message, name='ominas_point::init', $
                                       'Incompatible vector array dimensions.'
  end

 ;-----------------------
 ; flags
 ;-----------------------
 if(NOT defined(flags)) then $
           if(keyword_set(nv)) then flags = bytarr(nv)

 if(defined(flags)) then $
  begin
   self.flags_p = nv_ptr_new(flags)

   dim = [1]
   if(n_elements(flags) GT 1) then dim = size(flags, /dim)
   ndim = n_elements(dim)
   nvf = dim[0]
   ntf = 1
   if(ndim GT 1) then ntf = dim[1]

   if(NOT keyword_set(nv)) then $
    begin
     nv = nvf
     nt = ntf
    end $
   else if((nvf NE nv) OR (ntf NE nt)) then $
                nv_message, name='ominas_point::init', $
                                          'Incompatible flag array dimensions.'
  end


 ;--------------------------
 ; point-by-point data
 ;--------------------------
 if(keyword_set(data)) then $
  begin
   self.data_p = nv_ptr_new(data[*,*,ii])

   dim = size(data, /dim)
   ndim = n_elements(dim)
   nvd = (ntd = 1)
   ndat = dim[0]
   if(ndim GT 1) then nvd = dim[1]
   if(ndim GT 2) then ntd = dim[2]

   if(NOT keyword_set(nv)) then $
    begin
     nv = nvd
     nt = ntd
    end $
   else if((nvd NE nv) OR (ntd NE nt)) then $
              nv_message, name='ominas_point::init', $
                            'Incompatible point-by-point data array dimensions.'
  end


 ;--------------------------
 ; point-by-point data tags
 ;--------------------------
 if(keyword_set(tags)) then $
  begin
   self.tags_p = nv_ptr_new(tags[*,ii])

   dim = size(tags, /dim)
   ndim = n_elements(dim)
   nvt = dim[0]

   if(keyword_set(ndat)) then $
       if(nvt NE ndat) then nv_message, $
                     name='ominas_point::init', $
                                       'Incompatible tags array dimensions.'
  end


 ;--------------------------
 ; dimensions
 ;--------------------------
 self.nv = (self.nt = 0)
 if(keyword_set(nv)) then self.nv = nv[ii]
 if(keyword_set(nt)) then self.nt = nt[ii]

 return, 1
end
;=============================================================================



;=============================================================================
;+
; NAME:
;	ominas_point__define
;
;
; PURPOSE:
;	Structure for managing points.
;
;
; CATEGORY:
;	NV/SYS/PS
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	desc:		Data set description.
;
;	points_p:	Pointer to image points.
;
;	vectors_p:	Pointer to inertial vectors.
;
;	data_p:		Pointer to a point-by-point user data array.
;
;	tags_p:		Tags for point-by-point user data.
;
;	flags_p:	Pointer to point-by-point flag array.
;
;	input:		Description of input data used to produce these
;			points.
;
;	nv:		Number of elements in the nv direction.
;
;	nt:		Number of elements in the nt direction.
;
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
;  Spitale, 11/2015; 	Adapted from pg_points_struct__define
;	
;-
;=============================================================================
pro ominas_point__define

 struct={ominas_point, inherits ominas_core, $
		desc:		'', $		; data set description
		points_p:	ptr_new(), $	; image points
		vectors_p:	ptr_new(), $	; inertial vectors
		flags_p:	ptr_new(), $	; flags
		data_p:		ptr_new(), $	; point-by-point user data
		tags_p:		ptr_new(), $	; tags for p-b-p user data
		input:		'', $		; description of input data
		nv:		0l, $
		nt:		0l $
	}

end
;===========================================================================



