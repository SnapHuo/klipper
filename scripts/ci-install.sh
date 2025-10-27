#!/bin/bash
# Build setup script for continuous integration testing.
# See ci-build.sh for the actual test steps.

# Stop script early on any error; check variables; be verbose
set -eux

MAIN_DIR=${PWD}
BUILD_DIR=${PWD}/ci_build
CACHE_DIR=${PWD}/ci_cache
mkdir -p ${BUILD_DIR} ${CACHE_DIR}


######################################################################
# Install system dependencies
######################################################################

echo -e "\n\n=============== Install system dependencies\n\n"
PKGS="virtualenv libffi-dev build-essential"
PKGS="${PKGS} gcc-avr avr-libc"
PKGS="${PKGS} libnewlib-arm-none-eabi gcc-arm-none-eabi binutils-arm-none-eabi"

# 在新版本Ubuntu中，尝试安装python2-dev，如果失败则跳过
if apt-cache show python2-dev > /dev/null 2>&1; then
    PKGS="${PKGS} python2-dev"
else
    echo "Warning: python2-dev not available, continuing without it"
fi

sudo apt-get update
sudo apt-get install ${PKGS}


######################################################################
# Install pru gcc
######################################################################

echo -e "\n\n=============== Install embedded pru gcc\n\n"
PRU_ARCHIVE="pru-elf-2024.05.amd64.tar.xz"
PRU_URL="https://github.com/dinuxbg/gnupru/releases/download/2024.05/${PRU_ARCHIVE}"

if [ ! -f ${CACHE_DIR}/${PRU_ARCHIVE} ]; then
    wget "${PRU_URL}" -O "${CACHE_DIR}/${PRU_ARCHIVE}"
fi
cd ${BUILD_DIR}
tar xJf ${CACHE_DIR}/${PRU_ARCHIVE}


######################################################################
# Install or1k toolchain
######################################################################

echo -e "\n\n=============== Install or1k toolchain\n\n"
OR1K_ARCHIVE="or1k-elf-12.0.1-20220210-20220304.tar.xz"
OR1K_REL="or1k-12.0.1-20220210-20220304"
OR1K_URL="https://github.com/openrisc/or1k-gcc/releases/download/${OR1K_REL}/${OR1K_ARCHIVE}"
if [ ! -f ${CACHE_DIR}/${OR1K_ARCHIVE} ]; then
    wget "${OR1K_URL}" -O "${CACHE_DIR}/${OR1K_ARCHIVE}"
fi
cd ${BUILD_DIR}
tar xJf ${CACHE_DIR}/${OR1K_ARCHIVE}


######################################################################
# Create python3 virtualenv environment
######################################################################

echo -e "\n\n=============== Install python3 virtualenv\n\n"
cd ${MAIN_DIR}
virtualenv -p python3 ${BUILD_DIR}/python-env
${BUILD_DIR}/python-env/bin/pip install -r ${MAIN_DIR}/scripts/klippy-requirements.txt


######################################################################
# Create python2 virtualenv environment
######################################################################

echo -e "\n\n=============== Install python2 virtualenv\n\n"
cd ${MAIN_DIR}

# 尝试创建python2虚拟环境，如果失败则跳过
if command -v python2 > /dev/null 2>&1; then
    virtualenv -p python2 ${BUILD_DIR}/python2-env
    ${BUILD_DIR}/python2-env/bin/pip install -r ${MAIN_DIR}/scripts/klippy-requirements.txt
else
    echo "Warning: python2 not available, skipping python2 virtualenv creation"
fi