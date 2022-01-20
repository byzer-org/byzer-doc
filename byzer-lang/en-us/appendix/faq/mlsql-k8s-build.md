# How to create the mirror environment in Byzer K8s deployment mode?
It is recommended to make two mirrors:

The basic image, which should be possessed with:

1. JDK
2. Conda (Python related environment)
3. Spark distribution

In this article, we will take Spark 3.0 as an example:

Suppose the mirror environment name is: spark:v3.0.0-hadoop3.2.

Note: The mirror file needs to be executed in the root directory of the Spark distribution.

```sql
ARG java_image_tag=14.0-jdk-slim

FROM openjdk:${java_image_tag}

ARG spark_uid=185

RUN set -ex && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y bash tini libc6 libpam-modules krb5-user libnss3 && \
    mkdir -p /opt/spark && \
    mkdir -p /opt/spark/examples && \
    mkdir -p /opt/spark/work-dir && \
    touch /opt/spark/RELEASE && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/*

RUN apt-get update \
    && apt-get install -y \
        git \
        wget \
        cmake \
        build-essential \
        curl \
        unzip \
        libgtk2.0-dev \
        zlib1g-dev \
        libgl1-mesa-dev \
    && apt-get clean \
    && echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh \
    && wget \
        --quiet "https://repo.anaconda.com/miniconda/Miniconda3-4.7.12.1-Linux-x86_64.sh" \
        -O /tmp/anaconda.sh \
    && /bin/bash /tmp/anaconda.sh -b -p /opt/conda \
    && rm /tmp/anaconda.sh \
    && /opt/conda/bin/conda install -y \
        libgcc python=3.6.9 \
    && /opt/conda/bin/conda clean -y --all \
    && /opt/conda/bin/pip install \
        flatbuffers \
        cython==0.29.0 \
        numpy==1.15.4

RUN /opt/conda/bin/conda create --name dev python=3.6.9 -y \
    && source /opt/conda/bin/activate  dev \
    && pip install pyarrow==0.10.0 \
    && pip install ray==0.8.0 \
    && pip install aiohttp psutil setproctitle grpcio pandas xlsxwriter watchdog requests click uuid sfcli  pyjava

COPY jars /opt/spark/jars
COPY bin /opt/spark/bin
COPY sbin /opt/spark/sbin
COPY kubernetes/dockerfiles/spark/entrypoint.sh /opt/
COPY examples /opt/spark/examples
COPY kubernetes/tests /opt/spark/tests
COPY data /opt/spark/data

ENV SPARK_HOME /opt/spark

WORKDIR /opt/spark/work-dir
RUN chmod g+w /opt/spark/work-dir

ENTRYPOINT [ "/opt/entrypoint.sh" ]

USER ${spark_uid}
```

Next, we will package all Byzer-related dependencies based on this mirror:

```sql
FROM spark:v3.0.0-hadoop3.2
COPY streamingpro-mlsql-spark_3.0_2.12-2.0.1-SNAPSHOT.jar /opt/spark/work-dir/
WORKDIR /opt/spark/work-dir
ENTRYPOINT [ "/opt/entrypoint.sh" ]
```

Usually basic mirror environment is quite stable. But Byzer will upgrade frequently.
