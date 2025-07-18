# Dockerfile no nó Master [barravento]
# Nome: barravento
# Serviços: Spark Master, Namenode, Datanode, Elasticsearch Master
# Portas Expostas: 7077, 8080, 9000, 9870, 9200
# Recursos Spark/Elasticsearch: Spark Driver: 2 núcleos, 2GB RAM; ES Master: 2GB JVM
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/opt/spark/bin:/opt/hadoop/bin

# Instalação das dependências básicas
# Principais aspectos: Versão do JAVA e do Python
RUN apt-get update && \
    apt-get install -y openssh-server openjdk-11-jdk curl wget python3.6 python3.6-venv python3.6-distutils python3-pip unzip net-tools && \
    ln -sf /usr/bin/python3.6 /usr/bin/python && \
    ln -sf /usr/bin/python3.6 /usr/bin/python3 && \
    pip3 install pyspark==3.0.1

# Instalação do Spark
# Garantindo versão 3.0.1 do Spark para versão homologada do linkage CIDACS-RL e Atyimo
ENV SPARK_VERSION=3.0.1
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3.2 /opt/spark && \
#    ln -s /opt/spark/bin/* /usr/local/bin/ && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.2.tgz

# HDFS - Hadoop
ENV HADOOP_VERSION=3.3.6
RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xvzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /opt/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# Elasticsearch
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.1.3-linux-x86_64.tar.gz && \
    tar -xzf elasticsearch-8.1.3-linux-x86_64.tar.gz && \
    mv elasticsearch-8.1.3 /opt/elasticsearch && \
    rm elasticsearch-8.1.3-linux-x86_64.tar.gz

COPY elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml
COPY jvm.options /opt/elasticsearch/config/jvm.options

# SSH Setup
RUN mkdir /var/run/sshd && \
    echo 'root:01' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$HADOOP_HOME/bin




EXPOSE 22 7077 8080 9200 9870 9000

CMD ["/usr/sbin/sshd", "-D"]

# INICIANDO SERVIÇOS
# HDFS
# Variáveis para rodar HDFS como root (caso não use usuário específico)
ENV HDFS_NAMENODE_USER=root \
    HDFS_DATANODE_USER=root \
    HDFS_SECONDARYNAMENODE_USER=root \
    HDFS_JOURNALNODE_USER=root \
    HDFS_ZKFC_USER=root \
    YARN_RESOURCEMANAGER_USER=root \
    YARN_NODEMANAGER_USER=root

RUN $HADOOP_HOME/bin/hdfs namenode -format -force || true
RUN $HADOOP_HOME/sbin/start-dfs.sh
# SPARK MASTER
RUN $SPARK_HOME/sbin/start-master.sh
# ELASTIC MASTER
RUN /opt/elasticsearch/bin/elasticsearch
