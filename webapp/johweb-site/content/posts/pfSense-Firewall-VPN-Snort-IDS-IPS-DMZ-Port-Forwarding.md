+++
title = 'PfSense Firewall VPN Snort IDS IPS DMZ Port Forwarding'
draft = false
+++

# About the lab

In this lab I will be setting up a private network (using virtualization) and then secure it using a firewall. The firewall I’m using is pfSense which is a widely recognized, powerful, free and opensource firewall from Netgate. Although it is targeted for SOHO and mid-sized businesses, it is very often adopted by large enterprises because of its robust firewall capabilities and low cost to setup.

To extend pfSense’s capabilities and make it more secure, I added a VPN (using ProtonVPN and OpenVPN) and IDS/IPS (Snort) service to it!

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fba7bfe27-d13b-48c8-8d01-d007b2af1e98%2FUntitled.png?table=block&id=e10839fc-7a46-4e18-a21a-6a21b7c5558a&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1380&userId=&cache=v2)

### My objectives for this lab

My primary objective with this lab is to get hands-on experience and understand how firewalls, vpn and IDS/IPS systems work. I have only read about these technologies but never got to set them up, so this was a perfect opportunity for me to go behind the scenes and dive into its nooks and crannies.

So far, this lab was an absolute fun to setup - especially when you see your firewall rules finally block some bad traffic, the VPN system hides your public IP and the IDS/IPS system block some suspicious traffic!

### Lab Contents

- Setup a virtualized private network with pfSense as the firewall
    - Setup appropriate firewall rules (both WAN and LAN side)
    - Using pfSense to create a screened subnet (or DMZ) and isolate it using effective rules
    - Hosting a web server in the DMZ and making it available to the internet, using port forwarding
    - Enabling remote firewall administration
- Setup a VPN on pfSense and route all traffic through it
- Implement IDS/IPS capabilities on pfSense using *Snort*
    - Custom Snort rules to alert Nmap scanning
- Setup a dynamic DNS *(will add soon, work in-progress …..)*
- Setup a captive portal access for visitors *(will add soon, work in-progress …..)*

# Lab Setup

![ProtonVPN service is used for VPN connectivity. Enabled by OpenVPN](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F95e03030-828e-4097-8092-a7d12b52593b%2FpfSense_FlowChart_(2).png?table=block&id=7b5981a9-6044-49d7-b003-4e978d9be80e&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

ProtonVPN service is used for VPN connectivity. Enabled by OpenVPN

---

# Setting up pfSense Firewall

I might purchase a NetGate SG-1100 firewall appliance in the future for my home setup, but for now I’m using virtual machines to setup the pfSense firewall. So yeah this can be considered a virtual firewall.

Head over to pfSense’s website and download the ISO image of your choice. I choose the AMD 64-bit.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F42bdc7ba-0098-4357-b61f-57bd619bad72%2FUntitled.png?table=block&id=334c4409-b5e2-468c-86c6-00422ec6701d&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

I’m using virtual box to setup the virtual machines. This is the configuration I used:

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F454d87fb-2c33-4af7-9a82-ced8f989011e%2FUntitled.png?table=block&id=a44d36c2-acd0-4577-a2a9-3dfd44364924&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=770&userId=&cache=v2)

Now, enable two adapters for the pfsense vm on VBox -

- one *Bridged Mode* adapter - for the WAN side
- one *Internal Network* adapter - for the LAN side 
(You can add more LAN interfaces - see [Interface Assignment](https://www.notion.so/pfSense-Firewall-VPN-Snort-IDS-IPS-DMZ-Port-Forwarding-etc-a6875e6091b84177929d71283857f13b?pvs=21) )
    
    Connect to ‘pfsenselan1’ *Internal Network*. 
    pfSense’s DHCP server is ON by default. So, pfSense will automatically assign a default IP of 192.168.1/24 to all devices in the ‘pfsenselan1’ *Internal Network.*
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Feb3ae5a5-5c70-4e92-9258-0466be402128%2FUntitled.png?table=block&id=f0bb7b01-7fbf-4b22-9ac9-f04403b2a7c7&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=670&userId=&cache=v2)
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Ff7213b2c-78e6-444b-8f8f-5b247e1e7bb9%2FUntitled.png?table=block&id=a6ff545b-05f2-4e13-9e7d-603fbe3e25fe&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=770&userId=&cache=v2)
    

