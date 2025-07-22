#!/bin/bash
# Criei este entrypoint para garantir que não haverá o problema "ERROR: JAVA_HOME is not set and could not be found."

# Precisamos configurar as variáveis de ambiente necessárias
# TODO: verificar se o java-home precisa ser setado ao chamar o start-dfs.sh
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$SPARK_HOME/bin

# Ativa o serviço SSH
service ssh start

# Formata o namenode apenas se o diretório ainda não existir
#if [ ! -d "/tmp/hadoop-root/dfs/name" ]; then
#  $HADOOP_HOME/bin/hdfs namenode -format -force
#fi

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
    <name>dfs.namenode.name.dir</name>
    <value>file:/opt/hadoop/hdfs/namenode</value>
  </property>

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

  <property>
    <name>dfs.namenode.rpc-address</name>
    <value>barravento:9000</value>
  </property>
</configuration>
EOF


# Inicia o HDFS
# Formata o NameNode 
su -s /bin/bash hadoop -c "env JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 $HADOOP_HOME/bin/hdfs namenode -format -force"

# Inicia o NameNode em background (em algumas execuções, o namenode não está subindo e eu não entendo o motivo). 
su -s /bin/bash hadoop -c "env JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 $HADOOP_HOME/bin/hdfs namenode" &

# Então estou obrigando o datanode a esperar (porta 9000 aberta)
echo "Aguardando o NameNode iniciar na porta 9000..."
while ! nc -z barravento 9000; do
  sleep 2
done
echo "NameNode iniciado, indo para o Datanode!"

# Inicia o DataNode
su -s /bin/bash hadoop -c "env JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 $HADOOP_HOME/bin/hdfs datanode" &

# Inicia o Spark Master
$SPARK_HOME/sbin/start-master.sh

# Inicia o Elasticsearch (modo background)
## Evitando o erro: max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]
echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf

## Cria arquivo de configuração adequado
cat <<EOF > /opt/elasticsearch/config/elasticsearch.yml
cluster.name: "es-cluster"
node.name: "barravento"
node.roles: [ master ]
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: []
cluster.initial_master_nodes: ["barravento"]

xpack.security.enabled: false
xpack.security.transport.ssl.enabled: false
xpack.security.http.ssl.enabled: false

ingest.geoip.downloader.enabled: false
EOF

# Agora é importante esvaziar os ficheiros
echo 'export PATH=$PATH:/opt/elasticsearch/bin' >> /home/elastic/.bashrc
su -s /bin/bash elastic -c "elasticsearch-keystore remove xpack.security.transport.ssl.keystore.secure_password"
su -s /bin/bash elastic -c "elasticsearch-keystore remove xpack.security.transport.ssl.truststore.secure_password"
su -s /bin/bash elastic -c "elasticsearch-keystore remove xpack.security.http.ssl.keystore.secure_password"

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

# Mantém o container ativo
tail -f $SPARK_HOME/logs/*.out
