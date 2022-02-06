import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
import seaborn as sns
import networkx as nx
from networkx.algorithms import bipartite
from sklearn.manifold import TSNE
import math
import xml.dom.minidom
import glob #library to read n files 
from itertools import zip_longest
import pickle
from IPython.display import display
import argparse


parser = argparse.ArgumentParser(description='Skill and Job Recommendation based on given Skill and/or Job')
parser.add_argument('-s','--skill', type=str, metavar='', help='Skill to base the recommendation on')
parser.add_argument('-j','--job', type=str, metavar='', help='Job to base the recommendation on')
args = parser.parse_args()


def nodes_connected(u, v):
    """
    Function that returns True when 2 nodes are directly connected (connected through an edge)
    Params
    ------
        u: node of a graph: node u
        v: node of a graph: node v
    """    
    return u in G.neighbors(v)

def list_inv_sort(l):
    """
    Return a sorting list based on the job date from the oldest to the newest
    
    Params
    ------
        :l: list : job transition of one resume
     """
    return(sorted(l,key=lambda l:l[0], reverse=True))

def jobs_catch(empl, d):
    """
    Return a list with all the founded jobs on the CV
    
    Params
    ------
        :empl: minidom object: all the "EmploymentItem" from the xml resume
        :d: dictionary : dictionary with job_id as a key and LB_QUALIFICATION
     """    
    j_list = [] # list of jobs, empty at the beginning, with all the jobs at the end.
    i = 0 # incremental value when a job is added in order to get a chronological order.
    last_j = '' # a string value to keep in memory the last job in order to don't add two times the same job.
    for e in empl: # loop which parse all EmploymentItem the to add each job to the j_list.
        if (e.getElementsByTagName("JobCode")[0].getAttribute('id')): #check if for the job "e", there is a JobCode. 
            if ((int(e.getElementsByTagName("JobCode")[0].attributes["id"].value) in d) and (last_j != ''.join(d[int(e.getElementsByTagName("JobCode")[0].attributes["id"].value)]))): #check if for the job "e", there is a JobCode and if the last added job is not the same that current job 
                if(e.getElementsByTagName("StartDate")[0].firstChild): #check if I can get start date for the job, if yes add it if not I am puting "-1" as you can see in the else.
                    j_list.append([i, e.getElementsByTagName("StartDate")[0].firstChild.data, ''.join(d[int(e.getElementsByTagName("JobCode")[0].attributes["id"].value)])])
                else:
                    j_list.append([i,-1,''.join(d[int(e.getElementsByTagName("JobCode")[0].attributes["id"].value)])])
                last_j = ''.join(d[int(e.getElementsByTagName("JobCode")[0].attributes["id"].value)]) #add the job to the last_j in order to keep it in memory.
                i = i + 1
    #bellow I check if there is a job in RecentEmploymentItem which is the actual job, if yes I add it.
    if (len(doc.getElementsByTagName("RecentEmploymentItem")) > 0 and (doc.getElementsByTagName("RecentEmploymentItem")[0].getElementsByTagName("FunctionCode")[0].getAttribute("id")) and (int(doc.getElementsByTagName("RecentEmploymentItem")[0].getElementsByTagName("FunctionCode")[0].attributes["id"].value) in d)):
        if (len(j_list) > 0 and (last_j != ''.join(d[int(doc.getElementsByTagName("RecentEmploymentItem")[0].getElementsByTagName("FunctionCode")[0].attributes["id"].value)]))):
            [[i,-1,''.join(d[int(doc.getElementsByTagName("RecentEmploymentItem")[0].getElementsByTagName("FunctionCode")[0].attributes["id"].value)])]] + j_list
            print()
    j_list = list_inv_sort(j_list) #here I inverse the list in order to get the oldest at the begining and the current at the end.
    return(j_list)

def sigmoid(x):
    """
    Returns sigmoid function of given parameter x
    """
    return 1 / (1 + math.exp(-x))
  
