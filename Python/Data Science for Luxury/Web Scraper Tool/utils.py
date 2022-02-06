import sys
import os
import json
import re
import datetime
import time
from lxml import html
import numpy as np
import pandas as pd
import random
from fake_useragent import UserAgent
import unicodedata

#SELENIUM
from selenium import webdriver
#CHROME
from selenium.webdriver.chrome.options import Options
#FIREFOX
#from selenium.webdriver.firefox.options import Options
#from selenium.webdriver.firefox.firefox_binary import FirefoxBinary
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from fake_useragent import UserAgent
from selenium.webdriver import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By

from pyvirtualdisplay import Display

#from webdriver_manager.chrome import ChromeDriverManager

#REQUESTS
import requests
import http.cookies

def get_scraping_date(scraping_date):
    if scraping_date is None:
        d = datetime.datetime.today().strftime("%Y-%m-%d")
    else:
        try:
            d = datetime.datetime.strptime(scraping_date, "%Y-%m-%d").strftime("%Y-%m-%d")
        except:
            print('date format is wrong, format accepted : YYYY-MM-DD')
            sys.exit(1)
    return d

def get_abs_path(rel_path):
   return os.path.join(os.path.dirname(__file__), rel_path)

def load_cookie_jar(cookies_folder_path):
    try:
        cookie_jar = requests.cookies.RequestsCookieJar()
    
        for f in os.listdir(cookies_folder_path):
            if '.json' in f:
                with open(os.path.join(cookies_folder_path, f)) as json_file:
                    data = json.load(json_file)
                    for att, v in data.items():
                        if att == 'cookies':
                            for cookie in v:
                                if type(cookie)==str:
                                    cookie = http.cookies.SimpleCookie(cookie)
                                elif type(cookie)==dict:
                                    #print(cookie)
                                    pass
                                cookie_jar.update(cookie)
        return cookie_jar
    except Exception as e:
        print(e)
        return None

def load_cookies_header(cookies_folder_path):
    try:
        cookies_dict = {}

        for f in os.listdir(cookies_folder_path):
            if '.json' in f:
                with open(os.path.join(cookies_folder_path, f)) as json_file:
                    data = json.load(json_file)
                    for att, v in data.items():
                        if att == 'cookies':
                            for cookie in v:
                                if type(cookie)==str:
                                    cookie = http.cookies.SimpleCookie(cookie)
                                elif type(cookie)==dict:
                                    #print(cookie)
                                    pass
                                cookies_dict.update({cookie['name'] : cookie['value']})

                                
        return cookies_dict
    except Exception as e:
        print(e)
        return None

def get_cookies_list(cookies_folder_path):
    try:
        cookies_list = []

        for f in os.listdir(cookies_folder_path):
            if '.json' in f:
                with open(os.path.join(cookies_folder_path, f)) as json_file:
                    data = json.load(json_file)
                    for att, v in data.items():
                        if att == 'cookies':
                            for cookie in v:
                                if type(cookie)==str:
                                    cookie = http.cookies.SimpleCookie(cookie)
                                elif type(cookie)==dict:
                                    #print(cookie)
                                    pass
                                cookies_list += [cookie]

                                
        return cookies_list
    except Exception as e:
        print(e)
        return []

########################################### UTILS CLEANING ################################################
###########################################################################################################

def get_useragent():
    ua = UserAgent()
    return ua.random

def invert(d):
    return dict((v,k) for k in d for v in d[k])

def invert_new(d):
    inverted_d = {}
    if type(d) == dict:
        for k, v in d.items():
            l = convert_as_list(v)
            for u in l:
                if u not in inverted_d.keys():
                    inverted_d[u] = k
    return inverted_d

def correct_xpath(html_dict, xpaths, in_url):
    """
    "xpaths" can be either a list of xpaths or a simple xpath
    """
    if type(xpaths)==str:
        xpath_list = [xpaths]
    elif type(xpaths)==list:
        xpath_list = xpaths
    
    elem_l = []
    xpath_l = []
    for xpath in xpath_list:
        if in_url == True:
            if 'concat(//' in xpath:
                elem = html_dict['page_in']
            elif 'concat(./' in xpath:
                elem = html_dict['item_in']
            elif xpath[:2] == 'o/':
                xpath = re.sub('^o', '', xpath)
                elem = html_dict['page_out']
            elif xpath[:2] == 'o.':
                xpath = re.sub('^o', '', xpath)
                elem = html_dict['item_out']
            elif xpath[:2] == '//':
                elem = html_dict['page_in']
            elif xpath[:2] == './':
                elem = html_dict['item_in']
        elif in_url == False:
            if 'concat(//' in xpath:
                elem = html_dict['page_out']
            elif 'concat(./' in xpath:
                elem = html_dict['item_out']
            elif xpath[:2] == '//':
                elem = html_dict['page_out']
            elif xpath[:2] == './':
                elem = html_dict['item_out']
        
        elem_l += [elem]
        xpath_l += [xpath]
            
    return elem_l, xpath_l

