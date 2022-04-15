project(pyvenv_test LANGUAGES)

set(CONAN_DISABLE_CHECK_COMPILER 1) # not compiling anything here
include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

find_package(pyvenv REQUIRED HINTS ${CMAKE_BINARY_DIR})
enable_testing()
add_test(NAME python_version COMMAND pyvenv::python --version)
add_test(NAME pip_list COMMAND pyvenv::pip list)
