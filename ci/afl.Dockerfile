FROM aflplusplus/aflplusplus

RUN apt update && apt install -y \
    libjpeg-turbo-progs \
    && rm -rf /var/lib/apt/lists/*
