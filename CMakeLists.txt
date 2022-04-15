cmake_minimum_required(VERSION 3.9)
project(Example CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR})
list(APPEND CMAKE_PREFIX_PATH ${CMAKE_BINARY_DIR})

if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
  message(STATUS "Downloading conan.cmake from https://github.com/conan-io/cmake-conan")
  file(DOWNLOAD "https://raw.githubusercontent.com/conan-io/cmake-conan/0.18.1/conan.cmake"
                "${CMAKE_BINARY_DIR}/conan.cmake"
                TLS_VERIFY ON)
endif()

include(${CMAKE_BINARY_DIR}/conan.cmake)

conan_cmake_configure(REQUIRES python-sphinx/4.4.0
                      GENERATORS cmake)

conan_cmake_autodetect(settings)

conan_cmake_install(PATH_OR_REFERENCE .)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup(TARGETS)

option(SPHINX_HTML "Build html help with Sphinx" ON)

find_package(python-sphinx)

add_custom_command(
	OUTPUT
		${CMAKE_SOURCE_DIR}/doc/index.rst
		${CMAKE_SOURCE_DIR}/doc/conf.py
	COMMAND python3::sphinx-quickstart
		doc
		-p example
		-a author
		-l en
		-r 1.0
		--no-sep
		--no-batchfile
		--no-makefile
	WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
	COMMENT "Building sphinx-quickstart..."
)

add_custom_target(quickstart
	DEPENDS ${CMAKE_SOURCE_DIR}/doc/index.rst
)

include(SphinxMacros)
add_sphinx(documentation
	SOURCEDIR doc
	OUTPUTDIR doc
)
