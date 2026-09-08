# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# Modified by code@ongoing.today to be smaller.
FROM ghcr.io/astral-sh/uv:0.12.10@sha256:2bb3ebca0a796a155094a27773d290c4b074572e6107f171d88d086682fd2500 AS uv
FROM quay.io/jupyter/base-notebook:latest@sha256:eaa4faf647919e915f9cb90c19cade55b0518b0949cf543d59269dee471f4ecd

LABEL maintainer="Coding <code@ongoing.today>"

USER root

COPY --from=uv /uv /usr/local/bin/uv
COPY pyproject.toml uv.lock /tmp/build/

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
        # Versions are pinned in uv.lock (source of truth); unpinned installs let jupyter_ai's federated JS drift out of sync with jupyterlab core's shared singletons.
        uv --project /tmp/build export --frozen --no-hashes --no-emit-project -o /tmp/build/requirements.txt && \
        uv pip install --python /opt/conda/bin/python --no-deps -r /tmp/build/requirements.txt && \
        jupyter labextension disable "@jupyter-ai/chat-commands" && \
        rm -rf /tmp/build && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc && \
    rm -rf /usr/local/share/man /var/cache/debconf/*-old

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8888/api || exit 1
