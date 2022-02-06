import argparse
import sys
#print(sys.stdout.encoding) #console encoding
import pandas as pd
import numpy as np
import yaml
import re
import os
import time
import datetime
import pathlib

import utils
from db.InsertSession import InsertSession

class SCRAPER():
    def __init__(self, config, name, folder, brand, hm=False, show_browser=False, output_format=None, split_part=None, mongodb_scope=None, scraping_date=None, brand_out=False):
        self.scraping_date = utils.get_scraping_date(scraping_date)
        if mongodb_scope is not None:
            print('Data will be saved in mongodb')
            self.mongodb = True
            self.IS = InsertSession(mongodb_scope)
        else:
            self.mongodb = False

        #driver rotation
        self.r = 0
        self.inc = 0

        self.max_time_loading = 10 #to find items in a page (specific to selenium)
        self.wait_between_selenium = 1 #1 #in case wait is not in the config file (specific to selenium)
        self.wait_between_requests = 0.5 #in case wait is not in the config file (specific to requests)

        #get split part
        if split_part is None:
            split_part='1_1'
        self.nb_splits=int(split_part.split('_')[0])
        self.part=int(split_part.split('_')[1])

        self.get_output_format(output_format)

        self.show_browser = show_browser

        self.config = config

        #get brand
        self.brand = brand
        self.brand_out = brand_out
        if self.brand_out is True and self.brand is not None:
            brands_filepath = os.path.join(pathlib.Path(__file__).parent.absolute(), 'utils/config/brands.yaml')
            name_brand_dict = yaml.safe_load(open(brands_filepath))
            self.brand_fullname = name_brand_dict.get(self.brand, None)
            if self.brand_fullname is None:
                print('{} is missing in yaml : "brands"'.format(self.brand))
                sys.exit(1)

        self.brands_processed = []
        self.get_filepath(folder)

        #excluded to compute
        #perfumes
        self.excluded = []
        #self.excluded = ['coupang.com', 'allegro.pl', 'amazon.co.jp', 'amazon.com', 'amazon.ae', 'amazon.it', 'amazon.es', 'amazon.co.uk', 'amazon.de', 'shopee.tw', 'jd.com', 'randewoo.ru', 'tmon.co.kr', 'wemakeprice.com', 'walmart.com', 'taobao.com', 'tmall.com', 'rakuten.co.jp', 'ebay.com', 'ebay.com_outside', 'exemple.com', 'overstock.com', 'emag.ro_inside'] #manual stuff
        #self.excluded += []
        
        #price_monitoring

        for n in list(self.config.keys()):
            for kw in ['cartier', 'vacheron', 'hermes', 'chanel', 'lv', 'audemars', 'hublot', 'zenith', 'bvlgari']:
                if '_cny' in n or kw in n:
                    self.excluded.append(n)

        #initialize dataframe storing all the results
        self.df = pd.DataFrame()
        self.get_scraping_list(name)
        
        #manual input required
        if hm:
            print('Manual input asked')
            self.hm = True
        else:
            print('No manual input, machine running without help.')
            self.hm = False

        self.config_proxy = {
            'jp': {
                'mode': 'proxymesh',
                'address': 'jp.proxymesh.com:31280',
                'username': '',
                'password': '',
                'country': 'Japan',
                'alpha2': 'jp'
            },
            'fr': {
                'mode': 'proxymesh',
                'address': 'fr.proxymesh.com:31280',
                'username': '',
                'password': '',
                'country': 'France',
                'alpha2': 'fr'
            },
            'ch': {
                'mode': 'proxymesh',
                'address': 'ch.proxymesh.com:31280',
                'username': '',
                'password': '',
                'country': 'Switzerland',
                'alpha2': 'ch'
            },
            'us-ny': {
                'mode': 'proxymesh',
                'address': 'us-ny.proxymesh.com:31280',
                'username': '',
                'password': '',
                'country': 'United States',
                'alpha2': 'us'
            },
            'us-fl': {
                'mode': 'proxymesh',
                'address': 'us-fl.proxymesh.com:31280',
                'username': '',
                'password': '',
                'country': 'United States',
                'alpha2': 'us'
            },
            'uk': {
                'mode': 'proxymesh',
                'address': 'uk.proxymesh.com:31280',
                'username': '',
                'password': '',
                'country': 'United Kingdom',
                'alpha2': 'uk'
            },
            'sg': {
                'mode': 'proxymesh',
                'address': 'sg.proxymesh.com:31280',
                'username': '',
                'password': '',
                'country': 'Singapore',
                'alpha2': 'sg'
            },
            'hk': {
                'mode': 'setup vpn',
                'address': 'hk',
                'key': 'XEA-JKLRO-ER',
                'username': '',
                'password': '',
                'country': 'Hong Kong',
                'alpha2': 'hk'
            },
            'tw': {
                'mode': 'setup vpn',
                'address': 'tw',
                'key': 'XEA-JKLRO-ER',
                'username': '',
                'password': '',
                'country': 'Taiwan',
                'alpha2': 'tw'
            },
            'manual': {
                'mode': 'setup vpn',
                'address': None,
                'key': 'XEA-JKLRO-ER',
                'username': '',
                'password': ''
            }
        }

    def get_output_format(self, output_format):
        try:
            if output_format is None or output_format == 'xlsx':
                self.output_format = '.xlsx'
            elif output_format == 'csv':
                self.output_format = '.csv'
            elif output_format == 'tsv':
                self.output_format = '.tsv'
            print('\nFormat of output chosen: {}'.format(self.output_format))
        except:
            print('Something is wrong with output format:', output_format)
            sys.exit(1)

    def get_filepath(self, folder):
        #filepath creation
        if folder is None:
            self.fpath = os.path.join('', 'data')
            if 'data' not in os.listdir(folder):
                os.mkdir(self.fpath)
        else:
            self.fpath = folder

    def get_scraping_list(self, name):
        #already computed check
        if self.mongodb is False:
            self.computed = []
            for d in os.listdir(self.fpath):
                d = re.sub('result_', '', d)
                d = re.sub(self.output_format, '', d)
                self.computed += [d]

            if name is None:
                reduced_scraping_list = []
                for d in list(self.config.keys()):
                    if (d not in self.excluded and d not in self.computed):
                        reduced_scraping_list += [d]

                self.scraping_list = utils.get_part_of_list(reduced_scraping_list, self.nb_splits, self.part)
                utils.display_names_to_process(self.scraping_list)
            else:
                if name in list(self.config.keys()):
                    self.scraping_list = [name]
                    if name in self.computed:
                        print(os.path.join(self.fpath, 'result_' + name + self.output_format))
                        self.df = utils.read_file(os.path.join(self.fpath, 'result_' + name + self.output_format), self.output_format)
                        try:
                            self.brands_processed = list(self.df['brand'].unique())
                        except:
                            pass
                else:
                    print('"{}" is not in config file'.format(name))
                    sys.exit(1)
        elif self.mongodb is True:
            if name is None:
                #get list of already inserted config_name in mongodb for a specific time_scope
                self.computed = self.IS.extract_inserted_name_mongodb(self.scraping_date)

                reduced_scraping_list = []
                for d in list(self.config.keys()):
                    if (d not in self.excluded and d not in self.computed):
                        reduced_scraping_list += [d]

                self.scraping_list = utils.get_part_of_list(reduced_scraping_list, self.nb_splits, self.part)
                utils.display_names_to_process(self.scraping_list)
                
            else:
                if name in list(self.config.keys()):
                    self.scraping_list = [name]

                    reply = str(input('Correct website (1) | Scrape only missing brands (2) ? Answer: '))
                    print(reply)
                    if reply[0] == '1':
                        print('Choice 1 selected: Correct website')
                        pass
                    elif reply[0] == '2':
                        print('Choice 2 selected: Scrape missing brands from website')
                        #get list of brands already inserted in mongodb for a specific config_name and time_scope
                        self.brands_processed = self.IS.extract_inserted_brand_mongodb(name, self.scraping_date)

    def scrape_list(self):
        for name in self.scraping_list:
            self.name = name
            print('\nCollecting data for ... {}'.format(name))

            config = self.config[name]
            #print(config)

            if 'domain' not in config:
                config.update({'domain': name})
            elif 'domain' in config and config['domain'] is None:
                config.update({'domain': name})
            
            if self.mongodb is True:
                scrape = self.IS.columns_check_before_scraping(config)
            if (self.mongodb is True and scrape is True) or self.mongodb is False:

                if 'manual_input' in config and config['manual_input']==True and self.hm == False:
                    print('No processing "{}" (manual input required). Currently machine mode is active'.format(name))
                    continue
            
                utils.sleep(3)

                if 'proxy' not in config or config['proxy']!=True:
                    config.update({'proxy': False})
                    proxy = None
                    self.iplocation = None
            
                if 'js' in config and config['js']==True:
                    if 'wait' not in config:
                        config.update({'wait': self.wait_between_selenium})

                    #if 'page_load_timeout' not in config:
                        #config.update({'page_load_timeout': self.page_load_timeout})

                    #USE SELENIUM
                    if 'proxy' in config and config['proxy']==True:
                        if self.hm==True:
                            self.iplocation = 'manual'
                            proxy = self.config_proxy[self.iplocation]
                            print('manual proxy selected')
                        elif 'iplocation' in config and config['iplocation'] in {c for c in list(self.config_proxy.keys())}:
                            self.iplocation = config['iplocation']
                            proxy = self.config_proxy[self.iplocation]
                        else:
                            self.iplocation = 'us-ny'
                            proxy = self.config_proxy[self.iplocation]
                            #proxy = self.config_proxy[next(iter(config_proxy.keys()))]
                            print('proxy is not in the list, random proxy selected in the list (us-ny)')

                    self.driver = utils.launch_driver(show_browser=self.show_browser, proxy=proxy)

                    #log to proxy
                    no_proxy_detected = utils.log_to_proxy(self.driver, proxy)
                    if no_proxy_detected == True:
                        continue
                else:
                    #update wait time for non-js website (0 by default)
                    if 'wait' not in config:
                        config.update({'wait': self.wait_between_requests})

                    config.update({'js': False})
                    self.driver = None

                    if 'proxy' in config and config['proxy']==True:
                        if 'iplocation' in config and config['iplocation'] in {c for c in list(self.config_proxy.keys())}:
                            self.iplocation = config['iplocation']
                        else:
                            self.iplocation = 'random'

                #manual mode before going to the website
                if self.hm==True:
                    print('Manual mode before going to the website : "Enter" to continue')
                    input()
            
                self.scrape_one(config)

                #SAVE FILE
                if len(self.df)>0:
                    if self.mongodb is True:
                        self.IS.insert_from_raw_to_mongodb(self.df)
                        self.df = pd.DataFrame()
                    elif self.mongodb is False:
                        print('Saving file locally...')
                        utils.write_file(self.df, name, self.fpath, self.output_format)
                        #reset df only here at the end of the website
                        self.df = pd.DataFrame()
                try:
                    self.driver.quit()
                    time.sleep(5)
                except:
                    pass

    def scrape_one(self, config):
        try:
            if type(config['start_url']) == list:
                start_urls = config['start_url']
            elif type(config['start_url']) == str:
                start_urls = [config['start_url']]
            elif type(config['start_url']) == dict:
                if self.brand is not None:
                    if self.brand_out is True and 'all' in config['start_url'].keys():
                        start_urls = utils.convert_as_list(config['start_url']['all'])
                        #format start_urls with the corresponding brand
                        start_urls = [utils.format_start_url_all(start_urls[k], self.brand_fullname) for k in range(len(start_urls))]
                    elif self.brand in config['start_url'].keys():
                        start_urls = utils.convert_as_list(config['start_url'][self.brand])
                    else:
                        print('"{0}" is not in config for {1}'.format(self.brand, config['domain']))
                else:
                    #remove start_url 'all' from config
                    config['start_url'] = config['start_url'].pop('all')
                    print(config['start_url'])

                    inv_su_b = utils.invert_new(config['start_url'])
                    start_urls = list(inv_su_b.keys())

            for k in range(len(start_urls)):
                rows_list = []
                
                if type(config['start_url']) == dict:
                    if self.brand is not None:
                        brand = self.brand
                    else:
                        brand = inv_su_b[start_urls[k]]
                elif type(config['start_url']) == list:
                    brand = config['brand']

                config.update({'brand': brand})
                print('\nProcessing {}\n'.format(brand))

                if brand in self.brands_processed:
                    print(brand, "is already in dataframe\n")
                    continue

                #case where start_url is n/a
                if 'http' not in start_urls[k]:
                    continue

                if '{}' in start_urls[k]:
                    min_page = utils.get_min_page(config)

                    i = min_page
                    print('scraping page: {}\n'.format(i))
                    start_url_k = start_urls[k].format(utils.get_incremental(i, config))
                    #start_url_k = start_urls[k].replace('{}', str(utils.get_incremental(i, config)))
                else:
                    start_url_k = start_urls[k]
                    
                self.driver, self.r, self.inc, rotate_proxy = utils.rotate_driver(config['js'], self.driver, self.r, self.inc, show_browser=self.show_browser, proxy=self.config_proxy)
                r = utils.query(start_url_k, config['js'], self.driver, config['proxy'], self.config_proxy, self.iplocation)

                utils.wait_loading(config['items_out'], self.driver, self.max_time_loading)
                utils.sleep(config['wait'])
                
                #extract start of each url
                self.start = utils.extract_start(self.driver, r)

                #print(config)

                #MANUAL CHANGE REQUIRED
                if ('manual_input' in config and config['manual_input']==True and self.hm==True): # or (self.hm==True):
                    print('Manual mode : "Enter" to continue')
                    input()

                #ACTIONS BEFORE PARSING ITEMS
                self.actions_before_parsing(config)
                
                #get items and check number
                items_out = utils.get_items(config['js'], self.driver, r, config["items_out"])
                #case where js website using multiples pages with click only
                utils.load_more_click_next(items_out, self.driver, config, self.start)
                    
                print(len(items_out), 'items detected!')
                print('scraping...\n')

                page_out = utils.get_page(config['js'], self.driver, r)
                
                max_page = utils.get_max_page(config, page_out)

                perm_l, x_l = utils.perm_fields(config)
                
                self.last_page = False
                while len(items_out)>0:
                    #collect data

                    #go in each item
                    for idx_out, item_out in enumerate(items_out):
                        #update html dict to extract data
                        html_dict = {
                                    'page_out': page_out,
                                    'item_out': item_out
                                    }

                        #append perm columns to dict result
                        dict1 = {k: config[k] for k in perm_l}
                        dict1.update({"config_name": self.name})
                        dict1.update({"start_url": start_url_k})
                        dict1.update({"date": self.scraping_date})

                        url = utils.get_value(item_out, config['url'], 'url', config['domain'], self.start)
                        #print('url:', url)

                        if config['in_url'] == True:
                            try:
                                url = utils.change_url(url, config['domain'])
                                self.driver, self.r, self.inc, rotate_proxy = utils.rotate_driver(config['js'], self.driver, self.r, self.inc, show_browser=self.show_browser, proxy=self.config_proxy)
                                r = utils.query(url, config['js'], self.driver, config['proxy'], self.config_proxy, self.iplocation)
                                dict1.update({"url" : utils.get_current_url(url, config['js'], self.driver, r)})
                            except Exception as e:
                                pass
                            
                            #scroll
                            if 'click_popup' in config and config['click_popup'] is not None:
                                utils.click_popup(self.driver, config['click_popup'])
                            if 'scroll' in config and config['scroll']==True:
                                utils.scroll(self.driver)
                            if 'scroll_n2' in config and config['scroll_n2']==True:
                                utils.scroll_n2(self.driver, config['items_in'])
                            
                            if 'items_in' in config and config['items_in'] is not None:
                                utils.wait_loading(config['items_in'], self.driver, self.max_time_loading)
                                utils.sleep(config['wait'])

                                #get items and check number
                                items_in = utils.get_items(config['js'], self.driver, r, config["items_in"])
                                #print(len(items_in), 'items in')
                                if len(items_in)>0:
                                    for idx_in, item_in in enumerate(items_in):
                                        html_dict.update({'item_in': item_in})

                                        #ACTIONS TO CLICK IN OFFER
                                        if 'click_items_in' in config and config['click_items_in'] is not None:
                                            try:
                                                click_elems = self.driver.find_elements_by_xpath(config['click_items_in'])
                                                utils.click(self.driver, click_elems[idx_in])
                                            except:
                                                pass
                                    
                                        self.actions_click(config)
                                    
                                        dict1.update({"url" : utils.get_current_url(url, config['js'], self.driver, r)})
                                        page_in = utils.get_page(config['js'], self.driver, r)
                                        html_dict.update({'page_in': page_in})

                                        dict1 = self.collect_information(dict1, x_l, html_dict, config)

                                        utils.display_results(dict1)
                                        rows_list.append(dict1.copy())
                                #single item case where websites have sometimes single item and multiples items depending on page
                                else:
                                    self.actions_click(config)

                                    html_dict.update({'item_in': None})
                                    page_in = utils.get_page(config['js'], self.driver, r)
                                    html_dict.update({'page_in': page_in})

                                    dict1 = self.collect_information(dict1, x_l, html_dict, config)

                                    utils.display_results(dict1)
                                    rows_list.append(dict1.copy())
                                
                            else:
                                #utils.wait_loading(config['price'], self.driver, self.max_time_loading) #not working
                                utils.sleep(config['wait'])

                                page_in = utils.get_page(config['js'], self.driver, r)
                                html_dict.update({'page_in': page_in})
                                

                                dict1 = self.collect_information(dict1, x_l, html_dict, config)

                                utils.display_results(dict1)
                                rows_list.append(dict1.copy())

                        else:
                            dict1.update({"url" : url})

                            dict1 = self.collect_information(dict1, x_l, html_dict, config)
                            
                            utils.display_results(dict1)
                            rows_list.append(dict1.copy())

                    if '{}' in start_urls[k] and i<max_page:
                        #check if last page already collected
                        if self.last_page is True:
                            break

                        #increment
                        i+=1
                        print('scraping page: {}\n'.format(i))
                        start_url_k = start_urls[k].format(utils.get_incremental(i, config))
                        #start_url_k = start_urls[k].replace('{}', str(utils.get_incremental(i, config)))
                        self.driver, self.r, self.inc, rotate_proxy = utils.rotate_driver(config['js'], self.driver, self.r, self.inc, show_browser=self.show_browser, proxy=self.config_proxy)
                        r = utils.query(start_url_k, config['js'], self.driver, config['proxy'], self.config_proxy, self.iplocation)
                        dict1.update({"start_url": start_url_k})
                        utils.sleep(config['wait'])
                        """
                        if self.hm==True:
                            print('Manual mode: "Enter" to continue')
                            input()
                        """

                        #ACTIONS BEFORE PARSING ITEMS
                        self.actions_before_parsing(config)

                        #get items and check number
                        items_out_new = utils.get_items(config['js'], self.driver, r, config["items_out"])
                        #print(len(items_out_new), 'items outer')

                        self.last_page = utils.get_last_page_check(config, items_out, items_out_new)
                        items_out = utils.get_items_based_on_similarity_check(config, items_out, items_out_new, self.start)
                        page_out = utils.get_page(config['js'], self.driver, r)
                    else:
                        items_out = []
                
                current_df = pd.DataFrame(rows_list)
                self.df = pd.concat([self.df, current_df], ignore_index=True, sort=False)

                if len(self.df)>0:
                    if self.mongodb is True:
                        self.IS.insert_from_raw_to_mongodb(self.df)
                        self.df = pd.DataFrame()
                    elif self.mongodb is False:
                        print('Saving file locally...')
                        utils.write_file(self.df, self.name, self.fpath, self.output_format)

        except Exception as e:
            print(e)

    def collect_information(self, dict1, x_l, html_dict, config):
        #collect information
        for e in x_l:
            elem_l, xpath_l = utils.correct_xpath(html_dict, config[e], config['in_url'])
            res = utils.get_value(elem_l, xpath_l, e, config['domain'], self.start)
            dict1.update({e: res})
        return dict1

    def actions_before_parsing(self, config):
        if 'click_popup' in config and config['click_popup'] is not None:
            utils.click_popup(self.driver, config['click_popup'])

        if 'scroll_slowly' in config and config['scroll_slowly']==True:
            utils.scroll_slowly(self.driver)

        if 'scroll' in config and config['scroll']==True:
            utils.scroll(self.driver)

        if 'load_more' in config and config['load_more'] is not None:
            utils.load_more(self.driver, config['load_more'])

        if 'load_more2' in config and config['load_more2'] is not None:
            utils.load_more2(self.driver, config['load_more2'])

        if 'load_more3' in config and config['load_more3'] is not None:
            utils.load_more3(self.driver, config['load_more3'])

        if 'load_more_static' in config and config['load_more_static'] is not None:
            utils.load_more_static(self.driver, config['load_more_static'])

    def actions_click(self, config):
        l=[]
        if 'actions' in config and config['actions'] is not None:
            if type(config['actions']) == str:
                l=[config['actions']]
            elif type(config['actions']) == list:
                l=config['actions']
            for xpath_a in l:
                try:
                    btn = self.driver.find_element_by_xpath(xpath_a)
                    utils.click(self.driver, btn)
                    if xpath_a == '//button[contains(text(), "Show price")]':
                        time.sleep(10)
                except:
                    pass

