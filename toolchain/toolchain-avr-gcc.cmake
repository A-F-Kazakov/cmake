set(CMAKE_SYSTEM_NAME		Generic)
set(CMAKE_SYSTEM_VERSION	1)
set(CMAKE_SYSTEM_PROCESSOR	avr)

message(STATUS "Cross-compiling with the ${CMAKE_SYSTEM_PROCESSOR} toolchain")
message(STATUS "Toolchain prefix: ${CMAKE_INSTALL_PREFIX}")

if(NOT DEVICE)
	message(FATAL_ERROR "\"DEVICE\" type needed")
endif()

if(NOT FREQ)
	message(FATAL_ERROR "\"FREQ\" value needed")
endif()

set(CMAKE_EXECUTABLE_SUFFIX .elf)
set(CMAKE_CROSSCOMPILING ON)

set(CMAKE_C_COMPILER_WORKS      1)
set(CMAKE_CXX_COMPILER_WORKS    1)

find_program(AVR_GCC      ${CMAKE_SYSTEM_PROCESSOR}-gcc)
find_program(AVR_GPP      ${CMAKE_SYSTEM_PROCESSOR}-g++)
find_program(AVR_AS       ${CMAKE_SYSTEM_PROCESSOR}-as)
find_program(AVR_AR       ${CMAKE_SYSTEM_PROCESSOR}-ar)
find_program(AVR_OBJCOPY  ${CMAKE_SYSTEM_PROCESSOR}-objcopy)
find_program(AVR_OBJDUMP  ${CMAKE_SYSTEM_PROCESSOR}-objdump)
find_program(AVR_SIZE     ${CMAKE_SYSTEM_PROCESSOR}-size)

macro(toolchain_notfound progname)
  message("Error: program ${progname} not found")
  message(FATAL_ERROR "missing program prevents build")
  return()
endmacro(toolchain_notfound)

if(NOT AVR_GCC)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-gcc")
endif()
if(NOT AVR_GPP)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-g++")
endif()
if(NOT AVR_AS)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-as")
endif()
if(NOT AVR_AR)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-ar")
endif()
if(NOT AVR_OBJCOPY)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-objcopy")
endif()
if(NOT AVR_OBJDUMP)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-objdump")
endif()

if(CMAKE_VERSION VERSION_LESS "3.6.0")
	include(CMakeForceCompiler)
	cmake_force_c_compiler("${AVR_GCC}" GNU)
	cmake_force_cxx_compiler("${AVR_GPP}" GNU)
	cmake_force_as_compiler("${AVR_AS}" GNU)
else()
	set(CMAKE_C_COMPILER      "${AVR_GCC}")
	set(CMAKE_CXX_COMPILER    "${AVR_GPP}")
	set(CMAKE_ASM_COMPILER    "${AVR_AS}")
endif()

set(CMAKE_AR		${AVR_AR})
set(CMAKE_OBJCOPY	${AVR_OBJCOPY})
set(CMAKE_SIZE		${AVR_SIZE})

set(CMAKE_FIND_ROOT_PATH  ${CMAKE_INSTALL_PREFIX})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(BUILT_TEMPLATE "<FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET>")

set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <CMAKE_C_LINK_FLAGS> ${BUILT_TEMPLATE}")
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER> <CMAKE_CXX_LINK_FLAGS> ${BUILT_TEMPLATE}")

set(DEFAULT_DEFINITIONS "-Wl,-Map -Wl,${DEVICE}.map -mthumb -Wl,--gc-sections -mmcu=${DEVICE} -DF_CPU=${FREQ}UL")

SET(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} ${DEFAULT_DEFINITIONS}")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${DEFAULT_DEFINITIONS}")

macro(build_AVR EXECUTABLE)
	add_custom_command(TARGET ${EXECUTABLE}
		POST_BUILD COMMAND
			${CMAKE_OBJCOPY}
		ARGS
			-O ihex
			-R.eeprom
			${CMAKE_BINARY_DIR}/${EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX}
			${CMAKE_BINARY_DIR}/${EXECUTABLE}.hex
	)

	add_custom_command(TARGET ${EXECUTABLE}
		POST_BUILD COMMAND
			${AVR_OBJCOPY}
		ARGS
			-O ihex
			-j .eeprom
			--set-section-flags=.eeprom="alloc,load"
			--change-section-lma .eeprom=0
			--no-change-warnings
			${CMAKE_BINARY_DIR}/${EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX}
			${CMAKE_BINARY_DIR}/${EXECUTABLE}-eeprom.hex
	)

	add_custom_command(TARGET ${EXECUTABLE}
		POST_BUILD COMMAND
			${AVR_SIZE}
		ARGS
			${CMAKE_BINARY_DIR}/${EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX}
			-C;
			--mcu=${DEVICE}
			--format=avr
	)
endmacro()
