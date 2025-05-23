# Prepare your package for installation here.
# Use 'define()' to define configuration variables.
# Use 'configure_file()' to substitute configuration values.
is_windows = identical(.Platform$OS.type, "windows")
is_macos = identical(Sys.info()[['sysname']], "Darwin")

CC_RAW = r_cmd_config("CC")
CXX_RAW = r_cmd_config("CXX")

CC_ARGS = strsplit(CC_RAW, " ")[[1]]
CXX_ARGS = strsplit(CXX_RAW, " ")[[1]]

uses_ccache = FALSE
if (grepl("ccache", CC_ARGS[1])) {
  uses_ccache = TRUE
  CC = paste(CC_ARGS[-1], collapse = " ")
}

if (grepl("ccache", CXX_ARGS[1])) {
  uses_ccache = TRUE
  CXX = paste(CXX_ARGS[-1], collapse = " ")
}

CC_COMPILER = strsplit(CC, " ")[[1]][1]
CXX_COMPILER = strsplit(CXX, " ")[[1]][1]

CC_FULL = normalizePath(
  Sys.which(CC_COMPILER),
  winslash = "/"
)
CXX_FULL = normalizePath(
  Sys.which(CXX_COMPILER),
  winslash = "/"
)
TARGET_ARCH = Sys.info()[["machine"]]
PACKAGE_BASE_DIR = normalizePath(getwd(), winslash = "/")

syswhich_cmake = Sys.which("cmake")

if (syswhich_cmake != "") {
  CMAKE = normalizePath(syswhich_cmake, winslash = "/")
} else {
  if (is_macos) {
    cmake_found_in_app_folder = file.exists(
      "/Applications/CMake.app/Contents/bin/cmake"
    )
    if (cmake_found_in_app_folder) {
      CMAKE = normalizePath("/Applications/CMake.app/Contents/bin/cmake")
    } else {
      stop("CMake not found during configuration.")
    }
  } else {
    stop("CMake not found during configuration.")
  }
}

#Use pkg-config (if available) to find a system library
LIBDEFLATE_SYSTEM = ""

pkgconfig_path = Sys.which("pkg-config")

if (pkgconfig_path != "") {
  exists_args = c("--exists", "'libdeflate >= 1.24'", "--print-errors")
  include_args = c("--cflags", "libdeflate")
  lib_args = c("--static", "--libs", "libdeflate")

  libdeflate_exists = ifelse(
    length(system2(pkgconfig_path, exists_args, stdout = TRUE)) == 0,
    "TRUE",
    "FALSE"
  )
  libdeflate_include = system2(pkgconfig_path, include_args, stdout = TRUE)
  libdeflate_link = system2(pkgconfig_path, lib_args, stdout = TRUE)
} else {
  libdeflate_exists = "FALSE"
  libdeflate_include = ""
  libdeflate_link = ""
}

build_libdeflate = TRUE
if (libdeflate_exists == "TRUE") {
  libdeflate_dir = substr(strsplit(libdeflate_link, " ")[[1]][1], 3, 500)
  message(
    sprintf(
      "*** configure.R: Found installed version of libdeflate with correct version at '%s', will link in that version to the package.",
      libdeflate_dir
    )
  )
  build_libdeflate = FALSE
}

define(
  PACKAGE_BASE_DIR = PACKAGE_BASE_DIR,
  TARGET_ARCH = TARGET_ARCH,
  CMAKE = CMAKE,
  CC_FULL = CC_FULL,
  CXX_FULL = CXX_FULL,
  LIBDEFLATE_SYSTEM = libdeflate_exists,
  LIBDEFLATE_INCLUDE = libdeflate_include,
  LIBDEFLATE_LINK = libdeflate_link
)

# Everything below here is package specific

if (!dir.exists("src/libdeflate/build")) {
  dir.create("src/libdeflate/build")
}

file_cache = "src/libdeflate/build/initial-cache.cmake"
writeLines(
  sprintf(
    r"-{set(CMAKE_C_COMPILER "%s" CACHE FILEPATH "C compiler")
  set(CMAKE_CXX_COMPILER "%s" CACHE FILEPATH "C++ compiler")
  set(CMAKE_C_FLAGS "-fPIC -fvisibility=hidden" CACHE STRING "C flags")
  set(CMAKE_CXX_FLAGS "-fPIC -fvisibility=hidden -fvisibility-inlines-hidden" CACHE STRING "C++ flags")
  set(CMAKE_POSITION_INDEPENDENT_CODE ON CACHE BOOL "Position independent code")
  set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Build type")
  set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libs")
  set(CMAKE_OSX_ARCHITECTURES "%s" CACHE STRING "Target architecture")}-",
    CC_FULL,
    CXX_FULL,
    TARGET_ARCH
  ),
  file_cache
)

inst_dir = file.path(PACKAGE_BASE_DIR, "inst") # ${PACKAGE_BASE_DIR}/inst
dir.create(inst_dir, recursive = TRUE, showWarnings = FALSE)

include_dir = file.path(inst_dir, "include")
if (!dir.exists(include_dir)) {
  dir.create(include_dir)
}
lib_dir = file.path(inst_dir, "lib")
if (!dir.exists(lib_dir)) {
  dir.create(lib_dir)
}
lib_arch = file.path(lib_dir, TARGET_ARCH)

if (!dir.exists(lib_arch)) {
  dir.create(lib_arch)
}

build_dir = file.path(PACKAGE_BASE_DIR, "src/libdeflate/build") # already created earlier
src_dir = ".." # evaluated inside build/

cmake_cfg = c(
  src_dir,
  "-C",
  "../build/initial-cache.cmake",
  "-DCMAKE_INSTALL_PREFIX=\"../../../inst\"",
  paste0("-DCMAKE_INSTALL_LIBDIR=lib/", TARGET_ARCH),
  "-DCMAKE_INSTALL_INCLUDEDIR=include",
  "-DLIBDEFLATE_BUILD_GZIP=OFF",
  "-DLIBDEFLATE_BUILD_SHARED_LIB=OFF",
  "-DCMAKE_BUILD_TYPE=Release",
  "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
)

setwd(build_dir)

status = system2(CMAKE, cmake_cfg)
if (status != 0) stop("CMake configure step failed")

setwd(PACKAGE_BASE_DIR)

lf_ify = function(path) {
  if (!file.exists(path)) return(invisible())
  txt = readLines(path, warn = FALSE) # strips CR automatically
  writeLines(txt, path, sep = "\n", useBytes = TRUE)
}

if (!is_windows) {
  configure_file("src/Makevars.in")
} else {
  configure_file("src/Makevars.win.in")
}

lf_ify("src/Makevars")
lf_ify("src/Makevars.win")