Run the virtual machine and you will be greeted by the following BIOS screen:

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fc38d3b99-def1-490d-9add-30ff03ca7593%2FUntitled.png?table=block&id=9d8bf689-e344-49b7-a8ea-4574c2c73c11&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

Run through the BIOS settings to install the firewall on the VM. The screenshots below shows the sequence of steps I took leading up to the installation

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fc35e1bb2-ef87-490f-83e0-e50379e2350d%2FUntitled.png?table=block&id=106e0e6e-acaa-4f49-ae05-3852de1ee993&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F085329c1-5e6a-4045-8153-1044d57edd3e%2FUntitled.png?table=block&id=bc25a8d5-f2cb-4efa-8870-e6c70d4c13a5&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F085329c1-5e6a-4045-8153-1044d57edd3e%2FUntitled.png?table=block&id=bc25a8d5-f2cb-4efa-8870-e6c70d4c13a5&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fe4bcdb2a-7387-4132-96b3-47ae8d45c150%2FUntitled.png?table=block&id=4852179d-b432-48de-9444-e8e3c6ef64c1&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fb0817466-c2d9-4542-b57e-d64f01ce6956%2FUntitled.png?table=block&id=a4e2910b-cbc9-46d9-b739-8df7a29ba4d2&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

After the installation is complete, configure both the WAN and LAN interfaces as shown below:

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F4d666177-b889-4889-acee-0f4b5c30da9c%2FUntitled.png?table=block&id=b0aaa468-86ad-47ac-9cb7-bac314fa1b21&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F4807d36c-49bc-4b22-8125-b7cd37f83aa2%2FUntitled.png?table=block&id=cdd192b0-68f1-4f34-8498-5d0aad2f639c&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

Connect another VM (like Kali Linux) to the same LAN subnet as pfSense (show in pic below) - so we can access the pfSense web interface to setup pfsense and make configuration/setting changes.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Ffa7718c4-9fea-4ad5-9d2f-5953c657b17f%2FUntitled.png?table=block&id=2c901904-9ff1-49f3-a590-df16d41a28b4&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

Setting up the web interface is pretty straightforward. Follow the 

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F26e3405a-8b57-4842-be88-f495094ba010%2FUntitled.png?table=block&id=9f018bc5-a2d3-4463-847c-890d8efa85c6&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

Uncheck this option if the WAN is also in a private network

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fc6b0c070-eb63-416d-a93f-79b6e2adf967%2FUntitled.png?table=block&id=aeb8499d-cdc4-4c0e-8ab6-3f7fed984484&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

---

# Firewall Rules

Firewall rules are what makes or breaks any firewall and it is the most important piece of configuration in your firewall. Firewall rules are defined in a rules table and it decides whether to let packets travel across the firewall (in both directions).

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/45762f0c-c069-407c-b8b3-91bfffea8c2d/Untitled.gif?id=4102ae02-082a-49f5-84d4-71188825cf84&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=eGo-5-parZ-YroiOGNf2gOzgbqZHssXsHG8BD-okAys)

## Firewall Rules Best Practices

- Set a default implicit *deny* rule at the very bottom and add *allow* protocols/connections rules on top of the implicit deny rule
- pfSense has a built-in implicit deny by default for the WAN side firewall rule table. (You cannot see this rule though on the table)
    
    So, you don’t have to set a DENY ALL rule on the WAN side
    
- Keep track of the rules - document the rules used. Decommission unused rules
- Use separators to group the rules. Makes it easy to identify them

---

# Screened Subnet/DMZ

