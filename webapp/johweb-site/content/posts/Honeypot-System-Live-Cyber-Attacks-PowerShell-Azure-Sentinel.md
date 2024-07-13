+++
title = 'Honeypot System Live Cyber Attacks PowerShell Azure Sentinel'
draft = false
+++



# About the Lab

Here is a demonstration video I made for this lab:

https://youtu.be/VisgPkkExLQ

# Lab Objectives

- Setup a honeypot virtual machine that is wide exposed to the internet (zero-inbound rules)
    - A honeypot is a computer with weak security.
    - Just like how honey bees are attracted to honey, we can attract hackers from around the world to try to hack into our computer.
        
        Hackers love weakly configured computers. And unlike bees, hackers use automated tools to find goodies 
        
- Analyze incoming traffic
    - While hackers are busy trying to break into our computer (or virtual machine), we can quietly extract data about them - like their IP address, location and few other information
    - In this lab, I’m only interested in plotting the location of the attackers on a world map in real time!

# Lab Workflow

![HoneyPot Network Diagram (3).png](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F72685fe4-bfdc-4c48-b623-77bdead64449%2FHoneyPot_Network_Diagram_(3).png?table=block&id=c84dda9b-8b87-4497-8eb8-860e1a749808&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fc587612b-8770-4d95-90dc-758e80b164b4%2FUntitled.png?table=block&id=18b7acc2-7fca-4db8-acd1-5ea39c563a93&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F98701889-c1ab-4a68-ae6c-7f7affaf8f9a%2FUntitled.png?table=block&id=8085dff5-7781-4970-a4aa-0065f9559604&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

- Essentially we a trying to detect failed RDP logon attempts to our honeypot VM. Windows OS tags such events with an ID of 4625 and they are added to a centralized pool of logs (that also includes other event IDs).
- Since we are only interested in RDP failed logons, we filter events (from the ‘centralized pool’) with the ID 4625 and store them onto a separate log file under C:\ProgramData\<custom log file name> in our VM
- With the help of a third-party service we discover the latitude and longitude of the IP that is embedded in each of the filtered logs.
- **<describe the entire steps in the lab>**

# Setting up the lab

### P**rerequisites**

- An Azure account with subscription (or you can sign up for free trial)
- Basic understanding of the Azure portal
- A host computer with internet connection

### Resources used

- Azure cloud portal
    - Windows 10 Pro Virtual Machine (2 vcpus, 8GB memory)
    - Azure Sentinel (SIEM)
    - Azure Log Analytics Framework
- Windows Host Machine
- Account on [ipgeolocation.io](https://ipgeolocation.io/)

### Setup Windows Virtual Machine

In the search bar on the Azure portal dashboard, type ‘virtual machine’. Select the first option.

Create a virtual machine with the configuration as shown in the image below. Follow the subsequent steps as they appear on the screen; they are simple and straight-forward

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F7feb00d8-1380-4421-98a8-1e03aecc9dfe%2FUntitled.png?table=block&id=ded7bcfa-dcea-4fb5-9368-3233c4a478b1&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=670&userId=&cache=v2)

Now let’s log into our honeypot VM and configure it to start receiving random internet connections!

Copy the VM’s public IP by navigating to the VM’s overview section

![Untitled.png](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F07b33bdc-7606-4101-a976-eac633a3b550%2FUntitled.png?table=block&id=597f9a12-783d-487c-9d4a-20d598387486&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

### **Connect to VM**

Open *Remote Desktop Connection* on your host computer and connect to the Azure VM using its IP address, as shown below:

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/4466202d-ffa7-4b9b-b026-45bf58cd4ffc/Untitled.gif?id=f027d466-e3fc-4401-9875-c7e142720c61&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=40B__5I3BqXV0tplLMALXG9L_dALoIveVduvh0-D-FI)

### **Turn OFF VM Firewalls**

All the Firewall rules under Windows Defender are turned OFF. This ensures that all kinds of traffic can freely access our VM

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fd5d85f4a-c379-4f87-9e57-e644de21f1cf%2FUntitled.png?table=block&id=adad2c7b-7107-46f0-ade3-e8e2e7e22338&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=960&userId=&cache=v2)

