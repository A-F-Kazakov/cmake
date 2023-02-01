option(ENABLE_CLANG_TIDY "Enable static analysis with clang-tidy" OFF)

if(ENABLE_CLANG_TIDY)
	find_program(CLANGTIDY clang-tidy)

	if(NOT CLANGTIDY)
		message(WARNING "clang-tidy requested but executable not found")
	else()
		message(STATUS "clang-tidy is enabled")

		set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
		set(CMAKE_CXX_CLANG_TIDY ${CLANGTIDY} -p${CMAKE_BINARY_DIR} -fix)
	endif()
endif()
