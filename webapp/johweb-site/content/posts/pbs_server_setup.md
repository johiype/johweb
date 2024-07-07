---
title: 'Deploying Proxmox Backup Server (PBS)'
draft:  false
---

## Direct Storage Passthrough to PBS VM

I want my PBS VM to have direct access to my backup SSD. Below are the steps on how to do it

- Before you proceed - it is a good practice to wipe your drive of any data

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fa31ac799-00a3-4216-b833-c7fc10c39dcc%2FUntitled.png?table=block&id=8914dd90-45a0-49bd-a82f-d3f1a40709dd&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

- Note down the SSD’s Unix-based device name and serial number under *Disks*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F2edc400a-f011-429e-bf20-8de0084757a4%2FUntitled.png?table=block&id=8925f542-2927-4241-ada9-43b05943a6e7&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

- Now let’s list the disks on your Proxmox’s shell using command `ls -n /dev/disk/by-id/`. 
Note down the full namespace of the disk serial with the help of your SSD’s Unix-based device name.
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F0babb805-7131-415a-8679-e18dbd414db5%2FUntitled.png?table=block&id=93b25566-4fdf-4769-a6ab-2bc40e78711b&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- Note down the ID of your PBS VM and the {disk type}{disk number} of the primary drive where PBS is installed. In my case it is *scsi0* and VM id is 106.
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F096706af-cad0-435a-b51c-62ef847f688a%2FUntitled.png?table=block&id=ff3b9fa7-8db4-4faf-852b-293d9188d986&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1340&userId=&cache=v2)
    
- Use command `qm set {vmid} -{disk-type}{number} /dev/disk/by-id/{disk-serial}`in Proxmox shell to mount the SSD to your VM. Choose a `-{disk-type}{number}` that is unique from all the orther drives in that VM. Mine is as below:
    
    `qm set 106 -scsi1 /dev/disk/by-id/ata-KINGSTON_SA400S37960G_50026B7785270A47`
    
- Once the above steps are done, you will now see the SSD mounted under the *Hardware* tab of your VM:
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F117f6c90-cbac-49a6-8820-26c8fa3a831e%2FUntitled.png?table=block&id=5cff69d6-2576-4593-a514-2169026b2064&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)
    
- Now, double click the disk and deselect the *Backup* option because you don't want to backup the backup disk!
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fff09aafd-766e-492c-9e4d-609fd8f95068%2FUntitled.png?table=block&id=ab7523d5-cff8-4104-a7d1-07b02db2159d&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)
    

# Let’s backups VMs

## Mounting the disks in PBS

You can use PBS’s web interface to mount virtual disks to the PBS server

- Go to *Storage/Disks* > Directory and then Create: Directory

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fb679b9fc-30b4-4df4-b6dd-9bbbf721f883%2FUntitled.png?table=block&id=32af35c2-944c-40de-84e2-6e993134c844&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

- Select the disk from the list. Choose the filesystem of your choice. Since I’m not using RAID or multiple disks for backup, I decided to go with the default ext4 file system. Also enable the disk as a datastore so the backups can be stored in that disk.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fc4e928b9-63e9-49f8-bf41-d04bc28b5ebc%2FUntitled.png?table=block&id=0db087b8-7792-4e5a-ae64-021f2beb4497&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

## Connecting PBS to Proxmox VE

Now let’s connect PBS as the backup system to our Proxmox Virtual Environment (PVE). 
To do this we add the PBS server as a datastore in PVE.

- Click on Datacenter > Storage > Proxmox Backup Server as seen below
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fde75e32b-25db-42c3-830e-d691943ad8c8%2FUntitled.png?table=block&id=f4d2b523-51db-4e39-a8e7-b1def9c3f0bb&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)
    
- Provide a name for your datastore, ip address of you PBS server, PBS access username and password - make sure that account has sufficient permissions to perform data transfer and storage, Datastore is the name of the datastore in your PBS. Obtain Fingerprint from PBS server - this is used by PVE for verifying if its communicating with the right PBS server.
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Ffe207911-63d1-4bbe-9693-3cd3b0d4a8e2%2FUntitled.png?table=block&id=c6b8f4c9-41e3-4855-85ca-fd2eeedd6d6f&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)
    
- Now let’s start backing up your VMs in PVE!
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F80447752-e431-45a9-8c56-c5f4186130e0%2FUntitled.png?table=block&id=70b83486-370a-4c90-bd8e-2428857125a7&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- Select your PBS storage disk. I prefer to use the Stop backup mode - as it “provides the highest consistency of the backup” than other modes, plus also given the fact that I can afford the downtime of my VMs.
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F969b82c9-1f78-4992-ab57-a1760ab8a4ce%2FUntitled.png?table=block&id=4ae4037a-b410-477f-9f92-c3c1ed3c7ddd&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1680&userId=&cache=v2)
    
    NOTE: Make sure that your VM is running while you are backing it as you will encounter “VM not running” error otherwise.
    
- Once your backup succeeds, you can view them under *Backups* section under the VM

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F3194af08-51d2-4cf3-85b7-69bf9d4f58bc%2FUntitled.png?table=block&id=aab01c24-b092-4963-ae1d-59ae30827b14&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

# Let’s restore VMs

https://youtu.be/xgLr9uaMqro?t=412

First make sure your PBS server’s datastore is connected to the PVE

Follow the steps as shown below. Step 3 is selecting the backup you want to restore

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fe1b06b15-bcde-4a28-ac12-fc127a0750cd%2FUntitled.png?table=block&id=292392a3-4aea-4560-b4e2-a2d2ac2a2664&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

Enter a VM ID of choice, choose you PVE datastore, override any VM setting you prefer and hit *Restore*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F1e65b44a-a637-4249-a917-b797ab54a09e%2FUntitled.png?table=block&id=52dbb0ff-196a-4ef4-89f6-b0b8272eebee&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

# PBS Maintenance

### Garbage Collection

Garbage collection performs a clean up of your PBS server as it will remove all the previous backup data - thus helping to free up space in the backup disk as well. You can also schedule garbage collection.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fa5e11ebb-2cd0-46c8-b467-52957fe69798%2FUntitled.png?table=block&id=0a00b984-ef78-4175-bb25-5e7826394fae&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=960&userId=&cache=v2)

According to [PBS documentation](https://pbs.proxmox.com/docs/backup-client.html#garbage-collection), after a garbage collection process, the data will only be removed after 24hrs5mins

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F905ce094-9eb4-4808-86e9-0b1b391cccac%2FUntitled.png?table=block&id=5d91ab7d-1766-457e-9293-ab2285d0855f&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

## References

- https://www.youtube.com/watch?v=WgCl4zPdBzcy

