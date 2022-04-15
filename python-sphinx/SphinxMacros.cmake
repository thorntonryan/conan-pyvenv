if(__SPHINX_MACROS)
  return()
endif()
set(__SPHINX_MACROS 1)

include(CMakeParseArguments)

option(SPHINX_HTML "Build html help with Sphinx" OFF)
option(SPHINX_QTHELP "Build Qt help with Sphinx" OFF)

find_package(python-sphinx)


# user settings for output formats, defaulting to on if you have the appropriate tools
set(SPHINX_HTML "${SPHINX_HTML}" CACHE BOOL "Build html help with Sphinx")

if(NOT DEFINED SPHINX_QTHELP)
	find_package(Qt5 COMPONENTS Help QUIET)
	if(TARGET Qt5::qhelpgenerator)
		set(SPHINX_QTHELP ON)
	endif()
endif()
set(SPHINX_QTHELP "${SPHINX_QTHELP}" CACHE BOOL "Build Qt help with Sphinx")

# and start setting up build targets
if(NOT TARGET sphinx)
	add_custom_target(sphinx)
	set_target_properties(sphinx PROPERTIES FOLDER sphinx)
endif()

function(ADD_SPHINX Target)
	CMAKE_PARSE_ARGUMENTS(_args "" "SOURCEDIR;OUTPUTDIR;CONFIG_PATH" "CONFIG_SETTINGS" ${ARGN})

	if(NOT _args_SOURCEDIR)
		set(_args_SOURCEDIR ${CMAKE_CURRENT_SOURCE_DIR})
	elseif(NOT IS_ABSOLUTE "${_args_SOURCEDIR}")
		SET(_args_SOURCEDIR "${CMAKE_CURRENT_SOURCE_DIR}/${_args_SOURCEDIR}")
	endif()

	if(NOT _args_OUTPUTDIR)
		set(_args_OUTPUTDIR ${CMAKE_CURRENT_BINARY_DIR}/sphinx)
	elseif(NOT IS_ABSOLUTE "${_args_OUTPUTDIR}")
		SET(_args_OUTPUTDIR "${CMAKE_CURRENT_BINARY_DIR}/${_args_OUTPUTDIR}")
	endif()	

	if(_args_CONFIG_PATH)
		if(NOT IS_ABSOLUTE "${_args_CONFIG_PATH}")
			SET(_args_CONFIG_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${_args_CONFIG_PATH}")		
		endif()
		set(_args_CONFIG_PATH -c ${_args_CONFIG_PATH}})
	endif()	
	
	set(config_settings_override)
	set(_qthelp_basename)
	foreach(setting ${_args_CONFIG_SETTINGS})
		list(APPEND config_settings_override -D ${setting})

		if(NOT _qthelp_basename AND ${setting} MATCHES "^project=(.*)$")
			set(_qthelp_basename ${CMAKE_MATCH_1})
		elseif(${setting} MATCHES "^qthelp_basename=(.*)")
			set(_qthelp_basename ${CMAKE_MATCH_1})
		endif()
	endforeach()

	if(NOT _qthelp_basename)
		set(_qthelp_basename ${PROJECT_NAME})
		list(APPEND config_settings_override -D qthelp_basename=${PROJECT_NAME})
		message(STATUS "SphinxMacros: Cannot infer qthelp_basename. Using `qthelp_basename=${PROJECT_NAME}` as default value.")
	endif()

	set(sphinx_doc_formats)
	set(last_format_symbol)
	if(SPHINX_HTML)
		set(format_output_symbol ${_args_OUTPUTDIR}/html.stamp)
		set_property(SOURCE ${format_output_symbol} PROPERTY SYMBOLIC 1)
		add_custom_command(
			OUTPUT ${format_output_symbol}
			COMMAND python3::sphinx-build # ${python3::sphinx-build}
			${_args_CONFIG_PATH}
			-d ${_args_OUTPUTDIR}/doctrees
			-b html
			${config_settings_override}
			${_args_SOURCEDIR}
			${_args_OUTPUTDIR}/html
			COMMENT "sphinx-build html"
			DEPENDS ${last_format_symbol} # serialize different formats so they can safely share the doctrees
			VERBATIM
			)
		set(last_format_symbol ${format_output_symbol})
		file(GLOB_RECURSE SPHINX_SOURCE_FILES
			CONFIGURE_DEPENDS
			"${_args_SOURCEDIR}/*.rst"
		)
		add_custom_target(${Target}.html DEPENDS ${format_output_symbol} SOURCES ${SPHINX_SOURCE_FILES})
		set_target_properties(${Target}.html PROPERTIES FOLDER sphinx)
		add_dependencies(sphinx ${Target}.html)
	endif()

	if(SPHINX_QTHELP)
		if(NOT TARGET Qt5::qhelpgenerator)
			find_package(Qt5 COMPONENTS Help REQUIRED)
		endif()
		set(format_output_symbol ${_args_OUTPUTDIR}/qthelp.stamp)
		set_property(SOURCE ${format_output_symbol} PROPERTY SYMBOLIC 1)
		add_custom_command(
			OUTPUT ${format_output_symbol}
			COMMAND python3::sphinx-build # ${python3::sphinx-build}
			${_args_CONFIG_PATH}
			-d ${_args_OUTPUTDIR}/doctrees
			-b qthelp
			${config_settings_override}
			${_args_SOURCEDIR}
			${_args_OUTPUTDIR}/qthelp
			COMMENT "sphinx-build qthelp"
			DEPENDS ${last_format_symbol} # serialize different formats so they can safely share the doctrees
			VERBATIM
			)
		set(last_format_symbol ${format_output_symbol})

		set(QHC_FILE ${_args_OUTPUTDIR}/qthelp/${_qthelp_basename}.qhc)
		set(QHCP_FILE ${_args_OUTPUTDIR}/qthelp/${_qthelp_basename}.qhcp)
		add_custom_command(
			OUTPUT ${QHC_FILE}
			COMMAND Qt5::qhelpgenerator ${QHCP_FILE}
			DEPENDS ${format_output_symbol}
		)
		file(GLOB_RECURSE SPHINX_SOURCE_FILES
			CONFIGURE_DEPENDS
			"${_args_SOURCEDIR}/*.rst"
		)
		add_custom_target(${Target}.qthelp DEPENDS ${QHC_FILE} SOURCES ${SPHINX_SOURCE_FILES})
		set_target_properties(${Target}.qthelp PROPERTIES FOLDER sphinx)
		add_dependencies(sphinx ${Target}.qthelp)
	endif()
endfunction()