Let’s setup a screened subnet (aka. DMZ) in our network and secure it using pfSense

**What is a screened subnet?**

A screened subnet is a subnet within your private network infrastructure that is isolated from all other subnets. A screened subnet can be a VLAN or a separate physical network in itself.

**Why do we need a screened subnet?**

If you have services like a web server or file server that people from the internet (or any other network outside our infrastructure) have to access them, then we place them within the screened subnet. This is done to prevent our LAN from getting infected if in any case our exposed services gets breached.

### Adding VM NIC Interface

Let’s create a new network interface in our VM to create the screened subnet

New interfaces can be added to pfSense to create more LAN connections - for example to create a separate LAN network for guests or for a screened subnet

- First assign a NIC adapter to pfSense through VBox
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fa747ea2c-473f-467e-b211-723507e5cc55%2FUntitled.png?table=block&id=16b7b250-371c-45f8-b263-1733099d1ff1&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=670&userId=&cache=v2)
    

### Deploying the subnet in pfSense

Click on **Add** button at *Interfaces* (from the top of web dashboard) *>> Assignments*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fe5701006-466e-450c-a48e-ae42035a229a%2FUntitled.png?table=block&id=e25e63d0-3c94-44ad-887f-957f2cb7b9b6&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

Enable the newly added interface/adapter

![Click on the interface](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F6c41150d-354a-459d-83e1-9bc32aa02e33%2FUntitled.png?table=block&id=046a810d-84a0-4415-8c3e-68271e3a4128&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=960&userId=&cache=v2)

Click on the interface

Set the following configuration for the newly added interface. The IP address for the DMZ is 10.0.0.0/8

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F3aa41279-b16a-45b3-ba81-0306b1f24573%2FUntitled.png?table=block&id=64b4dc15-00dd-4a01-86f2-4d03512336fc&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

Enable DHCP server (optional) for the new LAN

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fe937aef5-46a6-4f39-b4e9-f18feede0dd4%2FUntitled.png?table=block&id=61bf737e-2c5b-4379-a7c5-05eb5de81c91&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

### Firewall Rules for the DMZ

Now, let’s configure the necessary firewall rules for the newly added subnet

***DENY* access from DMZ to the pfSense admin portal.**

We don’t want anyone in the DMZ to access our pfSense portal

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fd207bf0c-39e9-4df6-bdbf-10d072800ae6%2FUntitled.png?table=block&id=ea6bf606-d739-40cf-ae77-bb8240e58968&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

**DENY DMZ from accessing the LAN network. Create a DENY firewall rule in DMZ where all the traffic from DMZ is blocked from entering LAN network:**

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F5a7fb5ce-7318-419d-9829-a5318c2c3be7%2FUntitled.png?table=block&id=0abe813c-d8aa-49bf-9207-f5ea84695a1f&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

**Only allows DMZ to access web services (port 80, 443, 8080, 53) and DENY ALL access to other services/ports from the DMZ network**

First, lets create an alias to group the ports together. Alias is a feature in pfSense to simply adding rules to the rule set. It groups information together and you can then refer them by simply referring the alias name wherever you want in the configurations.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fef96a3ee-4794-471c-96e5-c884f1b6c4fa%2FUntitled.png?table=block&id=ef78eeec-70b3-429c-bd63-e64818b52b14&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

Put in the web relevant port addresses in the field to add them to the alias

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F3c7950af-4309-4853-83ee-c09d90739f0b%2FUntitled.png?table=block&id=31d227d0-9c01-4d76-801b-babb53e04556&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

Once the alias is created, head over to the firewall rules for the DMZ to create a rule to ONLY ALLOW TCP/UDP traffic from the DMZ and block the rest.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fb6740eca-77fd-4908-ba7d-5d17131a04a5%2FUntitled.png?table=block&id=75b260c3-162d-41a3-be46-9ac2719f38c7&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

---

## Hosting a Web Server in DMZ (Accessible from the Internet!)