def format_url(domain, url, start):
    try:
        if 'http' not in url:
            if url[:2] == '//':
                mstart = re.sub('//.*', '', start)
                return mstart + url
            elif url[0] == '/':
                return start + domain + url
            else:
                return start + domain + '/' + url
        else:
            return url
    except Exception as e:
        #print(e)
        return None

def sleep(t): #randomsleep
    if t > 1:
        s = random.uniform(t, t+2)
        print('sleep', s, 'sec')
        time.sleep(s)
    else:
        sleep2(t)

def sleep2(t):
    #wait
    try:
        print('sleep', t, 'sec')
        time.sleep(t)
    except Exception as e:
        #print(e)
        time.sleep(0)

def perm_fields(config):
    perm_l = []
    x_l = []
    for k, v in config.items():
        if type(v)==str:
            if '/' not in v:
                perm_l.append(k)
            else:
                if '/text()' in v or '/@' in v:
                    x_l.append(k)
        elif type(v)==list:
            for i in v:
                if '/text()' in i or '/@' in i:
                    if k not in x_l:
                        x_l.append(k)
        elif v is None:
            perm_l.append(k)
    
    if 'url' in x_l:
        x_l.remove('url')
    if 'max_page' in x_l:
        x_l.remove('max_page')
    if 'min_page' in perm_l:
        perm_l.remove('min_page')
    if 'iplocation' in perm_l:
        perm_l.remove('iplocation')
    if 'items_in' in perm_l:
        perm_l.remove('items_in')
    if 'incremental' in perm_l:
        perm_l.remove('incremental')

    return perm_l, x_l

def get_min_page(config):
    if 'min_page' in config and config['min_page'] is not None:
        min_page = config['min_page']
    else:
        min_page=1
    return min_page

def convert_as_list(x):
    if type(x)==str:
        l = [x]
    elif type(x)==list:
        l = x
    return l

def display_names_to_process(l):
    #display name going to be processed
    print('\nTotal length of scraping list: {}\n'.format(len(l)))
    time.sleep(2)
    for idx, n in enumerate(l):
        print('- {0} ({1})'.format(n, str(idx+1)))
    print('\n')
    time.sleep(2)

def get_part_of_list(list, nb_splits, part):
    #verification
    if len(list)<nb_splits:
        return list

    q = len(list)//nb_splits
    r = len(list)%nb_splits
    
    if part<nb_splits:
        l = list[q*(part-1):q*part]
    elif part==nb_splits:
        l = list[q*(part-1):q*part+r]
    else:
        print('ERROR : part can not be higher than nb of splits')
        l = []
    return l

def get_max_page(config, page_out):
    default_max_page = 200

    #max page
    if 'max_page' in config and config['max_page'] is not None:
        if type(config['max_page'])==int:
            max_page = config['max_page']
        else:
            try:
                max_page = page_out.xpath(config['max_page'])[0]
                max_page = int(max_page)
            except:
                #when xpath is not found in page
                max_page = 15
    else:
        #max page by default
        max_page=default_max_page
    
    print('(Max page by default: {})\n'.format(max_page))
    return max_page

def get_incremental(i, config):
    #format is always NUMBER*i+1 or NUMBER*i
    new_i = i
    if 'incremental' in config and config['incremental'] is not None:
        inc = config['incremental']
        l = re.findall('[0-9]{1,}', inc)
        if len(l)==1:
            new_i = int(l[0])*i
        elif len(l)>1:
            new_i = int(l[0])*i+int(l[1])
                         
    return new_i

def write_file(df, name, fpath, output_format):

    result_filename = 'result_' + str(name) + output_format

    #save
    if output_format == '.xlsx':
        writer = pd.ExcelWriter(os.path.join(fpath, result_filename), engine='xlsxwriter', engine_kwargs={'options': {'strings_to_urls': False}})
        df.to_excel(writer, index=False)
        writer.close()
    elif output_format == '.tsv':
        df.to_csv(os.path.join(fpath, result_filename), sep='\t', index=False, encoding='utf-8')
    elif output_format == '.csv':
        df.to_csv(os.path.join(fpath, result_filename), sep=',', index=False, encoding='utf-8')
    print('file saved!')

