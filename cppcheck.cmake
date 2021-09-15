option(ENABLE_CPPCHECK "Enable static analysis with cppcheck" OFF)

if(${ENABLE_CPPCHECK})
	find_program(CPPCHECK cppcheck)

	if(NOT CPPCHECK)
		message(WARNING "cppcheck requested but executable not found")
	else()
		message(STATUS "cppcheck is enabled")

	set(CMAKE_CXX_CPPCHECK ${CPPCHECK}
									--suppress=missingInclude
									--enable=all
									--inconclusive
									--std=c++14
									--template="[{severity}][{id}] {message} {callstack} \(On {file}:{line}\)"
									--verbose
									--quiet)
	endif()
endif()