Let’s try hosting a web server in the DMZ and make it accessible from the internet!

For the sake of this lab, I’m not using any full-fledged web server, instead I’m spinning up a simple server on port 80 using Python on Kali Linux.

`python -m SimpleHTTPServer 80`

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fcc262a84-27d9-46b4-8d63-1fce36dcb1e4%2FUntitled.png?table=block&id=fe0d7751-2934-40de-aa40-69c3fdc9de3f&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

To allow people from the internet to access the web server in the DMZ we have to enable port forwarding.

### Port Forwarding

Port forwarding is a technique in networking to allow uninitiated traffic from outside to access certain resources in our private network. In our case we want to allow any random netizens to access our web server. This is possible thanks to port forwarding.

*Add* new port forwarding as shown below:

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F0d253731-b4c1-4b65-b04f-a6085fa8c64d%2FUntitled.png?table=block&id=67d7bb0c-c013-4125-a1ed-9ac554c8f3c4&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fce8dae09-0785-4df9-a331-c46e7d7bb4ae%2FUntitled.png?table=block&id=3bd392be-7608-4f07-bff5-eee5fad42c5a&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

- **Steps 1,2** → Choose WAN as the interface to allow port forwarding for internet traffic and choose TCP as protocol because we are only allowing web traffic.
- **Steps 3,4** → Choose the destination as WAN address. The MAC address (or our public IP address) will be used to access the web server from outside along with the specific port number. In our case `<ip-address>:7777` must be used to access the web server from the internet
- **Steps 5,6** → Specify the local IP address of our hosted web server in the DMZ
- **Steps 7,8** → Port number of our web server
- **Step 9** → Give a description

---

## Enabling External Firewall Management

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F5d0d4724-3000-4326-944e-ee4ef28a00bb%2FUntitled.png?table=block&id=eb1cfdbd-50be-416e-a3dd-75b6f76b2f0a&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

---

# pfSense + VPN - Encrypting Internet Traffic

Let’s add a VPN connection to our LAN network to encrypt its internet traffic!

### **Why use VPN?**

There are many reasons as to why one would recommend using a VPN. It encrypts everything (of course if you are using a tunnel-mode VPN), including your data and metadata. It keeps ISPs and bad actors from prying on your privacy. 

It also largely depends on the VPN service provider you choose because if your VPN provider is logging data on their side then the whole effort to stay truly confidential or anonymous is in vain.

### VPN Configuration

- VPN Service used - *ProtonVPN*
- VPN Protocol used - *OpenVPN*
    - Custom security protocol that utilizes SSL/TLS // OpenSSL
    - AES-256 encryption, with dynamic DHCP, NAT and stateful firewall support (perfect for us!)
    - Tunnel Mode - Everything is encrypted
        
        ![Screengrab of my pfSense OpenVPN configuration, showing the encryption details](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/413b0f60-be10-4f6a-ac8e-8492711fc2e4/Untitled.png)
        
        Screengrab of my pfSense OpenVPN configuration, showing the encryption details
        
        ![You can see the VPN status](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/4a417cda-f7ab-421a-9441-5079ecc7f8f3/Untitled.png)
        
        You can see the VPN status
        
- VPN Client - pfSense provides built-in support for OpenVPN.

### VPN Setup Workflow

- Setup account on any VPN
- Download OpenVPN configuration from your account (this is unique information)
- Enter the configuration details onto pfSense (as detailed below)
- Setup an OpenVPN interface/gateway on pfSense
- Route all traffic from LAN through the OpenVPN interface/gateway

The documentation I followed to setup the VPN: https://protonvpn.com/support/pfsense-2-6-x-vpn-setup/ . I recommend checking it out as it’s highly detailed and easy to follow.

With that said, let’s see how to setup a VPN on pfSense

### **Step One: Add the Certificate**

Download OpenVPN configuration from your VPN account

Add OpenVPN’s certificate authority on pfSense. This would allow pfSense to perform SSL/TLS handshake with the VPN server to encrypt the traffic

