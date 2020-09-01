FROM alpine:3.11

# Install dependencies
RUN apk add bzip2 ca-certificates curl file gcc g++ git libressl libsodium-dev make openssh-client patch readline-dev tar tini libffi

# Install Python3
RUN apk --update add libffi-dev py3-pygments py3-cffi py3-cryptography py3-jinja2 py3-openssl py3-pexpect py3-tornado python3 python3-dev \
    && pip3 install --no-cache-dir --upgrade setuptools pip \
    && mkdir -p `python -m site --user-site`  \
    && pip3 install --no-cache-dir notebook==5.2.2 jupyter ipywidgets==6.0.1 jupyter_dashboards pypki2 ipydeps ordo jupyter_nbgallery

# Prepare Kernels
RUN pip3 install --no-cache-dir bash_kernel jupyter_c_kernel==1.0.0 \
    && python3 -m bash_kernel.install
  
COPY kernels /usr/share/jupyter/kernels/