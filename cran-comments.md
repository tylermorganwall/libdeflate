## Fixes v1.24-2

This version fixes the issues with compiling on the CRAN 'blackswan' test environment, which resulted from failing to account for that build environment's use of aliases/symlinks to pass in the compiler cache tool 'ccache'. The prior version checked for 'ccache', but failed in the case where 'ccache' use was not explicit (as it called 'normalizePath()' after finding the compiler, which expanded the symlink):

$ ln -s $(which ccache) clang
$ ./clang -v
Apple clang version 15.0.0 (clang-1500.3.9.4)
$ Rscript -e 'normalizePath("./clang")'
[1] "/usr/local/Cellar/ccache/4.5.1/bin/ccache"

This version fixes that behavior.

(thanks to Ivan Krylov on r-package-devel for helping debug this issue)

## CHECK Results

This has been successfully checked on macOS --as-cran, all 30 rhub runners, win-builder (old/release/dev), and mac-builder (release/dev).

# Response to BDR comments:

## Comment 1

(i) It is not clear what the point of this is.  R already uses
libdeflate if available for memCompress/memDecompress and as a result
libdeflate 1.23 is available as a system library on all the CRAN check
platforms including Windows and macOS (which provide static libraries).
There is no acknowledgement of 'prior art'.

### Response 1

To clarify the purpose of the package, the DESCRIPTION 'Description' field has been updated to note the differences between this interface to libdeflate's DEFLATE compression as compared to base R's 'memCompress()' interface (which fixes the compression level at the default value of 6, out of a range of 0-12), state that 'libdeflate' will link the system library if found when building the package, and note that it also provides a 'CMake' target to ease linking of downstream packages that wish to statically link 'libdeflate' to compilation units in their package source that link bundled static libraries using 'CMake'.

Additionally, a \seealso{} field was added to the package documentation to state the difference between the existing implementation of DEFLATE compression provided by base R and this implementation.

## Comment 2

(ii) It does not comply with the CRAN policy as warranted on submission.

"(Using external C/C++/Fortran/other libraries.) Where a package wishes
to make use of a library not written solely for the package, the package
installation should first look to see if it is already installed and if
so is of a suitable version."

### Response 2

The configure script has been updated to link the system libdeflate if found (either using pkg-config, or via common installation locations) and it is of a suitable version. I have confirmed the configuration step has successfully found and linked the system version during installation on all three win-builder runners.

## Comment 3

(iii) Its installation script is inadequate: see the attached log from
the machine used for the valgrind checks.

---

* installing *source* package ‘libdeflate’ ...
** this is package ‘libdeflate’ version ‘1.23.1’
** package ‘libdeflate’ successfully unpacked and MD5 sums checked
** using staged installation
** preparing to configure package 'libdeflate' ...
loading initial cache file ../build/initial-cache.cmake
-- The C compiler identification is unknown
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - failed
-- Check for working C compiler: /usr/bin/ccache
-- Check for working C compiler: /usr/bin/ccache - broken
CMake Error at /usr/share/cmake/Modules/CMakeTestCCompiler.cmake:67 (message):
  The C compiler

    "/usr/bin/ccache"

  is not able to compile a simple test program.

### Response 3

The configure script has been updated to account for the potential use of ccache.