Copy the certificate from your OpenVPN configuration

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F1e2e9ebe-19b6-446e-87f6-abdf4b2d508d%2FUntitled.png?table=block&id=9d2f09fa-4d23-41cb-87cf-bc74048893f6&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

Create a new certificate as shown below:

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fc5c36867-3d0d-4b6d-bc12-d2f1737675c8%2FUntitled.png?table=block&id=76d93369-ceb4-4faf-92fe-1737bc256f1b&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

Paste the copied certificate into the respective field as shown below:

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F9aa49d32-6300-4ac4-a071-0c3b0a9d637e%2FUntitled.png?table=block&id=7b6a52c9-cbaf-4e19-b0aa-88e16bd631b1&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

The certificate is added:

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fb9c91544-4126-4da8-8edf-706cb9b8f5ff%2FUntitled.png?table=block&id=3e381723-574d-4e14-b587-2c4c76451a2b&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

### **Step Two: Configure the OpenVPN Client**

In this step, you will add an OpenVPN client to encrypt your data and tunnel it to the VPN server.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F54c0b492-6323-4ca1-8228-db5bc3e51887%2FUntitled.png?table=block&id=b2061b6e-c07f-43cb-82b3-23b97b03e7f6&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

Provide mode and endpoint configuration details as below. 

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fa90237da-0d47-408a-997d-a794446020c7%2FUntitled.png?table=block&id=91cc85da-e5f2-480e-b0fd-9f6cef7463b7&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

Provide user authentication settings as below. The user authentication details can be found on your VPN provider’s dashboard

![Proton VPN dashboard](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F8da62a11-a19b-4318-9b5c-aa7d21eb9ad4%2FUntitled.png?table=block&id=0eac8089-3b00-438a-a420-924a21c2fb68&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

Proton VPN dashboard

![Untitled]https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Ffddadd05-4238-4c77-910f-c95556722986%2FUntitled.png?table=block&id=e28a1d62-0aaf-43e9-b42b-d3aeae94b632&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

Provide cryptographic settings as below. The TLS key can be found in your OpenVPN configuration file

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F990a6e49-cb71-465c-9a89-8403f45647ff%2FUntitled.png?table=block&id=af24bcad-2a03-46de-a45c-9c883ef1af9a&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1140&userId=&cache=v2)

Provide ping and advanced configuration as below

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F8c4b68ad-28c2-4a1e-9a21-2f071927ead1%2FUntitled.png?table=block&id=c9b56894-63aa-4ca8-95f5-579f5f6eb96e&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

At this point the status of the new VPN client should be showing **up**

![Head over to *Status* tab >> *OpenVPN*](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fee937e94-d05b-4066-b537-4fc90b55a90f%2FUntitled.png?table=block&id=b00c2a6d-a54e-4a3c-8a4b-76451dde8194&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

Head over to *Status* tab >> *OpenVPN*

### **Step Three: Configuring the OpenVPN Interface**

We have setup the OpenVPN client on pfSense. But that’s not all, we now have to route all traffic from LAN network through it

Assign new interface for OpenVPN as shown below under *Interfaces >> Assignments*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fd1a24040-ea9f-41bb-ae1a-7658fa689b2a%2FUntitled.png?table=block&id=5ce038ed-693d-4197-bd0d-f453389e243e&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

### Step Four: Setup Firewall Rules and NAT

Go to **Firewall → NAT → Outbound** and change **Mode** to **Manual Outbound NAT rule generation**, then **Save** and **Apply** the changes

Edit the two rules that has the IP address of LAN (where we are setting up the OpenVPN client) and edit its interface to that of our VPN, in this case *PROTONVPN*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Ff89f35b4-2418-4b1a-857a-929f747c3781%2FUntitled.png?table=block&id=469bbee7-0cd9-404d-a207-5853e730292a&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

Change the interface as shown below:

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F356cd3e2-10bc-47c9-8586-b32d0c69d696%2FUntitled.png?table=block&id=33a7f429-5770-4162-a1ab-0fb92509c2f1&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

Now what we have finally left is to set the gateway for our LAN network so all of its incoming/outgoing traffic will be redirect through our VPN

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/503aade0-e391-4fbf-9bf1-789a157f67f5/Untitled.gif?id=2352c896-687b-4712-b917-81c0161c4182&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=NlaKmUzH_Hti5wFk0n7JuuGkpIC55eMSUozAVp-2mnc)

