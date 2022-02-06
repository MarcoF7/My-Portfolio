import pandas as pd
import numpy as np
import re
#from bs4 import BeautifulSoup
import os
import time
import random
import argparse
import yaml
import sys
import tqdm
import cv2
import urllib
from PIL import Image
import imagehash
import image_utils

import warnings
warnings.filterwarnings('ignore')
from skimage.measure import compare_ssim
from skimage.transform import resize
from scipy.stats import wasserstein_distance

#import ssl
#ssl._create_default_https_context = ssl._create_unverified_context
import utils

class IMAGES_URLS_EXTRACTOR():
    def __init__(self, config_path, domain, brand, folder, show_browser, campaign_img_path):
        self.domain = domain
        self.brand = brand

        #resize img parameters
        self.width = 1024
        self.height = 1024

        if campaign_img_path is None:
            self.campaign_img_path = 'campaign_imgs'
        else:
            self.campaign_img_path = campaign_img_path
        #read config
        try:
            with open(config_path, 'r', encoding='utf-8') as file:
                self.config = yaml.safe_load(file)
        except Exception as e:
            print("Error obtained when opening config file:", e)
            sys.exit(1)

        self.create_filepath(folder)
        #read previous result file
        try:
            self.df = pd.read_excel(os.path.join(self.fpath, 'result_campaign_similarity' +'.xlsx'))
            print('Previous file found, adding next results to this file.')
        except:
            self.df = pd.DataFrame(columns=['domain', 'page_type', 'url', 'image_url', 'size_wh_image_url', 'brand', 'sift_similarity', 'nb_matches', 'diff_corners', 'matching', 'campaign_img_name', 'size_wh_campaign_img']) # 'structural_sim', 'pixel_sim', 'emd', 'phash', 'dhash', 'chash', 'ahash',
            print('No previous file found, creating a new one.')

        self.initialize_parameters()

        #launch driver
        self.driver = utils.launch_driver(show_browser=show_browser)

    def initialize_parameters(self):
        self.brands_list = []
        if self.brand is not None:
            self.brands_list = ['general', self.brand]
        else:
            for domain, brand_urls_dict in self.config.items():
                for brand, urls in brand_urls_dict.items():
                    if brand not in self.brands_list:
                        self.brands_list += [brand]

        if self.domain is not None:
            self.domains_list = [self.domain]
        else:
            self.domains_list = list(self.config.keys())

        dom_brands = {}
        for domain in self.domains_list:
            for brand in self.brands_list:
                processed = self.df[(self.df['domain']==domain)&(self.df['brand']==brand)]
                if len(processed) == 0 and brand in self.config[domain]:
                    if domain in dom_brands.keys():
                        dom_brands[domain] += [brand]
                    else:
                        dom_brands[domain] = [brand]
        self.dom_brands = dom_brands

    def create_filepath(self, folder):
        if folder is None:
            self.fpath = os.path.join('', 'results')
            if 'results' not in os.listdir(folder):
                os.mkdir(self.fpath)
        else:
            self.fpath = folder

    def extract_images_urls(self, domain, url):
        try:
            rows_list = []

            #GO TO URL AND WAIT PAGE LOADING
            self.driver.get(url)
            #self.driver.refresh()
            self.driver.implicitly_wait(10)

            start = utils.extract_start(self.driver, None)
    
            images_format = ['.png', '.jpeg', '.jpg', '.gif', '.webp', 'background-image']
            regexp = '|'.join(images_format)
    
            attributes_list=['@src', '@src-set', '@data-src', '@data-srcset', '@style']
            attr_to_search = (" or ").join(attributes_list)

            #extract body or full page otherwise with specifc locations to find images urls
            try:
                elems = self.driver.find_elements_by_xpath("//body//*" + "[" + str(attr_to_search) + "]")
            except:
                try:
                    elems = self.driver.find_elements_by_xpath("//*" + "[" + str(attr_to_search) + "]")
                except:
                    elems = []

            for e in tqdm.tqdm(elems):
                for a in attributes_list:
                    try:
                        img_url = e.get_attribute(a[1:])
                        #e.value_of_css_property('background-image')
                        #e.get_attribute('innerHTML')
                        if img_url is not None and img_url!="":
                            match = re.findall(str(regexp), img_url)
                            if len(match)>0:
                                rows_list.append({
                                    "image_url": img_url,
                                    "domain": domain,
                                    "url": url
                                })
                    except:
                        pass

            df = pd.DataFrame(rows_list)
            df['image_url'] = df["image_url"].apply(lambda x : self.clean_image_url(x, domain, start))
            df.drop_duplicates(subset=['image_url', 'domain'], inplace=True)
            return df

        except Exception as e:
            #print(e)
            return pd.DataFrame()

    def clean_image_url(self, img_url, domain, start):
        try:
            if "background-image" in img_url:
                img_url = re.sub('^.*background-image: url\("', '', img_url)
                img_url = re.sub('"\).*$', '', img_url)
                img_url = img_url.strip()
            
            img_url = utils.format_url(domain, img_url, start)
        
            return img_url
        except Exception as e:
            #print(e)
            return img_url

    def load_img_from_path(self, path):
        # Reading the downloaded campaign image
        img_array = cv2.imread(path)
        return img_array

    def transform_img_array(self, img_array, norm_size=True, norm_exposure=False):
        # transform into grey 2D array
        img_array = cv2.cvtColor(img_array, cv2.COLOR_BGR2GRAY).astype(int)
        # resizing returns float vals 0:255; convert to ints for downstream tasks
        if norm_size:
            img_array = resize(img_array, (self.height, self.width), anti_aliasing=True, preserve_range=True)
        if norm_exposure:
            img_array = self.normalize_exposure(img_array)
        return img_array


    def load_img_from_url(self, url):
        try:
            #Reading the item image from the website URL
            req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            webpage_img = urllib.request.urlopen(req).read()
            arr = np.asarray(bytearray(webpage_img), dtype=np.uint8)
            img = cv2.imdecode(arr, -1) # 'Load it as it is'
            img_exist = 1
            #Getting size of website image (Width x Height)
            size_img = list(img.shape[0:2])[::-1]            
        except:
            #In case the given URL is not readable
            img = None
            img_exist = 0
            size_img = None

        return img, img_exist, size_img

    def sift_sim(self, img_a, img_b):
        try:
            # initialize the sift feature detector
            orb = cv2.ORB_create(nfeatures=2000, scaleFactor = 2, nlevels = 2, firstLevel = 0, edgeThreshold = 0, WTA_K = 2, patchSize = 31)

            # find the keypoints and descriptors with SIFT
            kp_a, desc_a = orb.detectAndCompute(img_a, None)
            kp_b, desc_b = orb.detectAndCompute(img_b, None)

            # initialize the bruteforce matcher
            bf = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True) #cv2.NORM_HAMMING

            # match.distance is a float between {0:100} - lower means more similar
            matches = bf.match(desc_a, desc_b)
            nb_matches = len(matches)
            similar_regions = [i for i in matches if i.distance < 50]
            if len(matches) == 0:
                return 0, nb_matches

            score = round(len(similar_regions) / len(matches), 3)
            return score, nb_matches
        except:
            return None, None

    def similarity_campaign_scoring(self, df_imgs):
        """Function to compute the similarity index based on a dataframe of items URLs
        and the campaign images given by a path"""
        #Initializing the output file
        similarity_results = pd.DataFrame(columns=['domain', 'page_type', 'url', 'image_url', 'size_wh_image_url', 'brand', 'sift_similarity', 'nb_matches', 'diff_corners', 'matching', 'campaign_img_name', 'size_wh_campaign_img']) #'structural_sim', 'pixel_sim', 'emd', 'phash', 'dhash', 'chash', 'ahash',

        #Looping through all webpage items collected
        for index, row in tqdm.tqdm(df_imgs.iterrows(), total=len(df_imgs)):
            item_url = row['image_url']
            page_type = row['page_type']
            domain = row['domain']
            url = row['url']
            img_website, img_website_exist, size_img_website = self.load_img_from_url(item_url)

            #In case image url was not loaded, we pass to the next url image
            if img_website_exist == 0:
                continue

            #Looping through all subfolders and files within the campaign folder
            for subdir, dirs, files in os.walk(self.campaign_img_path):    
                #Retrieving the brand
                dirname = subdir.split(os.path.sep)[-1]
                #sys.stdout.write(dirname)
                #sys.stdout.write('\n')        
                #In case the website image brand doesn't match the campaign brand, we pass
                #Except for HOMEPAGE in which we have to check for all campaigns
                if page_type.upper() not in [dirname.upper(),"GENERAL"]:
                    continue

                for file in files:
                    campaign_img_path = os.path.join(subdir, file)
                    #sys.stdout.write(campaign_img_path)
                    #sys.stdout.write('\n')
                    img_campaign = self.load_img_from_path(campaign_img_path)

                    #Getting size of campaign image (Width x Height)
                    size_img_campaign = list(img_campaign.shape[0:2])[::-1]    

                    #compute different metrics
                    sift_sim_value, nb_matches = self.sift_sim(img_campaign, img_website)
                    diff_corners = self.corner_comparison(img_campaign, img_website)
                    """
                    #not used metrics
                    #phash, dhash, chash, ahash = self.hash_sim(img_campaign, img_website)
                    #structural_sim = self.structural_sim(img_campaign, img_website)
                    #pixel_sim = self.pixel_sim(img_campaign, img_website)
                    #emd = self.earth_movers_distance(img_campaign, img_website)
                    """
                    #set final threshold for matching
                    if sift_sim_value == None:
                        matching = 0
                    elif sift_sim_value > 0.5 and nb_matches > 400 and diff_corners < 200:
                        matching = 1
                    else:
                        matching = 0

                    similarity_results = similarity_results.append(
                    {'domain': domain,
                     'page_type': page_type,
                     'url': url, 
                     'image_url': item_url, 
                     'size_wh_image_url': size_img_website,
                     'brand': dirname, 
                     'sift_similarity': sift_sim_value,
                     'nb_matches': nb_matches,
                     'diff_corners': diff_corners,
                     #'structural_sim': structural_sim,
                     #'pixel_sim': pixel_sim,
                     #'emd': emd,
                     #'phash': phash,
                     #'dhash': dhash,
                     #'chash': chash,
                     #'ahash': ahash,
                     'matching': matching,
                     'campaign_img_name': file,
                     'size_wh_campaign_img': size_img_campaign}, ignore_index=True)

        return similarity_results

    def campaign_similarity_check(self):
        print('Starting Campaign Similarity process...')

        for domain, brands_list in self.dom_brands.items():
            print('Processing', domain)

            print('Extracting images urls for each page url of the domain...')
            #Initializing website items dataframe
            df_imgs = pd.DataFrame(columns=['domain', 'page_type', 'url', 'image_url'])
            for brand in brands_list:
                for url in self.config[domain][brand]:
                    dfc_imgs = self.extract_images_urls(domain, url)
                    dfc_imgs['page_type'] = brand
                    #self.df = self.df.append(res, ignore_index=True)
                    df_imgs = pd.concat([df_imgs, dfc_imgs], ignore_index=True)
            
            utils.write_file(df_imgs, 'images_urls', self.fpath, '.xlsx')

            ########## COMPUTING SIMILARITY CAMPAIGN SCORING #############
            print('Computing similarity for {} collected images...'.format(len(df_imgs)))
            df_sim = self.similarity_campaign_scoring(df_imgs)
            #filter only on matching
            #df_sim = df_sim[df_sim['matching']==1]
            print('Found {} match'.format(len(df_sim[df_sim['matching']==1])))

            self.df = pd.concat([self.df, df_sim], ignore_index=True)
            utils.write_file(self.df, 'campaign_similarity', self.fpath, '.xlsx')
            print('File saved')

        print('Process finished.')

    def compute_corners_mean(self, img_array):
        try:
            h, w, c = img_array.shape
            region_w = int(round(0.05*w,0))
            region_h = int(round(0.05*h,0))
                
            top_right=img_array[:region_h,w-region_w:,:].mean()
            bottom_right=img_array[h-region_h:,w-region_w:,:].mean()
            top_left=img_array[:region_h,:region_w,:].mean()
            bottom_left=img_array[h-region_h:,:region_w,:].mean()
            #mean_corners=np.mean([top_right,bottom_right,top_left,bottom_left])
            return top_right, bottom_right, top_left, bottom_left
        except:
            return None, None, None, None

    def corner_comparison(self, img_a, img_b):
        img_a = image_utils.transform_crop(img_a)
        #img_a = cv2.resize(img_a, (self.width, self.height))
        img_a = cv2.cvtColor(img_a, cv2.COLOR_BGR2RGB)

        img_b = image_utils.transform_crop(img_b)
        #img_b = cv2.resize(img_b, (self.width, self.height))
        img_b = cv2.cvtColor(img_b, cv2.COLOR_BGR2RGB)

        top_right_a, bottom_right_a, top_left_a, bottom_left_a = self.compute_corners_mean(img_a)
        top_right_b, bottom_right_b, top_left_b, bottom_left_b = self.compute_corners_mean(img_b)

        if top_right_a is None or top_right_b is None:
            return None
        else:
            diff = abs(top_right_a - top_right_b) + abs(bottom_right_a - bottom_right_b) + abs(top_left_a - top_left_b) + abs(bottom_left_a - bottom_left_b)
            return round(diff, 1)
         
def args_handler():
    parser = argparse.ArgumentParser(description='Detect SIMILARITY of campaign images')
    parser.add_argument('config_path', help='path of the config file')
    parser.add_argument('--campaign_img_path', help='path of the campaign images folder')
    parser.add_argument('--domain', help='domain to extract images urls')
    parser.add_argument('--brand', help='specific brand to compute')
    parser.add_argument('--folder', help='folder to store output df of images urls')
    parser.add_argument('--show_browser', '-d', action='store_true', help='show display (by default no display)')
    args = parser.parse_args()
    return args

def main(args):
    ex = IMAGES_URLS_EXTRACTOR(args.config_path, args.domain, args.brand, args.folder, args.show_browser, args.campaign_img_path)
    ex.campaign_similarity_check()
    ex.driver.quit()

if __name__ == "__main__":
    main(args_handler())

