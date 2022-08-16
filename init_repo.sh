#!/bin/bash

shopt -s extglob

# "make clean" option
if [ "$1" = "clean" ]
then
	rm -rfv !("$0") > /dev/null 2>&1
	rm .gitignore
	exit 1
fi

# Variables
PROJ_NAME="testProj"
BUILD_SCRIPT="build.sh"
SOURCE_DIR="src"
INCLUDE_DIR="include"
TEST_DIR="tests"
REF_DIR="references"
SUBDIRS=($SOURCE_DIR $INCLUDE_DIR $TEST_DIR $REF_DIR)
CMAKEFILE="CMakeLists.txt"
PLACEHOLDER_FILES=("$SOURCE_DIR/$PROJ_NAME.c" "$SOURCE_DIR/file1.c" "$SOURCE_DIR/file2.c" "$INCLUDE_DIR/file1.h" "$INCLUDE_DIR/file2.h")

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
echo "project($PROJ_NAME LANGUAGES C)" >> $CMAKEFILE
echo >> $CMAKEFILE
echo "include_directories($SOURCE_DIR $INCLUDE_DIR $TEST_DIR)" >> $CMAKEFILE
echo >> $CMAKEFILE
echo "find_program(CLANG_TIDY_PROG clang-tidy)" >> $CMAKEFILE
echo "if(CLANG_TIDY_PROG)" >> $CMAKEFILE
echo -e "\t\tset(CMAKE_C_CLANG_TIDY" >> $CMAKEFILE
echo -e "\t\t\${CLANG_TIDY_PROG};" >> $CMAKEFILE
echo -e '\t\t"--checks=* -llvm-include-order, -cppcoreguidelines-*, -readability-magic-numbers, -clang-analyzer-security.insecureAPI.DeprecatedOrUnsafeBufferHandling, -hiccp-no-assembler")' >> $CMAKEFILE
echo -e '\t\tset(CMAKE_C_FLAGS "-g")' >> $CMAKEFILE
echo -e '\telse()' >> $CMAKEFILE
echo -e '\t\tset(CMAKE_C_COMPILER gcc)' >> $CMAKEFILE
echo -e '\t\tset(CMAKE_C_FLAGS "-g -Wall -pedantic")' >> $CMAKEFILE
echo -e '\tendif()' >> $CMAKEFILE


# Add structure for files
# Note: This will require by-hand editing of filenames depending on project
echo "add_executable($PROJ_NAME ${PLACEHOLDER_FILES[@]}" >> $CMAKEFILE
echo >> $CMAKEFILE

# Add Threading package
echo "set(THREADS_PREFER_PTHREAD_FLAG ON)" >> $CMAKEFILE
echo "find_package(Threads REQUIRED)" >> $CMAKEFILE
echo "target_link_libraries($PROJ_NAME PRIVATE Threads::Threads" >> $CMAKEFILE

# Add Address Sanitizer
echo >> $CMAKEFILE
echo "target_compile_options($PROJ_NAME PRIVATE -fsanitize=address)" >> $CMAKEFILE
echo "target_link_options($PROJ_NAME PRIVATE -fsanitize=address)" >> $CMAKEFILE

# Create .gitignore
touch ".gitignore"
echo "build/" >> ".gitignore"
echo "__pycache__/" >> ".gitignore"