### Setup network firewall rules

Set the inbound traffic rule to allow ALL and ANY type of traffic (including RDP) to enter our VM. This is makes it easy for network scanners to discover our VM (or our honeypot!)

See the screengrab below on how to set it up

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/0b0fa6e6-4747-4987-aba2-0ed04c84737f/Untitled.gif?id=1269f804-f4d4-477a-a4d6-8be07eb3cb7e&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=XX3tprY5_HdVFO7Sm94rKUZ3YcNmT7p5roSn52YktVY)

### Setup ***Log Analytics Workspace***

- *Log Analytics Workspace* is an Azure product to log/collect data from other Azure services
- We **can use it to ingest Windows Event Viewer logs generated by our exposed Windows VM to Sentinel, which is our SIEM tool
- You can think of *Log Analytics Workspace* as a middle-man system that standardizes the log data coming from the VM, so it can be read in the SIEM tool

**Steps to setup Log Analytics Workspace**

Go the search and type *Log Analytics Workspace,* and choose the first option. Click on the blue C*reate Log Analytics Workspace*  button

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F8da3d4e3-1bb0-49e2-9877-e06d6b52a88a%2FUntitled.png?table=block&id=8af708a5-cdcc-4163-974e-78b6ccf38484&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

Choose the subscription, region and Name (as shown below) and click *Review + Create*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fe820d338-b1e6-4292-bd6c-c6fcf1f73ae3%2FUntitled.png?table=block&id=b34ddfcf-53aa-4f4b-a9a8-296dd2b9e305&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=770&userId=&cache=v2)

### **Enable Data Collection**

Azure by default has a security policy that controls the amount of log data being collected from the VM to the Log Analytics Workspace

We can change the control setting to *All Events* that essentially allows us to remove all restrictions and collect all kinds of logs from the VM.

Below screengrab shows how to navigate to the settings

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/9019eb73-ca6c-4c9e-ab78-42cf49328b92/Untitled.gif?id=a35e8059-4eb2-438f-ba78-750cf92cb83d&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=mfZKJX-DSf-GWO22gE0DL5_5-VCtjMe4dPfvCDS5R6k)

Change the control to *All Events*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F71377969-c016-4fec-8760-4714e6ba237e%2FUntitled.png?table=block&id=47e38258-d1a2-4095-86a1-e7f10d4d2ce4&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1440&userId=&cache=v2)

Now lets connect Log Analytics Workspace to our VM

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F09838073-137f-471b-854f-9d47ca45ab94%2FUntitled.png?table=block&id=64cbcc28-2c65-4ee4-95c3-a9075fb936fd&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

Click on *Connect* to successfully make the connection

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fc7652a56-d194-457f-8350-2fd017607e6f%2FUntitled.png?table=block&id=2d0041e3-10f3-45fc-9ad2-ade0b1fa1ad3&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

### **Analyzing events in the VM using Event Viewer**

