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

| Nome do Nó     | Papel            | Serviços                 | Memória | Núcleos |
|----------------|------------------|--------------------------|---------|---------|
| barravento     | Master            | Spark Master, HDFS NN, Elasticsearch Master | 5 GB    | 2       |
| jardimdealah   | Worker 1          | Spark Worker, HDFS DN    | 1 GB    | 2       |
| stellamaris    | Worker 2          | Spark Worker, HDFS DN    | 1 GB    | 2       |
| lagamar        | Submissor + Jupyter | Jupyter Notebook, Spark submit | 2 GB    | 1       |

---

## 4. Interfaces Web Disponíveis

| Serviço         | URL                              |
|-----------------|----------------------------------|
| Spark Master UI | http://localhost:8080            |
| HDFS Namenode   | http://localhost:9870            |
| Elasticsearch   | http://localhost:9200            |
| Jupyter         | http://localhost:8888            |

---

## 5. Comandos úteis

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
