#!/bin/bash

# Define JAVA_HOME explicitamente
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH=$PATH:$HADOOP_HOME/bin:$SPARK_HOME/bin:$JAVA_HOME/bin

# Inicia o serviço SSH (opcional, útil para testes manuais)
service ssh start

# Inicia o DataNode
$HADOOP_HOME/bin/hdfs --daemon start datanode

# Aguarda o Spark Master estar acessível
until nc -z barravento 7077; do
  echo "Aguardando Spark Master (barravento:7077)..."
  sleep 2
done

# Inicia o Spark Worker e aponta para o Spark Master
$SPARK_HOME/sbin/start-slave.sh spark://barravento:7077

# Mantém o container vivo
tail -f /dev/null
