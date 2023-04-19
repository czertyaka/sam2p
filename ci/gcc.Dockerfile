FROM rikorose/gcc-cmake:latest

RUN apt update && apt install -y \
    libjpeg-turbo-progs \
    lcov \
    && rm -rf /var/lib/apt/lists/*

