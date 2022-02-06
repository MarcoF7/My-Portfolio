import sys
import os
from pyspark import SparkContext, SparkConf

# Spark Implementation ---------------------------------------

def degree_graph(theText_file):
    degree_graph = theText_file           \
       .map(lambda line: line.split(",")) \
       .map(lambda x: len(x[1:]))

    print("Max Degree = ",degree_graph.max())
    print("Min Degree = ",degree_graph.min())
    print("Avg Degree = ",degree_graph.sum()/degree_graph.count())

# Main code -------------------------------------------
# - generate the input and output file names
#   Set the input and output paths with your namenode (sar01 or sar17)
#   and your account
#     ex: input_path = "hdfs://sarZZ:9000/data/temperatures/"
#     ex: output_path = "hdfs://sarZZ:9000/cpuXXX/cpuXXX_YY/" 
input_path = "hdfs://sar01:9000/data/sn/"
output_path = "hdfs://sar01:9000/cpupsmia1/cpupsmia1_10/"
file_name = os.path.basename(sys.argv[1])
input_file_name = input_path + file_name
output_file_name = output_path + os.path.splitext(file_name)[0]+".out"

# - create the Spark context and open the input file as a RDD (in the HDFS)
sc = SparkContext()
text_file = sc.textFile(input_file_name)

# - run the Spark code and save the resulting RDD (in the HDFS)
degree_graph(text_file)
#degree_graph.saveAsTextFile(output_file_name)