def check_in_folder(name, folder):
    try:
        if folder is None:
            fpath = os.path.join('', 'data')
        else:
            fpath = os.path.join(folder, 'data')

        if name in os.listdir(fpath):
            return True
        else:
            return False
    except:
        pass

def display_results(dictx):
    #display results
    for r, val in dictx.items():
        try:
            print('{0}: {1}'.format(r, val))
        except:
            print('{0}: error with console display'.format(r))
    print(' ')

################################################# SELENIUM ################################################
###########################################################################################################

def launch_driver(show_browser=False, proxy=None):
    #options
    options = Options()
    #options.binary_location = r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'
    #options.binary_location = '/mnt/c/Program\ Files\ \(x86\)/Google/Chrome/Application/chrome.exe'
    if show_browser is True:
        options.add_argument("--window-size=1366,768")
        #options.add_argument("--start-maximized")
        display = False
    elif show_browser is False:
        print('headless mode')
        #options.add_argument('--headless')
        display = Display(visible=0, size=(1366, 768))
        display.start()

    options.add_argument('--no-sandbox')
    #options.add_argument('--remote-debugging-port=9222')

    options.add_argument("--lang=en")   
    prefs = {
        #"prefs": {'intl.accept_languages': 'en,en_US'},
        "translate":{"enabled":"true"},
        #"profile.default_content_settings":{"images": 2}, #disable images loading in selenium to speed up page loading
        #"profile.managed_default_content_settings":{"images": 2} #disable images loading in selenium to speed up page loading
    }

    options.add_experimental_option("prefs", prefs)
    options.add_argument('--ignore-certificate-errors')
    options.add_argument("--disable-notifications")
    options.add_argument("--disable-popup-blocking")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
    options.add_argument("--disable-infobars")
    #options.add_argument("--enable-javascript")
    #options.add_argument("--disable-extensions")
    #options.add_argument("--incognito")

    #avoid being detected when using selenium by changing selenium parameters
    options.add_argument('--disable-blink-features=AutomationControlled')
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option('useAutomationExtension', False)

    #random user agent
    #options.add_argument('user-agent={}'.format(get_useragent()))
    #specific user agent
    options.add_argument('user-agent={}'.format('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36'))
    #own chrome profile with cookies: chrome://version/
    #options.add_argument('--user-data-dir=/mnt/c/Users/TCO/AppData/Local/Google/Chrome/User Data/Default')
    #else
    #options.add_argument('--profile-directory=Default')
    #options.add_argument('--user-data-dir=~/.config/google-chrome')

    options.add_argument('Accept-Language={}'.format('en-US,en;q=0.5'))

    #cookies loading if necessary
    options.add_extension('utils/extensions/J2TEAM_Cookies.crx')

    if proxy == None:
        options.add_extension('utils/extensions/webrtcleakshield.crx')
        capabilities = options.to_capabilities()
    elif proxy['mode'] == 'setup vpn':
        options.add_extension('utils/extensions/setupvpn.crx')
        options.add_extension('utils/extensions/webrtcleakshield.crx')
        options.add_extension('utils/extensions/simple_proxy.crx')
        options.add_extension('utils/extensions/best_proxy_manager.crx')

        capabilities = options.to_capabilities()

    elif proxy['mode'] == 'proxymesh':
        options.add_extension('utils/extensions/proxy_auth.crx')
        options.add_extension('utils/extensions/webrtcleakshield.crx')

        capabilities = options.to_capabilities()

        #add proxy if necessary
        capabilities['proxy'] = {'proxyType': 'MANUAL',
                                'httpProxy': proxy['address'],
                                'ftpProxy': proxy['address'],
                                'sslProxy': proxy['address'],
                                'noProxy': '',
                                'class': "org.openqa.selenium.Proxy",
                                'autodetect': False}
        capabilities['proxy']['socksUsername'] = proxy['username']
        capabilities['proxy']['socksPassword'] = proxy['password']
    
    chrome_path = 'utils/driver/chromedriver_91.exe' #windows
    #chrome_path = 'utils/driver/chromedriver_91' #linux
    #chrome_path = 'utils/driver/chromedriver_89.exe' #windows
    #chrome_path = 'utils/driver/chromedriver_94' #linux
    #chrome_path = r"C:\Users\TCO\Desktop\git\scraper\utils\driver\chromedriver_89.exe"
    print(chrome_path)
    driver = webdriver.Chrome(executable_path=chrome_path, desired_capabilities=capabilities)
    #driver = webdriver.Chrome(ChromeDriverManager().install(), desired_capabilities=capabilities)
    print(driver.execute_script("return navigator.userAgent;"))

    #avoid being detected when using selenium by changing selenium parameters
    driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
    #change cdc_ by tco_ for exemple in chromedriver

    #to change user agent (a cleaner way would be to quit and launch selenium)
    #driver.execute_cdp_cmd('Network.setUserAgentOverride', {"userAgent": 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.53 Safari/537.36'})

    #CHECK A WAY TO NOT BE DETECTED BY CLOUDFLARE OR DATADOME
    #import cfscrape #github.com/Anorov/cloudflare-scrape

    time.sleep(1.5)
    #close windows
    while len(driver.window_handles)>1:
        driver.switch_to.window(driver.window_handles[len(driver.window_handles)-1])
        time.sleep(0.5)
        driver.close()
        time.sleep(0.5)
    driver.switch_to.window(driver.window_handles[len(driver.window_handles)-1])

    #add_cookies_to_browser(driver)

    driver.implicitly_wait(10)
    driver.set_page_load_timeout(20)

    return driver

