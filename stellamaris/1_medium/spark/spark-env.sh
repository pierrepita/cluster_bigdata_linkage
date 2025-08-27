#!/usr/bin/env bash

# Diretório de instalação do Spark
export SPARK_HOME=/opt/spark

# Host do master
export SPARK_MASTER_HOST=barravento
export SPARK_MASTER_PORT=7077
export SPARK_WORKER_WEBUI_PORT=8081
export SPARK_WORKER_OPTS="-Dspark.worker.timeout=120 -Dspark.worker.cleanup.enabled=true -Dspark.worker.cleanup.interval=1800"

# Aponta para o master
export SPARK_WORKER_CORES=8
export SPARK_WORKER_MEMORY=30g

# Diretório onde os logs e os dados temporários do worker ficarão
export SPARK_WORKER_DIR=/opt/spark/work
export SPARK_LOCAL_DIRS=/tmp/spark

# Número de workers por nó (geralmente 1, a menos que você tenha mais de um por host)
export SPARK_WORKER_INSTANCES=1

# java/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$HADOOP_HOME/bin:$JAVA_HOME/bin
