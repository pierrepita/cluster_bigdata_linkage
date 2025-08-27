#!/usr/bin/env bash

# Diretório de instalação do Spark
export SPARK_HOME=/opt/spark

# Host do master
export SPARK_MASTER_HOST=barravento
export SPARK_MASTER_PORT=7077
export PYSPARK_SUBMIT_ARGS='--master spark://barravento:7077 --deploy-mode client --packages org.elasticsearch:elasticsearch-spark-30_2.12:8.1.3 pyspark-shell'

# Aponta para o master
export SPARK_WORKER_CORES=2
export SPARK_WORKER_MEMORY=1g

# Diretório onde os logs e os dados temporários do worker ficarão
export SPARK_WORKER_DIR=/opt/spark/work

# Número de workers por nó (geralmente 1, a menos que você tenha mais de um por host)
export SPARK_WORKER_INSTANCES=1

