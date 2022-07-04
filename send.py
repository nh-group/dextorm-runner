#!/usr/bin/env python3


import requests
import yaml
import json
import argparse
import os

parser = argparse.ArgumentParser(description='Run dextorm experiment')
parser.add_argument('dextorm_conf_path',
                    help="the path to the dextorm configuration file")
parser.add_argument('jacoco_report_xml',
                    help="the path to the jacoco report xml file(s)")
args = parser.parse_args()

with open(args.dextorm_conf_path) as f:
    conf = yaml.load(f, Loader=yaml.Loader)

if os.path.isdir(args.jacoco_report_xml):
    for folder, _, files in os.walk(args.jacoco_report_xml):
        to_send_files = [os.path.join(folder,f) for f in files if f.endswith(".json")]
        break
else:
    to_send_files = [args.jacoco_report_xml]


for to_send_file in sorted(to_send_files):
    with open(to_send_file) as f:
        data=json.load(f)
        for k, v in conf["publishers"]["restPublishers"].items():
            requests.post(v["baseUrl"], json=data, headers={
                        "Content-type": "application/json"})
    print(f"press enter to send coverage information from file {to_send_file}")
    input()
    print(f"sent {to_send_file}")
