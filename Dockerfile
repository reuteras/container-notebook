# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
# Modified by code@ongoing.today to be smaller.
FROM ghcr.io/astral-sh/uv:0.13.6@sha256:af22a52f5eafef3d78e551599d405c02df61919d18028f0cea8eda93bc9986d0 AS uv
FROM quay.io/jupyter/base-notebook:latest@sha256:e7e1d8727cdca641ae97c4aa96afafc21b85eb8908da1a0dafa7ddb00c8e1554

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
