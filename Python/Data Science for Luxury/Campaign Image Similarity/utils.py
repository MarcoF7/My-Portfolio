import os
import datetime
import re
import numpy as np
import pandas as pd
import unicodedata
import hashlib

import random
from fake_useragent import UserAgent

#from forex_python.converter import CurrencyRates
from cosmetics.parsing.forex.forex_rater import HistoricalForexRater, ForexRater

from deep_translator import GoogleTranslator
from googletrans import Translator

def deep_translate(text):
    #text should be less than 5000 characters
    try:
        text = str(text)
        translator = GoogleTranslator(source='auto', target='en', proxies=get_proxy(True, None))
        translated = translator.translate(text)
        #print(translated)
        return translated
    except Exception as e:
        print(e)
        return None

def get_proxy(proxy, country):
    countries = ['fr', 'us', 'us-ny', 'us-fl', 'uk']
    country_proxies = {c: ':@{}.proxymesh.com:'.format(c) for c in countries}

    if proxy == True:
        if country is None:
            random_country = random.choice(countries)
            http_country = country_proxies[random_country]
        else:
            http_country = country_proxies[country]
        proxy = {'http': 'http://{}'.format(http_country)}
    else:
        proxy = None

    return proxy

def translate_with_google(string, source='auto', destination='en'):
    try:
        proxy = get_proxy(True, None)
        translator = Translator(user_agent=UserAgent().random, proxies=proxy)
        translated_string = translator.translate(string, dest=destination, src=source).text
        if translated_string is not None:
            print(translated_string)
            return translated_string
        else:
            return ''
    except Exception as e:
        print(e)
        return None

def invert(d):
    return dict((v,k) for k in d for v in d[k])

dict_ml_to_oz={
        3: ['0.1', '.1'],
        5: ['0.17', '0,17'],
        10: ['0.33', '0.34'],
        15: ['0.5', '0,5', ' .5'],
        25: ['0.8','0.84', 'O.85', '.84', '0-8', '0-84', '0-85', '0,8', '0,84', '0,85'],
        30: ['1', '1.0', '1,0'],
        35: ['1.1', '1.18', '1.2', '1-1', '1-2', '1,2', '1,1'],
        40: ['1.3', '1.35', '1.4', '1-3', '1-4', '1,3', '1,35', '1,4', '1.33'],
        50: ['1.6', '1.7', '1-6', '1-7', '1,6', '1,7'],
        60: ['2', '2.0', '2,0'],
        65: ['2.2', '2-2', '2.3', '2-3', '2,2', '2,3'],
        75: ['2.5', '2-5', '2,5', '2.6'],
        85: ['2.8','2.87', '2-8', '2-87', '2,8', '2,87'],
        90: ['3','3.04', '3.0', '3,0'],
        100:['3.4','3.3','3-4','3-3', '3,4', '3,3'],
        125:['4.2', '4-2', '4,2'],
        150:['5', '5.0', '5,0'],
        200:['6.8', '6.7', '6-8', '6-7', '6,7', '6,8'],
        225:['7.5', '7.6'],
        250:['8.5'],
        300:['10', '10.0'],
        400:['13.5'],
        450:['15.2'],
        500:['17', '16.9']
        }

dict_oz_to_ml = invert(dict_ml_to_oz)

def get_abs_path(rel_path):
   return os.path.join(os.path.dirname(__file__), rel_path)

def invert(d):
    return dict((v,k) for k in d for v in d[k])

def week_of_month(dt):
    """
    Returns the week of the month for the specified date
    """
    d = dt.day
    if d >= 1 and d <= 7:
        return 1
    elif d > 7 and d <= 14:
        return 2
    elif d > 14 and d <= 21:
        return 3
    else:
        return 4

def strip_accents(text):
    try:
        ntext = unicodedata.normalize('NFKD', text) #better than NFD
        ntext = ntext.encode('ascii', 'ignore')
        ntext = ntext.decode("utf-8")
        return str(ntext)
    except:
        return text

def clean_string(x):
    try:
        if x is None:
            return x
        x = str(x).lower()
        x = x.replace(" ", "").replace("-", "").replace("_", "").replace("'", "").replace(".", "")
        #nx = strip_accents(x)
        return x
    except:
        return x

def get_life_span_info(life_span_date):
    if life_span_date is None:
        life_span_date = datetime.date.today()
    else:
        try:
            life_span_date = datetime.datetime.strptime(
                life_span_date, "%Y-%m-%d"
            ).date()
        except:
            pass
    year = life_span_date.strftime("%Y")
    month = life_span_date.strftime("%B")
    quarter = "Q{0}".format(week_of_month(life_span_date))
    life_span = "{0} {1} {2}".format(quarter, month, year)
    return life_span

