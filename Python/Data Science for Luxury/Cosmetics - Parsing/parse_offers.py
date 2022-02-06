# coding=utf-8
from cosmetics.parsing.ParsingSession import ParsingSession
import argparse
import os
import sys

def parse_args():
    ''' Handle the different parameters required to launch the script '''
    parser = argparse.ArgumentParser()
    parser.add_argument("-p", "--prod", help = "Execute on production database", action = "store_true")
    parser.add_argument("--span", help = "Restrict the offers to the specified life span (e.g. 'Q4 April 2021')")
    parser.add_argument("--brand", help = "parse a specific brand")
    parser.add_argument("--all", help = "Indicate that ALL offers should be considered (except those restricted with --span)", action = "store_true")
    args = parser.parse_args()
    return args

def main(args):
    if args.prod:
        db_scope = "prod"
    else:
        db_scope = "local"

    p = ParsingSession(db_scope, args.span, args.brand, args.all)

    p.parsing()


if __name__ == "__main__":
    main(parse_args())