def launch_firefox_driver(headless=False, proxy=None):
    #options
    options = Options()
    profile=webdriver.FirefoxProfile()
    #monExecutable = FirefoxBinary('driver/geckodriver.exe')
    driver = webdriver.Firefox(firefox_profile=profile, executable_path='driver/geckodriver.exe') #firefox_binary= monExecutable
    return driver

def add_cookies_to_browser(driver):
    #driver.get('https://www.allegro.pl')
    cookies_list = get_cookies_list('utils/cookies')
    for cookie in cookies_list:
        try:
            driver.add_cookie(cookie)
        except:
            try:
                driver.add_cookie({"name": cookie["name"], "domain": cookie["domain"], "value": cookie["value"]})
            except Exception as e:
                print(e)
                print(cookie)
                pass

    driver.refresh()
################################################# QUERY ###################################################
###########################################################################################################

def get_current_url(url, js, driver, r):
    try:
        if js == True:
            current_url = driver.current_url
        else:
            current_url = r.url
        if current_url is not None or current_url != '':
            return current_url
        return url
    except:
        return url

def change_url(url, domain):
    dom_to_change = [
        'amazon.com',
        'amazon.co.jp',
        'amazon.ae',
        'amazon.es',
        'amazon.it',
        'amazon.de',
        'amazon.co.uk'
    ]

    if domain in dom_to_change:
        if domain in ['amazon.com', 'amazon.co.jp', 'amazon.ae', 'amazon.de', 'amazon.es', 'amazon.it', 'amazon.co.uk']:
            try:
                ref_id = re.findall("/dp/.+/", url)[0]
                if ref_id != '':
                    url = "https://www." + domain + ref_id + 'ref=olp-opf-redir?aod=1&ie=UTF8&condition=NEW'
            except Exception as e:
                print(e)
                pass

    return url

def query(url, js, browser, proxy, config_proxy, country):
    try:
        print('querying:', url, '\n')
    except:
        pass
    try:
        if js == True:
            browser.get(url)
            return None
        else:
            headers, proxy = get_proxy(proxy, config_proxy, country)
            #cookie_jar = load_cookie_jar(r'C:\Users\TCO\Downloads\cookies') #cookies=cookie_jar
            r = requests.get(url, headers = headers, proxies=proxy, verify = True, timeout=15)
            return r
    except:
        if js == True:
            browser.execute_script("window.stop();")
        return None

def get_proxy(proxy, config_proxy, country):
    countries = ['jp', 'fr', 'ch', 'us-ny', 'us-fl', 'uk', 'sg', 'nl', 'de', 'us']
    """
    countries = []
    for k, v in config_proxy.items():
        if v['mode'] == 'proxymesh':
            countries.append(k)
    """
    country_proxies = {c: ':@{}.proxymesh.com:'.format(country) for c in countries}

    #cookies_dict = load_cookies_header(r'C:\Users\TCO\Downloads\cookies')
    headers = {
           'user-agent': get_useragent(),
           'Accept-Language': 'en-US,en;q=0.5'
           #'Cookies': cookies_dict
        }
    if proxy == True:
        if country is None or country == 'random':
            random_country = random.choice(countries)
            print(random_country)
            http_country = country_proxies[random_country]
        else:
            http_country = country_proxies[country]
        proxy = {'http': 'http://{}'.format(http_country), 'https': 'https://{}'.format(http_country)}
    else:
        proxy = None

    return headers, proxy

###################################### EXTRACT INFORMATION ################################################
###########################################################################################################

def get_page(js, driver, r):
    #get content of the page
    try:
        if js == True:
            content_page = driver.page_source
        elif js == False:
            #here no selenium, driver corresponds to the response r = requests.get
            content_page = r.content
    
        tree = html.fromstring(content_page)
        return tree
    except:
        return None

