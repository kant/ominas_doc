;==============================================================================
; dir_rep
;
;==============================================================================
function dir_rep, filename, new_dir

 split_filename, filename, dir, name

 return, new_dir + name
end
;==============================================================================


