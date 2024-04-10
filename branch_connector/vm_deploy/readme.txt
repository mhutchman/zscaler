----------------------------readme----------------------------
This script was written and tested with Proxmox version 7.3.3


---- new-bc-vm-from-clone.sh -----

:::::::::::::Purpose:::::::::::::
This script allows performs the following functions

1 - it reads in your branch connector api key, admin username, password from the bc_variables.txt file
2 - it reads in your proxmox ISO directory and branch connector template ID from the bc_variables.txt file
3 - it finds the next available VM ID in the proxmox cluster
4 - it then asks the user for the name they want to assign to the new VM
5 - then clones your branch connector vm template to that next available VM ID
6 - it asks the user if they are or are not deploying an integrated app connector in the branch connector VM
7 - it gathers the cc_url for the config template from the user input
8 - it gathers the branch connector IP infofrmation and optionally the integrated app connector ip information and provisioning key, from the user input
9 - it creates the user-data file in YAML format
10 - it utilizes genisoimage to create an ISO file from user-data file
11 - it mounts the ISO to the cloned branch connector VM as a CDROM
12 - it cleans up the user-data YAML file
13 - it boots the new  cloned branch connector VM
:::::::::::::Purpose:::::::::::::


:::::::::::::Assumptions:::::::::::::
this shell sript assumes
1 - you are running proxmox
2 - you have a branch connector VM template created
3 - the branch connector VM template is capable of running small & medium VMs with or without integrated AppConnector
:::::::::::::Assumptions:::::::::::::


:::::::::::::Info about the branch connector VM Template:::::::::::::
The template is set with 4 CPU cores, 8GB RAM, 128GB of disk, 4 Network Interfaces
root@pve:~# qm config 108
agent: 1
boot: order=scsi0
cores: 4
memory: 8192
meta: creation-qemu=7.1.0,ctime=1691002627
name: bc-template
net0: virtio=3E:3C:FE:8A:B1:21,bridge=vmbr0
net1: virtio=DE:52:08:59:B8:93,bridge=vmbr0
net2: virtio=F6:74:3B:75:62:05,bridge=vmbr0
net3: virtio=AA:B3:B1:DC:0E:BB,bridge=vmbr0
numa: 0
onboot: 1
ostype: other
scsi0: SSD:108/vm-108-disk-0.raw,iothread=1,size=128G,ssd=1
scsihw: virtio-scsi-single
smbios1: uuid=86f3cbea-60be-4136-8a3b-f364c77bbe5a
sockets: 1
template: 1
vmgenid: d6632f90-af34-461f-8103-d60b4ad957e2
:::::::::::::Info about the branch connector VM Template:::::::::::::


:::::::::::::Instructions:::::::::::::
On the proxmox server where your Branch Connector template is located
place the bc_variabes.txt and new-bc-vm-from-clone.sh files in the same directory as eachother
in my case i placed them both in /root so that when I login I can execute them without changing directories

edit the bc_variables.txt file to contain the proper values for
your connector portal API Key
the username and password for your admin account
the ISO directory you wish to store your userdata.cfg files that will be mounted to the branch connector VM CDROM
the VM ID of your branch connector template

once complete, cd into the directory where you placed the bc_variabes.txt and new-bc-vm-from-clone.sh
grant the new-bc-vm-from-clone.sh execute permissions on proxmox

root@pve:~# chmod +x new-bc-vm-from-clone.sh

and execute the script via
./new-bc-vm-from-clone.sh
:::::::::::::Instructions:::::::::::::
