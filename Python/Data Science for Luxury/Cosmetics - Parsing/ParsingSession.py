# coding=utf-8
from db.Logger import Logger
from db.Session import Session
from cosmetics.parsing import utils

import pandas as pd
import tqdm
import sys
import os
import yaml
import datetime
import numpy as np
import re
import unicodedata

class ParsingSession(Session):
    def __init__(self, db_scope, time_scope, brand, all_offers):
        Session.__init__(self, db_scope)
        self.logger = Logger("parsing").logger

        self.all_offers = all_offers
        self.time_scope = time_scope

        self.brand = brand

        # Holds the list of uids to discard
        self.discard = []

        #Load data
        self.extract_brand_uids()
        self.extract_seller_country()

        self.extract_product_brand()
        self.get_exp()
        #self.update_exp_ranking()
        self.regexp_mapping()

        self.load_offers()

        self.get_meta_cluster()
        self.get_ref()

#DB DATA LOADING FUNCTIONS
##################################################################################################
    def extract_brand_uids(self):
        stmt = """SELECT full_name, uid FROM cosmetics.brand"""
        res = self.entry_point.query(stmt)
        self.dict_brands = {brand: brand_uid for brand, brand_uid in res}

    def extract_product_brand(self):
        stmt = """SELECT product_name, brand FROM cosmetics.product_brand"""
        res = self.entry_point.query(stmt)
        self.dict_product_brand = {product_name : brand for product_name, brand in res}

    def get_brand_full_name(self, brand_name):
        if brand_name is not None:
            stmt = """SELECT name, full_name FROM cosmetics.brand"""
            res = self.entry_point.query(stmt)

            try:
                brand_dict = {}
                for name, brand in res:
                    brand_dict[name] = brand

                self.brand = brand_dict[brand_name]
            except:
                self.logger.error("brand full name not found")
                sys.exit(1)
        else:
            self.brand = None

    def extract_seller_country(self):
        stmt = """
        SELECT uid, country FROM cosmetics.seller 
        """
        res = self.entry_point.query(stmt)
        self.seller_country = {seller_uid: country for seller_uid, country in res}

    def get_exp(self):
        stmt = """
        SELECT e.uid, e.class, e.N_EXP, e.exp, e.exp_rank FROM cosmetics.exp e
        """

        print("Gathering expressions informations ...")

        self.exp = self.entry_point.query(stmt)
        
        self.exp_dict = {}
        for obj in self.exp:
            CLASS = obj[1]
            if CLASS not in self.exp_dict.keys():
                self.exp_dict[CLASS] = {}
            N_EXP = obj[2]
            exp = obj[3]
            exp_rank = obj[4]
            if N_EXP not in self.exp_dict[CLASS]:
                self.exp_dict[CLASS][N_EXP] = [(exp, exp_rank)]
            else:
                self.exp_dict[CLASS][N_EXP] += [(exp, exp_rank)]

    def get_meta_cluster(self):
        stmt = """
        SELECT mc.uid, mc.c_subgroup, mc.sub_N_EXP, mc.N_EXP, mc.c_group FROM cosmetics.metacluster mc
        """

        print("Gathering metacluster information ...")

        self.metacluster = self.entry_point.query(stmt)
        
        self.mc_dict = {}
        for obj in self.metacluster:
            sub_N_EXP = obj[2]
            N_EXP = obj[3]
            if sub_N_EXP not in self.mc_dict.keys():
                self.mc_dict[sub_N_EXP] = N_EXP

    def get_ref(self):
        stmt = """
        SELECT brand, valid_ref_code, capacity, data_origin, price, currency, country, life_cycle FROM cosmetics.ref_latest
        """

        print("Extracting references & related info : prices & life cycles from MySQL...")

        self.ref = self.entry_point.query(stmt)

        #to store retail prices
        self.rw_dict = {}
        #to store product life cycles
        self.lc_dict = {}
        #to store subcategory + product_name
        self.subcategory_product_capa_dict = {}

        for brand, valid_ref_code, capacity, data_origin, price, currency, country, life_cycle in self.ref:
            if brand not in self.rw_dict.keys():
                self.rw_dict[brand] = {}
            if valid_ref_code not in self.rw_dict[brand]:
                self.rw_dict[brand][valid_ref_code] = {}
            if data_origin not in self.rw_dict[brand][valid_ref_code]:
                self.rw_dict[brand][valid_ref_code][data_origin] = {}
            if currency not in self.rw_dict[brand][valid_ref_code][data_origin]:
                self.rw_dict[brand][valid_ref_code][data_origin][currency] = {}
            self.rw_dict[brand][valid_ref_code][data_origin][currency][country] = price

            if brand not in self.lc_dict.keys():
                self.lc_dict[brand] = {}
            if valid_ref_code not in self.lc_dict[brand]:
                self.lc_dict[brand][valid_ref_code] = life_cycle

            if brand not in self.subcategory_product_capa_dict.keys():
                self.subcategory_product_capa_dict[brand] = {}
            if valid_ref_code is not None:
                subcategory_product_name = re.sub(r'[0-9]*(ml|g|kg|)$|Pack of', '', valid_ref_code).strip()
                if subcategory_product_name not in self.subcategory_product_capa_dict[brand]:
                    self.subcategory_product_capa_dict[brand][subcategory_product_name] = []
                if capacity is not None and capacity not in self.subcategory_product_capa_dict[brand][subcategory_product_name]:
                    self.subcategory_product_capa_dict[brand][subcategory_product_name] += [capacity]


    def update_exp_ranking(self):
        print("Extracting offers from MySQL...")
        #ranking based on all offers
        stmt = """
        SELECT o.uid, o.raw FROM cosmetics.offers o
        """

        offers = self.entry_point.query(stmt)

        sources = [utils.clean_string(raw) for uid, raw in offers]

        occ_list = []
        for row in tqdm.tqdm(self.exp):
            uid, classe, _, exp, _ = row
            regexp = utils.format_mapping(exp)
            sum_occ = 0
            for source in sources:
                match = re.findall(regexp, source)
                sum_occ += len(match)
            occ_list += [(sum_occ, uid, classe)]

        df = pd.DataFrame(occ_list, columns=["freq", "uid", "class"])
        df["exp_rank"] = df["freq"].rank(method='first', ascending=False)
        df["exp_rank"] = df["exp_rank"].apply(lambda x : int(x))
        updates = df[["freq", "exp_rank", "uid"]].to_dict('records')
        #updates = [tuple(x) for x in fdf.values]
        """
        fdf = pd.DataFrame()
        for classe in df["class"].unique():
            subdf = df[df["class"]==classe]
            subdf["exp_rank"] = subdf["freq"].rank(method='first', ascending=False)
            fdf = pd.concat([fdf, subdf], sort='False', ignore_index=True)
        fdf = fdf[["freq", "exp_rank", "uid"]]
        """
        # Update expression ranking table
        print("Updating occurence and rank for {} expressions in database".format(len(updates)))

        update_stmt = """
        UPDATE cosmetics.exp SET freq = %(freq)s, exp_rank = %(exp_rank)s 
        WHERE uid = %(uid)s"""

        self.entry_point.execute_many(update_stmt, updates)
        print("Added frequency and ranks.")

        #query again exp
        self.get_exp()

    def regexp_mapping(self):
        self.regexp_dict = {exp[3]: utils.format_mapping(exp[3]) for exp in self.exp}

    def load_offers(self):
        print("Extracting unprocessed offers from MySQL...")

        stmt = """
        SELECT o.uid, o.raw, o.currency, o.website, o.seller_uid FROM cosmetics.offers o
        WHERE (o.processed = 0 OR %(all_offers)s IS TRUE)
        """
        if self.time_scope:
            stmt += """AND o.time_scope = %(time_scope)s"""

        if self.brand:
            stmt += """AND SUBSTRING_INDEX(o.raw, ' ', 1) = %(brand)s"""

        self.offers = self.entry_point.query(stmt, {"time_scope": self.time_scope, "brand": self.brand, "all_offers": self.all_offers})

        if len(self.offers)==0:
            self.logger.error("No unprocessed offers found")
            sys.exit(1)

