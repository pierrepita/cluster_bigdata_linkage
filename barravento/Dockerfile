# Dockerfile no nó Master [barravento]
# Nome: barravento
# Serviços: Spark Master, Namenode, Datanode, Elasticsearch Master
# Portas Expostas: 7077, 8080, 9000, 9870, 9200
# Recursos Spark/Elasticsearch: Spark Driver: 2 núcleos, 2GB RAM; ES Master: 2GB JVM
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$PATH:/opt/spark/bin:/opt/hadoop/bin

# Versões
ENV ELASTIC_VERSION=8.1.3 \
    SPARK_VERSION=3.0.1 \
    HADOOP_VERSION=3.3.6 

# Instalação das dependências básicas
# Principais aspectos: Versão do JAVA e do Python
RUN apt-get update && \
    apt-get install -y software-properties-common git p7zip-full nano openssh-server openjdk-11-jdk curl wget python3 python3-venv python3-distutils python3-pip unzip net-tools netcat && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    pip3 install pyspark==3.0.1

# Copiando o arquivo que orienta quais pacotes python devem ser instalados
COPY requirements_python.txt /root/requirements_python.txt
RUN pip3 install --no-cache-dir -r /root/requirements_python.txt

# Instalação do Spark
# Garantindo versão 3.0.1 do Spark para versão homologada do linkage CIDACS-RL e Atyimo

RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3.2 /opt/spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.2.tgz

COPY spark-env.sh /opt/spark/conf/spark-env.sh
RUN chmod +x /opt/spark/conf/spark-env.sh
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf


# HDFS - Hadoop
## É necessário criar um usuário hadoop para iniciar o hadoop
RUN groupadd -g 2000 hadoop && useradd -u 2000 -g hadoop -m hadoop

RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xvzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /opt/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

COPY core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
COPY hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml

# Elasticsearch
## O ES demanda instalação 17 do Java
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk
## É necessário criar um usuário elastic para iniciar o elastic
RUN groupadd -g 1000 elastic && useradd -u 1000 -g elastic -m elastic
## Agora é só baixar os instaladores 
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz && \
    tar -xzf elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz && \
    mv elasticsearch-${ELASTIC_VERSION} /opt/elasticsearch && \
    rm elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz

COPY elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml
COPY jvm.options /opt/elasticsearch/config/jvm.options

# Baixando o conector elasticsearch-hadoop para que o Spark possa interagir corretamente com o Elasticsearch
# Isso deve permitir um melhor controle de versão local. 
RUN wget https://repo1.maven.org/maven2/org/elasticsearch/elasticsearch-hadoop/${ELASTIC_VERSION}/elasticsearch-hadoop-${ELASTIC_VERSION}.jar -o /opt/spark/jars/elasticsearch-hadoop-${ELASTIC_VERSION}.jar

# SSH Setup
RUN mkdir /var/run/sshd && \
    echo 'root:01' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV HADOOP_HOME=/opt/hadoop
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin:$HADOOP_HOME/bin

EXPOSE 22 7077 8080 9200 9870 9000 4040 4041 4042

CMD ["/usr/sbin/sshd", "-D"]

ENV HDFS_NAMENODE_USER=hadoop \
    HDFS_DATANODE_USER=hadoop \
    HDFS_SECONDARYNAMENODE_USER=hadoop \
    HDFS_JOURNALNODE_USER=hadoop \
    HDFS_ZKFC_USER=hadoop \
    YARN_RESOURCEMANAGER_USER=hadoop \
    YARN_NODEMANAGER_USER=hadoop

COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]