Event viewer is a Windows service that lets us view the logs generated by the machine. These are the same logs that will be transferred to SIEM via the *Log Analytics Workspace.* Check to make sure the logs are collected in the *Event Viewer.* See [PowerShell Script](https://www.notion.so/Honeypot-System-Live-Cyber-Attacks-PowerShell-Azure-Sentinel-f6027926a581424d92ae54bbe2d1b18c?pvs=21) below for details on how the logs are utilized for our project.

**NOTE**: We are only interested in the logs with the Event ID of 4625 that represents RDP logon failure

![Event Viewer picked up a logon failure](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F45f91891-e7ab-4e96-be52-eeb902e6aded%2FUntitled.png?table=block&id=1cca7416-7890-4a15-8e4e-f00d88d5d361&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

Event Viewer picked up a logon failure

# Setting up the Honeypot Environment

### PowerShell Script and Setting up getgeolocation.io

The PowerShell script is used to automate the tasks defined under the [Lab Workflow](https://www.notion.so/Honeypot-System-Live-Cyber-Attacks-PowerShell-Azure-Sentinel-f6027926a581424d92ae54bbe2d1b18c?pvs=21)  - from log extraction, filtering till using [ipgeolocation.io](http://getgeolocation.io) for geo data extraction.

- Download the script from [Sentinel-Lab/Custom_Security_Log_Exporter.ps1 at main · joshmadakor1/Sentinel-Lab · GitHub](https://github.com/joshmadakor1/Sentinel-Lab/blob/main/Custom_Security_Log_Exporter.ps1) into the VM and open it in PowerShell ISE
- Create an account at [ipgeolocation.io](http://getgeolocation.io) and copy your unique API key from your account dashboard. And, replace the existing API key on the PowerShell script with yours
- After the above steps are completed, run the script for a few seconds. This is done to generate a dummy log to [train the *Log Analytics Workspace* system](https://www.notion.so/Honeypot-System-Live-Cyber-Attacks-PowerShell-Azure-Sentinel-f6027926a581424d92ae54bbe2d1b18c?pvs=21)
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F20992fb3-d6f1-4866-85fd-ecfecae9ae3b%2FUntitled.png?table=block&id=17901ef4-9c1f-4d1a-8c18-63137f23b8e7&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)
    
    Shown below is *ipgeolocation* dashboard where you can track your API requests and copy your API key
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F99c98c8b-3331-4b1d-9ce0-f054f623087d%2FUntitled.png?table=block&id=2e185fba-ba38-439e-bf15-cdd8952d1403&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)
    

### Training *Log Analytics Workspace*

Now we have to point *Log Analytics Workspace* to the log file inside our VM (generated when were setting up the PowerShell script) - so it knows where to fetch the log to transfer to Sentinel (our SIEM tool)

Also, we have to train the system to only pickup the appropriate *parameter: value* pair from the log data. Since the log data is in a formatting that is not understandable by the system, we have to train to recognize relevant values.

Under Log Analytics Workspace, click on *Custom Logs* and click *Add Custom Logs*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fee8e845a-13b7-4615-8e7a-5ef2e569809d%2FUntitled.png?table=block&id=e42cd8b8-d061-48c2-aaf5-39500d94aa4d&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

Choose the sample log file in our VM as shown below. This sample log file will then be used to train the system

![A custom log file is uploaded to train the system](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F90884d11-d6a8-49c1-be49-4b41c7e2e67a%2FUntitled.png?table=block&id=859e52a8-1f17-41fb-82f3-9d519812b2c5&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

A custom log file is uploaded to train the system

Below screenshot shows the log file in our VM being linked to the *Log Analytics Workspace* so it can draw the latest log data from the VM automatically

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F96e125b7-7ab5-4992-886a-3c4e29f1d0da%2FUntitled.png?table=block&id=9f4b7ba0-4e18-4457-8c52-1ecef15f3d71&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1250&userId=&cache=v2)

Below is a screengrab of me training the system to properly identify relevant values from the log data

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/d90ca0a2-e7b4-46b3-b5f3-5b2df02f4b5b/Untitled.gif?id=32295423-6697-4959-92cc-5d34ae52bf8a&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720267200000&signature=nIKXc8ZnFO6IB4aqzDHt_gr-KdgRDtJT3Xt73Br9mcs)

### Setup Sentinel

Now it is time to setup our Sentinel SIEM tool

Azure Sentinel is a SIEM tool built into the Azure cloud infrastructure. We will use Sentinel to analyze the logs generated by the VM and plot that data on a live world map 

Surprisingly it is easy to setup Sentinel.  Search for Sentinel and click on the first option and select *Create*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fd6369d36-17a7-4f33-91ed-b3433cd7a689%2FUntitled.png?table=block&id=3a872831-05d1-4c27-bf8e-302ff4a3b933&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

Add Sentinel to the workspace we already created in the above steps

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fb87a6245-6d48-433f-8baf-dc739365d71a%2FUntitled.png?table=block&id=18c1cd28-bcff-4731-b1eb-c1fb443159e1&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1150&userId=&cache=v2)

Below is a screenshot of the Sentinel dashboard

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2F275e4f60-53a5-446c-b96a-ed18d302e5a1%2FUntitled.png?table=block&id=08ee84c7-e41e-4416-94da-ce7d2c2804d8&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1440&userId=&cache=v2)

Navigate to Sentinel and create a new Workbook (as shown below)

Once a workbook is created, run the below code to query the log to display the data in the map

`FAILED_RDP_WITH_GEO_CL | summarize event_count=count() by sourcehost_CF, latitude_CF, longitude_CF, country_CF, label_CF, destinationhost_CF
| where destinationhost_CF != "samplehost"
| where sourcehost_CF != ""` where `FAILED_RDP_WITH_GEO_CL` is the name of the custom log table I created inside *Log Analytics Workspace* while I was training it 

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/4039790c-a842-40ab-a5e4-67746293e9e9/Untitled.gif?id=97e4868e-67a0-4d00-ba2d-4a81fc3dfe98&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720375200000&signature=uZ-hbrq5XrOMNLHpfMBaKyYK_EhaA4ziMbugQA3ZsIs)