### Results!

Below are screen grabs from before and after setting up the VPN. 

As you can see, the screen shot below shows my actual IP address and location

![ Before setting up the VPN on LAN. Yes, this is my location ��](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F5300eb93-5202-4c53-80ed-135a3ddcc619%2FUntitled.png?table=block&id=6312139e-de57-45d5-a69a-59f5c033b580&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

 Before setting up the VPN on LAN. Yes, this is my location ��

Below is my new public IP address and location after I setup the VPN

![After setting up the VPN on LAN](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F465a2dae-6f95-44e5-be20-32b302dd6743%2FUntitled.png?table=block&id=b64f808b-621b-4d04-8881-02b9478159af&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

After setting up the VPN on LAN

---

# pfSense + Snort

- network based firewall
- recommended to place behined firewall on lan side because of less resurce utilization by snort as its only getting pre-filtered packets from the firewall

### Installing Snort on pfSense

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/6ff03f16-8301-4ef4-9f93-6d4ae035dc3d/Untitled.gif?id=11dcca67-0f38-4a6d-b831-d9be077afb6e&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=wyq1MvWo0uGTCN5jTeS1f5mYnLG-wnprleLdJY2zCKA)

### Configuring Snort Global Settings

![Yes I did change the Oinkcode!](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/8f8e4574-6c5f-41d2-a51a-8ea0271f37c3/Untitled.gif?id=1a6cbdc1-ac02-4c1e-a75b-0108b2de1c7a&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=Ef4H7W1jbuptMdKiwNwO5NvgWAUBoIJN1o4JaBsYcvE)

Yes I did change the Oinkcode!

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fd74c8d80-0a37-4471-8df0-7ce731a45b20%2FUntitled.png?table=block&id=f2be3096-00a1-468c-aeae-a15b9c2bfe9a&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1340&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F2aaf1035-472f-4388-aab2-ae2d3f2642fa%2FUntitled.png?table=block&id=e947ca39-3d6f-42b7-bc10-f8326953eeb3&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1340&userId=&cache=v2)

### Setting WAN interface

Here we enable Snort on the WAN interface - to inspect all incoming traffic entering our network infrastructure from the internet

- IPS mode is set to Legacy Mode or in other words partial packet inspection - not as robust as inline mode. Unfortunately my NIC does not support inline mode, so I gave to resort to Legacy Mode. Hopefully it won’t make any misses
- I’m only blocking the SRC IP address and not the DST address. It’s up to you!
- The rest of the options are left to default. But whenever you can, I strongly recommend to fine tune your settings!

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/8a23f4e2-bd5d-45b9-a469-b0be6b83eaac/Untitled.gif?id=c4196783-c3e7-4651-8ff1-d7ced4dec4b8&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=63FxafILoS5xEapRqp-j2Wi8xXHfwECO2u8660vvdVc)

### Selecting WAN Rules

Under *WAN Categories* we set the rules (pre-defined rules) that Snort can use to inspect the packets. We can manually select each rule we want to apply or let Snort decide which rules to use based on the category we apply. I chose *Security*  category as seen below

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fb73e655c-0cd8-4bf6-8cd5-3220c112da4f%2FUntitled.png?table=block&id=dfc1db45-c53e-4e66-b2dc-5910c8e27601&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

Apart from using pre-defined Snort rules we can also write custom rules, which we can set under the *WAN Rules* section/tab as seen below

### Applying WAN Rules

