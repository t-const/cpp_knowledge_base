cmake_minimum_required(VERSION 3.10)
get_filename_component(ProjectId ${CMAKE_CURRENT_SOURCE_DIR} NAME)
string(REPLACE " " "_" ProjectId ${ProjectId})
project(${ProjectId} VERSION 1.0 LANGUAGES CXX)
SET(COMPONENT_NAME ${PROJECT_NAME})

MESSAGE(STATUS "Creating project ${PROJECT_NAME} using component name ${COMPONENT_NAME}")

include(cmake/BuildSetup.cmake)
include(cmake/TargetFunctions.cmake)

# Permit better projects organization in generated solution file.
# Will produce "CMakePredefinedTargets" and "CTestDashboardTargets" folder in generated solution
SET_PROPERTY(GLOBAL PROPERTY USE_FOLDERS ON)

# Setup compiler options and build folders
SetupBuildSettings()

# Create the main application library
set(libraryName ${PROJECT_NAME}-lib)

CreateLibrary(
   ${libraryName}
   true
   "${CMAKE_CURRENT_SOURCE_DIR}/include/"
   "${CMAKE_CURRENT_SOURCE_DIR}/src/"
)

# Uncomment and setup for lib dependencies
# Manage project dependencies
# target_link_libraries(
#     ${libraryName}
#     PUBLIC
# )

# Create executable
set(app ${PROJECT_NAME})

CreateExecutable(
   ${app}
   "${CMAKE_CURRENT_SOURCE_DIR}/app/src/"
   "${CMAKE_CURRENT_SOURCE_DIR}/app/include/"
)

# Manage project dependencies
target_link_libraries(
    ${app}
    PRIVATE
        ${libraryName}
)

# Add the tests subdirectory
add_subdirectory(tests)