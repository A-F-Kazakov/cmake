option(ENABLE_CLANG_TIDY "Enable static analysis with clang-tidy" OFF)
option(ENABLE_CLANG_TIDY_FIX_ERROR "Enable fixing mechanism" OFF)

if(ENABLE_CLANG_TIDY)
	find_program(CLANGTIDY clang-tidy)

	if(NOT CLANGTIDY)
		message(WARNING "clang-tidy requested but executable not found")
	else()
		message(STATUS "Enabled clang-tidy")

		if(ENABLE_CLANG_TIDY_FIX_ERRORS)
			set(FIX_ERRORS "--fix-errors")
		endif()

		if(CLANG_TIDY_FILTER_FILES)
			set(FILTER_FILES "--line-filter=\"${CLANG_TIDY_FILTER_FILES}\"")
		endif()

		if(CLANG_TIDY_WARNINGS_AS_ERRORS)
			set(WARNINGS_AS_ERRORS "--warnings-as-errors=\"${CLANG_TIDY_WARNINGS_AS_ERRORS}\"")
		endif()

		set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
		set(CMAKE_CXX_CLANG_TIDY ${CLANGTIDY} -p ${CMAKE_BINARY_DIR} -fix ${FIX_ERRORS} ${FILTER_FILES} ${WARNINGS_AS_ERRORS})
	endif()
endif()
