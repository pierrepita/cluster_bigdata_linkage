FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
# Instala dependências: SSH, Java, Python 3.6 e utilitários comuns
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
# Instala dependências: SSH, Java, Python 3.6 e utilitários comuns
    apt-get install -y \
        openssh-server \
        openjdk-11-jdk \
        curl wget unzip \
        python3.6 \
        python3.6-venv \
        python3.6-distutils \
        python3-pip && \
    ln -sf /usr/bin/python3.6 /usr/bin/python && \
    ln -sf /usr/bin/python3.6 /usr/bin/python3 && \
    python3.6 -m pip install --upgrade pip && \
    python3.6 -m pip install pyspark==3.0.1 && \
# Cria o diretório usado pelo daemon SSH
    mkdir /var/run/sshd && \
# Define a senha root para SSH
RUN echo 'root:bdlinkage' | chpasswd
# Permite login direto como root via SSH
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

ENV SPARK_VERSION=3.0.1

# Baixa e descompacta o Apache Spark 3.0.1
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop3.2.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop3.2 /opt/spark && \
# Cria links simbólicos para comandos do Spark no PATH global
    ln -sf /opt/spark/bin/* /usr/local/bin/ && \
    rm spark-${SPARK_VERSION}-bin-hadoop3.2.tgz

ENV SPARK_HOME=/opt/spark
ENV PATH="$SPARK_HOME/bin:$PATH"
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

COPY authorized_keys /root/.ssh/authorized_keys
COPY spark_pi.py /root/spark_pi.py

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

