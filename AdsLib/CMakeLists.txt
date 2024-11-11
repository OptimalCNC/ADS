set(COMMON_SOURCES
  AdsDef.cpp
  AdsDevice.cpp
  AdsFile.cpp
  AdsLib.cpp
  ECatAccess.cpp
  Frame.cpp
  LicenseAccess.cpp
  Log.cpp
  RouterAccess.cpp
  RTimeAccess.cpp
  Sockets.cpp

  RegistryAccess.cpp
  SymbolAccess.cpp

  bhf/ParameterList.cpp
)

# the standalone library
list(
    APPEND SOURCES
    ${COMMON_SOURCES}
    standalone/AdsLib.cpp
    standalone/AmsConnection.cpp
    standalone/AmsNetId.cpp
    standalone/AmsPort.cpp
    standalone/AmsRouter.cpp
    standalone/NotificationDispatcher.cpp
)
if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
    add_library(ads STATIC ${SOURCES})
else()
    add_library(ads ${SOURCES})
endif()
add_library(ads::ads ALIAS ads)

target_include_directories(ads PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
$<INSTALL_INTERFACE:include/ads>)

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  target_link_libraries(ads PUBLIC wsock32)

endif()


if(WIN32 EQUAL 1)
    target_link_libraries(ads PUBLIC ws2_32)
endif()

target_link_libraries(ads PUBLIC Threads::Threads)
option(USE_TWINCAT_ROUTER "If ON, will also build a library `ads_twincat` using TwinCAT router." OFF)
if (USE_TWINCAT_ROUTER)
    list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake")
    find_package(TwinCAT REQUIRED)
    list(
        APPEND SOURCES_TWINCAT
        ${COMMON_SOURCES}
        TwinCAT/AdsLib.cpp
    )
    add_library(ads_twincat ${SOURCES_TWINCAT})
    target_compile_definitions(ads_twincat PUBLIC USE_TWINCAT_ROUTER)
    target_include_directories(ads_twincat PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include/ads>)
    target_link_libraries(ads_twincat PUBLIC TwinCAT::TwinCAT)
endif ()

