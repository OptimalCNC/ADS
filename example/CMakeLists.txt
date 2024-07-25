set(SOURCES
  example.cpp
)

add_executable(example.bin ${SOURCES})

if (USE_TWINCAT_ROUTER)
  target_link_libraries(example.bin PUBLIC ads_twincat)
else()
  target_link_libraries(example.bin PUBLIC ads)
endif ()
