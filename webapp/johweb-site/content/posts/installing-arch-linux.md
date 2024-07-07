+++
title = 'Installing Arch Linux'
draft = false
+++

### Things I did

- Create three partitions - sda1, sda2 and sda3
    
    `fdisk /dev/sda`
    
    - *sda1* - boot partition , GPT, filesystem/FAT32
    `mkfs.fat -F32 /dev/sda1`
    - sda2 - EFI boot files, GPT, filesystem/ext4
    `mkfs.ext4 /dev/sda2`
    - sda3 - Arch Linux is installed here, GPT, LVM, Encrypted
    `cryptsetup luksFormat /dev/sda3` - for encrypting *sda3*
    Encryption passphrase: *qwerty*
- The tutorial I followed used LVM on the third partition to install Arch Linux. Here is how to setup LVM on *sda3*
    - First, you have to create a *device mapper device* for sda3.
    Device Mapper is a framework/service that is used to create an abstraction layer (like an API) between Linux modules (like LVM, crypsetup etc.) and the underlying hardware/block-device.
        - Why the need for an abstraction layer?
        Device mapper serves as a flexible and powerful virtual/abstract layer (between Linux modules and block devices) for managing block devices, allowing for advanced features and capabilities that would not be possible with direct access to physical devices.
    - Before we install LVM on sda3, we have to first decrypt it. *Cryptsetup* comes with a feature that allows you to decrypt and create a device mapper with a custom name, at the same time:
        
        `cryptsetup open —type luks /dev/sda3 lvm` (*lvm* is the custom device mapper name I provided)
        

### Let’s setup LVM on sda3

- create LVM physical volume
`pvcreate /dev/mapper/lvm`
- create LVM volume group named *volgroup0*
`vgcreate volgroup0 /dev/mapper/lvm`
- create logical volumes *lv_root* and lv*_home*
`lvcreate -L 30GB volgroup0 -n lv_root
lvcreate -L 8GB volgroup0 -n lv_home`
- Install necessary kernel modules for LVM (*dm_mod*):
`modprobe dm_mod`
Check if the installed LVM modules can detect the volume groups:
`vgscan`
- Activate all volume groups - **`vgchange -ay`**
When you run the command, the system will scan for inactive volume groups and activate them, making their logical volumes accessible for use through */dev/volgroup0*

<aside>
⭐ **The setup so far:**

root@archiso ~ # lsblk
NAME                                              MAJ:MIN        RM    SIZE   RO   TYPE   MOUNTPOINTS
sda                                                        8:0                0      45G     0       disk
├─sda1                                                 8:1                0      1G       0       part
├─sda2                                                 8:2                0      1G       0       part
└─sda3                                                 8:3                0      43G     0       part
    └─lvm                                              254:0             0      43G     0       crypt
          ├─volgroup0-lv_root                 254:1             0      30G     0       lvm
          └─volgroup0-lv_home               254:2             0     12G      0       lvm

*#we created, formatted, installed LVM etc. on sda3 using a live USB/CD iso.*

</aside>

- Format both logical volumes with an ext4 file system:
`mkfs.ext4 /dev/volgroup0/lv_root
mkfs.ext4 /dev/volgroup0/lv_home`

### Let’s begin the installation of Arch Linux on *sda3*

- Essentially all of the Linux commands you saw above were run from the live USB (or live virtual CD) containing the Arch ISO image (aka. *installation environment)*
- Mount *lv_root*, *lv_home* (of sda3) and *sda2* to */mnt* of the live USB/CD.
    - The reason why we mount lv_root and lv_home to /mnt of the installation environment is so we can run commands inside /mnt, and that will sync the same to the volumes lv_root and lv_home.
    - `mount /dev/volgroup0/lv_root /mnt`
    - `mkdir /mnt/home
    mount /dev/volgroup0/vol_home /mnt/home`
    - `mkdir /mnt/boot
    mount /dev/sda2 /mnt/boot`
- Once the above mounts are done, we can now proceed to make changes in the /mnt directory, hence resulting in those changes happening in the lvm volumes as well!
- Install the required packages for Arch Linux on */mnt* , thereby installing them on *lv_root.*
`pacstrap -i /mnt base`
- When you do an `ls /mnt` you can see that it got populated with a minimal Linux file system
- Add *lv_root, lv_home* and *sda2* mount point to fstab file (of the main disk)
`genfstab -U -p /mnt >> /mnt/etc/fstab`
- Since we have a barebones Linux file system setup in */mnt,* we can use chroot to log into it and run some commands to install Arch!
    - Remember,  running commands and doing any operations in /mnt (/mnt is of the live USB) means you’re doing the same on sda3’s lvm volumes!
    - `arch-chroot /mnt` to create a temporary Linux runtime container inside /mnt  - you can then run commands inside it to install the Linux Kernel and other Linux and Arch packages . This results in the installation of Arch Linux on *sda3* !
