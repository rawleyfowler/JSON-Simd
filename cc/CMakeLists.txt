cmake_minimum_required(VERSION 3.9)
project(simd-json VERSION 1.0.0 DESCRIPTION "Raku bindings for simdjson: https://github.com/simdjson/simdjson")
add_library(simd-json SHARED
  json-native.cc
  lib/simdjson/singleheader/simdjson.cpp)
set_target_properties(simd-json PROPERTIES VERSION ${PROJECT_VERSION})
set_target_properties(simd-json PROPERTIES PUBLIC_HEADER lib/simdjson/singleheader/simdjson.h)
set_target_properties(simd-json PROPERTIES SOVERSION 1)
target_include_directories(simd-json PRIVATE .)
install(TARGETS simd-json
	LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
	PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