def get_items(js, driver, r, xpath):
    #wait loading 5sec max time loading
    try:
        if js == True:
            wait_loading(xpath, driver, 10)

        #get content of the page
        page = get_page(js, driver, r)
    
        #xpath items
        items = page.xpath(xpath)
    
        return items
    except:
        return []

def get_value(elem_l, xpath_l, key, domain, start):
    if type(xpath_l)==str:
        xpath_list = [xpath_l]
    elif type(xpath_l)==list:
        xpath_list = xpath_l
    if type(elem_l)==list:
        elem_list = elem_l
    else:
        elem_list = [elem_l]
    
    res = ''
    for i, xpath in enumerate(xpath_list):
        try:
            v = elem_list[i].xpath(xpath)

            if len(v)>0:
                if type(v)==list:
                    v = v[0]
                v = str(v)
            #clean_value
            if '/text()' in xpath:
                v = re.sub('\n', '', v)
                v = re.sub('\s{2,}', ' ', v)
                v = v.strip()
            elif 'url' in key:
                v = format_url(domain, v, start)

            if type(v)==str:
                #take the first value working for price
                """
                if res != '':
                    continue
                """
                if (key == 'price' or key == 'capacity') and res !='':
                    continue
                if res != '':
                    res += ' '
                    #res += ' || '
                res += v
        except:
            pass
    if res == '':
        return None
    else:
        return res

def extract_start(driver, r):
    try:
        if r is None:
            beg = driver.current_url
        if driver is None:
            beg = r.url
        start = ''
        if 'https' in beg:
            start += 'https://'
        else:
            start += 'http://'
        if 'www.' in beg:
            start += 'www.'
        return start
    except:
        return 'https://www.'

def read_file(fpath, output_format):
    if output_format == '.xlsx':
        df = pd.read_excel(fpath)#, encoding='utf8')
    elif output_format == '.csv':
        df = pd.read_csv(fpath, sep=',', encoding='utf8')
    elif output_format == '.tsv':
        df = pd.read_csv(fpath, sep='\t', encoding='utf8')
    return df

###################################### ACTIONS IN SELENIUM ################################################
###########################################################################################################

#USELESS NOW
def click_js(browser, button, index, offset_x, offset_y):
    try:
        actions = ActionChains(browser)
        button.location_once_scrolled_into_view
        browser.execute_script("window.scrollTo(0, 540)") 
        if offset_x != 0 or offset_y != 0:
            actions.move_to_element_with_offset(button, (index+1)*int(offset_x), (index+1)*int(offset_y))
        else:
            actions.move_to_element(button)
        actions.click(button).perform()
        time.sleep(2)
    except:
        pass

def click(driver, button):
    try:
        button.click()
        time.sleep(2)
    except:
        try:
            actions = ActionChains(driver)
            button.location_once_scrolled_into_view
            actions.move_to_element(button)
            time.sleep(1.5)
            actions.click(button).perform()
            time.sleep(2)
        except:
            try:
                button.location_once_scrolled_into_view
                driver.execute_script("window.scrollTo(0, 540)") 
                actions.move_to_element(button)
                actions.click(button).perform()
                time.sleep(2)
            except:
                return True
        pass
    return False

def scroll_slowly(browser):
    try:
        height = int(browser.execute_script("return document.body.scrollHeight"))
        tranche = int(height/14)
    except Exception as e:
        pass
        #print(e)
    X = 0
    Y = tranche
    while Y < height:
        browser.execute_script("window.scrollTo({0}, {1})".format(X, Y))
        X += tranche
        Y += tranche
        time.sleep(0.5)

def wait_loading(xpath, driver, max_time_loading):
    if type(xpath)==str:
        #wait loading
        try:
            WebDriverWait(driver, max_time_loading).until(EC.presence_of_element_located((By.XPATH, xpath)))
        except Exception as e:
            #print(e)
            #print('Press enter')
            #input()
            try:
                #pass
                #driver.set_page_load_timeout(20)
                driver.refresh()
                #driver.set_page_load_timeout(2.5)
            except:
                pass

            #pass

def load_more(browser, button_xpath):
    while True:
        try:
            last_height = int(browser.execute_script("return document.body.scrollHeight"))
        except Exception as e:
            #print(e)
            pass
        try:
            #browser.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            button = browser.find_element_by_xpath(button_xpath)
            time.sleep(1)

            actions = ActionChains(browser)
            button.location_once_scrolled_into_view
            #browser.execute_script("window.scrollTo(0, 540)") 
            actions.move_to_element(button)
            time.sleep(1)
            actions.click(button).perform()
            time.sleep(2)
            #driver.manage().timeouts().implicitlyWait()
            new_height = int(browser.execute_script("return document.body.scrollHeight"))
            time.sleep(3)

            print(new_height, last_height)
            if new_height == last_height:
                print("Nothing else to load")
                break
            last_height = new_height
        except Exception as e:
            #print(e)
            print("Nothing else to load")
            break
    return

