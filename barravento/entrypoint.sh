#!/bin/bash
# Criei este entrypoint para garantir que não haverá o problema "ERROR: JAVA_HOME is not set and could not be found."

# Precisamos configurar as variáveis de ambiente necessárias
# TODO: verificar se o java-home precisa ser setado ao chamar o start-dfs.sh
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin

# Ativa o serviço SSH
service ssh start

# Formata o namenode apenas se o diretório ainda não existir
if [ ! -d "/tmp/hadoop-root/dfs/name" ]; then
  $HADOOP_HOME/bin/hdfs namenode -format -force
fi

# Inicia o HDFS
$HADOOP_HOME/sbin/start-dfs.sh

# Inicia o Spark Master
$SPARK_HOME/sbin/start-master.sh

# Inicia o Elasticsearch (modo background)
nohup /opt/elasticsearch/bin/elasticsearch &

# Mantém o container ativo
tail -f $SPARK_HOME/logs/*.out
