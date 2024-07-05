
+++
title = 'Proxmox PCI GPU Passthrough'
draft = false
+++

### System Background

Proxmox version 8.0.3

Nvidia Quadro K2200 GPU

### What is PCI/GPU passthrough?

### Why PCI/GPU Passthrough?

For running some AI models locally with the help of *Ollama*

## Requirements

- Your motherboard should support IOMMU (Input-Output Memory Management Unit) - This is a hardware component that allows hardware as well as virtual machines direct access to memory address spaces.
    
    Traditionally VMs only have access to virtual memory address spaces. With IOMMU, VMs can have direct access to real memory address spaces.
    
    Intel refers to IOMMU as Intel VT-d. Make sure IOMMU or its equivalent is enabled in your BIOS/UEFI
    
    ![Image from https://h30434.www3.hp.com/t5/Business-PCs-Workstations-and-Point-of-Sale-Systems/Enable-Virtualization-in-BIOS-how-to/td-p/8088471](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fd19b7f4c-adec-47b9-bcde-75ca68dd6e3e%2FUntitled.png?table=block&id=87d48476-421a-49d7-95b1-e699677539f8&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=960&userId=&cache=v2)
    
    Image from https://h30434.www3.hp.com/t5/Business-PCs-Workstations-and-Point-of-Sale-Systems/Enable-Virtualization-in-BIOS-how-to/td-p/8088471
    
- I’m using Ubuntu Server in this guide as it is my preferred OS for this project. If you are on Windows this guide will not work.

## So this is how I did it …..

- SSH into your proxmox server
- Let’s enable IOMMU in Linux Kernel
`nano /etc/default/grub` and add the line
`GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on"` 
then , `update-grub`
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F32ad7e1e-bf7b-44be-9917-fef8bee33ad5%2FUntitled.png?table=block&id=77f0205a-bc12-413f-9fcc-6b73852953dd&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=960&userId=&cache=v2)
    
- I also nanoed into `nano /etc/kernel/cmdline` and added `intel_iommu=on`. 
Then ran `proxmox-boot-tool refresh` to update the new boot configurations.
    - NOTE: I did both the above steps. Since my VM uses UEFI for booting, I only had to do the second step. But I had to add `intel_iommu=on` to `/etc/default/grub` as well for passthrough to work. I need to look more in to this!
- Now run `update-grub`
- `nano /etc/modules` and add the below kernel modules. These modules have to be loaded on boot for passthrough to work (essentially vfio works in conjunction with IOMMU to allow VMs direct I/O hardware access).
    
    ```
    vfio
    vfio_iommu_type1
    vfio_pci
    vfio_virqfd
    ```
    
- Run `lspci` and note down its PCI ID which in my case is 04:00 as see below.
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fddf7a34b-4535-449b-8aed-128a86da7c78%2FUntitled.png?table=block&id=a3cc46e8-a025-4878-b285-907b576055fe&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=960&userId=&cache=v2)
    
- Note down the hexadecimal identification of your GPU using
`lspci -n -s 04:00 -v` (where *04:00* is the PCI ID I got from the above step)
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F27ee42c1-1193-4939-9593-827dabaeb505%2FUntitled.png?table=block&id=dbd5d6b0-a9e8-472c-bd7c-d001ec03e2db&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=770&userId=&cache=v2)
    
- Now let’s specify the hexadecimal ID of the GPU to *vfio:*
`echo "options vfio-pci ids=10de:13ba disable_vga=1"> /etc/modprobe.d/vfio.conf`
*disable_vga=1* prevents the host computer from grabbing the GPU and using it for itself - thus leaving the GPU for full access by the VM
- As an additional precaution (to prevent host from using our GPU), let’s blacklist all the Nvidia GPU drivers on the host computer
    
    `echo "blacklist nvidia" >> /etc/modprobe.d/blacklist.conf`
    `echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf` (*nouveau* is an open source alternative to Nvidia’s proprietary drivers)
    
- Also add the following. I couldn’t wrap my head around what they’re for but I added them on to my proxmox
`echo "options vfio_iommu_type1 allow_unsafe_interrupts=1" > /etc/modprobe.d/iommu_unsafe_interrupts.conf`
    
    `echo "options kvm ignore_msrs=1" > /etc/modprobe.d/kvm.conf`
    
