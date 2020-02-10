# ignores <package>_FIND_VERSION_EXACT variable

if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FOUND)
	set(${CMAKE_FIND_PACKAGE_NAME}_PATH "" CACHE STRING "Custom ${CMAKE_FIND_PACKAGE_NAME} Library path")

	if("${${CMAKE_FIND_PACKAGE_NAME}_PATH}" STREQUAL "" AND LIB_PATH)
		set(${CMAKE_FIND_PACKAGE_NAME}_PATH ${LIB_PATH})
	endif()

	set(_${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH OFF)
	if(${CMAKE_FIND_PACKAGE_NAME}_PATH)
		set(_${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH ON)
	endif()

	set(${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH ${_${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH} CACHE BOOL "Disable search ${CMAKE_FIND_PACKAGE_NAME} Library in default path")
	unset(_${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH)

	set(${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH_CMD)
	if(${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH)
		set(${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH_CMD NO_DEFAULT_PATH)
	endif()

# If LIP_PATH variable exists, then will be no search in the default path

	if(${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH)
		set(ERROR_TEXT "${CMAKE_FIND_PACKAGE_NAME} library is not found in '${${CMAKE_FIND_PACKAGE_NAME}_PATH}'")
		if(${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION)
			set(${CMAKE_FIND_PACKAGE_NAME}_PATH "${${CMAKE_FIND_PACKAGE_NAME}_PATH}/${CMAKE_FIND_PACKAGE_NAME}-${${CMAKE_FIND_PACKAGE_NAME}_FIND_VERSION}")
			if(NOT EXISTS ${${CMAKE_FIND_PACKAGE_NAME}_PATH})
				 if(${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
					message(FATAL_ERROR ${ERROR_TEXT})
				 else()
					message(WARNING ${ERROR_TEXT})
				 endif()
			endif()
		else()
			file(GLOB _LIBS_FOUND "${${CMAKE_FIND_PACKAGE_NAME}_PATH}/${CMAKE_FIND_PACKAGE_NAME}-*")
			if(_LIBS_FOUND)
				list(LENGTH _LIBS_FOUND _LIBS_LENGTH)
				math(EXPR _INDEX "${_LIBS_LENGTH} - 1")
				list(GET _LIBS_FOUND ${_INDEX} _LIB)
				set(${CMAKE_FIND_PACKAGE_NAME}_PATH ${_LIB})
				unset(_LIBS_LENGTH)
				unset(_INDEX)
				unset(_LIB)
			else()
				if(${CMAKE_FIND_PACKAGE_NAME}_FIND_REQUIRED)
					message(FATAL_ERROR ${ERROR_TEXT})
				 else()
					message(WARNING ${ERROR_TEXT})
				endif()
			endif()
				unset(_LIBS_FOUND)
		endif()
	endif()

	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
		set(TARGET_ARCH x64)
	else()
		set(TARGET_ARCH x86)
	endif()

	if(NOT ${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS)
		set(${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS <component>)
	endif()

	set(<component>_HEADER "name")
	set(<component>_LIB "name")

	foreach(_COMPONENT ${${CMAKE_FIND_PACKAGE_NAME}_FIND_COMPONENTS})
		string(TOLOWER ${_COMPONENT} LOWERCASE_COMPONENT)
		find_path(${CMAKE_FIND_PACKAGE_NAME}_${_COMPONENT}_INCLUDE_DIR
						NAMES
							${${_COMPONENT}_HEADER}
						HINTS
							ENV ${CMAKE_FIND_PACKAGE_NAME}DIR
							${${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH_CMD}
						PATH_SUFFIXES
							include
						PATHS
							${${CMAKE_FIND_PACKAGE_NAME}_PATH}
					)

		if(${CMAKE_FIND_PACKAGE_NAME}_${_COMPONENT}_INCLUDE_DIR)
			list(APPEND _${CMAKE_FIND_PACKAGE_NAME}_INCLUDE_DIR ${${CMAKE_FIND_PACKAGE_NAME}_${_COMPONENT}_INCLUDE_DIR})
		endif()

		find_library(${CMAKE_FIND_PACKAGE_NAME}_${_COMPONENT}_LIBRARY
							NAMES
								${${_COMPONENT}_LIB}
							HINTS
								ENV ${CMAKE_FIND_PACKAGE_NAME}DIR
								${${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH_CMD}
							PATH_SUFFIXES
								lib
								${TARGET_ARCH}
								lib/${TARGET_ARCH}
							PATHS
								${${CMAKE_FIND_PACKAGE_NAME}_PATH}
						)

		if(${CMAKE_FIND_PACKAGE_NAME}_${_COMPONENT}_LIBRARY)
			list(APPEND _${CMAKE_FIND_PACKAGE_NAME}_LIBRARIES ${${CMAKE_FIND_PACKAGE_NAME}_${_COMPONENT}_LIBRARY})

			set(TARGET_NAME ${CMAKE_FIND_PACKAGE_NAME}::${_COMPONENT})

			if(NOT TARGET ${TARGET_NAME})
				add_library(${TARGET_NAME} UNKNOWN IMPORTED)
				set_target_properties(${TARGET_NAME} PROPERTIES IMPORTED_LOCATION "${${CMAKE_FIND_PACKAGE_NAME}_${_COMPONENT}_LIBRARY}" INTERFACE_INCLUDE_DIRECTORIES "${${CMAKE_FIND_PACKAGE_NAME}_${_COMPONENT}_INCLUDE_DIR}")
			endif()
		else()
			set(_${CMAKE_FIND_PACKAGE_NAME}_${_COMPONENT}_FOUND OFF)
		endif()
	endforeach()

	set(${CMAKE_FIND_PACKAGE_NAME}_INCLUDE_DIR ${_${CMAKE_FIND_PACKAGE_NAME}_INCLUDE_DIR} CACHE STRING "${CMAKE_FIND_PACKAGE_NAME} include directories")
	set(${CMAKE_FIND_PACKAGE_NAME}_LIBRARIES ${_${CMAKE_FIND_PACKAGE_NAME}_LIBRARIES} CACHE STRING "${CMAKE_FIND_PACKAGE_NAME} link libraries")

	if(${CMAKE_FIND_PACKAGE_NAME}_INCLUDE_DIR AND EXISTS "<FILE>")
	else()
		string(REGEX REPLACE ".*-([0-9]+).*" "\\1" ${CMAKE_FIND_PACKAGE_NAME}_VERSION_MAJOR "$${${CMAKE_FIND_PACKAGE_NAME}_PATH}")
		string(REGEX REPLACE ".*-[0-9]+\\.([0-9]+).*" "\\1" ${CMAKE_FIND_PACKAGE_NAME}_VERSION_MINOR "$${${CMAKE_FIND_PACKAGE_NAME}_PATH}")
		string(REGEX REPLACE ".*-[0-9]+.[0-9]+.([0-9]+).*" "\\1" ${CMAKE_FIND_PACKAGE_NAME}_VERSION_PATCH "$${${CMAKE_FIND_PACKAGE_NAME}_PATH}")
		set(${CMAKE_FIND_PACKAGE_NAME}_VERSION_STRING ${${CMAKE_FIND_PACKAGE_NAME}_VERSION_MAJOR}.${${CMAKE_FIND_PACKAGE_NAME}_VERSION_MINOR}.${${CMAKE_FIND_PACKAGE_NAME}_VERSION_PATCH})
		unset(${CMAKE_FIND_PACKAGE_NAME}_VERSION_MAJOR)
		unset(${CMAKE_FIND_PACKAGE_NAME}_VERSION_MINOR)
		unset(${CMAKE_FIND_PACKAGE_NAME}_VERSION_PATCH)
	endif()

	include(FindPackageHandleStandardArgs)

	find_package_handle_standard_args(${CMAKE_FIND_PACKAGE_NAME}
													FOUND_VAR ${CMAKE_FIND_PACKAGE_NAME}_FOUND
													REQUIRED_VARS
														${CMAKE_FIND_PACKAGE_NAME}_INCLUDE_DIR
														${CMAKE_FIND_PACKAGE_NAME}_LIBRARIES
													VERSION_VAR ${CMAKE_FIND_PACKAGE_NAME}_VERSION_STRING
												)

	mark_as_advanced(${CMAKE_FIND_PACKAGE_NAME}_PATH
							${CMAKE_FIND_PACKAGE_NAME}_NO_DEFAULT_PATH
							${CMAKE_FIND_PACKAGE_NAME}_INCLUDE_DIR
							${CMAKE_FIND_PACKAGE_NAME}_LIBRARIES
							)
endif()
