cmake_minimum_required(VERSION 2.8)
project(KBLAS C CXX)


# directly make an error if in-source build
if("${PROJECT_SOURCE_DIR}" STREQUAL "${PROJECT_BINARY_DIR}")
	message(FATAL_ERROR "In-source builds are not allowed.\n"
	"Please create a build directory first and execute cmake configuration from "
	"this directory. Example: mkdir build && cd build && cmake ..")
endif()


# Set the RPATH config
# --------------------
# use, i.e. don't skip the full RPATH for the build tree
set(CMAKE_SKIP_BUILD_RPATH  FALSE)
# when building, use the install RPATH already
# (automated test will need this)
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)
# the RPATH to be used when installing
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")


# KBLAS code
add_subdirectory(src)


# TESTS
option(KBLAS_TESTING "Generates testing binaries" OFF)
if( KBLAS_TESTING )
	## CMAKE MODULES :: MORSE
	## REQUIRED FOR TESTS TO LINK LIBRARIES
	if(EXISTS "${CMAKE_BINARY_DIR}/cmake_modules/morse/.svn/entries" )
		execute_process( COMMAND svn up ${CMAKE_BINARY_DIR}/cmake_modules/morse OUTPUT_QUIET )
	else()
		execute_process( COMMAND mkdir -p ${CMAKE_BINARY_DIR}/cmake_modules/morse
		                 COMMAND svn co https://scm.gforge.inria.fr/anonscm/svn/morse/trunk/morse_distrib/cmake_modules/morse ${CMAKE_BINARY_DIR}/cmake_modules/morse
		                 OUTPUT_QUIET )
	endif()


	## MORSE INITIALIZATION
	set( MORSE_DISTRIB_DIR "" CACHE PATH "Directory of MORSE distribution")
	if(MORSE_DISTRIB_DIR)
		list(APPEND CMAKE_MODULE_PATH ${MORSE_DISTRIB_DIR}/cmake_modules)
		list(APPEND CMAKE_MODULE_PATH "${MORSE_DISTRIB_DIR}/cmake_modules/morse")
		set(MORSE_CMAKE_MODULE_PATH ${MORSE_DISTRIB_DIR}/cmake_modules/morse )
	elseif(EXISTS "${CMAKE_BINARY_DIR}/cmake_modules/")
		list(APPEND CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR}/cmake_modules)
		list(APPEND CMAKE_MODULE_PATH "${CMAKE_BINARY_DIR}/cmake_modules/morse")
		set(MORSE_CMAKE_MODULE_PATH ${CMAKE_BINARY_DIR}/cmake_modules/morse )
	else()
		message(FATAL_ERROR "MORSE_DISTRIB_DIR is not set\n"
		                    "Please indicate where is located your MORSE distribution directory. "
		                    "This is necessary to find cmake_modules. \n"
		                    "If you are a MORSE developer, you normally have access to the svn repository of the MORSE_DISTRIB_DIR: "
		                    "svn checkout svn+ssh://yourlogin@scm.gforge.inria.fr/svnroot/morse/trunk/morse_distrib")
	endif()
	include(MorseInit)


	## BLAS
	find_package(BLASEXT)
	if(BLAS_FOUND)
		if (BLAS_LIBRARY_DIRS)
			# the RPATH to be used when installing
			list(APPEND CMAKE_INSTALL_RPATH "${BLAS_LIBRARY_DIRS}")
		endif()
		if(BLAS_LINKER_FLAGS)
			list(APPEND CMAKE_EXE_LINKER_FLAGS "${BLAS_LINKER_FLAGS}")
		endif()
		
		# Use parallel blas for cblas
		option( USE_PARALLEL_BLAS "If possible, prefer parallel blas libraries" ON )
		if( USE_PARALLEL_BLAS AND NOT "${BLAS_PAR_LIBRARIES}" STREQUAL "" )
		        message( STATUS "Using Parallel Blas" )
		        set( BLAS_LIBRARIES "${BLAS_PAR_LIBRARIES}" )
		endif()
	else()
		message(FATAL_ERROR "BLAS library has not been found")
	endif()


	# CBLAS
	find_package(CBLAS COMPONENTS BLASEXT)
	if(BLAS_FOUND)
		if (BLAS_LIBRARY_DIRS)
			# the RPATH to be used when installing
			list(APPEND CMAKE_INSTALL_RPATH "${BLAS_LIBRARY_DIRS}")
		endif()
		if(BLAS_LINKER_FLAGS)
			#list(APPEND CMAKE_EXE_LINKER_FLAGS "${BLAS_LINKER_FLAGS}")
			set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${BLAS_LINKER_FLAGS}")
		endif()
	else()
		message(FATAL_ERROR "BLAS library has not been found")
	endif()
	if(CBLAS_FOUND)
		include_directories(${CBLAS_INCLUDE_DIRS})
		if(CBLAS_LIBRARY_DIRS)
			# the RPATH to be used when installing
			list(APPEND CMAKE_INSTALL_RPATH "${CBLAS_LIBRARY_DIRS}")
		endif()
	else()
		if(MORSE_VERBOSE_FIND_PACKAGE)
			if(CBLAS_STANDALONE OR NOT CBLAS_WORKS)
				if (NOT CBLAS_cblas.h_DIRS)
					Print_Find_Header_Status(cblas cblas.h)
				endif ()
				if (NOT CBLAS_cblas_LIBRARY)
					Print_Find_Library_Status(cblas libcblas)
				endif ()
			endif()
		else()
			message(WARNING "CBLAS library has not been found and MORSE_VERBOSE_FIND_PACKAGE is set to OFF"
			                "Try to activate MORSE_VERBOSE_FIND_PACKAGE option (-DMORSE_VERBOSE_FIND_PACKAGE=ON) to get some hints for the detection")
		endif()
		message(FATAL_ERROR "A CBLAS library is required but has not been found")
	endif()