def load_more2(browser, button_xpath):
    """
    Same as load_more, but doesn't change the view to the button's position
    """
    while True:
        try:
            button = browser.find_element_by_xpath(button_xpath)
            time.sleep(1)
            actions = ActionChains(browser)
            actions.click(button).perform()
            time.sleep(3)

        except Exception as e:
            #print(e)
            print("Nothing else to load")
            break
    return

def load_more3(browser, button_xpath):
    """
    Same as load_more, but takes into consideration the case in which there are many buttons
    """
    buttons = browser.find_elements_by_xpath(button_xpath)
    time.sleep(1)

    if len(buttons) > 1:
        for i in range(len(buttons)):
            while True:
                try:
                    last_height = int(browser.execute_script("return document.body.scrollHeight"))
                except Exception as e:
                    #print(e)
                    pass
                try:
                    #browser.execute_script("window.scrollTo(0, document.body.scrollHeight);")
                    button = buttons[i]
                    time.sleep(1)

                    actions = ActionChains(browser)
                    button.location_once_scrolled_into_view
                    #browser.execute_script("window.scrollTo(0, 540)") 
                    actions.move_to_element(button)
                    time.sleep(1)
                    actions.click(button).perform()
                    time.sleep(4)
                    #driver.manage().timeouts().implicitlyWait()
                    new_height = int(browser.execute_script("return document.body.scrollHeight"))
                    time.sleep(1)

                    print(new_height, last_height)
                    if new_height == last_height:
                        print("Nothing else to load")
                        break
                    last_height = new_height
                except Exception as e:
                    #print(e)
                    print("Nothing else to load")
                    break
    else:
        while True:
            try:
                last_height = int(browser.execute_script("return document.body.scrollHeight"))
            except Exception as e:
                #print(e)
                pass
            try:
                #browser.execute_script("window.scrollTo(0, document.body.scrollHeight);")
                button = browser.find_element_by_xpath(button_xpath)
                time.sleep(1)

                actions = ActionChains(browser)
                button.location_once_scrolled_into_view
                #browser.execute_script("window.scrollTo(0, 540)") 
                actions.move_to_element(button)
                time.sleep(1)
                actions.click(button).perform()
                time.sleep(2)
                #driver.manage().timeouts().implicitlyWait()
                new_height = int(browser.execute_script("return document.body.scrollHeight"))
                time.sleep(3)

                print(new_height, last_height)
                if new_height == last_height:
                    print("Nothing else to load")
                    break
                last_height = new_height
            except Exception as e:
                #print(e)
                print("Nothing else to load")
                break
    return

#actions_click() does the same thing
def click_popup(driver, button_xpath):
    try:
        time.sleep(3)
        button = driver.find_element_by_xpath(button_xpath)
        time.sleep(1)
        click(driver, button)
    except:
        pass

def get_items_based_on_similarity_check(config, prev_items, new_items, start):
    #Check page similarity by comparing urls collected between last page and new page
    #return items if algorithm detects its a new page
    similarity_max = 0.5
    try:
        #constitue prev list
        urls_prev_list = []
        for prev_item in prev_items:
            prev_url = get_value(prev_item, config['url'], 'url', config['domain'], start)
            if prev_url is not None and prev_url not in urls_prev_list:
                urls_prev_list += [prev_url]
        #constitute new list
        urls_new_list = []
        for new_item in new_items:
            new_url = get_value(new_item, config['url'], 'url', config['domain'], start)
            if new_url is not None and new_url not in urls_new_list:
                urls_new_list += [new_url]

        #compare both list
        s=0
        for new_url in urls_new_list:
            if new_url in urls_prev_list:
                s+=1
        similarity = s/len(urls_new_list)
        if similarity >= similarity_max:
            items = []
        else:
            items = new_items.copy()
        return items
    except Exception as e:
        #print(e)
        items = []
        return items

def get_last_page_check(config, prev_items, new_items):
    #compare number of items between the 2 pages
    try:
        ratio_min = 0.5

        nb_items_prev = len(prev_items)
        nb_items_new = len(new_items)
        ratio_items_new = nb_items_new/nb_items_prev
        if ratio_items_new <= ratio_min:
            return True
        else:
            return False
    except Exception as e:
        #print(e)
        return False

