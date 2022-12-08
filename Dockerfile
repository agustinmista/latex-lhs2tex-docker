FROM ubuntu:22.04 AS base

# ----------------------------------------
# Install system dependencies

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get -y install \
    sudo \
    autoconf \
    curl \
    libnuma-dev \
    zlib1g-dev \
    libgmp-dev \
    libgmp10 \
    git \
    wget \
    lsb-release \
    software-properties-common \
    gnupg2 \
    apt-transport-https \
    gcc \
    autoconf \
    automake \
    build-essential \
    texlive-full

# ----------------------------------------
# Install GHCup, GHC, Cabal

# Instructions taken from:
# https://stackoverflow.com/a/71513191

ARG GPG_KEY=7784930957807690A66EBDBE3786C5262ECB4A3F
RUN gpg --batch --keyserver keys.openpgp.org --recv-keys $GPG_KEY

RUN curl https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup > /usr/bin/ghcup && \
    chmod +x /usr/bin/ghcup && \
    ghcup config set gpg-setting GPGStrict

ARG GHC=9.0.2
ARG CABAL=latest

RUN ghcup -v install ghc --isolate /usr/local --force ${GHC} && \
    ghcup -v install cabal --isolate /usr/local/bin --force ${CABAL}

# ----------------------------------------
# Move into userland

ARG USER_NAME=docker
ARG UID=1000
ARG GID=1000

RUN groupadd -g $GID -o $USER_NAME
RUN useradd -m -u $UID -g $GID -G sudo -o -s /bin/bash -d /home/$USER_NAME $USER_NAME
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER $USER_NAME
WORKDIR /home/$USER_NAME/

ENV PATH /home/$USER_NAME/.cabal/bin:$PATH

# ----------------------------------------
# Install Lhs2TeX

RUN cabal update && \
    cabal install --global lhs2tex

# ----------------------------------------
# Change the working directory and the entry point to emacs with better color support

WORKDIR /home/$USER_NAME/workdir

ENTRYPOINT ["/bin/bash"]