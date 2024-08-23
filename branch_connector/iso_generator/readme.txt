----------------------------readme----------------------------

---- bc-iso-gen.sh -----

:::::::::::::Purpose:::::::::::::
This script allows performs the following functions

1 - it reads your branch connector api key, admin username, password from the bc_variables.txt file
2 - it asks what hypervisor you're using - VMWare/KVM/MSFT HyperV
3 - it asks the user if they are or are not deploying an integrated app connector in the branch connector VM
4 - it gathers the cc_url for the config template from the user input
5 - it gathers the branch connector, and optionally the integrated app connector, ip information from the user input
6 - it creates the user-data file in YAML format
7 - it utilizes genisoimage to create an ISO file from user-data file
8 - it cleans up the user-data YAML file
:::::::::::::Purpose:::::::::::::


:::::::::::::Assumptions:::::::::::::
this shell sript assumes
1 - you have genisoimage installed on your machine where you are running this script
2 - you have a branch connector config template created in the Connector Portal
:::::::::::::Assumptions:::::::::::::


:::::::::::::Instructions:::::::::::::
On the machine where genisoimage is installed
place the bc_variabes.txt and bc-iso-gen.sh files in the same directory as eachother

edit the bc_variables.txt file to contain the proper values for
your connector portal API Key
the username and password for your admin account

once complete, cd into the directory where you placed the bc_variabes.txt and bc-iso-gen.sh
grant the bc-iso-gen.sh execute permissions on proxmox

root@pve:~# chmod +x bc-iso-gen.sh

and execute the script via
./bc-iso-gen.sh
:::::::::::::Instructions:::::::::::::
