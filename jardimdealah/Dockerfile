# Dockerfile do nó Worker 1 [jardimdealah]
# Nome: jardimdealah
# Serviços: Spark Worker, Datanode, Elasticsearch Worker
# Portas Expostas: 8081
# Recursos Spark/Elasticsearch: 2 executores, 2 núcleos cada, 1GB RAM
FROM ubuntu:18.04

# Variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV SPARK_VERSION=3.0.1
ENV HADOOP_VERSION=3.3.6
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:/opt/spark/bin:/opt/hadoop/bin
ENV PYSPARK_PYTHON=python3.6
ENV ELASTIC_VERSION=8.1.3

# Instala dependências básicas, Java, Python 3.6, pip, e ferramentas auxiliares
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk wget curl ssh net-tools python3.6 python3-pip unzip gnupg netcat && \
    ln -sf /usr/bin/python3.6 /usr/bin/python && \
    ln -sf /usr/bin/python3.6 /usr/bin/python3 && \
    python3.6 -m pip install --upgrade pip && \
    pip install pyspark==3.0.1

# Instala Spark
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3.2 /opt/spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.2.tgz

# Instala Hadoop
RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /opt/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# O hdfs precisa desta diretiva pra evitar o erro: 
# "2.063 ERROR: JAVA_HOME is not set and could not be found."
# COPY set-java-home-hdfs.sh /root/set-java-home-hdfs.sh
# RUN chmod +x /root/set-java-home-hdfs.sh && /root/set-java-home-hdfs.sh
RUN sed -i '2i export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' /opt/hadoop/sbin/start-dfs.sh

# Instala Elasticsearch
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz && \
    tar -xzf elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz && \
    mv elasticsearch-${ELASTIC_VERSION} /opt/elasticsearch && \
    rm elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz

# Instala elasticsearch-hadoop jar compatível
RUN mkdir -p /opt/elasticsearch/lib && \
    wget https://repo1.maven.org/maven2/org/elasticsearch/elasticsearch-hadoop/${ELASTIC_VERSION}/elasticsearch-hadoop-${ELASTIC_VERSION}.jar -P /opt/elasticsearch/lib

# Configura memória para Elasticsearch
RUN echo "-Xms2g\n-Xmx2g" > /opt/elasticsearch/config/jvm.options.d/memory.options

# Configura Elasticsearch como nó worker
COPY elasticsearch/elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml

# Configura Spark
COPY spark/spark-defaults.conf /opt/spark/conf/spark-defaults.conf

# Configurações do Hadoop (HDFS)
COPY hadoop/core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
COPY hadoop/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml

# Configura SSH para acesso entre nós
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo 'root:01' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

EXPOSE 22 8081

CMD ["/usr/sbin/sshd", "-D"]

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
