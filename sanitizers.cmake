option(ENABLE_SANITIZER_ADDRESS "Compile with address sanitize" OFF)
option(ENABLE_SANITIZER_LEAK "Compile with leak sanitizer" OFF)
option(ENABLE_SANITIZER_UNDEFINED_BEHAVIOR "Compile with ub sanitizer" OFF)
option(ENABLE_SANITIZER_THREAD "Compile with thread sanitizer" OFF)
option(ENABLE_SANITIZER_MEMORY "Compile with memory sanitizer" OFF)

if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
	set(SANITIZERS "")

	if(ENABLE_SANITIZER_ADDRESS)
		list(APPEND SANITIZERS "address")
		message(STATUS "Enabled address sanitizer")
	endif()

	if(ENABLE_SANITIZER_LEAK)
		list(APPEND SANITIZERS "leak")
		message(STATUS "Enabled leak sanitizer")
	endif()

	if(ENABLE_SANITIZER_UNDEFINED_BEHAVIOR)
		list(APPEND SANITIZERS "undefined")
		message(STATUS "Enabled undefined sanitizer")
	endif()

	if(ENABLE_SANITIZER_THREAD)
		if("address" IN_LIST SANITIZERS OR "leak" IN_LIST SANITIZERS)
			message(WARNING "Thread sanitizer does not work with Address and Leak sanitizer enabled")
		else()
			list(APPEND SANITIZERS "thread")
		message(STATUS "Enabled thread sanitizer")
		endif()
	endif()

	if(ENABLE_SANITIZER_MEMORY AND CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
		message(
			WARNING
				"Memory sanitizer requires all the code (including libc++) to be MSan-instrumented otherwise it reports false positives"
		)

		if("address" IN_LIST SANITIZERS OR "thread" IN_LIST SANITIZERS OR "leak" IN_LIST SANITIZERS)
			message(WARNING "Memory sanitizer does not work with Address, Thread and Leak sanitizer enabled")
		else()
			list(APPEND SANITIZERS "memory")
		message(STATUS "Enabled memory sanitizer")
		endif()
	endif()
elseif(MSVC)
	if(ENABLE_SANITIZER_ADDRESS)
		list(APPEND SANITIZERS "address")
		message(STATUS "Enabled address sanitizer")
	endif()
	if(ENABLE_SANITIZER_LEAK OR ENABLE_SANITIZER_UNDEFINED_BEHAVIOR OR ENABLE_SANITIZER_THREAD OR ENABLE_SANITIZER_MEMORY)
		message(WARNING "MSVC only supports address sanitizer")
	endif()
endif()

list(JOIN SANITIZERS "," LIST_OF_SANITIZERS)

if(LIST_OF_SANITIZERS)
	if(NOT "${LIST_OF_SANITIZERS}" STREQUAL "")
		set(TARGET_NAME ${CMAKE_PROJECT_NAME}_sanitizers)
		add_library(${TARGET_NAME} INTERFACE)
		add_library(${CMAKE_PROJECT_NAME}::sanitizers ALIAS ${TARGET_NAME})
		if(NOT MSVC)
			target_compile_options(${TARGET_NAME} INTERFACE -fsanitize=${LIST_OF_SANITIZERS})
			target_link_options(${TARGET_NAME} INTERFACE -fsanitize=${LIST_OF_SANITIZERS})
		else()
			string(FIND "$ENV{VSINSTALLDIR}" "$ENV{PATH}" index_of_vs_install_dir)
			if("index_of_vs_install_dir" STREQUAL "-1")
				message(
					SEND_ERROR
						"Using MSVC sanitizers requires setting the MSVC environment before building the project."
						"Please manually open the MSVC command prompt and rebuild the project."
				)
			endif()
			target_compile_options(${TARGET_NAME} INTERFACE /fsanitize=${LIST_OF_SANITIZERS} /Zi /INCREMENTAL:NO)
			target_link_options(${TARGET_NAME} INTERFACE /INCREMENTAL:NO)
		endif()
	endif()

	unset(LIST_OF_SANITIZERS)
	unset(SANITIZERS)
endif()