def load_more_click_next(items_out, driver, config, start):
    if 'click_next' in config and config['click_next'] is not None:
        next_b = ''
        page = 1
        print('page:', page, '-', len(items_out), 'items found, total:', len(items_out))
        while next_b is not None:
            try:
                time.sleep(3)
                next_b = driver.find_element_by_xpath(config['click_next'])
                time.sleep(0.5)
                fail_click = click(driver, next_b)
                wait_loading(config['items_out'], driver, 10)
                time.sleep(3)

                #actions to do to load items if necessary
                if 'scroll_slowly' in config and config['scroll_slowly']==True:
                    scroll_slowly(driver)
                if 'scroll' in config and config['scroll']==True:
                    scroll(driver)

                #find new items
                items_out_new = get_items(config['js'], driver, None, config["items_out"])
                items_out_new = get_items_based_on_similarity_check(config, items_out, items_out_new, start)
                items_out += items_out_new
                page += 1
                print('page:', page, '-', len(items_out_new), 'new items found, total:', len(items_out))
                #limit
                if fail_click == True: #or page>50:
                    break
            except Exception as e:
                next_b = None 
                print('No more to load\n')
        return items_out

def load_more_static(driver, button_xpath):
    fail_click = False
    while fail_click is False:
        try:
            time.sleep(4)
            next_b = driver.find_element_by_xpath(button_xpath)
            time.sleep(0.5)
            fail_click = click(driver, next_b)
            time.sleep(6)
        except Exception as e:
            #print(e)
            print('No more to load')
            break
    return

def scroll(browser):
    try:
        last_height = int(browser.execute_script("return document.body.scrollHeight"))
    except Exception as e:
        #print(e)
        pass
    while True:
        try:
            browser.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            time.sleep(5)

            new_height = int(browser.execute_script("return document.body.scrollHeight"))
            time.sleep(1)
            print(new_height, last_height)
            if new_height-50 <= last_height:
                """
                print("IS THIS THE END ?(Yes / No)")
                answer = input()
                if answer == 'Yes':
                    print("Nothing else to load")
                    break
                """
                break
            last_height = new_height
        except Exception as e:
            #print(e)
            print("Nothing else to load")
            break
    return

def scroll_n2(browser, xpath_items):
    try:
        count_items_refreshed = 1
        count_items = 0
        html = browser.find_element_by_tag_name('html')
        time.sleep(0.5)
        while count_items_refreshed > count_items:
            #count previous
            items_out = get_items(True, browser, None, xpath_items)
            count_items = len(items_out)
            #scroll down
            for i in range(10):
                html.send_keys(Keys.PAGE_DOWN)
                time.sleep(0.05)
            #count new/refreshed
            items_refreshed = get_items(True, browser, None, xpath_items)
            count_items_refreshed = len(items_refreshed)
            if count_items_refreshed == 0:
                break
        time.sleep(2)
    except Exception as e:
        print(e)
        pass

############################################# PROXY #######################################################
###########################################################################################################

