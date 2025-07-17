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

wait_for_host barravento 7077
wait_for_host barravento 9200

echo "Iniciando Elasticsearch worker..."
/opt/elasticsearch/bin/elasticsearch &

echo "Iniciando Spark Worker..."
$SPARK_HOME/sbin/start-slave.sh spark://barravento:7077

wait
