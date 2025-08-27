# Cluster Big Data para Testes de Indexação e Linkage

Este repositório configura um cluster Docker com HDFS, Spark e Elasticsearch integrados. Os serviços são organizados em diferentes nós, com suporte a notebooks, interface web de monitoramento e indexação de dados no Elasticsearch via PySpark.

---

## 1. Instalando o Docker com suporte ao usuário comum

### 1.1 Instalar dependências

```bash
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
```

### 1.2 Adicionar a chave GPG oficial do Docker

```bash
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

### 1.3 Adicionar o repositório Docker

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 1.4 Instalar Docker Engine e Docker Compose Plugin

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### 1.5 Verificar se a instalação funcionou

```bash
docker --version
docker compose version
```

### 1.6 Permitir que um usuário comum use Docker

```bash
newgrp docker
sudo usermod -aG docker $USER
```

⚠️ *Importante: Você precisa relogar ou reiniciar a sessão para que isso tenha efeito.*

### 1.7 Testar como usuário comum

```bash
docker run hello-world
docker compose version
```

### 1.8 Subir o cluster

```bash
docker compose up -d
```

---

## 2. Roteiro de uso

```bash
git clone https://github.com/pierrepita/cluster_bigdata_linkage.git
cd cluster_bigdata_linkage
docker compose up -d
ssh root@localhost -p 2222  # senha: 01
```

---

## 3. Nós do Cluster

| Nome do Nó     | Papel            | Serviços                 |
|----------------|------------------|--------------------------|
| barravento     | Master            | Spark Master, HDFS NN, Elasticsearch Master |
| jardimdealah   | Worker 1          | Spark Worker, HDFS DN    |
| stellamaris    | Worker 2          | Spark Worker, HDFS DN    |
| lagamar        | Submissor + Jupyter | Jupyter Notebook, Spark submit |

---
## 4. Configuração do Spark Standalone Cluster

### 4.1 Fixo (todos os cenários)

| Variável / Configuração        | Valor / Explicação                                                                 |
|--------------------------------|-------------------------------------------------------------------------------------|
| **SPARK_MASTER_HOST**          | `barravento` (hostname do Master)                                                   |
| **SPARK_MASTER_PORT**          | `7077` (porta do Master)                                                            |
| **spark.sql.adaptive.enabled** | `true` – Adaptive Query Execution ligado                                            |
| **spark.sql.adaptive.skewJoin.enabled** | `true` – Corrige joins com skew automaticamente                             |
| **spark.sql.files.maxPartitionBytes** | `64m` – Máximo de dados por partição de leitura                               |
| **spark.sql.broadcastTimeout** | `600` – Timeout (segundos) para broadcast de tabelas pequenas                       |
| **SPARK_LOCAL_DIRS**           | `/tmp/spark` (diretório local para shuffle/cache temporário)                        |
| **SPARK_LOG_DIR**              | `/opt/spark/logs` (logs locais; event logs podem ir para HDFS via `spark.eventLog.dir`) |

---

### 4.2 Variável por Cenário

| Cenário   | Master (barravento) | Worker (stellamaris / jardimdealah) | Executors por Worker                 | SQL Shuffle / Broadcast                  |
|-----------|----------------------|--------------------------------------|--------------------------------------|-------------------------------------------|
| **Pequeno** | 2 vCPU / 8 GB RAM  | 4 vCPU / 16 GB RAM                  | 1 executor, 3 cores, 12 GB RAM        | `spark.sql.shuffle.partitions=12`<br>`spark.sql.autoBroadcastJoinThreshold=50m` |
| **Médio**   | 4 vCPU / 16 GB RAM | 8 vCPU / 32 GB RAM                  | 2 executores, 4 cores cada, 12 GB RAM | `spark.sql.shuffle.partitions=48`<br>`spark.sql.autoBroadcastJoinThreshold=100m` |
| **Grande**  | 4–8 vCPU / 16–32 GB RAM | 16 vCPU / 64 GB RAM             | 3 executores, 5 cores cada, 16 GB RAM | `spark.sql.shuffle.partitions=72`<br>`spark.sql.autoBroadcastJoinThreshold=200m` |

---

### 4.3 Explicação das principais variáveis

- **SPARK_WORKER_CORES**: nº total de cores que cada Worker anuncia ao Master.  
- **SPARK_WORKER_MEMORY**: memória total que cada Worker oferece (reserve ~10% para SO/serviços).  
- **--executor-cores**: nº de cores usados por cada executor.  
- **--executor-memory**: heap de memória de cada executor (exclui overhead).  
- **spark.sql.shuffle.partitions**: nº de partições após operações de shuffle (ideal ≈ 2–3× total de cores do cluster).  
- **spark.sql.autoBroadcastJoinThreshold**: limite de tamanho para o Spark usar broadcast join (tabelas menores que esse valor são replicadas para todos executores).  

---

### 4.4 Regras práticas

- **Master (barravento)** nunca executa tasks; precisa de memória suficiente para o **driver** (8–32 GB).  
- **Workers** dedicam a maior parte da RAM/CPU aos executores (reserve sempre 1 core + ~2 GB para o SO).  
- O nº de **executores por Worker** e seus recursos variam conforme o cenário.  
- Ajuste `spark.sql.shuffle.partitions` sempre proporcional ao total de cores do cluster.  


### 4.5 Resumo
| Cenário  | Master (barravento) – `spark-env.sh` | Workers (stellamaris / jardimdealah) – `spark-env.sh` | `spark-defaults.conf` (todos os nós, valores variam por cenário) |
|----------|--------------------------------------|-------------------------------------------------------|------------------------------------------------------------------|
| **Pequeno**<br>(2 vCPU / 8 GB Master, 4 vCPU / 16 GB Worker) | ```bash<br>SPARK_MASTER_HOST=barravento<br>SPARK_MASTER_PORT=7077<br>SPARK_MASTER_WEBUI_PORT=8080<br>JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64<br>HADOOP_HOME=/opt/hadoop<br>SPARK_HOME=/opt/spark<br>SPARK_LOCAL_DIRS=/tmp/spark<br>``` | ```bash<br>SPARK_WORKER_CORES=4<br>SPARK_WORKER_MEMORY=14g<br>SPARK_WORKER_PORT=7078<br>SPARK_WORKER_WEBUI_PORT=8081<br>SPARK_LOCAL_DIRS=/tmp/spark<br>``` | ```properties<br>spark.master spark://barravento:7077<br>spark.hadoop.fs.defaultFS hdfs://barravento:9000<br>spark.sql.adaptive.enabled=true<br>spark.sql.adaptive.skewJoin.enabled=true<br>spark.sql.files.maxPartitionBytes=64m<br>spark.sql.shuffle.partitions=12<br>spark.sql.autoBroadcastJoinThreshold=50m<br>spark.sql.broadcastTimeout=600<br>spark.serializer=org.apache.spark.serializer.KryoSerializer<br>``` |
| **Médio**<br>(4 vCPU / 16 GB Master, 8 vCPU / 32 GB Worker) | *mesmo conteúdo fixo do Master acima* | ```bash<br>SPARK_WORKER_CORES=8<br>SPARK_WORKER_MEMORY=30g<br>SPARK_WORKER_PORT=7078<br>SPARK_WORKER_WEBUI_PORT=8081<br>SPARK_LOCAL_DIRS=/tmp/spark<br>``` | ```properties<br>spark.sql.shuffle.partitions=48<br>spark.sql.autoBroadcastJoinThreshold=100m<br>``` *(demais configs idênticas ao Pequeno)* |
| **Grande**<br>(4–8 vCPU / 16–32 GB Master, 16 vCPU / 64 GB Worker) | *mesmo conteúdo fixo do Master acima* | ```bash<br>SPARK_WORKER_CORES=16<br>SPARK_WORKER_MEMORY=60g<br>SPARK_WORKER_PORT=7078<br>SPARK_WORKER_WEBUI_PORT=8081<br>SPARK_LOCAL_DIRS=/tmp/spark<br>``` | ```properties<br>spark.sql.shuffle.partitions=72<br>spark.sql.autoBroadcastJoinThreshold=200m<br>spark.sql.broadcastTimeout=900<br>``` *(demais configs idênticas ao Pequeno)* |
---

