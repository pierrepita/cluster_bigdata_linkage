#!/bin/bash
# A ideia aqui é incluir o caminho do java no script de inicialização do hadoop, evitando o erro:
# "2.010 ERROR: JAVA_HOME is not set and could not be found."
HADOOP_HOME=/opt/hadoop
sed -i '2i export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' /opt/hadoop/sbin/start-dfs.sh
echo "start-dfs.sh conhece o java-home"
