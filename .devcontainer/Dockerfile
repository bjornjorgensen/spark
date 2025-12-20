#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Apache Spark Development Container
# Based on the existing Spark infra Dockerfile with additional development tools

FROM ubuntu:jammy-20240911.1

LABEL org.opencontainers.image.authors="Apache Spark project <dev@spark.apache.org>"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.ref.name="Apache Spark Dev Container"

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true
ARG USERNAME=spark-dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Install base packages and development tools
# Split into multiple RUN commands for better caching
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    software-properties-common \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install core build tools and libraries
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gfortran \
    git \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libgit2-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    liblapack-dev \
    libopenblas-dev \
    libpng-dev \
    libpython3-dev \
    libssl-dev \
    libtiff5-dev \
    libwebp-dev \
    libxml2-dev \
    pkg-config \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Install language runtimes
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk-headless \
    python3.10 \
    python3-pip \
    python3-psutil \
    python3-venv \
    r-base \
    nodejs \
    npm \
    ruby \
    ruby-dev \
    && rm -rf /var/lib/apt/lists/*

# Install documentation and utility tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    pandoc \
    qpdf \
    sudo \
    vim \
    nano \
    htop \
    less \
    man \
    openssh-client \
    procps \
    tree \
    unzip \
    zip \
    jq \
    ripgrep \
    fd-find \
    bat \
    && rm -rf /var/lib/apt/lists/*

# Install Maven
RUN wget https://archive.apache.org/dist/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz -O /tmp/maven.tar.gz \
    && tar -xzf /tmp/maven.tar.gz -C /usr/share \
    && ln -s /usr/share/apache-maven-3.9.11 /usr/share/maven \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
    && rm /tmp/maven.tar.gz

# Configure R repositories and install R packages
RUN echo 'deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/' >> /etc/apt/sources.list && \
    gpg --keyserver hkps://keyserver.ubuntu.com --recv-key E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    gpg -a --export E084DAB9 | apt-key add - && \
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/' && \
    apt-get update && rm -rf /var/lib/apt/lists/*

# Install R packages for SparkR development
RUN Rscript -e "install.packages(c('devtools', 'knitr', 'markdown', \
    'rmarkdown', 'testthat', 'devtools', 'e1071', 'survival', 'arrow', \
    'ggplot2', 'mvtnorm', 'statmod', 'xml2'), repos='https://cloud.r-project.org/')" && \
    Rscript -e "devtools::install_version('roxygen2', version='7.2.0', repos='https://cloud.r-project.org')" && \
    Rscript -e "devtools::install_version('lintr', version='2.0.1', repos='https://cloud.r-project.org')" && \
    Rscript -e "devtools::install_version('pkgdown', version='2.0.1', repos='https://cloud.r-project.org')" && \
    Rscript -e "devtools::install_version('preferably', version='0.4', repos='https://cloud.r-project.org')"

ENV R_LIBS_SITE="/usr/local/lib/R/site-library:${R_LIBS_SITE}:/usr/lib/R/library"

# Install PyPy for testing
RUN add-apt-repository ppa:pypy/ppa && \
    mkdir -p /usr/local/pypy/pypy3.10 && \
    curl -sqL https://downloads.python.org/pypy/pypy3.10-v7.3.17-linux64.tar.bz2 | tar xjf - -C /usr/local/pypy/pypy3.10 --strip-components=1 && \
    ln -sf /usr/local/pypy/pypy3.10/bin/pypy /usr/local/bin/pypy3.10 && \
    ln -sf /usr/local/pypy/pypy3.10/bin/pypy /usr/local/bin/pypy3

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | pypy3 && \
    pypy3 -m pip install numpy 'six==1.16.0' 'pandas>=2.2.0' scipy coverage matplotlib lxml

# Install Python packages for PySpark development
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Spark Connect dependencies
RUN python3 -m pip install --no-cache-dir \
    'grpcio>=1.76.0' \
    'grpcio-status>=1.76.0' \
    'protobuf==6.33.0' \
    'googleapis-common-protos>=1.71.0' \
    'zstandard>=0.25.0'

# Install core PySpark dependencies
RUN python3 -m pip install --no-cache-dir \
    'py4j>=0.10.9.9' \
    'numpy>=1.22' \
    'pyarrow>=18.0.0' \
    'six==1.16.0' \
    'pandas>=2.2.0' \
    scipy \
    'plotly<6.0.0' \
    'mlflow>=2.3.1' \
    scikit-learn \
    matplotlib \
    'memory-profiler>=0.61.0' \
    'pyyaml>=3.11'

# Install Python development and testing tools
RUN python3 -m pip install --no-cache-dir \
    unittest-xml-reporting \
    openpyxl \
    coverage \
    'ruff==0.14.8' \
    'mypy==1.8.0' \
    'pytest-mypy-plugins==1.9.3' \
    'flake8==3.9.0' \
    'pandas-stubs<1.2.0.54' \
    types-PyYAML \
    ipython \
    jupyter \
    black \
    pytest \
    'graphviz==0.20.3' \
    'flameprof==0.4' \
    viztracer \
    debugpy

# Install documentation tools
RUN python3 -m pip install --no-cache-dir \
    mkdocs \
    'pydata_sphinx_theme>=0.13' \
    nbsphinx \
    numpydoc \
    jinja2 \
    'sphinx==4.5.0' \
    'sphinxcontrib-applehelp<=1.0.4' \
    'sphinxcontrib-devhelp<=1.0.2' \
    'sphinxcontrib-htmlhelp<=2.0.1' \
    'sphinxcontrib-jsmath<=1.0.1' \
    'sphinxcontrib-qthelp<=1.0.3' \
    'sphinxcontrib-serializinghtml<=1.1.5' \
    sphinx-plotly-directive \
    sphinx-copybutton \
    'docutils<0.18.0' \
    markupsafe

# Install development scripts dependencies
RUN python3 -m pip install --no-cache-dir \
    'jira>=3.5.2' \
    PyGithub

# Install ZSH and Oh My Zsh for better shell experience
RUN apt-get update && apt-get install -y --no-install-recommends \
    zsh \
    fonts-powerline \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/zsh \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Set up directories with proper permissions
RUN mkdir -p /home/$USERNAME/.m2 \
    && mkdir -p /home/$USERNAME/.sbt \
    && mkdir -p /home/$USERNAME/.ivy2 \
    && mkdir -p /home/$USERNAME/.cache \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV MAVEN_HOME=/usr/share/maven
ENV PATH="${PATH}:${MAVEN_HOME}/bin"
ENV SPARK_LOCAL_IP=127.0.0.1

# Switch to non-root user
USER $USERNAME

# Install Oh My Zsh and useful plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Configure ZSH with useful plugins
RUN sed -i 's/plugins=(git)/plugins=(git mvn python docker kubectl zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc \
    && echo 'export SPARK_HOME=/workspace' >> ~/.zshrc \
    && echo 'export PATH="$SPARK_HOME/bin:$PATH"' >> ~/.zshrc

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/zsh"]
