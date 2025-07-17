from pyspark.sql import SparkSession
import random

spark = SparkSession.builder.appName("PySparkPi").getOrCreate()
sc = spark.sparkContext

def inside(_):
    x, y = random.random(), random.random()
    return x * x + y * y < 1

NUM_SAMPLES = 100000
count = sc.parallelize(range(0, NUM_SAMPLES)).filter(inside).count()
pi = 4.0 * count / NUM_SAMPLES

print(f"Pi is roughly {pi}")
spark.stop()
