#!/usr/bin/env python3

import json
import yaml
from yaml import Loader
import os
import requests
import argparse
import subprocess
import glob
import shutil

parser = argparse.ArgumentParser(description='Run dextorm experiment')
parser.add_argument('dextorm_jar_path', help="the path to the dextorm executable")
parser.add_argument('dextorm_conf_path', help="the path to the dextorm configuration file")
parser.add_argument('jacoco_report_xml', help="the path to the jacoco report xml file")
args = parser.parse_args()
'''
class Args:
    def __init__(self):
        self.dextorm_jar_path="/home/nherbaut/workspace/dextorm/DEXTORM/target/dextorm.jar"
        self.dextorm_conf_path="/home/nherbaut/workspace/dextorm/DEXTORM/src/main/resources/dextorm.yaml"
        self.jacoco_report_xml="/home/nherbaut/workspace/dextorm/dextorm-dummy-project/target/site/jacoco-ut/jacoco.xml"
    
args=Args()
'''
print(f"using report {args.jacoco_report_xml}")
if os.path.isdir(args.jacoco_report_xml):
    for dirpath, dirnames, filenames in os.walk(args.jacoco_report_xml):
        targets_xml_files=[os.path.join(dirpath,f) for f in filenames if f.endswith(".xml")]
        break
else:
    targets_xml_files=[args.jacoco_report_xml]

with open(args.dextorm_conf_path) as f:
    conf=yaml.load(f,Loader=Loader)

for targets_xml_file in targets_xml_files:
    if os.path.exists("tmp-json"):
        shutil.rmtree("tmp-json")
    os.mkdir("tmp-json")
    for temp_json in glob.glob('*.json'):
        os.remove(temp_json)
    print(f"processing {targets_xml_file}")
    for method in conf["differs"].keys():
        conf["app"]["diffAlgorithm"]=method
        with open("dextorm.yaml","w") as ff:
            yaml.dump(conf, ff)
        print(f"running with {method}") 
        subprocess.run(["java","-jar", args.dextorm_jar_path, "dextorm.yaml", targets_xml_file])
        
    data={}

    for dirpath, dirnames, filenames in os.walk("tmp-json"):
        for filename in [fn for fn in filenames if fn.endswith(".json")]:
            with open(os.path.join(dirpath,filename)) as f:
                print(f"loading json file {dirpath}/{filename}")
                json_content=json.load(f)
                usId,value = list(json_content.items())[0]
                
                if usId not in data:
                    data.update(json_content)
                    continue
                algotype,measurement=list(value.items())[0]
                if algotype in data[usId]:
                    data[usId][algotype].update(measurement)
                else:
                    data[usId].update({algotype:measurement})
                
        break
    
    with open(f"{targets_xml_file}.json","w") as result_json_file:
        json.dump(data, result_json_file)
    shutil.rmtree("tmp-json")
    


            
