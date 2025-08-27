#!/usr/bin/env bash

# Diretório de instalação do Spark
export SPARK_HOME=/opt/spark

# Host do master
export SPARK_MASTER_HOST=barravento
export SPARK_MASTER_PORT=7077

# Aponta para o master
export SPARK_WORKER_CORES=2
export SPARK_WORKER_MEMORY=1g

# Diretório onde os logs e os dados temporários do worker ficarão
export SPARK_WORKER_DIR=/opt/spark/work

# Número de workers por nó (geralmente 1, a menos que você tenha mais de um por host)
export SPARK_WORKER_INSTANCES=1