After running the query we can now setup the world map, as shown below:

![Untitled](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/21da35b7-c87a-4f32-ba2b-eb7786fa8381/Untitled.gif?id=41ec4107-b5b5-408b-80ea-11480e6a8fda&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720375200000&signature=LR2kOMQZWTQSivtfbjjTQ768mKwtgUV0GZVDbSt1LxM)

Once the map is setup we now simply have to wait for the data to show up on the map. The refresh time is 5 minutes, so the map get updated with new geo data every 5 minutes.

NOTE: If the PowerShell script is not running, now is the time to run it. Sit back relax and wait for the hackers to attack!!

# The Results!

Finally we have reached the end of the tutorial. So far we have setup a VM, PowerShell script to collect logs, Azure Sentinel, Log Analytics Workspace and a map to visualize the attacks. 

A few minutes after the setup was complete, I started receiving a slew of incoming traffic from unknown sources around the world. 

Thankfully I had the PowerShell script running in the background, so I was able to capture the traffic and display them in the PowerShell console in real-time as seen below!

![Real-time RDP logon fails. L for hackers XD . Captured around 19:27, 12 January 2023](https://file.notion.so/f/f/35060c7e-3917-4cd6-a745-937d3114d009/d3f143d6-af0f-44c8-8299-3a10d3370052/Untitled.gif?id=1df99076-e28b-4738-8190-abf22d2e5983&table=block&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&expirationTimestamp=1720375200000&signature=Uhuo2gKuz2RekrkcYdh9bp9_LmbmUqcqa-5zCa1eqRk)

Real-time RDP logon fails. L for hackers XD . Captured around 19:27, 12 January 2023

The live traffic I captured above are basically from network scanners scanning the internet looking for ‘weakly configured’ Windows machines to attack. Remember, we configured our host to be weak - by disabling its firewall.

Once they discover a host, they start brute forcing it using random usernames and passwords. Unfortunately only the usernames are captured in the logs.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fbeed3aee-4eb6-4237-bae0-bf7efa7efdf6%2FUntitled.png?table=block&id=99562ce4-878c-432c-bd79-a2029d3c21d0&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1540&userId=&cache=v2)

The above log data is plotted onto a world map in real-time.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fs3-us-west-2.amazonaws.com%2Fsecure.notion-static.com%2Fd30e447c-9945-4e73-9bb9-33869c0bd642%2FUntitled.png?table=block&id=1358d763-effd-461f-9b71-558e65acfcfb&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1440&userId=&cache=v2)