#PARSING FUNCTIONS 
##################################################################################################

    def parse_column(self, source, source_translated, CLASS, order_l=[0]):
        try:
            source = utils.clean_string(source)
            source_l = source.split('||')

            source_translated = utils.clean_string(source_translated)
            if source_translated is not None:
                source_translated_l = source_translated.split('||')

            if len(source_l)==1:
                order_l = [0]

            res = {}
            for i in order_l:
                source_i = source_l[i]
                if source_translated is not None:
                    source_i_translated = source_translated_l[i]

                for N_EXP, exprank_tuple_list in self.exp_dict[CLASS].items():
                    for exp, exp_rank in exprank_tuple_list:
                        match = re.findall(self.regexp_dict[exp], source_i)
                        if source_translated is not None:
                            match_translate = re.findall(self.regexp_dict[exp], source_i_translated)
                        else:
                            match_translate = []
                        if len(match)>0 or len(match_translate)>0:
                            if N_EXP not in res:
                                res[N_EXP] = [(exp, exp_rank)]
                            else:
                                res[N_EXP] += [(exp, exp_rank)]
                        else:
                            source_i_decode = utils.strip_accents(source_i)
                            match = re.findall(self.regexp_dict[exp], source_i_decode)
                            if len(match)>0:
                                if N_EXP not in res:
                                    res[N_EXP] = [(exp, exp_rank)]
                                else:
                                    res[N_EXP] += [(exp, exp_rank)]

                if len(res.keys())==1:
                    f_N_EXP = list(res.keys())[0]
                    return f_N_EXP
                #select a specific final result between multiple results possibles
                elif len(res.keys())>1:
                    kw_count={}
                    for N_EXP, exprank_tuple_list in res.items():
                        count = 0
                        for exp, exp_rank in exprank_tuple_list:
                            count+= len(exp.split('+'))
                        kw_count[N_EXP] = count

                    max_N_EXP = max(kw_count, key=kw_count.get)
                    max_count = kw_count[max_N_EXP]
                    count_values = list(kw_count.values())

                    if count_values.count(max_count)>1:
                        #discriminant ranking
                        #suppress N_EXP having count inferior to the max
                        res = {N_EXP: res[N_EXP] for N_EXP, count in kw_count.items() if count >= max_count}

                        try:
                            mini = 0
                            for N_EXP, exprank_tuple_list in res.items():
                                for exp, exp_rank in exprank_tuple_list:
                                    r = exp_rank
                                    if r > mini:
                                        mini = r
                                        p_N_EXP = N_EXP
                                    elif r == mini:
                                        if len(N_EXP)>len(p_N_EXP):
                                            p_N_EXP = N_EXP
                            f_N_EXP = p_N_EXP
                            return f_N_EXP
                        except:
                            pass

                    else:
                        f_N_EXP = max_N_EXP
                        return f_N_EXP
            return None
        except Exception as e:
            return None

    def parsing(self):
        print('Parsing information from raw data')
        #raw_columns_order = ['brand', 'url', 'title', 'capacity', 'price', 'currency', 'availability', 'image_url']
        update_batch = []

        for offer in tqdm.tqdm(self.offers):
            uid, raw, currency, website, seller_uid = offer
            raw_translated = utils.deep_translate(raw)
            country = self.seller_country.get(seller_uid, None)

            subcategory = self.parse_column(raw, raw_translated, 'subcategory', [2, 1, 3])
            typ = self.parse_column(raw, raw_translated, 'type', [3, 2])

            category = self.parse_column(raw, raw_translated, 'category', [2, 1])
            category = self.meta_clustering(category, subcategory)
            category = self.meta_clustering(category, typ)


            brand = self.parse_column(raw, raw_translated, 'brand', [2, 1, 0])
            brand_uid = self.dict_brands.get(brand, None)

            product_name = self.parse_column(raw, raw_translated, 'product_name', [2, 1])
            product_name = self.additional_check_with_brand(product_name, brand)
            collection = self.parse_column(raw, raw_translated, 'collection', [2, 1])
            #capacity
            capacity = utils.iter_capacity(raw, [3, 2, 1])

            availability_nc = raw.split("||")[6].strip()
            availability = self.parse_column(availability_nc, None, 'availability')
            #if availability is None and date is included add a specific function

            image_url = raw.split("||")[7].strip()
            if image_url == '':
                image_url = None

            #price
            price_nc = raw.split("||")[4].strip()
            price = utils.clean_price(price_nc)

            #reference
            valid_ref_code = utils.create_valid_ref_code(category, subcategory, product_name, typ, capacity)
            
            reference, official_retail_price, normalised_currency, normalised_price, price_delta, in_range, life_cycle = self.assign_valid_ref_code(brand, collection, valid_ref_code, price, currency, country, subcategory, product_name, typ, capacity)

            typ = utils.correct_based_on_ref_found(typ, reference)
            subcategory = utils.correct_based_on_ref_found(subcategory, reference)
            category = utils.correct_based_on_ref_found(category, reference)

            dict1 = {
                'uid': uid,
                'image_url': image_url,
                'category': category,
                'subcategory': subcategory,
                'brand': brand,
                'brand_uid': brand_uid,
                'collection': collection,
                'product_name': product_name,
                'type': typ,
                'capacity': capacity,
                'reference': reference,
                'price': price,
                'normalised_price': normalised_price, 
                'normalised_currency': normalised_currency,
                'official_retail_price': official_retail_price,
                'price_delta': price_delta,
                'life_cycle': life_cycle,
                'in_range' : in_range,
                'availability': availability,
                'is_tester': None,
                'batch': None,
                'processed': 1
                }

            #pid_hash = utils.get_id_hash(self.category, website, seller, url, dict1)
            #dict1.update({'pid_hash': pid_hash})

            update_batch += [dict1]

        #update offers
        self.update_offers(update_batch)

    def update_offers(self, update_batch):
        #Update offers
        update_stmt = """
        UPDATE cosmetics.offers SET image_url = %(image_url)s,
                                   category = %(category)s,
                                   subcategory = %(subcategory)s,
                                   brand = %(brand)s,
                                   brand_uid = %(brand_uid)s,
                                   collection = %(collection)s,
                                   product_name = %(product_name)s,
                                   type = %(type)s,
                                   capacity = %(capacity)s,
                                   reference = %(reference)s,
                                   price = %(price)s,
                                   normalised_price = %(normalised_price)s,
                                   normalised_currency = %(normalised_currency)s,
                                   official_retail_price = %(official_retail_price)s,
                                   price_delta = %(price_delta)s,
                                   life_cycle = %(life_cycle)s,
                                   in_range = %(in_range)s,
                                   availability = %(availability)s,
                                   is_tester = %(is_tester)s,
                                   batch = %(batch)s,
                                   processed = %(processed)s
        WHERE uid = %(uid)s
        """
        print("Updating database records...")
        self.entry_point.execute_several(update_stmt, update_batch)
        print("Updated.")

    def discard_offers(self):
        stmt = "UPDATE cosmetics.offers SET is_discarded = 1 WHERE uid = %s"
        # Prepare batch
        batch = [(uid, ) for uid in set(self.discard)]
        print("{0} offers discarded ...".format(len(batch)))
        self.entry_point.execute_several(stmt, batch)
        print("Discarded.")

    def meta_clustering(self, group_N_EXP, subgroup_N_EXP):
        if group_N_EXP is not None:
            return group_N_EXP
        else:
            if subgroup_N_EXP is not None:
                if subgroup_N_EXP in self.mc_dict.keys():
                    return self.mc_dict[subgroup_N_EXP]
                return None
            else:
                return None

    def additional_check_with_brand(self, product_name, brand):
        #case brand found
        if brand is not None:
            #case product found
            if product_name in self.dict_product_brand.keys():
                true_brand = self.dict_product_brand[product_name]
                #no info about the brand of the product
                if true_brand is None:
                    return product_name
                #product belongs to the brand scraped
                elif true_brand == brand:
                    return product_name
                #product found is wrong
                else:
                    return None
            else:
                return product_name
        #no check if brand is not found
        return product_name


    def validate_ref_found(self, brand, reference, capacity):
        found = False
        if reference is not None:
            if brand is not None and brand in self.rw_dict.keys():
                #reference without capacity
                reference_no_capa = re.sub(r'[0-9]*(ml|g|kg|)$|Pack of', '', reference).strip()

                #step 1 identify full ref in master data 
                if reference in self.rw_dict[brand].keys():
                    found = True
                #step 2 check if capacity is wrong
                if found is False:
                    if reference_no_capa in self.subcategory_product_capa_dict[brand].keys():
                        if capacity is None and len(self.subcategory_product_capa_dict[brand][reference_no_capa])==1:
                            new_capacity = self.subcategory_product_capa_dict[brand][reference_no_capa][0]
                            reference = reference_no_capa + ' ' + new_capacity
                            found = True

        return found, reference

    def assign_valid_ref_code(self, brand, collection, reference, price, currency, country, subcategory, product_name, typ, capacity):
        found = False
        if reference is not None:
            #create list to iterate : reference, reference without subcategory, reference without type, reference with collection
            ref_iter_list = [reference]
            #reference without subcategory
            if subcategory is not None:
                reference_no_subc = re.sub('^'+str(subcategory), '', reference).strip()
                if reference_no_subc not in ref_iter_list:
                    ref_iter_list += [reference_no_subc]
            else:
                reference_no_subc = reference
            #reference without type
            if typ is not None:
                reference_no_typ = re.sub('EDT|EDC|EDT', '', reference_no_subc).replace('  ', ' ').strip()
                if reference_no_typ not in ref_iter_list:
                    ref_iter_list += [reference_no_typ]
            #reference with collection
            if collection is not None:
                reference_with_col = (str(collection) + ' ' + reference_no_subc).strip()
                if reference_with_col not in ref_iter_list:
                    ref_iter_list += [reference_with_col]

            #print(ref_iter_list)
            for ref in ref_iter_list:
                found, reference = self.validate_ref_found(brand, ref, capacity)
                if found is True:
                    #print(found, reference)
                    break

        #start computing delta if found is True
        in_range = 0
        life_cycle = None
        if found is True:
            #get life cycle
            in_range = 1
            if brand in self.lc_dict.keys() and reference in self.lc_dict.keys():
                life_cycle = self.lc_dict[brand][reference]

            #select master data from client first and if it does not exist, use scraped master data from the web
            if 'master' in self.rw_dict[brand][reference].keys():
                official_prices = self.rw_dict[brand][reference]['master']
            else:
                official_prices = self.rw_dict[brand][reference]['web']
            
            official_retail_price, normalised_price, normalised_currency = utils.normalise_price(price, currency, country, official_prices)
            
            #in case official_retail_price = 0 with master compute again with web
            if official_retail_price == 0:
                if 'web' in self.rw_dict[brand][reference].keys():
                    official_prices = self.rw_dict[brand][reference]['web']
                    official_retail_price, normalised_price, normalised_currency = utils.normalise_price(price, currency, country, official_prices)

            price_delta = utils.get_delta(official_retail_price, normalised_price)
            #print(official_retail_price, normalised_price, normalised_currency, price_delta)

            return reference, official_retail_price, normalised_currency, normalised_price, price_delta, in_range, life_cycle

        return reference, 0, None, None, None, in_range, life_cycle




        
