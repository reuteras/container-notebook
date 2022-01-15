# My Jupyter Notebook

[![Linter](https://github.com/reuteras/container-notebook/actions/workflows/linter.yml/badge.svg)](https://github.com/reuteras/container-notebook/actions/workflows/linter.yml)

Built from the [minimal-notebook](https://github.com/jupyter/docker-stacks/tree/master/minimal-notebook) by [Jupyter](https://jupyter.org/). This started out with a goal to build a smaller version of the notebook by removing the following packages which reduces the size with about 1 GB.

* emacs-nox
* jed
* texlive-fonts-extra

Since then I've started to add tools that I find useful to the container.

At the moment I've switched to build the container on GitHub and at the moment I build for amd64 and arm64.
