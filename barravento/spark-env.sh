# SPARK_HOME/conf/spark-env.sh
export SPARK_MASTER_HOST=barravento
export SPARK_WORKER_CORES=2
export SPARK_WORKER_MEMORY=1g
export SPARK_DRIVER_MEMORY=5g
export SPARK_DRIVER_CORES=2

export SPARK_LOG_DIR=/opt/spark/logs
export SPARK_LOCAL_DIRS=/opt/spark/tmp

export PYSPARK_SUBMIT_ARGS='--master spark://barravento:7077 --packages org.elasticsearch:elasticsearch-spark-30_2.12:8.1.3 pyspark-shell'
# Opcional para debugging
export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=FILESYSTEM -Dspark.deploy.recoveryDirectory=/opt/spark/recovery"