#	## LAPACKE
#	find_package(LAPACKE COMPONENTS LAPACKEXT)
#	if(LAPACK_FOUND AND LAPACK_LIBRARY_DIRS)
#		# the RPATH to be used when installing
#		list(APPEND CMAKE_INSTALL_RPATH "${LAPACK_LIBRARY_DIRS}")
#	else()
#		message(FATAL_ERROR "A LAPACK library is required but has not been found")
#	endif()
#	if(LAPACKE_FOUND)
#		include_directories(${LAPACKE_INCLUDE_DIRS})
#		if(LAPACKE_LIBRARY_DIRS)
#			# the RPATH to be used when installing
#			list(APPEND CMAKE_INSTALL_RPATH "${LAPACKE_LIBRARY_DIRS}")
#		endif()
#		if(LAPACKE_LINKER_FLAGS)
#			set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${LAPACKE_LINKER_FLAGS}")
#		endif()
#	else()
#		if(MORSE_VERBOSE_FIND_PACKAGE)
#			if (LAPACKE_STANDALONE OR NOT LAPACKE_WORKS)
#				if (NOT LAPACKE_lapacke.h_DIRS)
#					Print_Find_Header_Status(lapacke lapacke.h)
#				endif ()
#				if (NOT LAPACKE_lapacke_LIBRARY)
#					Print_Find_Library_Status(lapacke liblapacke)
#				endif ()
#			endif()
#		else()
#			message(WARNING "LAPACKE library has not been found and MORSE_VERBOSE_FIND_PACKAGE is set to OFF"
#			                "Try to activate MORSE_VERBOSE_FIND_PACKAGE option (-DMORSE_VERBOSE_FIND_PACKAGE=ON) to get some hints for the detection")
#		endif()
#		message(FATAL_ERROR "A LAPACKE library is required but has not been found")
#	endif()

	# BUILD TESTS
	enable_testing() # enables ctest
	add_subdirectory(testing)
endif()


