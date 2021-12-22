message(STATUS "looking for castem library.")
option(enable-castem-pleiades "use a pleiades version of castem" OFF)

find_path(CASTEM_HEADER castem.h
    HINTS ${TFEL_INCLUDE_PATH})

function(check_castem_compatibility mat search_paths source)
  behaviour_query(behaviour_type
    ${mat} "${search_paths}" ${source} "--type")
  if(behaviour_type STREQUAL "1")
    # strain based behaviour, do nothing
  elseif(behaviour_type STREQUAL "2")
    # finite strain behaviour, do nothing
  elseif(behaviour_type STREQUAL "3")
    # cohesive zone model, do nothing
  else(behaviour_type STREQUAL "1")
    # unsupported behaviour type
    set(file_OK OFF PARENT_SCOPE)
  endif(behaviour_type STREQUAL "1")    
endfunction(check_castem_compatibility)

if(CASTEM_HEADER STREQUAL "CASTEM_HEADER-NOTFOUND")
  if(CASTEM_INSTALL_PATH)
    set(CASTEMHOME "${CASTEM_INSTALL_PATH}")
  else(CASTEM_INSTALL_PATH)
    set(CASTEMHOME $ENV{CASTEMHOME})
  endif(CASTEM_INSTALL_PATH)
  
  if(enable-castem-pleiades AND (NOT UNIX))
    message(FATAL "castem pleiades may only be used on linux")
  endif(enable-castem-pleiades AND (NOT UNIX))
  
  if(CASTEMHOME)
      find_path(CASTEM_INCLUDE_DIR castem.h
                HINTS ${CASTEMHOME}/include
  	      ${CASTEMHOME}/include/c)
      if(CASTEM_INCLUDE_DIR STREQUAL "CASTEM_INCLUDE_DIR-NOTFOUND")
      	message(FATAL_ERROR "castem.h not found")
      endif(CASTEM_INCLUDE_DIR STREQUAL "CASTEM_INCLUDE_DIR-NOTFOUND")
      message(STATUS "Cast3M include files path detected: [${CASTEM_INCLUDE_DIR}].")
      set(CASTEM_ROOT "${CASTEMHOME}")
      add_definitions("-DCASTEM_ROOT=\\\"\"${CASTEMHOME}\"\\\"")
      add_definitions("-DHAVE_CASTEM=1")
      if(enable-castem-pleiades)
        set(castem_supported_versions 10 12 14 15 16 17 18 19 20)
        foreach(cversion ${castem_supported_versions})
  	file(GLOB castem20${cversion}s "${CASTEMHOME}/bin/castem*${cversion}*_PLEIADES")
  	foreach(cexe ${castem20${cversion}s})
  	  if(castem_exe)
  	    if(NOT (${castem_exe} STREQUAL ${cexe}))
  	      message(FATAL "multiple castem executable found")
  	    endif(NOT (${castem_exe} STREQUAL ${cexe}))
  	  endif(castem_exe)
  	  set(castem_exe     ${cexe})
  	  set(castem_version ${cversion})
  	endforeach(cexe ${castem20${cversion}s})
        endforeach(cversion ${castem_supported_versions})
      else(enable-castem-pleiades)
        set(castem_supported_versions 14 15 16 17 18 19 20)
        foreach(cversion ${castem_supported_versions})
  	file(GLOB castem${cversion}s "${CASTEMHOME}/bin/castem${cversion}*")
  	foreach(cexe ${castem${cversion}s})
  	  if(castem_exe)
  	    if(NOT (${castem_exe} STREQUAL ${cexe}))
  	      message(FATAL "multiple castem executable found")
  	    endif(NOT (${castem_exe} STREQUAL ${cexe}))
  	  endif(castem_exe)
  	  set(castem_exe     ${cexe})
  	  set(castem_version ${cversion})
  	endforeach(cexe ${castem${cversion}s})
        endforeach(cversion ${castem_supported_versions})
      endif(enable-castem-pleiades)
      if(castem_exe)
        message(STATUS "found castem executable ${castem_exe}")
      else(castem_exe)
        message(FATAL_ERROR "found castem no suitable executable")
      endif(castem_exe)
      set(HAVE_CASTEM ON)
  else(CASTEMHOME)
    message(FATAL_ERROR "no CASTEMHOME defined")
  endif(CASTEMHOME)
endif(CASTEM_HEADER STREQUAL "CASTEM_HEADER-NOTFOUND")

function(getCastemBehaviourName name)
  set(lib "${name}Behaviours" PARENT_SCOPE)
endfunction(getCastemBehaviourName)
