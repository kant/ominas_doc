;==============================================================================
;+
; NAME:
;	nv_clone
;
;
; PURPOSE:
;       Allocates a new object as a copy of the given (existing) 
;	object.  All pointers in the new object are newly allocated.  
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	new_xd = nv_clone(xd)
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	 Object to clone.  May be any pointer or structure.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: NONE
;
;
; RETURN: 
;       Newly created object with all fields identical to
;       the input object, and new pointers.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
; 	Adapted by:	Spitale, 5/2016
;	
;-
;==============================================================================



;=============================================================================
; nv_clone_recurse
;
;=============================================================================
pro nv_clone_recurse, xd

 type = size(xd, /type)
 n = n_elements(xd)

 ;----------------------------------------------
 ; pointer 
 ;----------------------------------------------
 if(type EQ 10) then $
  begin
   for i=0, n-1 do if(ptr_valid(xd[i])) then $
    begin
     xd[i] = nv_ptr_new(*xd[i]) 
     nv_clone_recurse, *xd[i]
    end
  end $
 ;----------------------------------------------
 ; structure 
 ;----------------------------------------------
 else if(type EQ 8) then $
  begin
   for i=0, n-1 do $
    begin
     ntags = n_tags(xd[i])
     tags = tag_names(xd[i])
     for j=0, ntags-1 do if(NOT nv_protected(tags[j])) then $
      begin
       val = xd[i].(j)
       nv_clone_recurse, val
       xd[i].(j) = val
      end
    end
  end $
 ;----------------------------------------------
 ; object 
 ;----------------------------------------------
 else if(type EQ 11) then $
  begin
   for i=0, n-1 do if(obj_valid(xd[i])) then $
    begin
     _xd = cor_dereference(xd[i])

     ntags = n_tags(_xd)
     tags = tag_names(_xd)
     for j=0, ntags-1 do if(NOT nv_protected(tags[j])) then $
      begin
       val = _xd.(j)
       nv_clone_recurse, val
       _xd.(j) = val
      end

     xd[i] = obj_new(obj_class(xd[i]))
     cor_rereference, xd[i], _xd
    end
  end

end
;=============================================================================



;=============================================================================
; nv_clone
;
;=============================================================================
function nv_clone, xd0, noevent=noevent
@core.include
 nv_notify, xd0, type = 1, noevent=noevent

 xd = xd0
 nv_clone_recurse, xd
 return, xd
end
;=============================================================================
