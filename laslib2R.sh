#!/bin/bash

# The LASlib and LASzip are open source librairies developped by Martin Isenburg to read and
# write las and laz file. I wrapped these libraries into R. However R does not like the way
# LASLib and LASzip are coded. R does not like rand and srand and exit(1) and some other stuff.
# The following regex enable to automatically correct some problems:

files=`grep -lr "fprintf" src/`

perl -pi -w -e 's/fprintf\(stderr,/REprintf(/g;' $files

files=`grep -lr "exit(1)" src/`

perl -pi -w -e 's/exit\(1\)/throw std::runtime_error\("Internal error"\)/g;' $files

# Some extra changes were done manually:

# fopen_compressed.cpp                #include <R.h> and #define STRICT_R_HEADERS
# mydefs.hpp                          #include <R.h> and #define STRICT_R_HEADERS
# lasreaderpipeon.cpp      l96-101    comment lines
# laswriter.cpp            l135-199   comment lines
# laswriter.cpp            l1130,1135 for gcc 8+ replace strncpy by memcpy
# lasattributer.hpp        l79-80     for gcc 8+ replace strncpy by memcpy - requires to get the char* length:
#     int len = 0 ; while(*(description+len) != '\0' && len < 32) len++;
#     memcpy(this->description, description, len);
# lasdefinition.hpp        l572,697   for gcc 8+ replace strncpy by memcpy in the same way than lasattributer.hpp
# laswriter_bin.cpp        l176       for gcc 8+ replace strncpy by memcpy
# bytestreamount_file.hpp  l134       return (true)
# lastransform.cpp         l401       R::runif(0, RAND_MAX); (need #include <Rcpp.h>)
# lasfilter.cpp            l1298      R::runif(0, RAND_MAX); (need #include <Rcpp.h>)
# lasutility.cpp                      #include <stdexcept>

# CRAN is happy now!

# In addition:
# - Tiago added the support of a new filter: see issue #32

