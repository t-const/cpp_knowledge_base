# Enable testing
enable_testing()

# Find GoogleTest package (installed in /usr/local by default)
find_package(GTest REQUIRED)

set(testTarget ${PROJECT_NAME}-test)

# Add the test executable
CreateTest(${testTarget} "${CMAKE_CURRENT_SOURCE_DIR}/unit-tests")

# Link the test executable with GoogleTest and pthread
target_link_libraries(${testTarget} GTest::gtest_main pthread)
