if(DEVICE STREQUAL "STM32F407VG")

	set(DEVICE_FAMILY				"cortex-m4")
	set(DEVICE_FLASH_SIZE		"1M")
	set(DEVICE_RAM_SIZE			"192K")
	set(DEVICE_STACK_ADDRESS	"0x20010000")
	set(DEVICE_FLASH_ORIGIN		"0x08000000")
	set(DEVICE_RAM_ORIGIN		"0x20000000")

	if(DEVICE_FAMILY STREQUAL "cortex-m4")
		set(MCU_COMPILER_OPTIONS "${MCU_COMPILER_OPTIONS} -mcpu=cortex-m4 -march=armv7e-m")
	elseif(DEVICE_FAMILY STREQUAL "cortex-m3")
		set(MCU_COMPILER_OPTIONS "${MCU_COMPILER_OPTIONS} -mcpu=cortex-m3 -march=armv7-m -msoft-float")
	elseif(DEVICE_FAMILY STREQUAL "cortex-a9")
		set(MCU_COMPILER_OPTIONS "${MCU_COMPILER_OPTIONS} -mcpu=cortex-a9 -march=armv7-a -mthumb -mfloat-abi=hard -mfpu=neon")
	else()
		message(ERROR "Device family ${DEVICE_FAMILY} not recognized")
	endif()

	set(DEVICE_DEFINITION		"STM32F40_41xxx")
	set(DEVICE_HSE_DEFINITION	"HSE_VALUE=8000000u")

	set(CMSIS_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/cmsis")

	set(CMSIS_CORE_DIR "${CMSIS_ROOT_DIR}/include")
	set(CMSIS_SYSTEM_DIR "${CMSIS_ROOT_DIR}/src")

	set(CMSIS_CORE_HEADERS
		 ${CMSIS_CORE_DIR}/core_cm4.h
		 ${CMSIS_CORE_DIR}/core_cmFunc.h
		 ${CMSIS_CORE_DIR}/core_cmInstr.h
		 ${CMSIS_CORE_DIR}/core_cmSimd.h)

	set(CMSIS_SYSTEM_FILES
		 ${CMSIS_CORE_DIR}/stm32f4xx.h
		 ${CMSIS_SYSTEM_DIR}/startup_stm32f4xx.s
		 ${CMSIS_CORE_DIR}/system_stm32f4xx.h
		 ${CMSIS_SYSTEM_DIR}/system_stm32f4xx.c)

	set(CMSIS_FILES ${CMSIS_CORE_HEADERS} ${CMSIS_SYSTEM_FILES})

	set(LINKER_FILE "${CMSIS_ROOT_DIR}/stm32_flash.ld.in")

	configure_file(${LINKER_FILE} ${CMAKE_CURRENT_BINARY_DIR}/stm32_flash.ld)
	set(LINKER "-T${CMAKE_CURRENT_BINARY_DIR}/stm32_flash.ld")

else()
	message(FATAL_ERROR "To built need to setup \"DEVICE\" variable")
endif()