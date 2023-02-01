set(CMAKE_SYSTEM_NAME		Generic)
set(CMAKE_SYSTEM_VERSION	1)
set(CMAKE_SYSTEM_PROCESSOR	arm-none-eabi)

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

find_program(ARM_NONE_EABI_GCC      ${CMAKE_SYSTEM_PROCESSOR}-gcc)
find_program(ARM_NONE_EABI_GPP      ${CMAKE_SYSTEM_PROCESSOR}-g++)
find_program(ARM_NONE_EABI_AS       ${CMAKE_SYSTEM_PROCESSOR}-as)
find_program(ARM_NONE_EABI_AR       ${CMAKE_SYSTEM_PROCESSOR}-ar)
find_program(ARM_NONE_EABI_OBJCOPY  ${CMAKE_SYSTEM_PROCESSOR}-objcopy)
find_program(ARM_NONE_EABI_OBJDUMP  ${CMAKE_SYSTEM_PROCESSOR}-objdump)
find_program(ARM_NONE_EABI_SIZE     ${CMAKE_SYSTEM_PROCESSOR}-size)

macro(toolchain_notfound progname)
  message("Error: program ${progname} not found")
  message(FATAL_ERROR "missing program prevents build")
  return()
endmacro(toolchain_notfound)

if(NOT ARM_NONE_EABI_GCC)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-gcc")
endif()
if(NOT ARM_NONE_EABI_GPP)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-g++")
endif()
if(NOT ARM_NONE_EABI_AS)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-as")
endif()
if(NOT ARM_NONE_EABI_AR)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-ar")
endif()
if(NOT ARM_NONE_EABI_OBJCOPY)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-objcopy")
endif()
if(NOT ARM_NONE_EABI_OBJDUMP)
  toolchain_notfound("${CMAKE_SYSTEM_PROCESSOR}-objdump")
endif()

if(CMAKE_VERSION VERSION_LESS "3.6.0")
	include(CMakeForceCompiler)
	cmake_force_c_compiler("${ARM_NONE_EABI_GCC}" GNU)
	cmake_force_cxx_compiler("${ARM_NONE_EABI_GPP}" GNU)
	cmake_force_as_compiler("${ARM_NONE_EABI_AS}" GNU)
else()
	set(CMAKE_C_COMPILER      "${ARM_NONE_EABI_GCC}")
	set(CMAKE_CXX_COMPILER    "${ARM_NONE_EABI_GPP}")
	set(CMAKE_ASM_COMPILER    "${ARM_NONE_EABI_AS}")
endif()

set(CMAKE_AR		${ARM_NONE_EABI_AR})
set(CMAKE_OBJCOPY	${ARM_NONE_EABI_OBJCOPY})
set(CMAKE_SIZE		${ARM_NONE_EABI_SIZE})

set(CMAKE_FIND_ROOT_PATH  ${CMAKE_INSTALL_PREFIX})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(BUILT_TEMPLATE "<FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET>")

set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER> <CMAKE_C_LINK_FLAGS> ${BUILT_TEMPLATE}")
set(CMAKE_CXX_LINK_EXECUTABLE "<CMAKE_CXX_COMPILER> <CMAKE_CXX_LINK_FLAGS> ${BUILT_TEMPLATE}")

set(DEFAULT_DEFINITIONS "-Wl,-Map -Wl,${DEVICE}.map -mthumb -Wl,--gc-sections -mcpu=${DEVICE}")

SET(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} ${DEFAULT_DEFINITIONS}")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${DEFAULT_DEFINITIONS}")

macro(build_ARM EXECUTABLE)
	add_custom_command(TARGET ${EXECUTABLE}
		POST_BUILD COMMAND
			${CMAKE_OBJCOPY}
		ARGS
			-Oihex
			${CMAKE_CURRENT_BINARY_DIR}/${EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX}
			${CMAKE_CURRENT_BINARY_DIR}/${EXECUTABLE}.hex
	)

	add_custom_command(TARGET ${EXECUTABLE}
		POST_BUILD COMMAND
			${CMAKE_OBJCOPY}
		ARGS
			-Obinary
			${CMAKE_CURRENT_BINARY_DIR}/${EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX}
			${CMAKE_CURRENT_BINARY_DIR}/${EXECUTABLE}.bin
	)

	add_custom_command(TARGET ${EXECUTABLE}
		POST_BUILD COMMAND
			${CMAKE_SIZE}
		ARGS
			${CMAKE_CURRENT_BINARY_DIR}/${EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX}
	)
endmacro()

find_program(STM32_STLINK_CLI_EXECUTABLE
				 "ST-LINK_CLI.exe"
				 PATHS
				 "C:/Program Files (x86)/STMicroelectronics/STM32 ST-LINK Utility/ST-LINK Utility"
				 "C:/Program Files/STMicroelectronics/STM32 ST-LINK Utility/ST-LINK Utility"
				 DOC "STM32 ST-Link Utility Command Line Interface (ST-LINK_CLI.exe)")

if(STM32_STLINK_CLI_EXECUTABLE)
	message(STATUS "Founded STLINK_CLI ${STM32_STLINK_CLI_EXECUTABLE}")
endif()

if(UPLOAD)
	if(DEFINED STM32_STLINK_CLI_EXECUTABLE)
		macro(UPLOAD_HEX EXECUTABLE)
			# -c SWD UR : SWD communication protocol, Under Reset
			# -Q : quiet mode, no progress bar
			# -V : Verifies that the programming operation was performed successfully.
			# -P : program file (.hex)
			# -Rst
			#	-Run
			set(STLINK_CMD ${STM32_STLINK_CLI_EXECUTABLE} -c SWD UR -V -P ${CMAKE_BINARY_DIR}/${PROJECT_NAME}.hex -Rst)
			#    add_custom_target(program-flash DEPENDS ${PROJECT_NAME}.hex COMMAND ${STLINK_CMD})
			add_custom_command(TARGET ${EXECUTABLE} POST_BUILD COMMAND DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${EXECUTABLE}.hex COMMAND ${STLINK_CMD})
		endmacro()
	endif()
endif()
