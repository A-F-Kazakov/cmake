CMAKE_MINIMUM_REQUIRED(VERSION 3.3)
SET(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR avr)

#=======================================================================================================================

if(NOT DEVICE)
	MESSAGE(FATAL_ERROR "Нужно указать устройство: \"DEVICE\"")
endif()

if(NOT FREQ)
	MESSAGE(FATAL_ERROR "Нужно указать частоту устройства: \"FREQ\"")
endif()

#=======================================================================================================================

SET(CMAKE_C_COMPILER avr-gcc)
SET(CMAKE_CXX_COMPILER avr-g++)

SET(AVR_OBJCOPY avr-objcopy)
SET(AVR_SIZE avr-size)

set(FILENAME ${PROJECT_NAME}_${DEVICE})

set(CMAKE_EXECUTABLE_SUFFIX .elf)

SET(ELF_FILE		.elf)
SET(HEX_FILE		.hex)
SET(MAP_FILE		.map)
SET(EEPROM_FILE	-eeprom.hex)

set(AVR_DEFINITIONS "-mmcu=${DEVICE} -DF_CPU=${FREQ}UL -Wl,--gc-sections")

SET(CMAKE_C_FLAGS  "${CMAKE_C_FLAGS} -std=gnu99 ${AVR_DEFINITIONS}")
SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${AVR_DEFINITIONS}")

set(AVR_BUILD_PATTERN "<CMAKE_C_COMPILER> <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET>")

set(CMAKE_C_LINK_EXECUTABLE ${AVR_BUILD_PATTERN})
set(CMAKE_CXX_LINK_EXECUTABLE ${AVR_BUILD_PATTERN})

#=======================================================================================================================

#if(NOT ${SOURCE_FILES})
#	MESSAGE(FATAL_ERROR "Не указаны исходные файлы")
#endif()

#=======================================================================================================================

macro(build_AVR EXECUTABLE)
add_custom_command(TARGET ${EXECUTABLE}
		POST_BUILD COMMAND
		${AVR_OBJCOPY} -O ihex -R.eeprom ${CMAKE_BINARY_DIR}/${EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX} ${CMAKE_BINARY_DIR}/${EXECUTABLE}.hex)
add_custom_command(TARGET ${EXECUTABLE}
		POST_BUILD COMMAND
		${AVR_OBJCOPY} -O ihex -j .eeprom --set-section-flags=.eeprom="alloc,load"  --change-section-lma .eeprom=0 --no-change-warnings ${CMAKE_BINARY_DIR}/${EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX} ${CMAKE_BINARY_DIR}/${EXECUTABLE}-eeprom.hex)
add_custom_command(TARGET ${EXECUTABLE}
		POST_BUILD COMMAND
		${AVR_SIZE} ${CMAKE_BINARY_DIR}/${EXECUTABLE}${CMAKE_EXECUTABLE_SUFFIX} -C; --mcu=${DEVICE} --format=avr)
endmacro()