#!/usr/bin/env python3

import json
import os
import boto3

aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
websrv_usr = os.getenv('WEBSRV_USR')

ec2=boto3.resource("ec2")

bastion_host = []
bastion_instance = ec2.instances.filter(Filters=[{'Name': 'tag:server_type', 'Values': ['bastion_host']}])
for instance in bastion_instance:
	if(instance.private_ip_address == None):
		continue
	bastion_host.append(instance.public_ip_address)

bastion_host = bastion_host[0]

inventory = {
	"web_servers": {
	"hosts": [],
	"vars": {
                "ansible_user": f"{websrv_usr}",
                "ansible_ssh_common_args": f"-o StrictHostKeyChecking=no -J {websrv_usr}@{bastion_host}"
            }
	},
	"proxy_servers": {
	"hosts": [],
	"vars": {
                "ansible_user": f"{websrv_usr}",
                "ansible_ssh_common_args": f"-o StrictHostKeyChecking=no -J {websrv_usr}@{bastion_host}"
            }
	},
	 "bastion_server": {
        "hosts": [],
        "vars": {
                "ansible_user": f"{websrv_usr}",
		"ansible_ssh_common_args": f"-o StrictHostKeyChecking=no"
            }
        }
}

web_server_instances = ec2.instances.filter(Filters=[{'Name': 'tag:server_type', 'Values': ['web_server']}])
proxy_server_instances = ec2.instances.filter(Filters=[{'Name': 'tag:server_type', 'Values': ['proxy_server']}])
bastion_server_instance = ec2.instances.filter(Filters=[{'Name': 'tag:server_type', 'Values': ['bastion_host']}])

for instance in web_server_instances:
	if(instance.private_ip_address == None):
		continue
	inventory["web_servers"]["hosts"].append(instance.private_ip_address)

for instance in proxy_server_instances:
	if(instance.private_ip_address == None):
		continue
	inventory["proxy_servers"]["hosts"].append(instance.private_ip_address)
	inventory["proxy_servers"]["hosts"].append(instance.public_ip_address)

for instance in bastion_server_instance:
        if(instance.public_ip_address == None):
                continue
        inventory["bastion_server"]["hosts"].append(instance.public_ip_address)

print(json.dumps(inventory, indent=4, separators=(',', ': ')))
