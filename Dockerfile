FROM jarzamendia/alpine-3.11

# Instalando dependencias básicas
RUN apk add --no-cache wget curl tar bash ca-certificates tini

# Instalando Java Oracle
ENV JAVA_HOME=/opt/jdk \
   PATH=${PATH}:${JAVA_HOME}/bin

RUN cd /opt; \
    wget https://github.com/frekele/oracle-java/releases/download/8u212-b10/jre-8u212-linux-x64.tar.gz; \
    tar -xzf jre-8u212-linux-x64.tar.gz -C /opt;  \
    ln -s /opt/jre1.8.0_212 /opt/jdk; \ 
    rm -rf /opt/jdk/*src.zip \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/jre/lib/plugin.jar \
           /opt/jdk/jre/lib/ext/jfxrt.jar \
           /opt/jdk/jre/bin/javaws \
           /opt/jdk/jre/lib/javaws.jar \
           /opt/jdk/jre/lib/desktop \
           /opt/jdk/jre/plugin \
           /opt/jdk/jre/lib/deploy* \
           /opt/jdk/jre/lib/*javafx* \
           /opt/jdk/jre/lib/*jfx* \
           /opt/jdk/jre/lib/amd64/libdecora_sse.so \
           /opt/jdk/jre/lib/amd64/libprism_*.so \
           /opt/jdk/jre/lib/amd64/libfxplugins.so \
           /opt/jdk/jre/lib/amd64/libglass.so \
           /opt/jdk/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jdk/jre/lib/amd64/libjavafx*.so \
           /opt/jdk/jre/lib/amd64/libjfx*.so \
           /opt/jre-8u212-linux-x64.tar.gz;

# Instalando Scala
ENV SCALA_VERSION=2.12.12 \
    SCALA_HOME=/opt/scala

RUN cd /tmp; \
    wget "https://downloads.typesafe.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz" && \
    tar xzf "scala-${SCALA_VERSION}.tgz" && \
    mkdir "${SCALA_HOME}" && \
    rm "/tmp/scala-${SCALA_VERSION}/bin/"*.bat && \
    mv "/tmp/scala-${SCALA_VERSION}/bin" "/tmp/scala-${SCALA_VERSION}/lib" "${SCALA_HOME}" && \
    ln -s "${SCALA_HOME}/bin/"* "/usr/bin/" && \
    rm -rf "/tmp/"*

# Instalando Conda
ENV CONDA_VERSION="py38_4.8.2"
ENV CONDA_DIR="/opt/conda"
ENV PATH="$CONDA_DIR/bin:$PATH"
ENV PYTHONDONTWRITEBYTECODE=1

RUN mkdir -p "$CONDA_DIR"; \
    wget "http://repo.continuum.io/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh" -O miniconda.sh && \
    bash miniconda.sh -f -b -p "$CONDA_DIR" && \
    conda update --all --yes && \
    conda config --set auto_update_conda False && \
    rm -f miniconda.sh && \
    conda clean --all --force-pkgs-dirs --yes && \
    find "$CONDA_DIR" -follow -type f \( -iname '*.a' -o -iname '*.pyc' -o -iname '*.js.map' \) -delete && \
    mkdir -p "$CONDA_DIR/locks" && \
    chmod 777 "$CONDA_DIR/locks"

# Install R
RUN apk add --no-cache R R-dev

# Install Spark
ENV ENABLE_INIT_DAEMON true
ENV INIT_DAEMON_BASE_URI http://identifier/init-daemon
ENV INIT_DAEMON_STEP spark_master_init
ENV SPARK_HOME="/opt/spark"
ENV SPARK_VERSION=3.0.1
ENV HADOOP_VERSION=3.2
WORKDIR "$SPARK_HOME"
RUN curl -Ls "http://ftp.unicamp.br/pub/apache/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop$HADOOP_VERSION.tgz" | tar zxvf - -C "$SPARK_HOME" --strip=1

# Install Conda packages
RUN conda install -c conda-forge pyarrow && \
    conda install -c conda-forge pyspark && \
    conda install -c conda-forge findspark && \
    conda install -c conda-forge jupyterlab && \
    conda install -c conda-forge spylon-kernel && \
    conda install -c conda-forge r-irkernel  && \
    python -m spylon_kernel install

COPY scala.json /usr/local/share/jupyter/kernels/spylon-kernel/kernel.json

ENTRYPOINT [ "tini" ]

WORKDIR /notebooks

CMD ["jupyter","lab","--no-browser", "--ip=*","--port=8888","--notebook-dir=/notebooks", "--allow-root"]