- Here you can choose whether you want to apply C*ustom Snort rules* or pre-defined *IPS Policy* rules
- For this lab I choose to use pre-defined rules as they are more current, effective and developed by security experts around the world. But, if in any situation that is specific to your network I would recommend adding your own custom rules.
    - Check out my TryHackMe notes on creating custom Snort Rules: [Snort](https://www.notion.so/Snort-911050ce3c2f495fb0d61ef63870753d?pvs=21)
- You can scroll down on the page to see the list of individual rules that will be applied. That is a long list BTW!

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F260d9f58-4082-46a2-b466-7491c5bb96b9%2FUntitled.png?table=block&id=2005391c-e3bc-4632-8d30-440728626de9&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

### Block based on IP reputation (Optional)

We can let Snort decide public IP addresses that have low reputation and block activities from them. This can help reduce spam, adware and malicious websites

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fecb87737-fec4-43ff-9a69-e921606d6b20%2FUntitled.png?table=block&id=245e9a34-b01b-4053-aea3-2dc269a305be&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

### Adding Custom Snort Rules

Snort also gives us the opportunity to add custom Snort rules - for finer and custom control over our network. To do this you must know how to write custom rules - fortunately I know the basic syntax to write a simple ICMP ping alert rule

`alert icmp $EXTERNAL_NET any -> $HOME_NET any (msg:"Incoming ICMP Ping"; sid:989778;rev:1;)`
This rule *alerts* admins of any incoming icmp packets. You can also choose to drop them as well, its up to you.

See below on how to add custom snort rules

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/3ab7c48c-93bf-44bf-b09e-0c471bd3401d/Untitled.gif?id=f4ff1a89-c62c-4442-b4f5-28a1adeaf6d0&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=tjEyA3Uj36Q5xfCAJzMnB-KK6aQS0NL1r3giYQ25Dhw)

### Let’s Start Snort !

Starting Snort is really simple. Head over to *Services >> Snort* and click the button as shown below

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F27ec0e6e-8e24-48fc-aaf1-1db6598b66d5%2FUntitled.png?table=block&id=f4eb41f9-9d60-482f-8564-02e86ee149f3&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fbba53f5d-88fe-4b08-85d5-a1dc1ea19ebf%2FUntitled.png?table=block&id=636d0c96-5a88-48d0-85fd-8fc787ff8be1&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

### Let’s test out Snort!

Let’s see Snort in action

![Untitled]https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/e38774a5-6d7b-4f0b-8d67-0d5bfac62bd2/Untitled.gif?id=ef770130-6832-4651-beb7-f750957b4a70&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=XCiLZXHNu5fob43jcOSZUeB7QAv3j566-Ted_iOz2N0)

As you can see from the above screen grab I pinged our network from Kali Linux which is situated outside our network. The Windows machine (as seen on the left) is part of our network and has the pfSense admin dashboard open to view the alerts in real time. 

Snort picked up the incoming icmp packets and alerted it in real time! Just like I wanted! (yes, I only made it to alert, not block the packets)

Let’s try again with an Nmap scan. As you can see below Snort effectively alerted the admin about the Nmap scans taking place! Pretty good stuff!

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/8a178c9d-29d9-4fb4-a5ea-9013b7876b74/Untitled.gif?id=2383a04b-9c67-467c-869c-922ae61d51ec&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=S6yOGTghQYAaV3zo__QVEbe5zgMybFhLp1rQeRybJMk)

# NOTES

- **Block** - The packets are silently dropped at the firewall, and the sender is not aware of it
**Reject** - The packets are dropped and the sender is notified that their packets were dropped

# Troubleshooting Notes

- **Set the default gateway on the client**
    - Set the default gateway on the client as the LAN IP of the firewall

# References

- https://www.youtube.com/watch?v=YHnRKkNa36g
- https://www.youtube.com/watch?v=Vm98ofYp05g
- https://protonvpn.com/support/pfsense-2-6-x-vpn-setup/
- https://www.youtube.com/watch?v=TvQfD5oUN5o

