# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.28

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/qc/CMake

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/qc/CMake/build

# Include any dependencies generated for this target.
include project1/CMakeFiles/project1.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include project1/CMakeFiles/project1.dir/compiler_depend.make

# Include the progress variables for this target.
include project1/CMakeFiles/project1.dir/progress.make

# Include the compile flags for this target's objects.
include project1/CMakeFiles/project1.dir/flags.make

project1/CMakeFiles/project1.dir/src/project1.cc.o: project1/CMakeFiles/project1.dir/flags.make
project1/CMakeFiles/project1.dir/src/project1.cc.o: /home/qc/CMake/project1/src/project1.cc
project1/CMakeFiles/project1.dir/src/project1.cc.o: project1/CMakeFiles/project1.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --progress-dir=/home/qc/CMake/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object project1/CMakeFiles/project1.dir/src/project1.cc.o"
	cd /home/qc/CMake/build/project1 && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT project1/CMakeFiles/project1.dir/src/project1.cc.o -MF CMakeFiles/project1.dir/src/project1.cc.o.d -o CMakeFiles/project1.dir/src/project1.cc.o -c /home/qc/CMake/project1/src/project1.cc

project1/CMakeFiles/project1.dir/src/project1.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Preprocessing CXX source to CMakeFiles/project1.dir/src/project1.cc.i"
	cd /home/qc/CMake/build/project1 && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/qc/CMake/project1/src/project1.cc > CMakeFiles/project1.dir/src/project1.cc.i

project1/CMakeFiles/project1.dir/src/project1.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green "Compiling CXX source to assembly CMakeFiles/project1.dir/src/project1.cc.s"
	cd /home/qc/CMake/build/project1 && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/qc/CMake/project1/src/project1.cc -o CMakeFiles/project1.dir/src/project1.cc.s

# Object files for target project1
project1_OBJECTS = \
"CMakeFiles/project1.dir/src/project1.cc.o"

# External object files for target project1
project1_EXTERNAL_OBJECTS =

/home/qc/CMake/lib/libproject1.a: project1/CMakeFiles/project1.dir/src/project1.cc.o
/home/qc/CMake/lib/libproject1.a: project1/CMakeFiles/project1.dir/build.make
/home/qc/CMake/lib/libproject1.a: project1/CMakeFiles/project1.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --green --bold --progress-dir=/home/qc/CMake/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX static library /home/qc/CMake/lib/libproject1.a"
	cd /home/qc/CMake/build/project1 && $(CMAKE_COMMAND) -P CMakeFiles/project1.dir/cmake_clean_target.cmake
	cd /home/qc/CMake/build/project1 && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/project1.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
project1/CMakeFiles/project1.dir/build: /home/qc/CMake/lib/libproject1.a
.PHONY : project1/CMakeFiles/project1.dir/build

project1/CMakeFiles/project1.dir/clean:
	cd /home/qc/CMake/build/project1 && $(CMAKE_COMMAND) -P CMakeFiles/project1.dir/cmake_clean.cmake
.PHONY : project1/CMakeFiles/project1.dir/clean

project1/CMakeFiles/project1.dir/depend:
	cd /home/qc/CMake/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/qc/CMake /home/qc/CMake/project1 /home/qc/CMake/build /home/qc/CMake/build/project1 /home/qc/CMake/build/project1/CMakeFiles/project1.dir/DependInfo.cmake "--color=$(COLOR)"
.PHONY : project1/CMakeFiles/project1.dir/depend

