# My Jupyter Notebook

Built from the [minimal-notebook](https://github.com/jupyter/docker-stacks/tree/master/minimal-notebook) by [Jupyter](https://jupyter.org/). This started out with a goal to build a smaller version of the notebook by removing the following packages which reduces the size with about 1 GB.

* emacs-nox
* jed
* texlive-fonts-extra

Since then I've started to add tools that I find useful to the container.

At the moment I've switched to build the container on GitHub and build it for amd64 and arm64.

## Usage

To run it on Windows I use the following function in my PowerShell profile:

```
# Function to start a Jupyter notebook
function notebook () {
    docker run --name notebook --rm -p 8888:8888 -v C:\Users\reuteras\Documents\Jupyter\work\:/home/jovyan/work -v C:\Users\reuteras\Documents\Jupyter\.jupyter:/home/jovyan/.jupyter reuteras/container-notebook
}
```
