# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# Modified by code@ongoing.today to be smaller.
FROM jupyter/base-notebook:latest

LABEL maintainer="Coding <code@ongoing.today>"

USER root

# Install all OS dependencies for fully functional notebook server
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
        build-essential \
        git \
        inkscape \
        libsm6 \
        libsndfile1 \
        libxext-dev \
        libxrender1 \
        lmodern \
        netcat \
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
