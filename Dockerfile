# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# Modified by code@ongoing.today to be smaller.
FROM quay.io/jupyter/base-notebook:latest@sha256:93a31bb25a8773b797a059647a9b7f7b5f2f7bad2d9315294e41e34db2762fdb

LABEL maintainer="Coding <code@ongoing.today>"

USER root

# Install all OS dependencies for fully functional notebook server
# hadolint ignore=DL3008
RUN apt-get update && \
    dpkg --configure -a && \
    apt-get install -yq --no-install-recommends --fix-broken \
        build-essential \
        git \
        inkscape \
        libsm6 \
        libsndfile1 \
        libxext-dev \
        libxrender1 \
        lmodern \
        netcat-openbsd \
        python3-dev \
        tzdata \
        unzip \
        vim-tiny \
        texlive-xetex \
        texlive-fonts-recommended \
        texlive-plain-generic \
        bzip2 \
        curl \
        datamash \
        file \
        jq \
        p7zip-full \
        p7zip-rar \
        pigz \
        tshark \
        yara && \
        python -m pip --no-cache-dir install -U pip && \
        python -m pip --no-cache-dir install -U jupyterlab jupyter_ai langchain-ollama && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc && \
    rm -rf /usr/local/share/man /var/cache/debconf/*-old

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8888/api || exit 1
