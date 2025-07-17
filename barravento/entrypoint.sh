#!/bin/bash
set -e

wait_for_host() {
  local host="$1"
  local port="$2"
  local timeout="${3:-60}"
  echo "Aguardando $host:$port por até $timeout segundos..."
  for ((i=0; i<timeout; i++)); do
    nc -z "$host" "$port" && echo "$host:$port disponível!" && return 0
    sleep 1
  done
  echo "Timeout ao aguardar $host:$port"
  return 1
}

echo "Iniciando Namenode..."
$HADOOP_HOME/bin/hdfs namenode -format -force || true
$HADOOP_HOME/sbin/start-dfs.sh

echo "Iniciando Spark Master..."
$SPARK_HOME/sbin/start-master.sh

echo "Iniciando Elasticsearch Master..."
/opt/elasticsearch/bin/elasticsearch
