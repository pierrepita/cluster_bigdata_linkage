# Dockerfile do nó Worker 2 [stellamaris]
# Nome: stellamaris
# Serviços: Spark Worker, Datanode, Elasticsearch Worker
# Portas Expostas: 8082
# Recursos Spark/Elasticsearch: 2 executores, 2 núcleos cada, 1GB RAM
FROM ubuntu:20.04

# Variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV SPARK_VERSION=3.0.1
ENV HADOOP_VERSION=3.3.6
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$PATH:/opt/spark/bin:/opt/hadoop/bin
ENV PYSPARK_PYTHON=python3
ENV ELASTIC_VERSION=8.1.3

# Instala dependências básicas, Java, Python 3.6, pip, e ferramentas auxiliares
RUN apt-get update && \
    apt-get install -y software-properties-common git p7zip-full nano openjdk-11-jdk wget curl ssh net-tools python3 python3-pip unzip gnupg netcat && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/python3 /usr/bin/python3 && \
    python3 -m pip install --upgrade pip && \
    pip3 install pyspark==3.0.1

# Copiando o arquivo que orienta quais pacotes python devem ser instalados
COPY requirements_python.txt /root/requirements_python.txt
RUN pip3 install --no-cache-dir -r /root/requirements_python.txt

# Instala Spark
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3.2 /opt/spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.2.tgz

COPY spark/spark-env.sh /opt/spark/conf/spark-env.sh
RUN chmod +x /opt/spark/conf/spark-env.sh

# Instala Hadoop
## É necessário criar um usuário hadoop para iniciar o hadoop
RUN groupadd -g 2000 hadoop && useradd -u 2000 -g hadoop -m hadoop

RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /opt/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# Instala Elasticsearch
## O ES demanda instalação 17 do Java
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk
## É necessário criar um usuário elastic para iniciar o elastic
RUN groupadd -g 1000 elastic && useradd -u 1000 -g elastic -m elastic
# Elasticsearch
RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz && \
    tar -xzf elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz && \
    mv elasticsearch-${ELASTIC_VERSION} /opt/elasticsearch && \
    rm elasticsearch-${ELASTIC_VERSION}-linux-x86_64.tar.gz

COPY elasticsearch/elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml
COPY elasticsearch/jvm.options /opt/elasticsearch/config/jvm.options

# Baixando o conector elasticsearch-hadoop para que o Spark possa interagir corretamente com o Elasticsearch
# Isso deve permitir um melhor controle de versão local. 
RUN wget https://repo1.maven.org/maven2/org/elasticsearch/elasticsearch-hadoop/${ELASTIC_VERSION}/elasticsearch-hadoop-${ELASTIC_VERSION}.jar -o /opt/spark/jars/elasticsearch-hadoop-${ELASTIC_VERSION}.jar

# Configura memória para Elasticsearch
RUN echo "-Xms1g\n-Xmx1g" > /opt/elasticsearch/config/jvm.options.d/memory.options

# Configura Elasticsearch como nó worker
COPY elasticsearch/elasticsearch.yml /opt/elasticsearch/config/elasticsearch.yml

# Baixando o conector elasticsearch-hadoop para que o Spark possa interagir corretamente com o Elasticsearch
# Isso deve permitir um melhor controle de versão local. 
RUN wget https://repo1.maven.org/maven2/org/elasticsearch/elasticsearch-hadoop/${ELASTIC_VERSION}/elasticsearch-hadoop-${ELASTIC_VERSION}.jar -o /opt/spark/jars/elasticsearch-hadoop-${ELASTIC_VERSION}.jar

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
