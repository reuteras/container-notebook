# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# Modified by code@ongoing.today to be smaller.
FROM ghcr.io/astral-sh/uv:0.13.1@sha256:4a1f3666816dafadd20ceb71eac9a7d56d7ef30279f7d64048519ab901ada336 AS uv
FROM quay.io/jupyter/base-notebook:latest@sha256:3fc2b8023bb7e3f11a09bd77aa07575c1ece16a0b9b64556757e34c52f667a1a

LABEL maintainer="Coding <code@ongoing.today>"

USER 0

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
        7zip \
        7zip-rar \
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
# NB_UID is numeric (set by the base image); hadolint cannot resolve it.
# hadolint ignore=DL3066
USER ${NB_UID}

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD ["sh", "-c", "curl -f http://localhost:8888/api || exit 1"]
