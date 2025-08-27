#!/usr/bin/env bash

# Sobre o java/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$HADOOP_HOME/bin:$JAVA_HOME/bin

# Definições do master
export SPARK_MASTER_HOST=barravento
export SPARK_MASTER_PORT=7077

# Definições do worker ao negociar com o master
export SPARK_WORKER_CORES=4
export SPARK_WORKER_MEMORY=14g
export SPARK_WORKER_PORT=7078
export SPARK_WORKER_WEBUI_PORT=8081

# Definições de timeout para estabilidade
export SPARK_WORKER_OPTS="-Dspark.worker.timeout=120 -Dspark.worker.cleanup.enabled=true -Dspark.worker.cleanup.interval=1800"

# Diretório onde os logs e os dados temporários do worker ficarão
export SPARK_WORKER_DIR=/opt/spark/work

# Número de workers por nó (geralmente 1, a menos que você tenha mais de um por host)
export SPARK_WORKER_INSTANCES=1