- Run the rest of Arch installation inside chroot environment/container:
    - `passwd` - add password to root user of your Arch OS
    - `useradd -m -g users -G wheel johith` - add *johith* user and add it to *wheel* secondary group for sudo access and to primary group
    - `passwd johith` - assign password to *johith*
    - Install basic packages for your Arch OS using Arch’s own package manager called *pacman*
        
        `pacman -S base-devel dosfstools grub efibootmgr gnome gnome-tweaks lvm2 mtools nano networkmanager openssh os-prober sudo`
        
    - `systemctl enable sshd`
    - Install Linux Kernel and its headers. Also install Linux LTS as a backup kernel (this is optional)
    (chroot is currently using the kernel of the live USB’s arch ISO)
    `pacman -S linux linux-headers linux-lts linux-lts-headers`
    - Hardware support for Linux Kernel
    `pacman -S linux-firmware`
    - Install the GPU driver. In this case I’m installing mesa which is a driver for Intel GPU’s
    `pacman -S mesa`
    - Let’s edit `nano /etc/mkinitcpio.conf` . Add *encrypt* and *lvm2* in HOOKS between *block* and *filesystems*, as seen below. Read more on this below this page.
        
        ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F2ba6254b-b44d-4044-93f1-65870b00887c%2FUntitled.png?table=block&id=ab1057e7-bc0a-4ee1-9fff-0977adf96645&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=2000&userId=&cache=v2)
        
    - Configure new *initramfs* image for all your Kernels
    `mkinitcpio -p linux`
    `mkinitcpio -p linux-lts`
    - Set locale by editing `/etc/locale.gen` and uncommenting your locale, like below:
        
        ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F308d3314-c800-4ee9-b0d9-6b7e2b860d0d%2FUntitled.png?table=block&id=13718e6b-cb10-4805-9616-debd0222f158&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=510&userId=&cache=v2)
        
        Then run `locale-gen`
        
    - Edit the grub bootloader to tell the kernel on bootup to set up the specified block device (sda3) as a crypto device and map it to the specified volume group. This is typically used when the root filesystem is encrypted and needs to be decrypted before it can be mounted.
    `nano /etc/default/grub`
    Add the below line:
        
        ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2F93f36a70-e6a4-4aea-808b-ccf8394c2e37%2FUntitled.png?table=block&id=796a5f46-4eda-4ec5-b018-189afc53ea37&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=1620&userId=&cache=v2)
        
    
    ### Let’s install the GRUB Bootloader
    
    (we’re still inside chroot environment!)
    
    - create directory `mkdir /boot/EFI`
    - Mount it to *sda1* which is our boot partition
    `mount /dev/sda1 /boot/EFI`
    - Download and install GRUB
    `grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck`
    This will automatically install GRUB in /boot/EFI (this is it’s default location). Since */boot/EFI* is mounted on sda1, the GRUB EFI Bootloader is copied to our *sda1 “*boot” partition.
    - The next command will copy locale files for GRUB’s messaging to our boot directory:
    `cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo`
    - Generate a config file for `GRUB`:
    `grub-mkconfig -o /boot/grub/grub.cfg`
    - Enable GDM (gnome display manager) - this is used to display the login screen on bootup.
    `systemctl enable gdm`
    - Enable `NetworkManager` so networking will function when you bootup:
    `systemctl enable NetworkManager`
    - `exit` from chroot environment
- `umount -a` unmount everything from the live usb
- `reboot`
- Finally, set the correct locale/language inside Arch:
    
    ![Untitled](https://johith.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F35060c7e-3917-4cd6-a745-937d3114d009%2Fe5f57304-e98b-4572-b214-e3a849696939%2FUntitled.png?table=block&id=972afb2f-580f-458b-985a-69d0f30719b4&spaceId=35060c7e-3917-4cd6-a745-937d3114d009&width=860&userId=&cache=v2)
    

We use the live USB as an *installation environment* to install Arch Linux on the main hard disk.

Through the live USB or the Arch installation environment:

- we made partitions (sda1, sda2, sda3) on the main disk
- initialized sda3 with LVM and then created two *LVM logical volumes (*lv_root and vol_home*)*
- then installed Linux Kernel and other Linux packages on both the *logical volumes*
    - first mounted *lv_root* and *vol_home* to */mnt* in the live USB - this basically syncs the files and anything you do in /mnt on the live USB to the logical volumes lv_root and vol_home in sda3
    - 

### What is initramfs (Initialize RAM File System) ?

- The **initramfs** is a temporary file system that is loaded/mounted into memory during the Linux startup process before the actual root file system is mounted.
    - Its purpose is to provide the necessary tools, modules, and files required to mount the root file system and then start the system's init process (**`init`**).
- The **initramfs image** is the compressed file that contains the initramfs contents.
    - It is typically stored as a file within the Linux kernel's boot directory (**`/boot`**), with a filename like **`initramfs-linux.img`**
- The **initramfs generator** is a tool or script responsible for creating the initramfs image based on the system's configuration (**`/etc/mkinitcpio.conf`**). Arch Linux use a generator called *mkinitcpio.*
- `/etc/mkinitcpio.conf` **File:**
    - This file is located in the **`/etc`** directory of Linux systems that use **`mkinitcpio`** as the initramfs generator, such as Arch Linux. The purpose of this file is to configure how the initramfs image is generated.
- **`mkinitcpio` command** rebuilds the initramfs image based on the updated configuration, ensuring that the changes take effect during the next system boot.
- **HOOKS** are small scripts or programs that perform specific tasks necessary for booting the system. A HOOKS array in ***/etc/mkinitcpio.conf*** defines the sequence of hooks that **`mkinitcpio`** should execute to build the initramfs image.

### References
https://www.youtube.com/watch?v=FxeriGuJKTM