def gradient_wrt_skill(mini_batch_ss, mini_batch_js, skill_embedded, job_embedded, n_skills, k, regularization): 
    """
    Returns gradient of objective function with respect to skill embedded matrix

    Params
    ------
    mini_batch_ss: minibatch of skill-skill triplets
    mini_batch_js: minibatch of job-skill triplets
    skill_embedded: skill embedded matrix
    job_embedded: job embedded matrix
    n_skills: total number of skills in the analysis
    k: embedding dimension
    regularization: l2 regularization parameter
    """
    grad = 0
    
    #Objective skill-skill
    for triplet in mini_batch_ss:
        #Reading 3 elements of the triplet
        wx=skill_embedded[skills_dict[triplet[0]],:]
        wy=skill_embedded[skills_dict[triplet[1]],:]
        wz=skill_embedded[skills_dict[triplet[2]],:]
        #Defining Derivative of wx.wy w.r.t Skill Matrix
        deriv_wx_wy = np.zeros((n_skills,k))
        deriv_wx_wy[skills_dict[triplet[0]]]=wy
        deriv_wx_wy[skills_dict[triplet[1]]]=wx
        #Defining Derivative of wx.wz w.r.t Skill Matrix
        deriv_wx_wz = np.zeros((n_skills,k))
        deriv_wx_wz[skills_dict[triplet[0]]]=wz
        deriv_wx_wz[skills_dict[triplet[2]]]=wx
        #Computing dot product of elements
        Axy = np.dot(wx,wy)
        Axz = np.dot(wx,wz)
        #Computing the gradient
        grad_triplet = -((1/sigmoid(Axy-Axz))*(sigmoid(Axy-Axz))*(1-sigmoid(Axy-Axz))*(deriv_wx_wy-deriv_wx_wz))
        grad = grad + grad_triplet
    
    #Objective job-job
    #In this case, the gradient with respect to the skill matrix will be zero; therefore, we don't implement it.
    
    #Objective job-skill
    for triplet in mini_batch_js:
        #Reading 3 elements of the triplet
        wx=job_embedded[jobs_dict[triplet[0]],:]
        wy=skill_embedded[skills_dict[triplet[1]],:]
        wz=skill_embedded[skills_dict[triplet[2]],:]
        #Defining Derivative of wx.wy w.r.t Skill Matrix
        deriv_wx_wy = np.zeros((n_skills,k))
        deriv_wx_wy[skills_dict[triplet[1]]]=wx
        #Defining Derivative of wx.wz w.r.t Skill Matrix
        deriv_wx_wz = np.zeros((n_skills,k))
        deriv_wx_wz[skills_dict[triplet[2]]]=wx
        #Computing dot product of elements
        Axy = np.dot(wx,wy)
        Axz = np.dot(wx,wz)
        #Computing the gradient
        grad_triplet = -((1/sigmoid(Axy-Axz))*(sigmoid(Axy-Axz))*(1-sigmoid(Axy-Axz))*(deriv_wx_wy-deriv_wx_wz))
        grad = grad + grad_triplet        
            
    grad = grad + 2*regularization*skill_embedded
    
    return grad 
  
