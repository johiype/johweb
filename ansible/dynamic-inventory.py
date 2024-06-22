#!/usr/bin/env python3

import json
import os
import boto3

aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
region_name = os.getenv('AWS_REGION')
websrv_usr = os.getenv('WEBSRV_USR')

ec2=boto3.resource("ec2")

bastion_host = []
bastion_instance = ec2.instances.filter(Filters=[{'Name': 'tag:server_type', 'Values': ['bastion_host']}])
for instance in bastion_instance:
                #print instance.private_ip_address
	bastion_host.append(instance.public_ip_address)
bastion_host = bastion_host[0]

inventory = {
        "all": {
            "hosts": [],
            "vars": {
                "ansible_user": f"{websrv_usr}",
                "ansible_ssh_common_args": f"-o StrictHostKeyChecking=no -J {websrv_usr}@{bastion_host}"
            }
        }
    }

server_instances = ec2.instances.filter(Filters=[{'Name': 'tag:server_type', 'Values': ['web_server']}])

for instance in server_instances:
        inventory["all"]["hosts"].append(instance.private_ip_address)

print(json.dumps(inventory, indent=4, separators=(',', ': ')))
