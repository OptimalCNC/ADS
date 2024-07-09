
# FindTwinCAT.cmake
# Attempt to find TwinCAT
#
# This module defines
#   TwinCAT_FOUND - True if the system has TwinCAT
#   TwinCAT_INCLUDE_DIRS - The TwinCAT include directories
#   TwinCAT_LIBRARIES - The libraries needed to use TwinCAT
#   TwinCAT::TwinCAT - The imported target for TwinCAT

# You can provide a hint by setting TwinCAT_ROOT

set(TwinCAT_FOUND FALSE)


find_path(TwinCAT_INCLUDE_DIR
        NAMES "TcAdsAPI.h"
        HINTS ${TwinCAT_API_ROOT}/Include
)

find_path(TwinCAT_INCLUDE_DIR_DEF
        NAMES "TcAdsDef.h"
        HINTS ${TwinCAT_API_ROOT}/Include
)

if (CMAKE_SIZEOF_VOID_P GREATER 4)
  set(ARCH "x64")
endif ()

find_library(TwinCAT_LIBRARY
        NAMES "TcAdsDll.lib"
        HINTS "${TwinCAT_API_ROOT}/Lib/${ARCH}" "${TwinCAT_API_ROOT}/${ARCH}/lib"
)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(TwinCAT
        DEFAULT_MSG
        TwinCAT_INCLUDE_DIR
        TwinCAT_LIBRARY
)

if(TwinCAT_FOUND)
  set(TwinCAT_INCLUDE_DIRS ${TwinCAT_INCLUDE_DIR})
  set(TwinCAT_LIBRARIES ${TwinCAT_LIBRARY})
  if(NOT TARGET TwinCAT::TwinCAT)
    add_library(TwinCAT::TwinCAT SHARED IMPORTED)
    set_target_properties(
            TwinCAT::TwinCAT
            PROPERTIES
            IMPORTED_IMPLIB "${TwinCAT_LIBRARIES}"
            INTERFACE_INCLUDE_DIRECTORIES "${TwinCAT_INCLUDE_DIRS}"
    )
  endif()
endif()

mark_as_advanced(TwinCAT_INCLUDE_DIR TwinCAT_LIBRARY)

