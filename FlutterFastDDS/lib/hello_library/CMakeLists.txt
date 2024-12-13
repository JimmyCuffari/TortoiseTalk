cmake_minimum_required(VERSION 3.2 FATAL_ERROR)
project(hello_library VERSION 3.1.0 LANGUAGES C CXX)
add_library(hello_library SHARED hello.cpp hello.def)
add_executable(hello_test hello.cpp)

set_target_properties(hello_library PROPERTIES
    PUBLIC_HEADER hello.hpp
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "hello"
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)