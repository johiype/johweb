---
title: 'Buidling this Website Using CI/CD Pipeline Practices'
draft: false
weight: 1000
cover:
   image: "img/japanese.jpg"
   alt: "Some Text"
---
Hi there, I’m still working on improving this project and will subsequently publish a final updated and polished version of this article! Please excuse any errors that may have creeped in. Thank you!

## Project Code

🌟 All the IaC, CaC, Web App and Pipeline code for this project is my GitHub repo:   https://github.com/johiype/johweb 

## Tech Stack Overview

- **AWS** Cloud Provider for hosting web server
- **GitHub Repo** for project code and content hosting and version controlling
- **GitHub Actions** for running the CI/CD Pipeline
- **Terraform** for deploying and managing cloud resources
- **Ansible** for configuring servers
- **Hugo Framework** for building the website
- **Docker** for containerizing the web server
- **Bash** and **Python** for gluing everything together
- **Ubuntu Desktop** for local development environment
- **Cloudflare** for DNS service
- **Notion** for scribbling ideas, note taking and tracking tasks

## Infrastructure Diagram

![Johith Drawio Diagram.png](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fcff4ab84-2398-47a4-9bdc-2932dd7c7d8d%2FJohith_Drawio_Diagram.png?table=block&id=eae00568-863a-4cf2-990c-2bcc9663ff98&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

## GitHub Actions

![GitHub Workflow Diagram.png](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F2343648d-dc4e-4234-955f-6c83bbef63d4%2FGitHub_Workflow_Diagram.png?table=block&id=fc45c4a8-cf2d-4988-b9c3-324fd60d63a3&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

All the code is run from GitHub Actions using Workflow YAML files.
Triggers are based on criteria like pushing code to staging branch or pull request to main branch

Below are few screenshots of a chain of workflows that were triggered for complete project deployment - from infrastructure resource creation to configuring and serving the web server.

![Workflow started](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F600bf089-51d1-4981-bdf7-640fcb08b0f7%2FUntitled.png?table=block&id=63571ce1-3ca8-4089-a91d-72984906dcc0&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

Workflow started

![Workflow commenced](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fc2ecd01f-9138-478c-a6fd-4a8dccae6d3c%2FUntitled.png?table=block&id=1c4bf9a7-4476-491f-a277-dcc333ee4e32&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

Workflow commenced

Screenshot of a pull request that triggered the infra deployment workflow. 

As you can see, a comment is generated with *terraform plan* output. Upon confirming the pull request, the changes will be finally applied via *terraform apply.*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fedf91169-7737-46dc-8e72-e6f7d083fa96%2FUntitled.png?table=block&id=8029baf8-0dfd-464c-ab0e-c251bb504f2b&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F89273216-e890-4872-8314-fe66c2d9a63d%2FUntitled.png?table=block&id=55dfac0e-5e15-4e02-92ff-ffd9c5181562&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1780&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F3bce5c46-7197-4009-a18b-06dcd2f8e6d4%2FUntitled.png?table=block&id=caeaed48-184b-4158-9300-b8c3e2e1603c&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1540&userId=&cache=v2)

### AWS Infrastructure

- A custom VPC with one public and private subnet
- EC2 Instances:
    - A bastion host and a proxy server, both EC2 instances, created in public server
    - The main web server (EC2) is created in the private subnet
    - All instances are AArch64 based - for better performance and cheaper runtime rates from AWS
- An S3 bucket is used to backup Terraform state files
- An ECR (Elastic Container Registry) is used to store docker images
- All access to my AWS environment is restricted using IAM roles with limited privileges
- IAM roles are attached to EC2 instances to access resources like ECR to pull images

### Terraform

- Terraform code is used to create the entire AWS infrastructure

### Ansible

- Ansible is used to configure the EC2 instances (or servers) in the infrastructure

### Bastion Host

- All SSH connections enters the VPC through the bastion host
- Uses SSH Tunneling
- All outgoing internet traffic originating from private subnet flows through the bastion host which is also a NAT instance.
    - The NAT Instance is configure using [fck-nat](https://fck-nat.dev/stable/), which is a free, open-source and cheaper alternative to AWS’s managed NAT gateway.

### Proxy Server using Caddy Server

- All HTTP/HTTPS connections gets proxied to web server through the proxy server
- A proxy server in the public subnet
- Uses [Caddy Server](https://caddyserver.com/)
- How to create Caddyfile:
    
    [Caddyfile Tutorial - Caddy Documentation](https://caddyserver.com/docs/caddyfile-tutorial)
    
    https://github.com/caddyserver/dist/blob/master/config/Caddyfile
    

### Web Server

- An Apache server is used to serve the web files

### Docker

- All the server applications are containerized and are managed using Docker
- Installed docker compose using the standalone method:
    
    https://docs.docker.com/compose/install/standalone/
    
- Uses Dockerfile to create app image - uploaded to ECR
- Uses Compose file to create containers
- EC2 instances are installed with *amazon-ecr-credential-helper* to pull images from ECR as this is the recommended method over *docker login* 
https://github.com/awslabs/amazon-ecr-credential-helper
- NOTE: to push and pull images from ECR you have to authenticate your Docker CLI with AWS, using command: https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html#cli-authenticate-registry

### Hugo Framework

- Uses markdown files to generate web content
- `hugo new site example-site -f yml`
- `hugo new posts/first_post.md` - creates a new markdown file under *content* folder
- To serve website:
    
    `sudo hugo server -p 80 --baseURL="http://x.x.x.x" --bind="x.x.x.x"`
    

### Local Development Environment

- Running Ubuntu Desktop in my home lab server
- Uses go web server to test and debug website
- Push code to GitHub staging branches (app-staging, infra-staging)

## Credits

Without the contributions of open-source developers, this project would not be possible.

- Building Hugo site: https://github.com/peaceiris/actions-hugo
- Run jobs based on changes made to files: https://github.com/dorny/paths-filter
- Run Ansible Playbook: https://github.com/dawidd6/action-ansible-playbook
- Free and open-source NAT instance: https://fck-nat.dev/stable/
- Reverse proxy server: https://caddyserver.com/

## Future To-Do List

- Setup CloudWatch in AWS

## References
