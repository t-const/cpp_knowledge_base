include(CTest)
include(GoogleTest)

# Function CreateLibrary
#
# This function creates a library from the files found in the given folders.
# It supports C++ files
# It also groups files by categories to be displayed in MSVS.
#
# Input: 
#     targetName : the target name, e.g ${PROJECT_NAME}_staticLib
#     shared : True to create a shared library, False to create a static one
#     headerFolder : root folder where to search for header files
#     sourceFolder : root folder where to search for source files
#                 
# Output:
#     None
#
function(CreateLibrary targetName shared headerFolder sourceFolder)
   message(STATUS "Creating the ${targetName} ${shared} library target")
   
   # Find header files
   set(allHeaderFiles "")
   file(GLOB_RECURSE headerFiles "${headerFolder}/*.h")
   list(APPEND allHeaderFiles ${headerFiles})
   file(GLOB_RECURSE headerFiles "${headerFolder}/*.hh")
   list(APPEND allHeaderFiles ${headerFiles})
   
   if(sourceFolder)
      # Find source files
      set(allSourceFiles "")
      file(GLOB_RECURSE sourceFiles "${sourceFolder}/*.cc" "${sourceFolder}/*.cpp")
      list(APPEND allSourceFiles ${sourceFiles})

      # Create the library
      if(shared)
         set(libType SHARED)
      else()
         set(libType STATIC)
      endif()
      add_library(${targetName} ${libType} 
                  ${allHeaderFiles}
                  ${allSourceFiles}
      )
                  
      # Set common folders for library compilation output
      set_target_properties(${targetName} PROPERTIES
         LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
         RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_OUTPUT_DIRECTORY}
         ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      )
      
      target_include_directories(${targetName} 
         PUBLIC ${headerFolder} ${CMAKE_CURRENT_BINARY_DIR}
         PRIVATE ${sourceFolder})
      
      source_group(TREE ${headerFolder} PREFIX "Header Files" FILES ${allHeaderFiles})
      source_group(TREE ${sourceFolder} PREFIX "Source Files" FILES ${allSourceFiles})
   else()
      # Create the library (header-only, hence the use of an INTERFACE)
      add_library(${targetName} INTERFACE)
      target_include_directories(${targetName} INTERFACE ${headerFolder})

      # MSVS does not display header-only projects so use a custom target instead
      add_custom_target(${targetName}_files SOURCES ${allHeaderFiles})

   endif()
   
endfunction()

# Function CreateExecutable
#
# This function creates an executable from the files found in the given folders.
# It also groups files by categories to be displayed in MSVS.
#
# Input: 
#     targetName : the target name, e.g ${PROJECT_NAME}
#     sourceFolder : root folder where to search for source files
#     headerFolder : root folder where to search for header files
#                 
# Output:
#     None
#
function(CreateExecutable targetName sourceFolder headerFolder)
   message(STATUS "Creating the ${targetName} executable target")
   
   # Find source files
   set(allSourceFiles "")
   file(GLOB_RECURSE sourceFiles "${sourceFolder}/*.cc" "${sourceFolder}/*.cpp")
   list(APPEND allSourceFiles ${sourceFiles})
   set(allHeaderFiles "")
   if(EXISTS "${headerFolder}")
    file(GLOB_RECURSE headerFiles "${headerFolder}/*.h" "${headerFolder}/*.hh")
    list(APPEND allHeaderFiles ${headerFiles})
   endif(EXISTS "${headerFolder}")
   
   # Create the executable target
   add_executable(
      ${targetName}
      ${allHeaderFiles}
      ${allSourceFiles}
   )

   # Find private header files
   target_include_directories(${targetName}
      PRIVATE ${sourceFolder} ${headerFolder}
   )
   
   # Prepare environment for dependencies lookup
   set(environment "PATH=${CONAN_BIN_DIRS};%PATH%")
   string(REPLACE ";" "\;" environment "${environment}")

   # Set common folders for library compilation output
   set_target_properties(${targetName} PROPERTIES
      LABELS ${targetName}
      LIBRARY_OUTPUT_DIRECTORY ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_OUTPUT_DIRECTORY}
      ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      WORKING_DIRECTORY $<TARGET_FILE_DIR:${targetName}>
      VS_DEBUGGER_WORKING_DIRECTORY $<TARGET_FILE_DIR:${targetName}>
      VS_DEBUGGER_ENVIRONMENT "${environment}"
   )
         
   # Organize files by groups
   source_group(TREE ${sourceFolder} PREFIX "Source Files" FILES ${allSourceFiles})
   if(allHeaderFiles)
      source_group(TREE ${headerFolder} PREFIX "Header Files" FILES ${allHeaderFiles})
   endif()
   
endfunction()

# Function CreateTest
#
# This function creates an executable from the files found in the given folders.
#
# Input: 
#     targetName : the target name, e.g ${PROJECT_NAME}_test
#     sourceFolder : root folder where to search for source files
#                 
# Output:
#     None
#
function(CreateTest targetName sourceFolder)
   set(testName ${targetName})
   CreateExecutable( 
      ${testName}
      "${sourceFolder}"
      "${sourceFolder}"
   )

   # Add Google / CTest tests
   # SKIP_DEPENDENCY avoid CMake to be relaunched automatically when a c++ source file is modified
   gtest_add_tests(TARGET ${testName} TEST_LIST testCases SKIP_DEPENDENCY)

endfunction()
