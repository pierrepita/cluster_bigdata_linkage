# SPARK_HOME/conf/spark-env.sh
# Sobre o master
export SPARK_MASTER_HOST=barravento
export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=8080

# Sobre o java/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export PATH=$PATH:$SPARK_HOME/bin:$HADOOP_HOME/bin:$JAVA_HOME/bin

# Ajustes gerais
export SPARK_LOG_DIR=/opt/spark/logs
export SPARK_LOCAL_DIRS=/opt/spark/tmp

export PYSPARK_SUBMIT_ARGS='--master spark://barravento:7077 --packages org.elasticsearch:elasticsearch-spark-30_2.12:8.1.3 pyspark-shell'
# Opcional para debugging
export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=FILESYSTEM -Dspark.deploy.recoveryDirectory=/opt/spark/recovery"

