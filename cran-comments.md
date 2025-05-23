## CHECK PASSED

This has been checked on macOS --as-cran, all 30 rhub runners, win-builder, and mac-builder with no notes, warnings, or errors.

# Response to BDR comments:

## Comment 1

(i) It is not clear what the point of this is.  R already uses
libdeflate if available for memCompress/memDecompress and as a result
libdeflate 1.23 is available as a system library on all the CRAN check
platforms including Windows and macOS (which provide static libraries).
There is no acknowledgement of 'prior art'.

## Response 1

To clarify the purpose of the package, the DESCRIPTION 'Description' field has been updated to note the differences between this interface to libdeflate's DEFLATE compression as compared to base R's 'memCompress()' interface, state that 'libdeflate' will link the system library if found, and note that it also provides a 'CMake' target to ease linking of downstream packages that wish to link 'libdeflate' via 'CMake'. 

Additionally, a \seealso{} field was added to the R interface documentation to state the difference between the existing implementation of DEFLATE compression provided by base R and this implementation.

## Comment 2

(ii) It does not comply with the CRAN policy as warranted on submission.

"(Using external C/C++/Fortran/other libraries.) Where a package wishes
to make use of a library not written solely for the package, the package
installation should first look to see if it is already installed and if
so is of a suitable version."

## Response 2

The configure script has been updated to link the system libdeflate if found and it is of a suitable version.

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

## Response 3

The configure script has been updated to account for the potential use of ccache.