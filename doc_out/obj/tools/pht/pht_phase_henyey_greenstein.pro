;=============================================================================
; pht_phase_henyey_greenstein
;
;=============================================================================
function pht_phase_henyey_greenstein, g, parm
 k = parm[0]
 return, (1d - k^2) / (1d + k^2 - 2d*k*g)^1.5d /4d /!dpi
end
;=============================================================================
