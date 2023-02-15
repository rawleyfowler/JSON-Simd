function(initialize_submodule DIRECTORY)
  if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${DIRECTORY}/.git)
    find_package(Git QUIET REQUIRED)
    execute_process(COMMAND ${GIT_EXECUTABLE} clone https://github.com/simdjson/simdjson
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                    RESULT_VARIABLE GIT_EXIT_CODE)
  endif()
endfunction(initialize_submodule)

initialize_submodule(simdjson)

add_subdirectory(simdjson EXCLUDE_FROM_ALL)
