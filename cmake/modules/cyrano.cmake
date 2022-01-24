if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(CYRANO_CPPFLAGS "-DCYRANO_ARCH=64")
else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
  set(CYRANO_CPPFLAGS "-DCYRANO_ARCH=32")
endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )

function(check_cyrano_compatibility mat search_paths source)
  behaviour_query(modelling_hypotheses
    ${mat} "${search_paths}" ${source} "--supported-modelling-hypotheses")
  separate_arguments(modelling_hypotheses)
  list(FIND modelling_hypotheses "AxisymmetricalGeneralisedPlaneStrain"
    agpstrain)
  list(FIND modelling_hypotheses "AxisymmetricalGeneralisedPlaneStress"
    agpstress)
  if((agpstress EQUAL -1) AND (agpstrain EQUAL -1))
    set(msg "behaviour does not support any of the ")
    set(msg "${msg} 'AxisymmetricalGeneralisedPlaneStrain' or ")
    set(msg "${msg} 'AxisymmetricalGeneralisedPlaneStress modelling' hypothesis")
    set(compatibility_failure "${msg}" PARENT_SCOPE)
    set(file_OK OFF PARENT_SCOPE)
  else((agpstress EQUAL -1) AND (agpstrain EQUAL -1))
    behaviour_query(behaviour_type
      ${mat} "${search_paths}" ${source} "--type")
    if(NOT (behaviour_type STREQUAL "1"))
      set(compatibility_failure
          "only strain-based behaviours are supported" PARENT_SCOPE)
      set(file_OK OFF PARENT_SCOPE)
    else(NOT (behaviour_type STREQUAL "1"))
      behaviour_query(behaviour_has_strain_measure
        ${mat} "${search_paths}" ${source} "--is-strain-measure-defined")
      if(behaviour_has_strain_measure STREQUAL "true")
	    behaviour_query(behaviour_strain_measure
	      ${mat} "${search_paths}" ${source} "--strain-measure")
	if(behaviour_strain_measure STREQUAL "Linearised")
    elseif(behaviour_strain_measure STREQUAL "Hencky")
	else(behaviour_strain_measure STREQUAL "Linearised")
      set(compatibility_failure
          "unsupported strain measure '${behaviour_strain_measure}'" PARENT_SCOPE)
	  set(file_OK OFF PARENT_SCOPE)
	endif(behaviour_strain_measure STREQUAL "Linearised")
      endif(behaviour_has_strain_measure STREQUAL "true")
    endif(NOT (behaviour_type STREQUAL "1"))
  endif((agpstress EQUAL -1) AND (agpstrain EQUAL -1))
  if(file_OK)
    check_temperature_is_first_external_state_variable(${mat} "${search_paths}" ${source})
    if(NOT file_OK)
      set(file_OK OFF PARENT_SCOPE)
      set(compatibility_failure "${compatibility_failure}" PARENT_SCOPE)
    endif(NOT file_OK)
  endif(file_OK)
endfunction(check_cyrano_compatibility)
