cmake_minimum_required(VERSION 3.9)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_MACOSX_RPATH OFF)
set(CMAKE_THREAD_PREFER_PTHREAD ON)
set(THREADS_PREFER_PTHREAD_FLAG ON)

add_subdirectory(lib)

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
