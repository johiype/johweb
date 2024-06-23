#!/usr/bin/env python3

import json
import os
import boto3

aws_access_key_id = os.getenv('AWS_ACCESS_KEY_ID')
aws_secret_access_key = os.getenv('AWS_SECRET_ACCESS_KEY')
# region_name = os.getenv('AWS_REGION')
websrv_usr = os.getenv('WEBSRV_USR')

ec2=boto3.resource("ec2")

bastion_host = []
bastion_instance = ec2.instances.filter(Filters=[{'Name': 'tag:server_type', 'Values': ['bastion_host']}])
for instance in bastion_instance:
	if(instance.private_ip_address == None):
		continue
	#print(instance.private_ip_address)
	bastion_host.append(instance.public_ip_address)

bastion_host = bastion_host[0]
#print(bastion_host)

#inventory = {
#        "all": {
#	  "hosts": {
#            "web_servers": [],
#	    "proxy_servers":[],
#		},
#            "vars": {
#                "ansible_user": f"{websrv_usr}",
#                "ansible_ssh_common_args": f"-o StrictHostKeyChecking=no -J {websrv_usr}@{bastion_host}"
#            }
#        }
#    }

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
	}
}

web_server_instances = ec2.instances.filter(Filters=[{'Name': 'tag:server_type', 'Values': ['web_server']}])
proxy_server_instances = ec2.instances.filter(Filters=[{'Name': 'tag:server_type', 'Values': ['proxy_server']}])

for instance in web_server_instances:
	if(instance.private_ip_address == None):
		continue
	inventory["web_servers"]["hosts"].append(instance.private_ip_address)

for instance in proxy_server_instances:
	if(instance.private_ip_address == None):
		continue
	inventory["proxy_servers"]["hosts"].append(instance.private_ip_address)



#inventory = {
#    "web_servers": {
#        "hosts": [
#		"44#.55.3.226",
#		"44.66.44.33"
#		]
#	},
#	"proxy_servers": {
#	"hosts": [
#		"55.55.55.55",
#		"33.33.33.33"
#		]
#   }
#}

#print(inventory["web_servers"]["hosts"][0])

print(json.dumps(inventory, indent=4, separators=(',', ': ')))
