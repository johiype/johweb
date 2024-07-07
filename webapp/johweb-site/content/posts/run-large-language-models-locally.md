+++
title = 'Run Large Language Models Locally'
draft = false
+++


If you are planning to run LLMs on your Proxmox Virtual Environment, I recommend checking out my notes on [Proxmox PCI/GPU Passthrough](/posts/proxmox-pci-gpu-passthrough) before proceeding here.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F2ec38273-2168-497f-a0fb-aa6235bf616c%2FUntitled.png?table=block&id=b1adb8bd-247b-441e-a1a1-b840310d318d&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

- When you run a model like *phi* you might encounter the below error
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F97cef804-2708-4859-883e-2b498103693c%2FUntitled.png?table=block&id=a4de5be5-46e3-4cbb-b4af-20ecb2e56480&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1340&userId=&cache=v2)
    
- Use `journalctl -u ollama` to view the logs
- Not much information but that seems to be an issue when the underlying CPU does not understand or recognize the instructions provided by Ollama.
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Faa44bd1f-cda9-4222-ba06-1e6c3e886758%2FUntitled.png?table=block&id=7691b68e-f822-4e29-8a5f-2e2c417550c4&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- To fix this, change CPU type of VM from x86…. to *host*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F3338e5d6-3af4-4d61-ac90-25444fb594ae%2FUntitled.png?table=block&id=beb43d48-32f2-4d52-990f-3372fa0e42c8&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)


![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fb03ce5cd-a078-4a7e-8b07-1e4926f33661%2FUntitled.png?table=block&id=9659fa97-9fb9-4a77-96e1-d7ca2d61c558&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1730&userId=&cache=v2)


