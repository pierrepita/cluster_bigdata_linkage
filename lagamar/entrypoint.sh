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

echo "Iniciando Jupyter Notebook..."
jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --NotebookApp.token='' --no-browser &

echo "Aguardando Spark disponível para submissão..."
wait_for_host barravento 7077

/bin/bash
