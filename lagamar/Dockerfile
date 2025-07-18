# Dockerfile do nó Submissor [lagamar]
# Nome: stellamaris
# Serviços: Spark Submit, Jupyter, Datanode
# Portas Expostas: 2222 (SSH), 8888 (Jupyter)
# Recursos Spark/Elasticsearch: Ambiente interativo para submissão de jobs Spark

FROM ubuntu:18.04

# Variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV SPARK_VERSION=3.0.1
ENV HADOOP_VERSION=3.3.6
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:/opt/spark/bin:/opt/hadoop/bin
ENV PYSPARK_PYTHON=python3.6
ENV ELASTIC_VERSION=8.1.3

# Instala dependências essenciais
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk wget curl ssh net-tools python3.6 python3-pip unzip gnupg netcat && \
    ln -sf /usr/bin/python3.6 /usr/bin/python && \
    ln -sf /usr/bin/python3.6 /usr/bin/python3 && \
    python3.6 -m pip install --upgrade pip && \
    pip install pyspark==3.0.1 jupyter

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

# Instala elasticsearch-hadoop jar compatível
RUN mkdir -p /opt/elasticsearch/lib && \
    wget https://repo1.maven.org/maven2/org/elasticsearch/elasticsearch-hadoop/${ELASTIC_VERSION}/elasticsearch-hadoop-${ELASTIC_VERSION}.jar -P /opt/elasticsearch/lib

# Copia configurações de Spark
COPY spark/spark-defaults.conf /opt/spark/conf/spark-defaults.conf

# Copia configurações do Hadoop
COPY hadoop/core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
COPY hadoop/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml

# Copiando codigo spark_pi
COPY spark_pi.py /root/spark_pi.py

# Configura SSH
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo 'root:01' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Expõe portas para SSH e Jupyter
EXPOSE 2222 8888

# Comando de entrada com Jupyter e SSH em paralelo
CMD service ssh start && jupyter notebook --ip=0.0.0.0 --port=8888 --NotebookApp.token='' --allow-root --no-browser
