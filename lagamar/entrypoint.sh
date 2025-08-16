#!/bin/bash
set -e

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export ES_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH=$PATH:$HADOOP_HOME/bin:$SPARK_HOME/bin:$JAVA_HOME/bin

# Instalando pacotes python, conforme interesse do usuário
pip install -r /root/requirements_python.txt

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
jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --NotebookApp.token='' --no-browser --notebook-dir=/root &

echo "Aguardando Spark disponível para submissão..."
wait_for_host barravento 7077

## Definindo o JAVA_HOME e HADOOP_HOME para o usuário hadoop
# Garantindo que as variaveis de ambiente estarão no .bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /root/.bashrc
echo 'export HADOOP_HOME=/opt/hadoop' >> /root/.bashrc
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /root/.bashrc
echo 'export ES_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /root/.bashrc
echo 'export SPARK_HOME=/opt/spark' >> /root/.bashrc
echo 'export HADOOP_HOME=/opt/hadoop' >> /root/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/bin:$SPARK_HOME/bin:$JAVA_HOME/bin' >> /root/.bashrc
source /root/.bashrc

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
su -s /bin/bash hadoop -c "env JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 $HADOOP_HOME/bin/hdfs dfs -mkdir /spark-logs" &
su -s /bin/bash hadoop -c "env JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 $HADOOP_HOME/bin/hdfs dfs -mkdir /sandbox" &

/usr/sbin/sshd -D

# Mantém o container vivo
tail -f /dev/null