def format_mapping(exp):
    exp = re.sub('\s', '', exp)
    if '+' in exp:
        val = ''
        for el in exp.split('+'):
            val += '(?=.*'+str(el)+')'
        new_exp = val + '.*'
        return new_exp
    else:
        return exp

def clean_price(string):
    try:
        string = str(string)
        string = re.sub(' ', '', string)
        match = re.findall('[0-9]+', string)
        if len(match)>0:
            if len(match)==1:
                price = round(float(match[0]), 2)
                return price
            elif len(match)>1:
                if len(match[-1]) == 2:
                    if match[-1] == '00':
                        price = round(float(''.join(match[:-1])), 2)
                        return price
                    else:
                        uint = ''.join(match[:-1])
                        udec = match[-1]
                        price = round(float(uint + '.' + udec), 2)
                        return price
                elif len(match[-1]) > 2:                            
                    price = round(float(''.join(match)), 2)
                    return price
                elif len(match[-1]) == 1:
                    uint = ''.join(match[:-1])
                    udec = match[-1]
                    price = round(float(uint + '.' + udec), 2)
                    return price
        return 0
    except Exception as e:
        return 0

def extract_year(x, order_l=[0]):
    try:
        x = re.sub('\s{2,}', ' ', x)
        x = strip_accents(x)

        row_str = x.split('||')
        if len(row_str)==1:
            order_l = [0]
            
        #try to match age for whisky
        for i in order_l:
            string = row_str[i]
            for y in ['year', 'anos', 'ans']:
                match = re.findall('\d{1,2}\s{0,1}'+y, string)
                no_match = re.findall('\d{3,}\s{0,1}'+y, string)
                if len(match)>0 and len(no_match)==0:
                    age = str(match[0])
                    age = re.sub(y, '', age)
                    age = re.sub(' ', '', age)
                    age = age + ' year old'
                    return age
        #try to match year for wines (or whisky if age has not been found)
        for i in order_l:
            string = row_str[i]
            match = re.findall('19\d{2}|20\d{2}', string)
            if len(match)==1:
                year = str(match[0])
                return year
        return None
    except Exception as e:
        return None

def iter_capacity(source, order_l=[0]):
    try:
        source_l = source.split('||')
        if len(source_l)==1:
            order_l = [0]

        for i in order_l:
            source_i = source_l[i]

            capacity = extract_capacity(source_i)

            if capacity is not None:
                return capacity

        return None
    except:
        return None

def extract_capacity(string):
    try:
        string = str(string).lower()
        ns = re.sub('\s{2,}', ' ', string)
        
        for unit in ['ml', 'мл', 'cl', 'oz', 'ounce', 'fl', 'g', 'l']:
            if unit == 'cl':
                match = re.findall(r"\d{1,3}\s{0,1}"+unit, ns)
            elif unit == 'ml' or unit == 'мл':
                match = re.findall(r"\d{1,4}\s{0,1}"+unit, ns)
            elif unit == 'l':
                match = re.findall(r"\d[\,\.]\d{1,2}\s{0,1}"+unit+"|\d\s{0,1}"+unit, ns)
            elif unit == 'g':
                match = re.findall(r"\d{1,3}\s{0,1}"+unit, ns)
            elif (unit == 'oz' or unit == 'ounce' or unit == 'fl'):
                match = re.findall(r"\d[\,\.]\d{1,2}\s{0,1}"+unit+"|\d\s{0,1}"+unit, ns) #similar to l

            match_year = re.findall('19\d{2}\s{0,1}'+unit +'|20\d{2}\s{0,1}'+unit, ns)
            #to get one unique capacity
            match = list(set(match))
            if len(match)==1 and len(match_year)==0:
                volume_nc = match[0]
                volume = re.sub(',', '.', volume_nc).upper()
                V = convert_volume_to_ML(volume)
                return V
        """
        if len(ns)<30:
            #find ml volume
            match = re.findall("[1-9]\d{1,2}", string)
            if len(match)==1:
                volume = match[0] + 'ML'
                V = convert_volume_to_ML(volume)
                return V
            #find cl volume
            match = re.findall("[1-9]\d{1,2}", string)
            if len(match)==1:
                volume = match[0] + 'CL'
                V = convert_volume_to_ML(volume)
                return V
            #find l volume
            match = re.findall(r"\d[\,\.]\d{1,2}|\d", string)
            if len(match)==1:
                volume_nc = match[0]
                volume = re.sub(',', '.', volume_nc).upper() + 'L'
                V = convert_volume_to_ML(volume)
                return V
        """
        return None
    except Exception as e:
        return None