def log_to_proxy(driver, proxy):
    if proxy == None:
        pass
    elif proxy['mode'] == 'setup vpn':
        #SETUP VPN
        driver.get('chrome-extension://oofgbpoabipfcfjapgnbbjjaenockbdp/popup.html')

        time.sleep(2)

        english_button = driver.find_element_by_xpath('//div[@class="lang-list"]/ul/li[@data="en"]')
        click(driver, english_button)

        time.sleep(0.7)

        email_button = driver.find_element_by_xpath('//div[@id="emailsignin-option"]//div[@class="login-authcode-view__emailsignin__container"]')
        click(driver, email_button)

        time.sleep(0.5)

        login_button = driver.find_element_by_xpath('//input[@id="login-email"]')
        login_button.clear()
        login_button.send_keys(proxy['username'])

        time.sleep(0.5)

        password_button = driver.find_element_by_xpath('//input[@id="login-password"]')
        password_button.clear()
        password_button.send_keys(proxy['password'])

        sign_in_button = driver.find_element_by_xpath('//a[@id="login-button"]')
        click(driver, sign_in_button)

        time.sleep(0.5)

        continue_button = driver.find_element_by_xpath('//a[@class="btn btn--new-blue"]')
        click(driver, continue_button)

        try:
            if proxy['address'] is not None:
                try:
                    proxy_button = driver.find_element_by_xpath('//section[@id="free-server-list"]/div[contains(@sortkey,"{}")]'.format(proxy['alpha2']))
                    click(driver, proxy_button)
                    time.sleep(1.5)
                except Exception as e:
                    print(e)
                    #RESIDENTIAL
                    residential_button = driver.find_element_by_xpath('//a//span[contains(text(), "Residential")]')
                    click(driver, residential_button)
                    time.sleep(0.5)
                    try:
                        proxy_buttons = driver.find_elements_by_xpath('//section[@id="public-server-list"]/div[contains(@sortkey,"{}")]'.format(proxy['alpha2']))
                        print(proxy_buttons)
                    except Exception as e:
                        #print(e)
                        proxy_buttons = []
                    if len(proxy_buttons) == 0:
                        self.driver.quit()
                        time.sleep(3)
                        return True
                    else:
                        for ind in range(-1, -len(proxy_buttons)-1, -1):
                            proxy_button = proxy_buttons[ind]
                            fail_click = click(driver, proxy_button)
                            if fail_click is False:
                                print('Connected to proxy:', -ind, '(out of {})'.format(len(proxy_buttons)))
                                time.sleep(1.5)
                                break
            else:
                print('Please choose proxy location manually : "Enter" to continue')
                input()    
        except Exception as e:
            print(e)

        #PROXYMESH
    elif proxy['mode'] == 'proxymesh':
        driver.get('chrome-extension://ggmdpepbjljkkkdaklfihhngmmgmpggp/options.html')
        time.sleep(1.5)

        login_button = driver.find_element_by_xpath('//input[@id="login"]')
        login_button.clear()
        login_button.send_keys(proxy['username'])

        time.sleep(0.5)

        password_button = driver.find_element_by_xpath('//input[@id="password"]')
        password_button.clear()
        password_button.send_keys(proxy['password'])

        time.sleep(1)

        sign_in_button = driver.find_element_by_xpath('//button[@id="save"]')
        actions = ActionChains(driver)
        actions.click(sign_in_button).perform()

        time.sleep(2)

    return False

def rotate_driver(js, driver, r=0, inc=0, rotate=True, show_browser=False, proxy=None, activate_driver_rotation=False):
    if js == True and driver is not None:
        #activation condition
        if activate_driver_rotation is True:

            if r == 0:
                r = random.randint(7, 15)
                print('Rotating in', r, 'requests')
            if inc > r:
                rotate=True
            else:
                rotate=False
                inc+=1

            if rotate is True:
                #connect to a random proxy
                if proxy is not None:
                    countries = ['jp', 'fr', 'ch', 'us-ny', 'us-fl', 'uk', 'sg'] #, 'nl', 'de', 'us']
                    random_country = random.choice(countries)
                    print('Connecting to:', random_country)
                    proxy = proxy[random_country]

                #connect to proxy
                driver.quit()
                time.sleep(1)
                driver = launch_driver(show_browser, proxy)
                log_to_proxy(driver, proxy)

                #reset
                r = 0
                inc = 0
                rotate=False

            return driver, r, inc, rotate

        else:
            return driver, 0, 0, False

    return None, 0, 0, False

def strip_accents(text):
    try:
        ntext = unicodedata.normalize('NFKD', text) #better than NFD
        ntext = ntext.encode('ascii', 'ignore')
        ntext = ntext.decode("utf-8")
        return str(ntext)
    except:
        return text

def format_brand(x, symbol):
    try:
        if x is None:
            return x
        x = str(x).lower()
        x = x.replace("&", "").replace("-", "").replace("_", "").replace("'", "").replace(".", "")
        x = strip_accents(x)

        if symbol is not None:
            if symbol == "{+}":
                x = re.sub('\s+', '+', x)
                print(x)
            elif symbol == "{%20}":
                x = re.sub('\s+', '%20', x)
            elif symbol == "{-}":
                x = re.sub('\s+', '-', x)
            elif symbol == "{}":
                x = re.sub('\s+', '', x)
                
        return x
    except Exception as e:
        #print(e)
        return x

def format_start_url_all(url, brand):
    try:
        new_url = url
        
        #change
        if '{+}' in url:
            formated_brand = format_brand(brand, '{+}')
            new_url = re.sub('\{\+\}', formated_brand, new_url)
        elif '{%20}' in url:
            formated_brand = format_brand(brand, '{%20}')
            new_url = re.sub('\{%20\}', formated_brand, new_url)
        elif '{-}' in url:
            formated_brand = format_brand(brand, '{-}')
            new_url = re.sub('\{-\}', formated_brand, new_url)
        elif '{}' in url:
            formated_brand = format_brand(brand, '{}')
            new_url = re.sub('\{\}', formated_brand, new_url)

        #change page number to '{}' to adapt to other formating in scrape.py
        if '{i}' in url:
            new_url = re.sub('{i}', '{}', new_url)

        return new_url
    except Exception as e:
        #print(e)
        return new_url



