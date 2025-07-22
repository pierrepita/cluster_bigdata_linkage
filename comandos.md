# Comandos: 
# 1: rebuild das imagens mesmo que nada tenha mudado
docker compose build --no-cache
docker compose up --force-recreate --remove-orphans
# 2: remove os contêineres, volumes e órfãos
docker compose down --volumes --remove-orphans

# 3: subir depois do build (mas atualizando)
docker compose up -d --build

# 4: só subir depois do build
docker compose up -d 

# 5: resetar um node
docker restart barravento



# 7: Elasticsearch
## Checa nodes online
docker exec -it barravento bash
root@barravento:/# curl -s http://localhost:9200/_cat/nodes?v


http://localhost:8888/tree?

http://localhost:9870/dfshealth.html#tab-datanode

# 8: Executa SparkPi
spark-submit --master spark://barravento:7077 /root/spark_pi.py

# 9: Testando HDFS
## Colocando os dados no HDFS
hdfs dfs -mkdir /spark-logs
hdfs dfs -mkdir /sandbox
hdfs dfs -put /root/sandbox-tests/01-databaseA.csv /sandbox/
hdfs dfs -put /root/sandbox-tests/02-databaseB.csv /sandbox/

spark-submit --master spark://barravento:7077 /root/sandbox-tests/spark_pi.py
# Por algum motivo, o comando abaixo não está funcionando
spark-submit --master spark://barravento:7077 --jars /opt/spark/jars/elasticsearch-hadoop-8.1.3.jar /root/sandbox-tests/indexa-dbB-spark-es.py
# Esta alternativa, sim. 
spark-submit --master spark://barravento:7077 --packages org.elasticsearch:elasticsearch-spark-30_2.12:8.1.3 /root/sandbox-tests/indexa-dbB-spark-es.py


curl -X POST "http://barravento:9200/dbb/_search" -H 'Content-Type: application/json' -d '
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "nome": "Maria"
          }
        }
      ],
      "should": [
        {
          "match": {
            "cidade": {
              "query": "Salvador",
              "fuzziness": "AUTO"
            }
          }
        }
      ]
    }
  }
}
'

curl -X POST "http://barravento:9200/dbb/_search" -H 'Content-Type: application/json' -f 'sandbox-tests/consulta-es.json'
