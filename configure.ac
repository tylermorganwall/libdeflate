dnl Process this file with autoconf to produce a configure script.
AC_PREREQ([2.69])
AC_INIT([ROpenEXR], [0.1], [your-email@example.com])

dnl Make sure the src directory exists
AC_CONFIG_SRCDIR([src/Makevars.in])

dnl Find R
: ${R_HOME=`R RHOME`}
if test -z "${R_HOME}"; then
  AC_MSG_ERROR([could not determine R_HOME])
fi

dnl Find cmake
AC_PATH_PROG([CMAKE], [cmake])
if test -z "$CMAKE"; then
  dnl Check for a MacOS specific path
  AC_PATH_PROG([CMAKE], [cmake], [], [/Applications/CMake.app/Contents/bin])
fi

if test -z "$CMAKE"; then
  AC_MSG_ERROR([The 'cmake' program is required but not found.])
else
  AC_MSG_NOTICE([Using cmake: $CMAKE])
fi

dnl Get R compiler settings
CC_FULL=`"${R_HOME}/bin/R" CMD config CC`
CXX_FULL=`"${R_HOME}/bin/R" CMD config CXX`
CFLAGS=`"${R_HOME}/bin/R" CMD config CFLAGS`
CXXFLAGS=`"${R_HOME}/bin/R" CMD config CXXFLAGS`
CPPFLAGS=`"${R_HOME}/bin/R" CMD config CPPFLAGS`
LDFLAGS=`"${R_HOME}/bin/R" CMD config LDFLAGS`

dnl Detect the target architecture
AC_MSG_CHECKING([target architecture])
TARGET_ARCH=`${R_HOME}/bin/Rscript -e 'cat(Sys.info()[["machine"]])'`
AC_MSG_RESULT([${TARGET_ARCH}])

dnl For macOS, we need to use absolute paths and be very careful about flags
dnl Find the full path to the compiler
if echo "$CC_FULL" | grep -q "clang"; then
  CC=`which clang`
elif echo "$CC_FULL" | grep -q "gcc"; then
  CC=`which gcc`
else
  dnl Try to extract just the compiler name
  CC_NAME=`echo "$CC_FULL" | awk '{print $1}'`
  CC=`which $CC_NAME 2>/dev/null`
  if test -z "$CC"; then
    AC_MSG_ERROR([Could not find compiler: $CC_NAME])
  fi
fi

if echo "$CXX_FULL" | grep -q "clang++"; then
  CXX=`which clang++`
elif echo "$CXX_FULL" | grep -q "g++"; then
  CXX=`which g++`
else
  dnl Try to extract just the compiler name
  CXX_NAME=`echo "$CXX_FULL" | awk '{print $1}'`
  CXX=`which $CXX_NAME 2>/dev/null`
  if test -z "$CXX"; then
    AC_MSG_ERROR([Could not find compiler: $CXX_NAME])
  fi
fi

dnl Print debug info
AC_MSG_NOTICE([Using C compiler: $CC])
AC_MSG_NOTICE([Using C++ compiler: $CXX])
AC_MSG_NOTICE([Target architecture: ${TARGET_ARCH}])

dnl Create build directory for OpenEXR
mkdir -p src/libdeflate/build

dnl Get the absolute path to the source directory
PACKAGE_BASE_DIR=`cd "$(dirname "$0")" && pwd`
AC_SUBST([PACKAGE_BASE_DIR])

dnl Create a clean environment for CMake
dnl This is critical for macOS where architecture flags can conflict
export CMAKE_C_COMPILER="${CC}"
export CMAKE_CXX_COMPILER="${CXX}"
export CMAKE_C_FLAGS="-fPIC"
export CMAKE_CXX_FLAGS="-fPIC"

dnl Create a special CMake config file to force compiler settings
cat > src/libdeflate/build/initial-cache.cmake << EOF
set(CMAKE_C_COMPILER "${CC}" CACHE FILEPATH "C compiler")
set(CMAKE_CXX_COMPILER "${CXX}" CACHE FILEPATH "C++ compiler")
set(CMAKE_C_FLAGS "-fPIC" CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "-fPIC" CACHE STRING "C++ flags")
set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "Position independent code")
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type")
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libs")
set(CMAKE_OSX_ARCHITECTURES "${TARGET_ARCH}" CACHE STRING "Target architecture")
EOF

dnl Configure and build OpenEXR
mkdir -p ${PACKAGE_BASE_DIR}/inst
cd src/libdeflate/build
"${CMAKE}" ".." \
-C "../build/initial-cache.cmake" \
-DCMAKE_INSTALL_PREFIX="${PACKAGE_BASE_DIR}/inst/lib/${TARGET_ARCH}" \
-DLIBDEFLATE_BUILD_SHARED_LIB=OFF \
-DLIBDEFLATE_BUILD_GZIP=OFF \
-DCMAKE_BUILD_TYPE=Release \
-DCMAKE_POSITION_INDEPENDENT_CODE=ON
cd "${PACKAGE_BASE_DIR}"

dnl Substitute variables in Makevars
AC_SUBST([CMAKE])
AC_SUBST([TARGET_ARCH])

dnl Generate files
AC_CONFIG_FILES([src/Makevars])
if test -f "src/Makevars.win.in"; then
  CMAKE_WIN=`echo "${CMAKE}" | sed 's|/|\\\\|g'`
  AC_SUBST([CMAKE_WIN])
  AC_CONFIG_FILES([src/Makevars.win])
fi

AC_OUTPUT