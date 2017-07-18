;=============================================================================
;+
; NAME:
;       image_interp_poly
;
;
; PURPOSE:
;       Extracts a region from an image using Lagrange polynomial
;	interpolation.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = image_interp(image, grid_x, grid_y)
;
;
; ARGUMENTS:
;  INPUT:
;        image:         An array of image point arrays.
;
;       grid_x:         The grid of x positions for interpolation
;
;       grid_y:         The grid of y positions for interpolation
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of interpolated points at the (grid_x, grid_y) points.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
function image_interp_poly, image, grid_x, grid_y, mask=mask, zmask=zmask, valid=valid

 s = size(image)

 ;----------------------------- 
 ; interpolation points
 ;----------------------------- 
 grid_x0 = long(grid_x)
 grid_x1 = grid_x0 + 1
 grid_y0 = long(grid_y)
 grid_y1 = grid_y0 + 1

 ;----------------------------- 
 ; interpolation subscripts
 ;----------------------------- 
 sub_x0y0 = grid_x0 + s[1]*grid_y0
 sub_x0y1 = grid_x0 + s[1]*grid_y1
 sub_x1y0 = grid_x1 + s[1]*grid_y0
 sub_x1y1 = grid_x1 + s[1]*grid_y1

 ;----------------
 ; interpolation
 ;---------------- 
 x_x0  = grid_x-grid_x0
 x_x1  = grid_x-grid_x1
 x0_x1 = grid_x0-grid_x1
 y_y0  = grid_y-grid_y0
 y_y1  = grid_y-grid_y1
 y0_y1 = grid_y0-grid_y1

 interp = ( x_x1*(y_y1*image[sub_x0y0]-y_y0*image[sub_x0y1]) + $
            x_x0*(y_y0*image[sub_x1y1]-y_y1*image[sub_x1y0]) ) / (x0_x1*y0_y1)

 return, interp
end
;===========================================================================
