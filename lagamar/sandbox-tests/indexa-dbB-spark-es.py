from pyspark.sql import SparkSession

# Aqui a gente cria a sessão do Spark e já passa as configurações necessárias
# pra conectar no Elasticsearch. A ideia é que o Spark saiba onde está o ES
# e como enviar os dados pra lá.
spark = SparkSession.builder \
    .appName("IndexDatabaseB") \
    .config("spark.jars.packages", "org.elasticsearch:elasticsearch-spark-30_2.12:8.1.3") \
    .config("spark.es.nodes", "barravento") \
    .config("spark.es.port", "9200") \
    .config("spark.es.nodes.wan.only", "false") \
    .config("spark.es.resource", "dbb") \
    .getOrCreate()

# Aqui a gente lê o CSV que está lá no HDFS. Ele precisa estar no caminho certinho,
# e a opção header=True é pra garantir que ele leia os nomes das colunas certinho.
df = spark.read.option("header", True).csv("hdfs://barravento:9000/sandbox/02-databaseB.csv")

# Isso aqui mostra o esquema da tabela que o Spark entendeu.
# É uma boa pra confirmar se os dados foram lidos da forma certa.
df.printSchema()

# Agora vem a parte que realmente envia os dados pro Elasticsearch.
# A gente escolhe o formato específico do ES e aponta pro índice "databaseb".
# O modo overwrite apaga tudo que estiver lá antes — cuidado com isso!
df.write \
    .format("org.elasticsearch.spark.sql") \
    .option("es.resource", "dbb") \
    .mode("overwrite") \
    .save()

# Por fim, a gente fecha a sessão do Spark pra liberar os recursos.
spark.stop()
