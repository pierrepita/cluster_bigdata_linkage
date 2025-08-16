#!/bin/bash

# Define JAVA_HOME explicitamente
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export ES_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH=$PATH:$HADOOP_HOME/bin:$SPARK_HOME/bin:$JAVA_HOME/bin

# Instalando pacotes python, conforme interesse do usuário
pip install -r /root/requirements_python.txt

# Inicia o serviço SSH (opcional, útil para testes manuais)
service ssh start

# Exporta JAVA_HOME para o processo do elasticsearch
echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/profile
source /etc/profile

## Criando arquivos e dando a permissão necessária 
chown -R hadoop:hadoop /opt/hadoop/

## Definindo o JAVA_HOME e HADOOP_HOME para o usuário hadoop
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /home/hadoop/.bashrc
echo 'export HADOOP_HOME=/opt/hadoop' >> /home/hadoop/.bashrc

# permitindo a existencia do diretorio temporario hadoop
mkdir -p /tmp/hadoop-hadoop/dfs/name
mkdir -p /opt/hadoop/hdfs/namenode
mkdir -p /opt/hadoop/hdfs/datanode
chown -R hadoop:hadoop /tmp/hadoop-hadoop/
chown -R hadoop:hadoop /opt/hadoop

# Por algum motivo não funcionou copiar o arquivo para dentro do docker
# TODO: A suspeita é que arquivos padão são gerados na instalação
cat <<EOF > /opt/hadoop/etc/hadoop/core-site.xml
<configuration>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://barravento:9000</value>
  </property>
</configuration>
EOF

# Por algum motivo não funcionou copiar o arquivo para dentro do docker
# TODO: A suspeita é que arquivos padão são gerados na instalação
cat <<EOF > /opt/hadoop/etc/hadoop/hdfs-site.xml
<configuration>
  <property>
    <name>dfs.datanode.data.dir</name>
    <value>file:/opt/hadoop/hdfs/datanode</value>
  </property>

  <property>
    <name>dfs.replication</name>
    <value>2</value>
  </property>

  <property>
    <name>dfs.permissions</name>
    <value>false</value>
  </property>
</configuration>
EOF


# Inicia o DataNode
su -s /bin/bash hadoop -c "env JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 $HADOOP_HOME/bin/hdfs datanode" &
su -s /bin/bash hadoop -c "env JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 $HADOOP_HOME/bin/hdfs secondarynamenode" &

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



