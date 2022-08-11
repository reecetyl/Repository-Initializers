#!/bin/bash

# Variables
PROJ_NAME="testProj"
BUILD_SCRIPT="build.sh"
SOURCE_DIR="src"
INCLUDE_DIR="include"
TEST_DIR="tests"
SUBDIRS=($SOURCE_DIR $INCLUDE_DIR $TEST_DIR)
CMAKEFILE="CMakeLists.txt"

# Create base README
echo $PROJ_NAME >> "README.md"

# Create subdirectories
for dir in ${SUBDIRS[@]}; do
	mkdir $dir
done

# Create build script
touch $BUILD_SCRIPT
echo "mkdir build" >> $BUILD_SCRIPT
echo "cd build" >> $BUILD_SCRIPT
echo "cmake .." >> $BUILD_SCRIPT
echo "make" >> $BUILD_SCRIPT

# Create CMakeLists
touch $CMAKEFILE
echo "cmake_minimum_required(VERSION 3.15)" >> $CMAKEFILE
echo >> $CMAKEFILE
echo "project($PROJ_NAME) LANGUAGES C" >> $CMAKEFILE
echo >> $CMAKEFILE
echo "include_directories($SOURCE_DIR $INCLUDE_DIR $TEST_DIR)" >> $CMAKEFILE
echo >> $CMAKEFILE
echo "if(CLANG_TIDY_PROG)" >> $CMAKEFILE
echo -e "\t\tset(CMAKE_C_CLANG_TIDY" >> $CMAKEFILE
echo -e "\t\t\${CLANG_TIDY_PROG};" >> $CMAKEFILE
echo -e '\t\t"--checks=* -llvm-include-order, -cppcoreguidelines-*, -readability-magic-numbers, -clang-analyzer-security.insecureAPI.DeprecatedOrUnsafeBufferHandling, -hiccp-no-assembler")' >> $CMAKEFILE
echo -e '\t\t"set(CMAKE_C_FLAGS "-g"' >> $CMAKEFILE
echo -e '\telse()' >> $CMAKEFILE
echo -e '\t\tset(CMAKE_C_COMPILER gcc)' >> $CMAKEFILE
echo -e '\t\tset(CMAKE_C_FLAGS "-g -Wall -pedantic")' >> $CMAKEFILE
echo -e '\tendif()' >> $CMAKEFILE

echo >> $CMAKEFILE
echo >> $CMAKEFILE
echo "target_compile_options($PROJ_NAME PRIVATE -fsanitize=address)" >> $CMAKEFILE
echo "target_link_options($PROJ_NAME PRIVATE -fsanitize=address)" >> $CMAKEFILE

# Create .gitignore
touch ".gitignore"
echo "build/" >> ".gitignore"
echo "__pycache__/" >> ".gitignore" 