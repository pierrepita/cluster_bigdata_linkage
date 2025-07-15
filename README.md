# Cluster Big Data Linkage

Este repositório configura um cluster de Big Data com Spark Standalone, HDFS e Elasticsearch, empacotado com Docker Compose e pronto para testes e experimentações.

## 🔧 Subindo o Cluster

```bash
docker compose up -d --build
```

Você pode acessar:
- **Spark Master UI:** http://localhost:8080
- **Spark Job UI:** http://localhost:4040 (após submissão de job)
- **Elasticsearch UI:** http://localhost:9200
- **Acesso SSH aos containers:** `ssh root@localhost -p <port>`, senha `bdlinkage`

---

## 🚀 Executando o exemplo PySpark (`spark_pi.py`)

```bash
docker exec -it spark-submit bash
spark-submit --master spark://spark-master:7077 /root/spark_pi.py
```

---

## 📦 Trabalhando com o HDFS

### Subir arquivo para o HDFS

```bash
docker exec -it spark-master bash
hdfs dfs -put /opt/spark/README.md /user/root/
```

### Listar arquivos no HDFS

```bash
hdfs dfs -ls /user/root/
```

---

## 🔍 Indexando e Buscando no Elasticsearch

### Indexando um JSON no Elasticsearch

```bash
curl -X POST http://localhost:9200/pessoas/_doc/1 \
  -H 'Content-Type: application/json' \
  -d '{
    "nome": "Ana Maria",
    "idade": 29,
    "cidade": "Recife"
  }'
```

### Busca `must` (todos os critérios precisam ser atendidos)

```bash
curl -X GET http://localhost:9200/pessoas/_search \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "bool": {
        "must": [
          { "match": { "nome": "Ana" }},
          { "match": { "cidade": "Recife" }}
        ]
      }
    }
  }'
```

### Busca `fuzzy` (similaridade de texto)

```bash
curl -X GET http://localhost:9200/pessoas/_search \
  -H 'Content-Type: application/json' \
  -d '{
    "query": {
      "fuzzy": {
        "nome": {
          "value": "Anna",
          "fuzziness": 1
        }
      }
    }
  }'
```

---

## 🛑 Encerrando o Cluster

```bash
docker compose down
```

---

## 📁 Estrutura do Projeto

```text
cluster/
├── docker-compose.yml
├── spark/
│   └── spark-defaults.conf
├── hadoop/
│   └── core-site.xml
│   └── hdfs-site.xml
├── elasticsearch/
│   └── elasticsearch.yml
├── ssh/
│   └── Dockerfile
│   └── authorized_keys
│   └── spark_pi.py
```