+++
title = 'Installing Samba Network File Share System'
draft = false
+++



## Process outline

- Setup a Debian container (choose any Unix based OS of choice)
- Mount a disk/volume to the container
- Share the container’s mounted disk with your network using SAMBA
- Install *Cockpit* tool on the container and use it’s SAMBA management capability

### **Why Samba over NFS?**

**<rewrite below in more detail why you preferred SAMBA over NFS>**

I’m using Samba - which is a Unix implementation of the Window’s CIFS file share protocol. NFS file share protocol is usually recommend in enterprise environment where latency and bandwidth is a priority whereas SMB/SAMBA/SMB/CIFS focuses on reliability and compatibility - something appropriate for home lab users.

NFS and SMB are two widely used network file sharing protocols that have been developed for different operating systems and environments. NFS is known for its fast performance and low overhead, while SMB is known for its reliability and compatibility.

## Process In Detail

- Setup a container in Proxmox using Debian template. I used Debian 11.0
- Add a disk as a Mount Point to the container. Proxmox has built-in functionality to set mount points in containers
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F62bf9bb8-1885-4820-8c89-d83a0b5d21e3%2FUntitled.png?table=block&id=e4417c6a-3aaf-48ed-910a-26cc392a4664&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- Specify the disk, amount of storage space when mounting, path where the disk/volume should be mounted and enable Backup
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fadc4be8d-5066-4539-8d0c-5b9f54c73673%2FUntitled.png?table=block&id=321a07fb-214d-432b-8383-56d0f494caee&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1440&userId=&cache=v2)
    

### Installing Cockpit

**What is Cockpit?**

Cockpit is a Linux tool that allows admins to administer Linux systems through a web GUI, as an alternative to the traditional CLI. You can also add plugins to Cockpit to add extra functionality.

For example, you can extend the GUI capability to enable SAMBA file share using its https://github.com/45Drives/cockpit-file-sharing plugin, or its https://github.com/45Drives/cockpit-navigator plugin to navigate the Linux file system just like you would do on a Linux desktop environment.

- Add *bullseye-backports* to the source of your Debian container’s repository list to install the latest version of Cockpit
- Install cockpit from bullseye-backports using `apt install -t bullseye-backports cockpit --no-install-recommends`
- Allow root user to log into cockpit by removing it from the */etc/cockpit/disallowed-users* file. This is done for initial administration purposes
- Access Cockpit Web GUI by visiting: `<IP address of container>:9090`

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F4b4b4e76-59b9-440e-a993-3dc603c21706%2FUntitled.png?table=block&id=a9b6f8a6-4a01-424e-8df2-9bf5dc24c64f&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

- Install three Cockpit plugins from their official GitHub repositories on the container using `wget`. The three necessary plugins are :
    - https://github.com/45Drives/cockpit-file-sharing - To enable NFS and Samba file share management in *Cockpit*
    - https://github.com/45Drives/cockpit-identities - User and group management plugin. Although Cockpit already comes with an accounts manager, it does not have the ability to manage Samba passwords
    - https://github.com/45Drives/cockpit-navigator - Plugin to navigate the file system
- If the below error appears, let Cockpit include the necessary parameters and values by clicking *Fix Now*
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F4288ef07-11b5-4f44-a58a-eb45d0a07c23%2FUntitled.png?table=block&id=73b658f7-4aee-4e0b-9f5c-13293f1bba5a&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)
    
- Create groups and users, to whom you would want to share you file share with
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F3228ecb4-b774-44f9-b1cf-6f4a6d4540a7%2FUntitled.png?table=block&id=37e27ec0-dc48-4ff5-a6f1-6a39e1472042&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- Now let’s create some directories within you file server and set permissions on them to share with users.
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F570faa62-310c-4fb9-9b4c-a2e00231835b%2FUntitled.png?table=block&id=32c66e12-be67-41ce-8be7-f2c1572ac014&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- Below are the settings that I have enabled for my Samba share
Remember to set the directory you want to share under the original file share mount point
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fe7e400db-976c-429b-ab33-0c2c18d4b636%2FUntitled.png?table=block&id=af658cf3-3779-4cf2-965a-83648e6b5323&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=960&userId=&cache=v2)
    
- Set the appropriate permissions for the user or group. In my case *all_users* group which has all my users in i
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F67cb4b6c-220a-424d-9f72-aa1fc4e4ee35%2FUntitled.png?table=block&id=2efdb278-dc43-4a16-b1e3-e0a73dd2ed61&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)
    
- To access the file share on Windows, open a file explorer and in the search bar put in *\\<IP address of the file share> . It will prompt you for credentials where you put in your file share user account.*
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F0824633b-d35a-4f50-bb56-e4a0996f2b6b%2FUntitled.png?table=block&id=8a43a28d-7ba0-4a74-bb66-f93269d0cb78&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- To access the file share on Linux, open a file explorer > *Other Locations* and in the input bar put in *smb://<IP address of the file share>/* and hit *Connect*
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fee13c121-eb11-4b72-8b71-cb9eda36e4f2%2FUntitled.png?table=block&id=879b5f12-e4f3-48fb-923a-58ec4a1edc49&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1790&userId=&cache=v2)
    

### References

- https://www.youtube.com/watch?v=Hu3t8pcq8O0