def gradient_wrt_job(mini_batch_jj, mini_batch_js, skill_embedded, job_embedded, n_jobs, k, regularization): 
    """
    Returns gradient of objective function with respect to job embedded matrix

    Params
    ------
    mini_batch_jj: minibatch of job-job triplets
    mini_batch_js: minibatch of job-skill triplets
    skill_embedded: skill embedded matrix
    job_embedded: job embedded matrix
    n_jobs: total number of jobs in the analysis
    k: embedding dimension
    regularization: l2 regularization parameter
    """        
    grad = 0
    
    #Objective job-job
    for triplet in mini_batch_jj:
        #Reading 3 elements of the triplet
        wx=job_embedded[jobs_dict[triplet[0]],:]
        wy=job_embedded[jobs_dict[triplet[1]],:]
        wz=job_embedded[jobs_dict[triplet[2]],:]
        #Defining Derivative of wx.wy w.r.t Job Matrix
        deriv_wx_wy = np.zeros((n_jobs,k))
        deriv_wx_wy[jobs_dict[triplet[0]]]=wy
        deriv_wx_wy[jobs_dict[triplet[1]]]=wx
        #Defining Derivative of wx.wz w.r.t Job Matrix
        deriv_wx_wz = np.zeros((n_jobs,k))
        deriv_wx_wz[jobs_dict[triplet[0]]]=wz
        deriv_wx_wz[jobs_dict[triplet[2]]]=wx
        #Computing dot product of elements
        Axy = np.dot(wx,wy)
        Axz = np.dot(wx,wz)
        #Computing the gradient
        grad_triplet = -((1/sigmoid(Axy-Axz))*(sigmoid(Axy-Axz))*(1-sigmoid(Axy-Axz))*(deriv_wx_wy-deriv_wx_wz))
        grad = grad + grad_triplet
    
    #Objective skill-skill
    #In this case, the gradient with respect to the skill matrix will be zero; therefore, we don't implement it.
    
    #Objective job-skill
    for triplet in mini_batch_js:
        #Reading 3 elements of the triplet
        wx=job_embedded[jobs_dict[triplet[0]],:]
        wy=skill_embedded[skills_dict[triplet[1]],:]
        wz=skill_embedded[skills_dict[triplet[2]],:]
        #Defining Derivative of wx.wy w.r.t Job Matrix
        deriv_wx_wy = np.zeros((n_jobs,k))
        deriv_wx_wy[jobs_dict[triplet[0]]]=wy
        #Defining Derivative of wx.wz w.r.t Job Matrix
        deriv_wx_wz = np.zeros((n_jobs,k))
        deriv_wx_wz[jobs_dict[triplet[0]]]=wz
        #Computing dot product of elements
        Axy = np.dot(wx,wy)
        Axz = np.dot(wx,wz)
        #Computing the gradient
        grad_triplet = -((1/sigmoid(Axy-Axz))*(sigmoid(Axy-Axz))*(1-sigmoid(Axy-Axz))*(deriv_wx_wy-deriv_wx_wz))
        grad = grad + grad_triplet      
    
    grad = grad + 2*regularization*job_embedded
    
    return grad     
    
def create_mini_batches(triplets, batch_size): 
    """
    Returns a list containing mini-batches based on the batch size

    Params
    ------
    triplets: triplets to create minibatches from
    batch_size: size of each minibatch
    """
    mini_batches = [] 
    np.random.shuffle(triplets) 
    n_minibatches = len(triplets) // batch_size 

    for i in range(n_minibatches+1): 
        mini_batch = triplets[i * batch_size:(i + 1)*batch_size] 
        if mini_batch != []:
            mini_batches.append(mini_batch)
        
    return mini_batches 
  
def gradientDescent(triplets_ss, triplets_jj, triplets_js, n_skills, n_jobs, k, learning_rate = 0.001, batch_size = 1000, regularization = 0.0001):
    """
    Returns skill and job embedded matrices after computing mini-batch gradient descent

    Params
    ------
    triplets_ss: Skill-skill triplets
    triplets_jj: Job-Job triplets
    triplets_js: Job-Skill triplets
    n_skills: Number of skills in the analysis
    n_jobs: Number of jobs in the analysis
    k: Embedding dimension
    learning_rate: Learning Rate to use in the gradient descent algorithm 
    batch_size: size of the mini-batches to use in the gradient descent algorithm 
    regularization: l2 regularization parameter to use in the gradient descent algorithm 
    """
    #Initialize the Skill and Job embedding matrices
    skill_embedded = np.random.normal(0, 0.1, (n_skills, k)) #Mean 0 and standard deviation of 0.1
    job_embedded = np.random.normal(0, 0.1, (n_jobs, k)) #Mean 0 and standard deviation of 0.1
    
    #1 epoch
    nbr_epochs = 1
    for itr in range(nbr_epochs): 
        mini_batches_ss = create_mini_batches(triplets_ss, batch_size)
        mini_batches_jj = create_mini_batches(triplets_jj, batch_size)
        mini_batches_js = create_mini_batches(triplets_js, batch_size)
        
        for mini_batch_ss, mini_batch_jj, mini_batch_js in zip_longest(mini_batches_ss, mini_batches_jj, mini_batches_js, fillvalue=[]): 
            skill_embedded = skill_embedded - learning_rate * gradient_wrt_skill(mini_batch_ss, mini_batch_js, skill_embedded, job_embedded, n_skills, k, regularization) 
            job_embedded = job_embedded     - learning_rate * gradient_wrt_job(mini_batch_jj, mini_batch_js, skill_embedded, job_embedded, n_jobs, k, regularization) 

    return skill_embedded, job_embedded

