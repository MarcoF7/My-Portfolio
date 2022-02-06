import sys
import os
from pyspark import SparkContext, SparkConf

# Spark Implementation ---------------------------------------

def list_common_friends(x):
	person_friends = []
	for v1 in x[1:]:
		for v2 in x[1:]:
			if v1<v2:
				person_friends.append(((v1,v2),x[0]))
	return person_friends

def common_friends(theText_file):
    common_friends = theText_file           \
       .map(lambda line: line.split(",")) \
       .flatMap(list_common_friends) \
       .reduceByKey(lambda x, y: x+y) 

    print("Number of Rows = ",common_friends.count())
    return common_friends

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
common_friends = common_friends(text_file)
common_friends.saveAsTextFile(output_file_name)