def parse_args():
    """Handle the different parameters required to launch the script"""
    parser = argparse.ArgumentParser()
    parser.add_argument("config_path", help="Enter config path", type=str)
    parser.add_argument("--folder", help="folder to save file locally", type=str)
    parser.add_argument("--mongodb", help="mongodb config name to save data in mongodb (by default data is saved locally)", type=str)
    parser.add_argument("--split_part", help="Number of parts to split the config file (e.g '2_1' dividing in 2, processing part 1) part can not be higher than number of split", type=str)
    parser.add_argument("--name", help="Enter name of domain you want to scrape", type=str)
    parser.add_argument("--brand", help="to scrape a specific brand", type=str)
    parser.add_argument("--output_format", help="Choose an output format ('xlsx', 'tsv', 'csv') ('xlsx' selected by default)", type=str)
    parser.add_argument("-hm", "--humanmode", help = "Manual input used if human mode (-hm) by default, machine mode running (no manual input required)", action = "store_true")
    parser.add_argument("--date", help="Scraping date when correcting a specific website (Format should be YYYY-MM-DD", type=str)
    parser.add_argument('--show_browser', '-d', action='store_true', help='show display')
    parser.add_argument("--brand_out", help = "Required with flag --brand when scraping a brand outside the config file for all websites having the generic start_url 'all' parametered in the config file", action = "store_true")
    args = parser.parse_args()
    return args

def main(args):

    try:
        with open(args.config_path, 'r', encoding='utf-8') as file:
            config = yaml.safe_load(file)
    except Exception as e:
        print("Error obtained when opening config file:", e)
        sys.exit(1)

    s = SCRAPER(config, args.name, args.folder, args.brand, args.humanmode, args.show_browser, args.output_format, args.split_part, args.mongodb, args.date, args.brand_out)
    s.scrape_list()

if __name__ == "__main__":
    main(parse_args())