- Apply all changes
`update-initramfs -u -k all`
- Reboot host computer

### Creating a virtual machine

Now let’s see the process on how to create a virtual machine for PCI/GPU passthrough. Here I’m installing Ubuntu Server 22.0 

- Since my host computer is an EFI based system, I will use q35 for machine type and OVMF as BIOS type

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Ff7057172-c9ae-421d-9b9b-4b5606816639%2FUntitled.png?table=block&id=66e90194-84ef-4276-80c3-4a757c44224d&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=860&userId=&cache=v2)

- The below is CPU information

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fa9ddcf6f-420a-441e-97a5-2fdf8f5946fa%2FUntitled.png?table=block&id=24059519-791e-4ca1-b8df-c50cf901170c&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=860&userId=&cache=v2)

- Assign memory as required and disable “Ballooning Device”
NOTE: GPU passthrough uses static memory addresses to access hardware devices. If ballooning is enabled, then memory addresses (for virtual machines) become dynamic thus conflicting with passthrough process.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F43c76b0a-dd85-4f06-b630-73e477e08aec%2FUntitled.png?table=block&id=a53b6310-3b7b-4e4d-9df4-231f148ee6b3&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=960&userId=&cache=v2)

- Now proceed to install your virtual machine’s OS. Make sure to capture a Snapshot of your VMs fresh install, just in case if something goes wrong in the proceeding steps!
- Once installation is complete, shutdown the VM. 
Then head over to it’s *Hardware* > *Add* > *PCI Device*

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Ff05f830e-882e-46cc-b09e-8876478124df%2FUntitled.png?table=block&id=6d443194-8c2e-4491-9b4d-2f8ba8a8abcc&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=770&userId=&cache=v2)

- Select *Raw Device* and then choose your GPU from the list. Mine is the NVIDIA Quadro K2200

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F0a874333-3e66-42ec-8f6b-7b8f5616af3c%2FUntitled.png?table=block&id=e988218d-edb7-4e66-9c4e-9a6a45ff2812&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)

- Enable *All Functions* and *Primary GPU*
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F432978be-aee6-42ba-b63d-93ba67503217%2FUntitled.png?table=block&id=db31f96c-4000-41d6-a86a-58d1eed8afb9&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)
    
- Now let’s start your VM. Ohh wait….. you will be getting the below error!
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F89998f6e-48b8-48b0-a005-a314e2174f75%2FUntitled.png?table=block&id=1c639143-ab02-4a77-99d6-dd78c959365e&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- Don’t worry, this is normal. This is happening because we have disabled host’s access to the GPU. 
Now to access the VMs console/display - there are two options here:
    - 1. SSH in to the VM
    - 2. Setup an RDP server on VM and remote into it
- Take a *Snapshot* of your VM
    
    ### Let’s configure your VM OS to support GPU passthrough
    
- I have SSH’ed into my VM. Once you’re inside the VM, use `lspci`to check if the VM can recognize your GPU
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Ffe43a768-7342-4c55-b294-6b26138b58f5%2FUntitled.png?table=block&id=79494c01-3c25-455d-9e53-ae603953b923&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1060&userId=&cache=v2)
    
- Use `sudo lshw -C display | grep driver` to display the list of display drivers used by your VM
- In my case the only display driver is *nouveau* which is perfect! As mentioned before, nouveau is an open-source version of Nvidia’s proprietary GPU driver, that is embedded in Linux kernel.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fb7f7cb37-d3a6-4c89-816a-70c0081bdd33%2FUntitled.png?table=block&id=718f7e43-0a52-4c03-9a70-f408ae219fd1&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1320&userId=&cache=v2)

- NOTE: if for some reason there are multiple display drivers listed, I highly recommend to blacklist all the other non-nouveau drivers - so they don’t conflict with each other and raise any issues. You can do so by: `echo "blacklist driver-name" >> /etc/modprobe.d/blacklist.conf` inside your Linux VM and then reboot.
- Take a *Snapshot* of your VM

### Upgrading from Nouveau to Nvidia drivers

**Why upgrade to Nvidia GPU driver from nouveau?**

Nouveau drivers are pretty useful and functional, but in some instances certain software/utility does not support nouveau. 