def calc_dist_2d(vector_x, vector_y):
    """
    Returns euclidean distance between points vector_x and vector_y in 2D space
    """
    return math.sqrt((vector_x[0]-vector_y[0])**2+(vector_x[1]-vector_y[1])**2)


def top_skill_recomm_euclid(skill_name):
    """
    Returns a DataFrame containing all distances from a given skill (skill_name) to the rest of skills in the 2D embedded space
    """
    skill_name_id = skills_dict[skill_name] #Getting the skill ID
    skill_distances = [] #Initializing distances list

    #Iterating though all skills in the embedded space
    for i in range(skills_2D.shape[0]):
        #Computing distance between the current skill in analysis vs the rest
        distance = calc_dist_2d(skills_2D[skill_name_id,:],skills_2D[i,:])
        skill_distances.append(distance)
    
    #Formatting output DataFrame with distances
    df_skill_dist = pd.DataFrame(skill_distances,columns=['Distance'])
    df_skill_index = df_skill_dist.reset_index()
    df_skill_dict = df_skill_index.replace({'index': skills_dict_inv})
    
    return df_skill_dict

def top_job_recomm_euclid(job_name):
    """
    Returns a DataFrame containing all distances from a given job (job_name) to the rest of jobs in the 2D embedded space
    """
    job_name_id = jobs_dict[job_name] #Getting the job ID
    job_distances = [] #Initializing distances list

    #Iterating though all jobs in the embedded space
    for i in range(jobs_2D.shape[0]):
        #Computing distance between the current job in analysis vs the rest
        distance = calc_dist_2d(jobs_2D[job_name_id,:],jobs_2D[i,:])
        job_distances.append(distance)
        
    #Formatting output DataFrame with distances
    df_job_dist = pd.DataFrame(job_distances,columns=['Distance'])
    df_job_index = df_job_dist.reset_index()
    df_job_dict = df_job_index.replace({'index': jobs_dict_inv})
    
    return df_job_dict

def top_job_skill_recomm_euclid(job_name):
    """
    #Returns a DataFrame containing all distances from a given job (job_name) to the skills in the 2D embedded space
    """
    job_name_id = jobs_dict[job_name] #Getting the job ID
    job_skill_distances = [] #Initializing distances list

    #Iterating though all skills in the embedded space
    for i in range(skills_2D.shape[0]):
        #Computing distance between the current job in analysis vs the skills
        distance = calc_dist_2d(jobs_2D[job_name_id,:],skills_2D[i,:])
        job_skill_distances.append(distance)
        
    #Formatting output DataFrame with distances
    df_job_skill_dist = pd.DataFrame(job_skill_distances,columns=['Distance'])
    df_job_skill_index = df_job_skill_dist.reset_index()
    df_job_skill_dict = df_job_skill_index.replace({'index': skills_dict_inv})
    
    return df_job_skill_dict