def convert_volume_to_L(volume):
    #acceptable_volumes = ['0.35', '0.5', '0.6', '0.7', '0.75', '1.0', '1.5', '1.75', '2.0', '2.5', '3.0', '3.5', '4.0', '4.5', '5.0']
    try:
        volume = re.sub(' ', '', volume)
        if 'CL' in volume:
            unit = 'CL'
            V = re.sub(unit, '', volume)
            VL = str(float(V)/100)
            VL = normalize_capacity(VL)
            return VL
            if VL in acceptable_volumes:
                return VL
        elif 'ML' in volume:
            unit = 'ML'
            V = re.sub(unit, '', volume)
            VL = str(float(V)/1000)
            VL = normalize_capacity(VL)
            return VL
            if VL in acceptable_volumes:
                return VL
        elif 'L' in volume:
            unit = 'L'
            V = re.sub(unit, '', volume)
            VL = str(float(V))
            VL = normalize_capacity(VL)
            return VL
            if VL in acceptable_volumes:
                return VL
        return None
    except:
        return None

def convert_volume_to_ML(volume):
    #acceptable_volumes = ['0.35', '0.5', '0.6', '0.7', '0.75', '1.0', '1.5', '1.75', '2.0', '2.5', '3.0', '3.5', '4.0', '4.5', '5.0']
    try:
        volume = re.sub(' ', '', volume)
        if 'CL' in volume:
            unit = 'CL'
            V = re.sub(unit, '', volume)
            VL = str(float(V)*10)
            VL = normalize_capacity(VL) + 'ml'
            return VL
            if VL in acceptable_volumes:
                return VL
        elif ('ML' in volume or 'мл' in volume):
            V = re.sub('ML', '', volume)
            V = re.sub('мл', '', V)
            VL = str(float(V))
            VL = normalize_capacity(VL) + 'ml'
            return VL
            if VL in acceptable_volumes:
                return VL
        elif 'G' in volume:
            unit = 'G'
            V = re.sub(unit, '', volume)
            VL = str(float(V))
            VL = normalize_capacity(VL) + 'g'
            return VL
            if VL in acceptable_volumes:
                return VL
        elif 'L' in volume:
            unit = 'L'
            V = re.sub(unit, '', volume)
            VL = str(float(V)*1000)
            VL = normalize_capacity(VL) + 'ml'
            return VL
            if VL in acceptable_volumes:
                return VL
        elif 'OZ' in volume or 'OUNCE' in volume or 'FL' in volume:
            V = re.sub('OZ', '', volume)
            V = re.sub('OUNCE', '', V)
            V = re.sub('FL', '', V)
            if V in dict_oz_to_ml:
                VL = str(dict_oz_to_ml[V])
                VL = normalize_capacity(VL) + 'ml'
                return VL
            
        return None
    except:
        return None

def normalize_capacity(volume):
    #if '.' in volume:
    if '.' not in volume:
        #volume = volume + '.0'
        return volume
    else:
        volume = re.sub('.0$', '', volume)
        return volume

def extract_batch(string):
    batch_kw_list = ['carton', 'caisse', 'lot', 'set']
    batch_list = ['12', '6', '3']
    batch = None
    try:
        string = str(string).lower()
        
        for kw in batch_kw_list:
            if kw in string:
                for n in batch_list:
                    if n in string:
                        return n
                batch = 1
         #return None if kw not in text else return 1 if batch but no batch number detected
        return batch
    except Exception as e:
        return None
            
def compute_hash(string):
    try:
        hash_id = hashlib.sha512(string.encode("utf-8")).hexdigest()
        return hash_id
    except:
        return None
        
def get_id_hash(category, website, seller, url, dict1):
    if category == 'zz':
        try:
            wid_string = website + seller + url + dict1['name'] + dict1['year'] + dict1['capacity']
            wid_hash = compute_hash(wid_string)
            return wid_hash
        except Exception as e:
            return None
    return None


def create_valid_ref_code(category, subcategory, product_name, typ, capacity):
    try:
        valid_ref_code = ''
        if product_name is None:
            return None
        if category == 'Fragrance':
            if subcategory is None:
                l = [product_name, typ, capacity]
                #check capacity is None
                #if l[-1] is None:
                    #return None
            elif subcategory not in ["Set", "Refill"]:
                l = [subcategory, product_name, typ, capacity]
            else:
                return None

        else:
            l = [subcategory, product_name, capacity]

        for i in range(len(l)):
            try:
                valid_ref_code += l[i]
                valid_ref_code += ' '
            except:
                pass
        valid_ref_code = valid_ref_code.strip()

        if valid_ref_code != '':
            return valid_ref_code
        else:
            return None
    except:
        return None

