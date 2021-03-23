FROM ubuntu:20.04
MAINTAINER mongenae@its.jnj.com

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

ENV PACKAGES git gcc make g++ libboost-all-dev liblzma-dev libbz2-dev \
    ca-certificates zlib1g-dev libcurl4-openssl-dev curl unzip autoconf apt-transport-https ca-certificates gnupg software-properties-common wget openjdk-8-jre unzip r-base r-base-dev \
      locales \
      software-properties-common \
      build-essential \
      libxml2-dev \
      libssl-dev

ENV QUALIMAP_VERSION 2.2.1

WORKDIR /home

RUN apt-get update && \
    apt remove -y libcurl4 && \
    apt-get install -y --no-install-recommends ${PACKAGES} && \
    apt-get clean

RUN apt-get update

WORKDIR /home

RUN wget --no-check-certificate https://bitbucket.org/kokonech/qualimap/downloads/qualimap_v${QUALIMAP_VERSION}.zip
RUN unzip qualimap_v${QUALIMAP_VERSION}.zip

RUN Rscript -e "install.packages('optparse')"
RUN Rscript -e "install.packages('XML')"
RUN Rscript -e "if (!requireNamespace('BiocManager', quietly = TRUE)) install.packages('BiocManager')"
RUN Rscript -e "BiocManager::install(c('Repitools', 'GenomicFeatures'))"
RUN Rscript -e "BiocManager::install(c('NOISeq', 'Rsamtools', 'rtracklayer'))"


# Set environment variable(s)
# Configure "locale", see https://github.com/rocker-org/rocker/issues/19
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV PATH /home/qualimap_v${QUALIMAP_VERSION}/:${PATH}
ENV LD_LIBRARY_PATH "/usr/local/lib:${LD_LIBRARY_PATH}"

RUN echo "export PATH=$PATH" > /etc/environment
RUN echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" > /etc/environment
