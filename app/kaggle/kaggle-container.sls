
gcr.io/kaggle-images/python:
    docker_image:
      - present
      - tag: latest

kpython(){ podman run -v $PWD:/tmp/working -w=/tmp/working --rm -it gcr.io/kaggle-images/python python "$@" }
ikpython(){ podman run -v $PWD:/tmp/working -w=/tmp/working --rm -it gcr.io/kaggle-images/python ipython }
kjupyter(){ podman run -v $PWD:/tmp/working -w=/tmp/working -p 8888:8888 --rm -it gcr.io/kaggle-images/python jupyter notebook --no-browser --ip="\*" --notebook-dir=/tmp/working }

pip install DALL-E; pip install auto-sklearn; pip install jupyter_contrib_nbextensions; pip install jupyter_nbextensions_configurator;

podman run -v $PWD:/tmp/working -w=/tmp/working -p 8888:8888 --rm -it gcr.io/kaggle-images/python \
  bash "jupyter contrib nbextension install --user; jupyter notebook --notebook-dir=/tmp/working --ip='0.0.0.0' --port=8888 --no-browser --allow-root"

podman run -v $PWD:/tmp/working -w=/tmp/working -p 8888:8888 \
  --rm -it -e JUPYTER_ENABLE_LAB=yes \
  localhost/mykaggle \
  jupyter-lab --ip='0.0.0.0' --port=8888 --no-browser --allow-root


pip install


jupyter-matplotlib
jupyter_bokeh
jupyter_micropython_kernel

ipywebrtc

black isort jupyterlab_code_formatter
jupyterlab_templates

jupyterlab-plotly
jupyterlab_widgets
jupyterlab-go-to-definition
jupyterlab-markup
Jupyterlab-toc
jupyterlab-spellchecker
jupyterlab-variableInspector
jupyterlab-tour

jupyterlab_dracula
Jupyter-Atom-Dark-Theme

jupyterlab/debugger
Neptune-notebooks
