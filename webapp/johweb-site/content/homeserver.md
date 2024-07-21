---
title: "My Home Server Setup"
security:
  enableInlineShortcodes: true
---

| ![My Baby](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Ff874afb7-f50c-466d-bd66-8f45bdce0212%2F20240706_130356.jpg?table=block&id=6b6f4ee1-a127-4c90-b87b-1becbe397d41&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=860&userId=&cache=v2) |
|:--:| 
| *My Baby!* |


:construction_worker: :construction: Hi there, I'm currently working on improving this article and will soon publish a final, updated, and polished version.
Please excuse any errors that may have slipped in. Thank you!

## Specifications

- HP Z840 workstation
    - Intel(R) Xeon(R) CPU E5-2690 v3
        - 64 GB RAM
            - Nvidia Quadro K2200 GPU
            - Proxmox VE 8.0.3 Hypervisor
            Dashboard served on LAN address
            - Primary and a secondary storage for backup
                    (no RAID setup for redundancy as of now! I’m planning on setting it up soon)


## Few self-hosted software I’m running:

- [pfSense](https://www.pfsense.org/) firewall
- [Tailscale VPN](https://tailscale.com/) for remote access
- [Pi-Hole](https://pi-hole.net/) DNS
- Network File Share using Cockpit - [*Write-up*](https://johith.com/posts/installing-samba-network-file-share-system/)
- [Ollama](https://ollama.com/) for running LLM locally (with GPU passthrough) - [*Write-up*](https://johith.com/posts/run-large-language-models-locally/)
- [PBS](https://pbs.proxmox.com/wiki/index.php/Main_Page) Backup Server - [*Write-up*](https://johith.com/posts/pbs_server_setup/)
- The rest, I use my home server to host, learn and practice all sorts of software!
- Ohh yeah …… mmmm I have an [ArchLinux](https://www.notion.so/PUBLIC-HomeServer-d4b32e3131d943aa9010225fd7cd952b?pvs=21) VM BTW!!! LOL - [See how I installed it manually](https://johith.com/posts/installing-arch-linux/)

Below is a snapshot of my Proxmox dashboard, accessible via LAN:

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fe1586f70-3f9f-48c3-a6d7-126d5d9819d4%2FUntitled.png?table=block&id=900ece6b-1421-4f2c-9620-def770766a3d&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

## Future To-Do List:

- Implement SSO for local services

# Proxmox Notes

## Network Setup

eno1 and enp5s0 are the logical names used by linux/proxmox for the two ethernet cards on HP

The *linux bridge* in proxmox acts as a switch between your proxmox server and the ethernet card in you HP computer. *Linux Bridge* is the default bridge created by Proxmox ; you can create more as well.

![This is where you assign the ethernet cards to the bridge. ](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F5544daf2-09af-4c97-b202-7cd56f4b0cbc%2FUntitled.png?table=block&id=4c03669b-54a4-4269-a7b3-e24a71e3b4c5&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

This is where you assign the ethernet cards to the bridge. 

### Great Video for understanding everything about proxmox networking:

https://www.youtube.com/watch?v=zx5LFqyMPMU

### Best Proxmox VM settings for Windows 10 & Server

1. CPU type: host
2. Enable NUMA: 1

![enable Numa](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F67b07cd0-828c-40c8-9fab-136bdf90eb67%2FUntitled.png?table=block&id=90ef1e74-6b04-421f-b37c-6e54d17fa97d&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=860&userId=&cache=v2)

3. SCSI controller: VirtIO SCSI Single
![VirtIO SCSI](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F36011838-4c53-46cc-84ea-ad6fb8e5b3b2%2FUntitled.png?table=block&id=b8f47193-2cb0-4e92-880d-eb1a9f7ac494&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=860&userId=&cache=v2)