def url_formating(website, url):
    format_dict = {
        'sephora.fr': {'&format=ajax': ''}
    }
    if website in format_dict.keys():
        for k, v in format_dict[website].items():
            url = re.sub(k, v, url)

    return url

def get_delta(official_retail_price, normalised_price):
    threshold_max_delta = 10000
    try:
        if normalised_price > 0 and official_retail_price > 0:
            delta = (100 - normalised_price * 100 /official_retail_price) * -1
            if delta < threshold_max_delta:
                return round(delta, 2)
        return None
    except:
        return None

def normalise_price(price, currency, country, official_prices):
    #c = CurrencyRates()
    exr_eur = ForexRater(currency_from="EUR").get_forex_rates()
    exr_usd = ForexRater(currency_from="USD").get_forex_rates()
    exr_chf = ForexRater(currency_from="CHF").get_forex_rates()
    if currency in official_prices:
        # Here, we don't have to convert price for pivot calculation 
        # so we normalised_price = price
        normalised_price = price
        normalised_currency = currency

        if currency == "EUR":
            # If it is EUR, we need to distinguish from different country
            if country in official_prices[currency]:
                off_price = official_prices[currency][country]
            else:
                ref_country = next(iter(official_prices[currency]))
                off_price = official_prices[currency][ref_country]
        else:
            ref_country = next(iter(official_prices[currency]))
            off_price = official_prices[currency][ref_country]
    else:
        # If the currency is not listed, we try to use USD as a pivot
        if "USD" in official_prices:
            normalised_currency = "USD"

            ref_country = next(iter(official_prices["USD"]))
            off_price = official_prices["USD"][ref_country]
            # Here, we need to convert the offer price in USD
            
            dict_cur_usd = {
                "AED": 0.272294,
                "BYN": 0.41506,
                "NGN": 0.00258,
                "BHD": 2.65957,
                "EGP": 0.06227,
                "BDT": 0.01179,
                "KZT": 0.00245,
                "UAH": 0.03699,
                "CLP": 0.00125,
                "TWD": 0.03394,
                "VND": 0.000044,
                "MMK": 0.000537
            }
            
            if currency in dict_cur_usd.keys():
                try:
                    normalised_price = round(dict_cur_usd[currency]*float(price), 2)
                except Exception as e:
                    normalised_price = None
            else:
                try:
                    #exr = c.get_rates(normalised_currency)
                    exr = exr_usd
                    normalised_price = round(float(price)/exr[currency], 2)
                except Exception as e:
                    normalised_price = None
        elif "EUR" in official_prices:
            normalised_currency = "EUR"

            if "FRCA" in official_prices["EUR"]:
                ref_country = "FRCA"
            else:
                ref_country = next(iter(official_prices["EUR"]))
            off_price = official_prices["EUR"][ref_country]
            
            dict_cur_eur = {
                    "AED": 0.2407,
                    "BYN": 0.36689,
                    "NGN": 0.00228,
                    "BHD": 2.35098,
                    "EGP": 0.05505,
                    "BDT": 0.01042,
                    "KZT": 0.00216,
                    "UAH": 0.0327,
                    "CLP": 0.00111,
                    "TWD": 0.03,
                    "VND": 0.0000378,
                    "MMK": 0.00046
                }
            if currency in dict_cur_eur.keys():
                try:
                    normalised_price = round(dict_cur_eur[currency]*float(price), 2)
                    normalised_currency = "EUR"
                except Exception as e:
                    normalised_price = None
            else:
                try:
                    #exr = c.get_rates(normalised_currency)
                    exr = exr_eur
                    normalised_price = round(float(price)/exr[currency], 2)
                except Exception as e:
                    normalised_price = None
        elif "CHF" in official_prices:
            normalised_currency = "CHF"

            ref_country = next(iter(official_prices["CHF"]))
            off_price = official_prices["CHF"][ref_country]
            try:
                #exr = c.get_rates(normalised_currency)
                exr = exr_chf
                normalised_price = round(float(price)/exr[currency], 2)
            except Exception as e:
                normalised_price = None
        else:
            off_price = None
            normalised_price = None
            normalised_currency = None

    return off_price, normalised_price, normalised_currency

def correct_based_on_ref_found(kw, reference):
    try:
        if kw in reference:
            return kw
        #only specific case
        elif kw == "Fragrance":
            if 'EDP' in reference or 'EDT' in reference or 'EDC' in reference:
                return kw
            else:
                return None
        else:
            return None
    except Exception as e:
        #print(e)
        return kw

