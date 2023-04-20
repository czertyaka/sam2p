cmake_minimum_required(VERSION 3.21)
project(sam2p)
enable_language(CXX)
enable_testing()

if("${CMAKE_BINARY_DIR}" STREQUAL "${PROJECT_SOURCE_DIR}")
    message(FATAL_ERROR "Can not generate Makefile in project root directory")
endif()

set(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -W -Wall -Wextra -ansi -pedantic")
if ("${CMAKE_BUILD_TYPE}" STREQUAL "")
    set(CMAKE_BUILD_TYPE Release)
endif()
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
string(TOLOWER "${CMAKE_BUILD_TYPE}" BUILD_TYPE)
if ("${BUILD_TYPE}" STREQUAL release)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -s -Os -finline-functions")
elseif ("${BUILD_TYPE}" STREQUAL debug)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -g -O0 --coverage")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --coverage")
endif()

execute_process(
    COMMAND ${PROJECT_SOURCE_DIR}/mkdist.sh
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    RESULT_VARIABLE SAM2P_VERSION_RETCODE
    OUTPUT_VARIABLE SAM2P_VERSION
)
if (NOT ${SAM2P_VERSION_RETCODE} EQUAL 0)
    message(STATUS "SAM2P_VERSION_RETCODE=${SAM2P_VERSION_RETCODE}")
endif()
string(REGEX MATCH "[0-9]+\.[0-9]+\.[0-9]+" SAM2P_VERSION ${SAM2P_VERSION})
message(STATUS "SAM2P_VERSION=${SAM2P_VERSION}")

add_executable(print_sizeofs print_sizeofs.c)
add_custom_target(
    sizeofs
    DEPENDS sizeofs.h
)
add_custom_command(
    OUTPUT sizeofs.h
    COMMAND ${CMAKE_BINARY_DIR}/print_sizeofs > sizeofs.h
    DEPENDS print_sizeofs
)
add_custom_target(
    bts2
    DEPENDS bts2.tth
)
add_custom_command(
    OUTPUT bts2.tth
    COMMAND ${PROJECT_SOURCE_DIR}/gen_bts2_tth.sh
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)
add_executable(sam2p
    sam2p_main.cpp
    appliers.cpp
    crc32.c
    in_ps.cpp
    in_tga.cpp
    in_pnm.cpp
    in_bmp.cpp
    in_gif.cpp
    in_lbm.cpp
    in_xpm.cpp
    mapping.cpp
    in_pcx.cpp
    in_jai.cpp
    in_png.cpp
    in_jpeg.cpp
    in_tiff.cpp
    rule.cpp
    minips.cpp
    encoder.cpp
    pts_lzw.c
    pts_fax.c
    pts_defl.c
    error.cpp
    image.cpp
    gensio.cpp
    snprintf.c
    gensi.cpp
    out_gif.cpp
)
target_compile_options(sam2p
    PRIVATE
        -DHAVE_CONFIG2_H
        -DUSE_CONFIG_STDC_H
        -DSAM2P_VERSION=\"${SAM2P_VERSION}\"
        -fsigned-char
        -fno-rtti
        -fno-exceptions
        -nostdinc++
)
add_dependencies(sam2p sizeofs bts2)
target_include_directories(sam2p PRIVATE ${CMAKE_BINARY_DIR})

file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/test_dir)
function(sam2p_add_test)
    set(TEST ${ARGV0})
    set(INPUT_FILE ${ARGV1})
    set(OUTPUT_FILE ${ARGV2})
    add_test(
        NAME ${TEST}
        COMMAND ${CMAKE_BINARY_DIR}/sam2p ${INPUT_FILE} ${OUTPUT_FILE}
        WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test_dir
    )
endfunction()

sam2p_add_test(pts2_eps_test ${PROJECT_SOURCE_DIR}/examples/pts2.pbm try.eps)
sam2p_add_test(pts2_pdf_test ${PROJECT_SOURCE_DIR}/examples/pts2.pbm try.pdf)
sam2p_add_test(pts2_ps_test ${PROJECT_SOURCE_DIR}/examples/pts2.pbm try.ps)
sam2p_add_test(pts2_png_test ${PROJECT_SOURCE_DIR}/examples/pts2.pbm try.png)
sam2p_add_test(pts2_tiff_test ${PROJECT_SOURCE_DIR}/examples/pts2.pbm try.tiff)
sam2p_add_test(pts2_xpm_test ${PROJECT_SOURCE_DIR}/examples/pts2.pbm try.xpm)
sam2p_add_test(pts2_bmp_test ${PROJECT_SOURCE_DIR}/examples/pts2.pbm try.bmp)
sam2p_add_test(pts2_jpg_test ${PROJECT_SOURCE_DIR}/examples/pts2.pbm try.jpg)
sam2p_add_test(ptsbanner_eps_test ${PROJECT_SOURCE_DIR}/examples/ptsbanner.bmp try.eps)
sam2p_add_test(ptsbanner_pdf_test ${PROJECT_SOURCE_DIR}/examples/ptsbanner.bmp try.pdf)
sam2p_add_test(ptsbanner_ps_test ${PROJECT_SOURCE_DIR}/examples/ptsbanner.bmp try.ps)
sam2p_add_test(ptsbanner_png_test ${PROJECT_SOURCE_DIR}/examples/ptsbanner.bmp try.png)
sam2p_add_test(ptsbanner_xpm_test ${PROJECT_SOURCE_DIR}/examples/ptsbanner.bmp try.xpm)
sam2p_add_test(ptsbanner_bmp_test ${PROJECT_SOURCE_DIR}/examples/ptsbanner.bmp try.bmp)
sam2p_add_test(ptsbanner_jpg_test ${PROJECT_SOURCE_DIR}/examples/ptsbanner.bmp try.jpg)
sam2p_add_test(chessboard_ascii_eps_test ${PROJECT_SOURCE_DIR}/examples/chessboard_ascii.pbm try.eps)
sam2p_add_test(chessboard_ascii_pdf_test ${PROJECT_SOURCE_DIR}/examples/chessboard_ascii.pbm try.pdf)
sam2p_add_test(chessboard_ascii_ps_test ${PROJECT_SOURCE_DIR}/examples/chessboard_ascii.pbm try.ps)
sam2p_add_test(chessboard_ascii_png_test ${PROJECT_SOURCE_DIR}/examples/chessboard_ascii.pbm try.png)
sam2p_add_test(chessboard_ascii_tiff_test ${PROJECT_SOURCE_DIR}/examples/chessboard_ascii.pbm try.tiff)
sam2p_add_test(chessboard_ascii_xpm_test ${PROJECT_SOURCE_DIR}/examples/chessboard_ascii.pbm try.xpm)
sam2p_add_test(chessboard_ascii_bmp_test ${PROJECT_SOURCE_DIR}/examples/chessboard_ascii.pbm try.bmp)
sam2p_add_test(chessboard_ascii_jpg_test ${PROJECT_SOURCE_DIR}/examples/chessboard_ascii.pbm try.jpg)
