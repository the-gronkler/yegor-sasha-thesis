FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install full TeX Live distribution
# This takes a while to build but ensures you never miss a package
# For me it took a little under an hour
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    texlive-full \
    biber \
    latexmk \
    make \
    git \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*