if __name__ == '__main__':
    if not (args.skill or args.job):
        parser.error('No action requested, add --skill or --job')

    print("")
    print("Running Recommendation System...")
    print("")

    print("STEP 1. SKILL CO-OCCURRENCE ANALYSIS\n")
    ###STEP 1. SKILL CO-OCCURRENCE ANALYSIS###

    #Path for the randstad skills cvs file
    path_randstad_skills = 'Data/randstad-skills.csv'

    #Import randstad-skills CSV file 
    df = pd.read_csv(path_randstad_skills)

    #Creating a list of skills separated by job
    list_skills=[]

    for region, df_region in df.groupby('LB_QUALIFICATION'):
        sub_lst=df_region['LB_SAVOIRFAIRE'].values.tolist()
        list_skills.append(sub_lst)

    #Creating a DataFrame where each row represents a Job and each column a Skill. Possible values are '0' (a skill
    #is not required by a job) and '1' (skill is required by that job)
    u = pd.get_dummies(pd.DataFrame(list_skills), prefix='', prefix_sep='').sum(level=0, axis=1)

    #Creating 'v': a new matrix of dimension (number_of_skills, number_of_skills) where each value tells us how many times
    #a given pair of skills (row, column) appeared on the same job
    v = u.T.dot(u)
    #Set 0 to lower triangular matrix (including diagonal) in order to not repeat a skill-pair in the analysis
    v.values[np.tril(np.ones(v.shape)).astype(np.bool)] = 0

    #Reshape (from column to index)
    skill_co = v.stack()

    #Filter only count > 0 (at least 1 co-occurrence)
    skill_co = skill_co[skill_co >= 1].rename_axis(('source', 'target')).reset_index(name='weight')

    #In addition, we limit the weight above 20 to get meaningful skill co-occurrence data
    skill_co_filter = skill_co[skill_co['weight']>20]

    #Creating skill co-occurrence graph
    G = nx.from_pandas_edgelist(skill_co_filter,edge_attr=True)

    #Formatting source and target skills for later union
    skill_source = skill_co_filter[['source']].rename(columns={'source': 'Skills'})
    skill_target = skill_co_filter[['target']].rename(columns={'target': 'Skills'})

    #Uniting all skills
    skills_full = skill_source.append(skill_target)

    #Creating a list of unique skills
    skills_distinct = list(set(skills_full['Skills']))


    triplets_ss=[] # Training Triplets Skills: (Node, Neighbor, Non-Neighbor)
    neighbors = [] # Neighbors of each node
    not_neighbors=[] # Non-Neighbors of each node

    #Iterating through all nodes
    for i in range(len(skills_distinct)):
        #Initializing neighbors and not neighbors lists for a particular skill
        neighbors_node=[]
        not_neighbors_node=[]
        #Iterating through all nodes
        for j in range(len(skills_distinct)):
            if j!=i: #A node cannot be a neighbor of itself
                if nodes_connected(skills_distinct[i],skills_distinct[j]):
                    neighbors_node.append(skills_distinct[j]) #Append neighbor
                else:
                    not_neighbors_node.append(skills_distinct[j]) #Append not neighbor
        #Save results into a unified list for all nodes
        neighbors.append(neighbors_node)
        not_neighbors.append(not_neighbors_node)       

    #Iterating to fill triplets    
    for k in range(len(skills_distinct)): 
        for m in range(len(neighbors[k])):
            for n in range(len(not_neighbors[k])):          
                triplets_ss.append([skills_distinct[k],neighbors[k][m],not_neighbors[k][n]])       

    #Computing number of skills in the analysis
    n_skills = len(skills_distinct)

    #We need to assign a number to each skill
    skills_ids = list(range(len(skills_distinct))) #List of skill IDs
    skills_dict = dict(zip(skills_distinct,skills_ids)) #Dictionary that relates each skill to its ID
    skills_dict_inv = dict(zip(skills_ids, skills_distinct)) #Dictionary with positions inversed

    print("STEP 2. JOB TRANSITION ANALYSIS\n")
    ###STEP 2. JOB TRANSITION ANALYSIS###

    #Path to correspondance_metiers_17042018.csv
    path_corres = 'Data/CVs/correspondance_metiers_17042018.csv'

    #Path to the resume from extractREC001
    path_cv = 'Data/CVs/extractREC001/*'

    #transformation of the correspondance_metiers_17042018.csv to a dataframe
    df_corres = pd.read_csv(path_corres, delimiter=";") 

    #keep only the two column cd_profession which is the textkernel job id and LB_QUALIFICATION the job in the Randstad referential.
    df_corres = df_corres[["cd_profession","LB_QUALIFICATION"]] 

    #Removing the duplicate because some job_id mean multiple LB_QUALIFICATION, so as Gauthier suggest me I took a random job.
    df_corres = df_corres.drop_duplicates() 

    #Removing the na in order to get a job_id with his corresponding LB_QUALIFICATION.
    df_corres = df_corres.dropna() 

    #Building a dictionary with job_id as a key and LB_QUALIFICATION the value based on the df_corres.
    corres_dict = dict([(i,[a]) for i, a in zip(df_corres.cd_profession, df_corres.LB_QUALIFICATION)]) 

    list_jobs = [] #It is the list with all the sublist of transition job.
    for f in glob.glob(path_cv): #Loop which parse all the resume
        doc = xml.dom.minidom.parse(f)
        if (len(doc.getElementsByTagName("EmploymentItem")) > 1): #I check if there is more than one job on the CV, because with one job I can't get any transition.
            l = jobs_catch(doc.getElementsByTagName("EmploymentItem"),corres_dict) #Here I catch all the job from the cv f.
            if (len(l) > 1): #Before to add it in the final list I check that I got more than one different job from the resume
                list_jobs = list_jobs + [[x[2] for x in l]]

    #Creating a DataFrame where each row represents a CV (person) and each column a Job. Possible values are '0' (the person
    #never held that position) and '1' (the person worked in that position at some point)
    u = pd.get_dummies(pd.DataFrame(list_jobs), prefix='', prefix_sep='').sum(level=0, axis=1)

    #Creating 'v': a new matrix of dimension (number_of_jobs, number_of_jobs) where each value tells us how many times
    #a given pair of jobs (row, column) were held by a person
    v = u.T.dot(u)
    #Set 0 to lower triangular matrix (including diagonal) in order to not repeat a job-pair in the analysis
    v.values[np.tril(np.ones(v.shape)).astype(np.bool)] = 0

    #Reshape (from column to index)
    job_co = v.stack()

    #Filter only count > 0 (at least 1 transition ocurred for a particular source and target)
    job_co = job_co[job_co >= 1].rename_axis(('source', 'target')).reset_index(name='weight')

    #In addition, we limit the weight above 0 to get meaningful job transition data
    job_co_filter = job_co[job_co['weight']>0]

    #Creating job transition graph
    G = nx.from_pandas_edgelist(job_co_filter,edge_attr=True)

    #Formatting source and target jobs for later union
    job_source = job_co_filter[['source']].rename(columns={'source': 'Jobs'})
    job_target = job_co_filter[['target']].rename(columns={'target': 'Jobs'})

    #Uniting all jobs
    jobs_full = job_source.append(job_target)

    #Creating a list of unique jobs
    jobs_distinct = list(set(jobs_full['Jobs']))

    triplets_jj=[] # Training Triplets Jobs: (Node, Neighbor, Non-Neighbor)
    neighbors = [] # Neighbors of each node
    not_neighbors=[] # Non-Neighbors of each node
        
    #Iterating through all nodes
    for i in range(len(jobs_distinct)):
        #Initializing neighbors and not neighbors lists for a particular job
        neighbors_node=[]
        not_neighbors_node=[]
        #Iterating through all nodes
        for j in range(len(jobs_distinct)):
            if j!=i: #A node cannot be a neighbor of itself
                if nodes_connected(jobs_distinct[i],jobs_distinct[j]):
                    neighbors_node.append(jobs_distinct[j]) #Append neighbor
                else:
                    not_neighbors_node.append(jobs_distinct[j]) #Append not neighbor
        #Save results into a unified list for all nodes
        neighbors.append(neighbors_node)
        not_neighbors.append(not_neighbors_node)       

    #Iterating to fill triplets
    for k in range(len(jobs_distinct)): 
        for m in range(len(neighbors[k])):
            for n in range(len(not_neighbors[k])):          
                triplets_jj.append([jobs_distinct[k],neighbors[k][m],not_neighbors[k][n]])       

    #Computing number of jobs in the analysis
    n_jobs = len(jobs_distinct)

    #We need to assign a number to each job
    jobs_ids = list(range(len(jobs_distinct))) #List of job IDs
    jobs_dict = dict(zip(jobs_distinct,jobs_ids)) #Dictionary that relates each job to its ID
    jobs_dict_inv = dict(zip(jobs_ids, jobs_distinct)) #Dictionary with positions inversed

    print("STEP 3. JOB-SKILL ANALYSIS\n")
    ###STEP 3. JOB-SKILL ANALYSIS###

    #Saving skills used in the skill-skill analysis into a DataFrame
    skills_distinct_df = pd.DataFrame(skills_distinct,columns=['LB_SAVOIRFAIRE'])

    #Saving jobs used in the job-job analysis into a DataFrame
    jobs_distinct_df = pd.DataFrame(jobs_distinct,columns=['LB_QUALIFICATION'])

    #Filtering only the skills used in the skill-skill analysis
    df_skill_filter = df.merge(skills_distinct_df,how='inner',on=['LB_SAVOIRFAIRE'])

    #Filtering only the jobs used in the job-job analysis
    df_job_skill_filter = df_skill_filter.merge(jobs_distinct_df,how='inner',on=['LB_QUALIFICATION'])

    #Building a dataframe with all the job with them list of skills
    df_agg = df_job_skill_filter.groupby('LB_QUALIFICATION').agg({'LB_SAVOIRFAIRE':lambda x: list(x)}).reset_index() 

    #List of jobs
    list_jobs_js = df_agg['LB_QUALIFICATION'].values.tolist()

    #Building a list of skills in which each element (sublist) contains all skills of each job
    new_skills_list = df_agg['LB_SAVOIRFAIRE'].values.tolist()

    #Building a list with all the skills.
    total_skills_list = df_job_skill_filter["LB_SAVOIRFAIRE"].drop_duplicates().values.tolist()

    #Creating triplets Job-Skill (job, skill_of_job, not_skill_of_job)
    triplets_js = []
    for job in range(len(list_jobs_js)):
        for skill in range(len(new_skills_list[job])):
            l = list(set(total_skills_list) - set(new_skills_list[job]))
            for k in range(len(l)):
                triplets_js.append([list_jobs_js[job], new_skills_list[job][skill], l[k]])

    print("STEP 4. MINI-BATCH GRADIENT DESCENT ALGORITHM\n")
    ###STEP 4. MINI-BATCH GRADIENT DESCENT ALGORITHM###

    #Executing Mini-Batch Gradient Descent with an embedded space of dimension 40, learning rate of 0.001, batch size of 1000 and regularization factor of 0.0001
    skill_embedded, job_embedded = gradientDescent(triplets_ss, triplets_jj, triplets_js, n_skills, n_jobs, k=40) 

    print("STEP 5. DIMENSIONALITY REDUCTION\n")
    ###STEP 5. DIMENSIONALITY REDUCTION###

    #Concatenating for laterapplying dimensionality reduction to both
    skill_job_embedded = np.concatenate((skill_embedded,job_embedded),axis=0)
    #Using TSNE for non-linear dimensionality reduction
    embedding = TSNE(n_components=2)
    skill_job_2D = embedding.fit_transform(skill_job_embedded)
    #Separating back Job and Skill matrices
    skills_2D = skill_job_2D[:n_skills,:]
    jobs_2D = skill_job_2D[n_skills:,:]

    print("STEP 6. RECOMMENDATION\n")
    ###STEP 6. RECOMMENDATION###

    if args.skill:
        #Computing distances from a given skill to the rest of skills in the 2D embedded space
        df_skill_distances = top_skill_recomm_euclid(args.skill)        
        print("For Skill:",args.skill)
        print("Top 20 Skill Recommendation:")
        #Displaying results
        #Top 20 skill recommendation based on Skill
        nbr_top_skills = 21
        with pd.option_context('display.max_rows', nbr_top_skills, 'display.max_colwidth', None):
            display(df_skill_distances.sort_values(by='Distance').head(nbr_top_skills)[1:])
        print("")

    if args.job:
        #Computing distances from a given job to the rest of jobs in the 2D embedded space
        df_job_distances = top_job_recomm_euclid(args.job)
        print("For Job:",args.job)
        print("Top 20 Job Recommendation:")
        #Displaying results
        #Top 20 job recommendation based on Job
        nbr_top_jobs = 21
        with pd.option_context('display.max_rows', nbr_top_jobs, 'display.max_colwidth', None):
            display(df_job_distances.sort_values(by='Distance').head(nbr_top_jobs)[1:])
        print("")
        print("For Job:",args.job)
        print("Top 20 Skill Recommendation:")    
        #Computing distances from a given job to the skills in the 2D embedded space
        df_job_skill_distances = top_job_skill_recomm_euclid(args.job)
        #Displaying results
        #Top 20 skill recommendation based on Job
        nbr_top_job_skills = 21
        with pd.option_context('display.max_rows', nbr_top_job_skills, 'display.max_colwidth', None):
            display(df_job_skill_distances.sort_values(by='Distance').head(nbr_top_job_skills)[1:])        
        print("")
