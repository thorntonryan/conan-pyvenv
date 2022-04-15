cmake_minimum_required(VERSION 3.12)

if(NOT TARGET python3::sphinx-build)
    add_executable(python3::sphinx-build IMPORTED)
    set_target_properties(python3::sphinx-build PROPERTIES
		IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/../bin/sphinx-build.exe"
	)
endif()

if(NOT TARGET python3::sphinx-apidoc)
    add_executable(python3::sphinx-apidoc IMPORTED)
    set_target_properties(python3::sphinx-apidoc PROPERTIES
		IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/../bin/sphinx-apidoc.exe"
	)
endif()

if(NOT TARGET python3::sphinx-autogen)
    add_executable(python3::sphinx-autogen IMPORTED)
    set_target_properties(python3::sphinx-autogen PROPERTIES
		IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/../bin/sphinx-autogen.exe"
	)
endif()

if(NOT TARGET python3::sphinx-quickstart)
    add_executable(python3::sphinx-quickstart IMPORTED)
    set_target_properties(python3::sphinx-quickstart PROPERTIES
		IMPORTED_LOCATION "${CMAKE_CURRENT_LIST_DIR}/../bin/sphinx-quickstart.exe"
	)
endif()