- First, disable *Secure Boot* in your VMs BIOS/UEFI so Linux can installed unsigned Nvidia drivers. Let’s see below on how to disable secure boot.
- `uname -m` for checking Linux CPU architecture
- While your VM is booting, press the *Esc* button to open BIOS/UEFI. Select *Device Manager*
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F947c7706-80f4-45e9-94ad-26b10afa30a1%2FUntitled.png?table=block&id=60d96163-643f-4790-9f59-da6913d2b502&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- Select *Secure Boot Configuration*
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F33cb35ac-3ca6-4c4e-bfc9-472f48fb5752%2FUntitled.png?table=block&id=cbe2f5d2-942c-4e9b-ba9a-35c4b867cb9b&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- Disable *Attempt Secure Boot*
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F06dfb6b2-8e05-4ed8-a903-0f15ad75e14b%2FUntitled.png?table=block&id=1a15f097-cacd-4af1-9bee-36d50175d0e6&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- *Esc* all the way back to home view and *Reset*
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Faf8fb912-7101-47b6-b473-e162ae39e0b0%2FUntitled.png?table=block&id=9eb75f8c-8ca5-4da4-a0d3-ca234d8dda36&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- Now let’s procced to install Nvidia driver. Gather some system information as mentioned below:
    - `lsb_release -r` for finding your Ubuntu version
    - `uname -m` for finding Linux architecture
    - Nvidia driver installation requires C++ compiler. You can install the compiler provided by *GNU Compiler Collection (GCC)* using `sudo apt install build-essential`
    Use `gcc --version` to verify if its installed
- Head over to https://developer.nvidia.com/cuda-downloads to install Nvidia driver. Choose the options based on the information gathered from above.

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Ffedbb081-38b0-40f1-b035-1bea985504ff%2FUntitled.png?table=block&id=f63bf4b5-1903-4eac-b533-28c4794aa5fa&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F41963840-acaa-4000-a413-bcf64bb59497%2FUntitled.png?table=block&id=fd6c66e1-bac6-4b6e-b178-14d3259a82cc&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1540&userId=&cache=v2)

![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F232328f2-54ff-4633-8b74-07f2a5007f50%2FUntitled.png?table=block&id=4b8f9b85-cba8-4f26-b2e2-86af440c6415&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1910&userId=&cache=v2)

- I have only installed the driver
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fd596e937-1c5f-44f9-bfb8-df4ecbd5af5f%2FUntitled.png?table=block&id=1b837e16-9755-4919-89bb-1f7a9c5da72b&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1680&userId=&cache=v2)
    
- If you encounter the below error, reboot the VM.
    
    Upon reading the logs it seems that although Nvidia Cuda utility blacklisted Nouveau in `/etc/modprobe.d/` *,* the changes haven’t been applied to the Linux kernel - hence a simple reboot would apply the changes - ie. remove nouveau driver from Linux kernel’s memory space. Now, Nvidia Cuda can proceed to install its drivers and attach itself to Linux Kernel without interference from nouveau.
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F2125e47a-7c2c-4d26-99ab-2e299be81adb%2FUntitled.png?table=block&id=4279dfe1-257c-47ab-a917-886ebc7bfc93&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1640&userId=&cache=v2)
    
- Run the Cuda script again. This time the final output should be as below
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F72ce318c-7b6e-47f2-ad0c-6bcffd32c18c%2FUntitled.png?table=block&id=f6e016e6-b333-4793-9902-f7b2943cfec8&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1210&userId=&cache=v2)
    
- Check the display driver using `sudo lshw -C display | grep driver` . 
Finally nvidia replaced nouveau as the primary GPU driver
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F2d578067-f839-4776-b82b-ef37344c9038%2FUntitled.png?table=block&id=51e44fb4-f146-4e50-b87d-565dcad3e576&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1290&userId=&cache=v2)
    
- For a quick GPU test - apt install and use *nvtop* utility
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F241d801b-b84f-4b0f-8e3e-27948e01487d%2FUntitled.png?table=block&id=494e8853-62fe-4bea-8d50-e29b057b49b9&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
    
- If you have reached here - awesome and great job! Now capture a VM Snapshot before you proceed.

### References

- https://www.youtube.com/watch?v=_hOBAGKLQkI
- https://drive.google.com/file/d/1rPTKi_b7EFqKTMylH64b3Dg9W0N_XIhO/view
