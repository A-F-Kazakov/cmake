option(ENABLE_CLANG_FORMAT "Enable syntax formatting" OFF)

if(${ENABLE_CLANG_FORMAT})
	find_program(CLANG_FORMAT clang-format)

	if(NOT CLANG_FORMAT)
		message(WARNING "clang-fromat requested but executable not found")
	else()
		message(STATUS "clang-foramt is enabled")

		file(GLOB_RECURSE ALL_SOURCE_FILES *.cpp *.hpp *.c *.h)

		add_custom_target(${PROJECT_NAME}_clang_format ALL COMMAND ${CLANG_FORMAT} -style=file -i ${ALL_SOURCE_FILES})
		set_target_properties(${PROJECT_NAME}_clang_format PROPERTIES EXCLUDE_FROM_ALL ON)
	 endif()
 endif()
