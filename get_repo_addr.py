#!/usr/bin/env python3

import yaml
import argparse
    
parser = argparse.ArgumentParser(description='get informations on the current active repo address from issue collector')
parser.add_argument('-c', help="the path to the dextorm configuration file",default="dextorm.yaml")
parser.add_argument('-b', help="get the branch",action='store_true')
args = parser.parse_args()


with open(args.c) as f:
    conf=yaml.load(f,Loader=yaml.Loader)
    issueCollector=conf["app"]["issueCollector"]
    if args.b:
        print(conf["issueCollectors"]["github"][issueCollector].get("branch","master"))
    else:
        print(conf["issueCollectors"]["github"][issueCollector]["gitHubRepoName"])
