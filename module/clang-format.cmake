option(ENABLE_CLANG_FORMAT "Enable syntax formatting" ON)

if(${ENABLE_CLANG_FORMAT})
	find_program(CLANG_FORMAT clang-format)

	if(NOT CLANG_FORMAT)
		message(WARNING "Clang-fromat requested but executable not found")
	else()
		message(STATUS "Clang-foramt is enabled")
		file(GLOB_RECURSE ALL_SOURCE_FILES *.cpp *.h)
		add_custom_target(${PROJECT_NAME}-clang-format ALL COMMAND ${CLANG_FORMAT} -style=file -i ${ALL_SOURCE_FILES})
	endif()
endif()
