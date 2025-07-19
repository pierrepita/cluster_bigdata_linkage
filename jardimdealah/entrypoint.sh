#!/bin/bash

# Define JAVA_HOME explicitamente
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export ES_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH=$PATH:$HADOOP_HOME/bin:$SPARK_HOME/bin:$JAVA_HOME/bin

# Inicia o serviço SSH (opcional, útil para testes manuais)
service ssh start

# Exporta JAVA_HOME para o processo do elasticsearch
echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/profile
source /etc/profile

# Inicia o DataNode
$HADOOP_HOME/bin/hdfs --daemon start datanode


# Sobe os serviços do Spark Worker e Elasticsearch
# Aguarda o Spark Master estar acessível
until nc -z barravento 7077; do
  echo "Aguardando Spark Master (barravento:7077)..."
  sleep 2
done

# Inicia o Spark Worker e aponta para o Spark Master
$SPARK_HOME/sbin/start-slave.sh spark://barravento:7077

# Sobe o Elasticsearch como data node
# Inicia o Elasticsearch (modo background)
## Evitando o erro: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf

## Cria arquivo de configuração adequado
cat <<EOF > /opt/elasticsearch/config/elasticsearch.yml
cluster.name: es-cluster
node.name: jardimdealah
node.roles: [data]
network.host: 0.0.0.0
discovery.seed_hosts: ["barravento"]
cluster.initial_master_nodes: ["barravento"]
xpack.security.enabled: false
ingest.geoip.downloader.enabled: false
EOF

# Agora é importante esvaziar os ficheiros
echo 'export PATH=$PATH:/opt/elasticsearch/bin' >> /home/elastic/.bashrc
su -s /bin/bash elastic -c "elasticsearch-keystore remove xpack.security.transport.ssl.keystore.secure_password"
su -s /bin/bash elastic -c "elasticsearch-keystore remove xpack.security.transport.ssl.truststore.secure_password"
su -s /bin/bash elastic -c "elasticsearch-keystore remove xpack.security.http.ssl.keystore.secure_password"

## Evitando o erro: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
## Criando arquivos e dando a permissão necessária 
chown -R elastic:elastic /opt/elasticsearch/
## Evitando o erro: "elasticsearch.keystore is not a readable regular file"
chmod 600 /opt/elasticsearch/config/elasticsearch.keystore
## Evitando o erro: "AccessDeniedException: /opt/elasticsearch/config/jvm.options.d"
chmod 700 /opt/elasticsearch/config/jvm.options.d
## Evitando o erro: "AccessDeniedException: /opt/elasticsearch/config/certs"
chmod 700 /opt/elasticsearch/config/certs

## É necessário informar o JAVA_HOME garantir a execução do es
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /home/elastic/.bashrc
## Aqui, preciso evitar o erro: "could not find java in bundled JDK at /opt/elasticsearch/jdk/bin/java"
## Parece que, por algum motivo, o es procura seu próprio Java
echo 'export ES_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /home/elastic/.bashrc
## Pecar pelo excesso não é tão ruim: 
nohup su -s /bin/bash elastic -c "env JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 /opt/elasticsearch/bin/elasticsearch" &

# nohup /opt/elasticsearch/bin/elasticsearch &
/usr/sbin/sshd -D

# Mantém o container vivo
tail -f /dev/null