## 5. Interfaces Web Disponíveis

| Serviço         | URL                              |
|-----------------|----------------------------------|
| Spark Master UI | http://localhost:8080            |
| HDFS Namenode   | http://localhost:9870            |
| Elasticsearch   | http://localhost:9200            |
| Jupyter         | http://localhost:8888            |

---

## 6. Comandos úteis

### Acessar o node submissor

```bash
ssh root@localhost -p 2222  # senha: 01
```

### Spark: exemplo básico

```bash
spark-submit --master spark://barravento:7077 /root/sandbox-tests/spark_pi.py
```

### HDFS: enviar arquivos

```bash
/opt/hadoop/bin/hdfs dfs -put /root/sandbox-tests/01-databaseA.csv /sandbox/
/opt/hadoop/bin/hdfs dfs -put /root/sandbox-tests/02-databaseB.csv /sandbox/
```

### Spark com Elasticsearch

```bash
spark-submit --master spark://barravento:7077 \
  --packages org.elasticsearch:elasticsearch-spark-30_2.12:8.1.3 \
  /root/sandbox-tests/indexa-dbB-spark-es.py
```

### Elasticsearch – consulta via `curl`

```bash
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
}'
```

### Elasticsearch – consulta via arquivo

```bash
curl -X POST "http://barravento:9200/dbb/_search" \
  -H 'Content-Type: application/json' \
  -d @sandbox-tests/consulta-es.json
```

### Acessar o notebook de testes

Acesse: [http://localhost:8888/notebooks/sandbox-tests/indexa-dbB-spark-es.ipynb](http://localhost:8888/notebooks/sandbox-tests/indexa-dbB-spark-es.ipynb)

---

> Para dúvidas ou problemas, consulte os logs com `docker compose logs -f` ou acesse os containers com `docker exec -it <nome> bash`.
