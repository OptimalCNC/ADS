cmake_minimum_required(VERSION 3.13.0)

project(ads VERSION 0.0.20)

find_package(Threads)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)


if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  set(COMPILE_OPTIONS
    -pedantic
    -Wall
    -Wextra
  )
  add_definitions(-D_GNU_SOURCE)
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  # Compiler flags and definitions for Visual Studio come here
  add_compile_definitions(NOMINMAX)
  if (BUILD_SHARED_LIBS)
     message(FATAL_ERROR "Building shared library is not supported for MSVC")
  endif ()
endif()

add_definitions(-DCONFIG_DEFAULT_LOGLEVEL=1)

add_subdirectory(AdsLib)
add_subdirectory(AdsTool)
add_subdirectory(AdsLibTest)
add_subdirectory(example)


# Install library
include(GenerateExportHeader)

set_property(TARGET ads PROPERTY VERSION ${PROJECT_VERSION})
set_property(TARGET ads PROPERTY SOVERSION 3)

set(additional_export_targets "")
if (TARGET ads_twincat)
  set(additional_export_targets "ads_twincat")
  set_property(TARGET ads_twincat PROPERTY VERSION ${PROJECT_VERSION})
endif ()

# export library (either static or shared depending on BUILD_SHARED_LIBS)
install(TARGETS ads AdsTool ${additional_export_targets}
  EXPORT adsTargets
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include
  )

if(POLICY CMP0087)
  cmake_policy(SET CMP0087 NEW)
endif()

function(SDL_install_pdb TARGET DIRECTORY)
  get_target_property(type ${TARGET} TYPE)
  if(type MATCHES "^(SHARED_LIBRARY|EXECUTABLE)$")
    install(FILES $<TARGET_PDB_FILE:${TARGET}> DESTINATION "${DIRECTORY}" OPTIONAL)
  elseif(type STREQUAL "STATIC_LIBRARY")
    if(CMAKE_GENERATOR MATCHES "^Visual Studio.*")
      install(CODE "file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${DIRECTORY}\" TYPE FILE OPTIONAL FILES \"${CMAKE_CURRENT_BINARY_DIR}/\${CMAKE_INSTALL_CONFIG_NAME}/$<TARGET_FILE_BASE_NAME:${TARGET}>.pdb\")")
    else()
      install(CODE "file(INSTALL DESTINATION \"\${CMAKE_INSTALL_PREFIX}/${DIRECTORY}\" TYPE FILE OPTIONAL FILES \"${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${TARGET}.dir/$<TARGET_FILE_BASE_NAME:${TARGET}>.pdb\")")
    endif()
  endif()
endfunction()


if (MSVC AND CMAKE_BUILD_TYPE STREQUAL "Debug")
  SDL_install_pdb(ads "lib")
endif()

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/AdsLib/ DESTINATION include/ads/
  FILES_MATCHING PATTERN "*.hpp" PATTERN "*.h")


set(cmake_configfile_install lib/cmake/ads)
set(target_install_dest_name "${cmake_configfile_install}/adsTargets.cmake")

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/adsConfigVersion.cmake"
  VERSION ${ADSLIB_VERSION}
  COMPATIBILITY AnyNewerVersion
)

configure_package_config_file("${CMAKE_CURRENT_SOURCE_DIR}/cmake/Config.cmake.in"
                "${CMAKE_CURRENT_BINARY_DIR}/cmake/adsConfig.cmake"
                INSTALL_DESTINATION "${cmake_configfile_install}"
                PATH_VARS target_install_dest_name)

install(EXPORT adsTargets
    FILE adsTargets.cmake
    NAMESPACE ads::
    DESTINATION "${cmake_configfile_install}"
    EXPORT_LINK_INTERFACE_LIBRARIES)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/cmake/adsConfig.cmake"
      "${CMAKE_CURRENT_BINARY_DIR}/adsConfigVersion.cmake"
    DESTINATION "${cmake_configfile_install}")
if (USE_TWINCAT_ROUTER) 
  install(FILES cmake/FindTwinCAT.cmake DESTINATION "${cmake_configfile_install}")
endif()

include(cmake/Package.cmake)
# Configure Debian package if on Linux, you need to install dpkg-dev to build
# the package.
if(UNIX)
  configure_debian_package()
endif()
# Configure Windows package if on Windows, you need to install nsis to build the
# package.
if(WIN32)
  configure_windows_package()
endif()

