FROM gcr.io/kaggle-images/python

ADD clean-layer.sh  /tmp/clean-layer.sh

RUN pip install jupyter_contrib_nbextensions && \
    pip install jupyter_nbextensions_configurator && \
    pip install python-language-server[all] && \
    pip install jupyterlab && \
    pip install jupyterlab-lsp && \
    pip install auto-sklearn && \
    /tmp/clean-layer.sh
