# Cluster Spark + HDFS + Elasticsearch

Este projeto configura um cluster local com os seguintes serviços usando Docker Compose:

- **Apache Spark (Standalone)**: 1 master, 2 workers
- **HDFS (Hadoop 3.2.1)**: 1 NameNode que também atua como DataNode
- **Elasticsearch 8.1.3**
- **SparkSubmit com SSH**

## Estrutura de Serviços

| Serviço         | Descrição                         | Porta Exposta         |
|-----------------|-----------------------------------|------------------------|
| spark-master    | Spark Master                      | 8080                   |
| spark-worker-1  | Worker Spark                      | 8081                   |
| spark-worker-2  | Worker Spark                      | 8082                   |
| hdfs-namenode   | NameNode e DataNode               | 9870                   |
| elasticsearch   | Elasticsearch (no auth)           | 9200, 9300             |
| spark-submit    | Node com SSH para submit remoto   | 2222 (SSH)             |

---

## Pré-requisitos

- Docker
- Docker Compose
- Chave pública SSH para acesso ao SparkSubmit

---

## Passo a passo

### 1. Clone o repositório

```bash
git clone <repo-url>
cd cluster
```

### 2. Adicione sua chave pública SSH

Edite o arquivo:

```bash
vim ssh/authorized_keys
```

Cole sua chave pública no arquivo.

---

### 3. Suba o cluster

```bash
docker-compose up -d
```

---

### 4. Acesse as interfaces web

- Spark Master: http://localhost:8080
- Spark Worker 1: http://localhost:8081
- Spark Worker 2: http://localhost:8082
- HDFS NameNode: http://localhost:9870
- Elasticsearch: http://localhost:9200

---

### 5. Acesse o node SparkSubmit via SSH

```bash
ssh root@localhost -p 2222
# senha: sparkpass (caso não use chave)
```

---

### 6. Submeter um job Spark

Dentro do container `spark-submit`:

```bash
spark-submit --master spark://spark-master:7077 \
  --class org.apache.spark.examples.SparkPi \
  /opt/bitnami/spark/examples/jars/spark-examples_2.12-3.0.1.jar 10
```

---

### 7. Usar o HDFS

Dentro do container com Hadoop:

```bash
hdfs dfs -mkdir -p /data
hdfs dfs -put localfile.csv /data/
```

---

### 8. Consultar o Elasticsearch

Na máquina host:

```bash
curl http://localhost:9200/_cat/indices?v
```

---

## Observações

- Todos os serviços são configurados para não exigir autenticação.
- Todos os nodes (incluindo o Namenode) são também DataNodes.
- Memória configurada:
  - Cada Spark Worker com 4 executores e 2GB por executor
  - Driver com 3GB
  - Elasticsearch com 3GB

---