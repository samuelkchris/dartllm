cmake_minimum_required(VERSION 3.16)

add_executable(test_dartllm test_dartllm.cpp)

target_link_libraries(test_dartllm PRIVATE ${DARTLLM_TARGET})

target_include_directories(test_dartllm PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../src
)

add_test(NAME dartllm_tests COMMAND test_dartllm)
