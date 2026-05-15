# Dockerfile do nó Submissor [lagamar]
# Nome: stellamaris
# Serviços: Spark Submit, Jupyter, Datanode
# Portas Expostas: 2222 (SSH), 8888 (Jupyter)
# Recursos Spark/Elasticsearch: Ambiente interativo para submissão de jobs Spark
FROM ubuntu:22.04

# Variáveis de ambiente
ENV DEBIAN_FRONTEND=noninteractive
ENV SPARK_VERSION=3.5.3
ENV HADOOP_VERSION=3.3.6
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:/opt/spark/bin:/opt/hadoop/bin
ENV PYSPARK_PYTHON=python3
ENV ELASTIC_VERSION=7.15.2

# Instala dependências essenciais
RUN apt-get update && \
    apt-get install -y software-properties-common git p7zip-full nano openjdk-17-jdk openjdk-11-jdk wget curl rsync inetutils-ping ssh net-tools python3 python3-pip unzip gnupg netcat-openbsd gdal-bin libgdal-dev build-essential cmake pkg-config rustc cargo && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    pip3 install pyspark==3.5.3 jupyter

# Copiando o arquivo que orienta quais pacotes python devem ser instalados
ENV GDAL_CONFIG=/usr/bin/gdal-config
COPY requirements_python.txt /root/requirements_python.txt
RUN pip3 install --ignore-installed --no-cache-dir -r /root/requirements_python.txt

# Instala Spark
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3 /opt/spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

COPY spark/spark-env.sh /opt/spark/conf/spark-env.sh
RUN chmod +x /opt/spark/conf/spark-env.sh

# Instala Hadoop
## É necessário criar um usuário hadoop para iniciar o hadoop
RUN groupadd -g 5000 hadoop && useradd -u 5000 -g hadoop -m hadoop
RUN groupadd -g 5001 elastic && useradd -u 5001 -g elastic -m elastic

RUN wget https://downloads.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz && \
    tar -xzf hadoop-${HADOOP_VERSION}.tar.gz && \
    mv hadoop-${HADOOP_VERSION} /opt/hadoop && \
    rm hadoop-${HADOOP_VERSION}.tar.gz

# Instala elasticsearch-hadoop jar compatível
RUN mkdir -p /opt/elasticsearch/lib && \
    wget https://repo1.maven.org/maven2/org/elasticsearch/elasticsearch-hadoop/${ELASTIC_VERSION}/elasticsearch-hadoop-${ELASTIC_VERSION}.jar -P /opt/elasticsearch/lib

# Baixando o conector elasticsearch-hadoop para que o Spark possa interagir corretamente com o Elasticsearch
# Isso deve permitir um melhor controle de versão local. 
RUN wget https://repo1.maven.org/maven2/org/elasticsearch/elasticsearch-hadoop/${ELASTIC_VERSION}/elasticsearch-hadoop-${ELASTIC_VERSION}.jar -O /opt/spark/jars/elasticsearch-hadoop-${ELASTIC_VERSION}.jar

# Copia configurações de Spark
COPY spark/spark-defaults.conf /opt/spark/conf/spark-defaults.conf

# Copia configurações do Hadoop
COPY hadoop/core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
COPY hadoop/hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml

# Copiando codigo spark_pi
COPY sandbox-tests/spark_pi.py /root/sandbox-tests/spark_pi.py

# Configura SSH
RUN apt-get install -y openssh-server && \
    mkdir -p /var/run/sshd && \
    echo 'root:01' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Materiais necessários para os testes da infra
# RUN mkdir /root/sandbox-tests
COPY sandbox-tests/01-databaseA.csv /root/sandbox-tests/01-databaseA.csv
COPY sandbox-tests/02-databaseB.csv /root/sandbox-tests/02-databaseB.csv
COPY sandbox-tests/indexa-dbB-spark-es.py /root/sandbox-tests/indexa-dbB-spark-es.py
COPY sandbox-tests/consulta-es.json /root/sandbox-tests/consulta-es.json
COPY sandbox-tests/indexa-dbB-spark-es.ipynb /root/sandbox-tests/indexa-dbB-spark-es.ipynb

# Copia .bashrc com variaveis de ambiente para forçar a definição delas
COPY .bashrc /root/.bashrc
RUN chmod 644 /root/.bashrc

# Criando pasta .ssh para permitir copia de chaves ssh github
RUN mkdir -p /root/.ssh

# Expõe portas para SSH e Jupyter
EXPOSE 2222 8888 4040 4041 4042

# Comando de entrada com Jupyter e SSH em paralelo
CMD service ssh start && jupyter notebook --ip=0.0.0.0 --port=8888 --allow-root --NotebookApp.token='' --no-browser --notebook-dir=/root
