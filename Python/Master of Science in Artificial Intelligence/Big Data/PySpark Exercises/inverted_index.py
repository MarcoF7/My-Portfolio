import sys
import os
from pyspark import SparkContext, SparkConf
import re

# Remove terms not matching the regex (non letters terms) -----------------------
regex = re.compile('[^a-zA-Z ]')  # regular expression matching (good) words

def remove_non_letters(word):
    return regex.sub('', word)

# Search files containing a word in the inverted index --------------------------
def lookup(iindex, word):
    ld = iindex.lookup(word)
    if len(ld) > 0:
        print("The following documents contain the word '",word,"'")
        for d in sorted(ld[0]):
            print(os.path.relpath(d[5:], os.getcwd()))
    else:
        print("No documents contain the word '",word,"'")

# MapReduce code ---------------------------------------------------
def inverted_index(the_FileCollection, stopwords_list):
    output = the_FileCollection \
                .flatMap(lambda file:[(file[0], word) for word in file[1].lower().split()]) \
                .mapValues(remove_non_letters) \
                .filter(lambda file: len(file[1]) > 0) \
                .filter(lambda file: file[1] not in stopwords_list) \
                .distinct() \
                .map(lambda file: (file[1], [file[0]])) \
                .reduceByKey(lambda x, y: x+y)
    return output

# Main code ---------------------------------------------------------------------
# - generate the input and output file names (TO COMPLETE)
#   Set the input and output paths with your namenode (sar01 or sar17)
#   and your account
#     ex: input_file_names = "hdfs://sar01:9000/data/bbc/*"
#     ex: output_path = "hdfs://sar01:9000/cpuXXX1/cpuXXX1_1/"
input_file_names = "hdfs://sar01:9000/data/bbc/*"
output_path = "hdfs://sar01:9000/cpupsmia1/cpupsmia1_10/"
output_file_name = output_path + "bbc.out"
stopwords_file_name = "hdfs://sar01:9000/data/stopwords.txt"

# - create the Spark context
sc = SparkContext()

# - read the input files (in the HDFS)
#   ########################  GOOD TO KNOW  ########################
#   The Spark function wholeTextFiles loads into a RDD the content 
#   of the text files contained in the given directory.
#   Each item of the RDD is a pair (f, content), where f is the name 
#   of a file and content is the content of the file.
#   ################################################################
file_collection = sc.wholeTextFiles(input_file_names)

# - read the list of words not to index (each user can have its own list)
stopwords_list = sc.textFile(stopwords_file_name).collect()

# - create the invertex index
iindex = inverted_index(file_collection, stopwords_list)

# - save the results (in the HDFS)
iindex.saveAsTextFile(output_file_name)
