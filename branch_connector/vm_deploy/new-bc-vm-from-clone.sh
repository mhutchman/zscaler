#!/bin/bash
# written using proxmox 7.3.3
# Variable file containing additional data
source ./bc-vm-variables.txt


##########
#Start of Functions#


# Function to validate boolean input
validate_boolean() {
    input=$1
    if [[ "$input" =~ ^(yes|no|true|false)$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate integer input
validate_integer() {
    input=$1
    if [[ "$input" =~ ^[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate IP address
validate_ip() {
    input=$1
    if [[ "$input" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate subnet mask
validate_subnet_mask() {
    input=$1
    if [[ "$input" =~ ^(255\.){3}(0|128|192|224|240|248|252|254|255)$ ]]; then
        return 0
    else
        return 1
    fi
}


# Get the list of VMIDs
vmid_list=$(pvesh get /cluster/resources --type vm --output-format yaml | grep vmid | awk '{print $2}')

# Function to find the next available VMID
find_next_vmid() {
    local next_vmid=100  # Start checking from VMID 100
    while true; do
        if ! echo "$vmid_list" | grep -q -w $next_vmid; then
            echo $next_vmid
            break
        fi
        ((next_vmid++))
    done
}

# Function to create a new VM with the provided name and VMID

create_new_vm() {
    local vmid=$1
    local name=$2
    qm clone $bc_template_id $vmid --name $name --full
    echo "VM $name with ID $vmid created successfully."
}
#End of Function Definitions#
##########

##########
# validate genisoimage is installed 
if ! dpkg-query -W -f='${Status}' genisoimage 2>/dev/null | grep -q "installed"; then
    echo "Error: genisoimage package is not installed. Please install it before running this script."
    exit 1
else 
    echo "genisoimage is installed"
fi

#Execute Functions
# Call the function to find the next available VMID
next_vmid=$(find_next_vmid)
echo "Next available VMID: $next_vmid"


#####################
#create the new bc VM from template
# Prompt the user to input the name for the new VM
read -p "Enter the name for the new VM: " vm_name

# Call the function to create a new VM with the next available VMID and the provided name
create_new_vm $next_vmid "$vm_name"
#####################


while true; do
    echo "Are you using the Integrated App Connector on your BC VM? (yes/no)"
    read is_appc
    validate_boolean "$is_appc"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Invalid input! Please enter 'yes' or 'no'."
    fi
done


echo "Enter your cc_url:"
read cc_url

# Validating IP address input for mgmt_ip
while true; do
    echo "Enter your Management IP address:"
    read mgmt_ip
    validate_ip "$mgmt_ip"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Invalid IP address format! Please enter a valid IP address."
    fi
done

# Validating IP address input for mgmt_subnet
while true; do
    echo "Enter your Management Subnet Mask:"
    read mgmt_subnet
    validate_subnet_mask "$mgmt_subnet"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Invalid IP address format! Please enter a valid IP address."
    fi
done

# Validating IP address input for mgmt_gateway
while true; do
    echo "Enter your Management Gateway:"
    read mgmt_gateway
    validate_ip "$mgmt_gateway"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Invalid IP address format! Please enter a valid IP address."
    fi
done

# Validating IP address input for dns_1
while true; do
    echo "Enter your Primary DNS server:"
    read dns_1
    validate_ip "$dns_1"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Invalid IP address format! Please enter a valid IP address."
    fi
done

# Validating IP address input for dns_2
while true; do
    echo "Enter your Secondary DNS server:"
    read dns_2
    validate_ip "$dns_2"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Invalid IP address format! Please enter a valid IP address."
    fi
done

echo "Enter your DNS Search Suffix:"
read dns_search

# If is_appc is true, ask for provisioning_key
if [[ "$is_appc" =~ ^(yes|true)$ ]]; then
    echo "Enter your provisioning key:"
    read provisioning_key
    
# Validating IP address input for mgmt_ip
while true; do
    echo "Enter your App Connector IP Address:"
    read appc_ip
    validate_ip "$appc_ip"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Invalid IP address format! Please enter a valid IP address."
    fi
done

# Validating IP address input for mgmt_subnet
while true; do
    echo "Enter your App Connector subnet mask:"
    read appc_subnet
    validate_subnet_mask "$appc_subnet"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Invalid IP address format! Please enter a valid IP address."
    fi
done

# Validating IP address input for mgmt_gateway
while true; do
    echo "Enter your App Connector Default Gateway:"
    read appc_gateway
    validate_ip "$appc_gateway"
    if [ $? -eq 0 ]; then
        break
    else
        echo "Invalid IP address format! Please enter a valid IP address."
    fi
done

else
    break
fi

# Outputting to YAML file
output_yaml="./user-data"
output_iso="$outputdir/userdata_${next_vmid}.iso"

if [[ "$is_appc" =~ ^(yes|true)$ ]]; then
    cat > "$output_yaml" <<EOF #cloud-config
ZSCALER:
  cc_url:" $cc_url"
DEV:
  api_key: "$api_key"
  username: "$username"
  password: "$password"
management_interface:
  name: "vtnet0"
  ip: "$mgmt_ip"
  netmask: "$mgmt_subnet"
  gateway: "$mgmt_gateway"
control_interface:
  name: "vtnet1"
  ip: "$appc_ip"
  netmask: "$appc_subnet"
  gateway: "$appc_gateway"
resolv_conf:
  nameservers: ["$dns_1", "$dns_2"]
  domain: "$dns_search"
zscaler_app_connector:
  enable: "yes"
  provisioning_key: "$provisioning_key"
EOF

else
    cat > "$output_yaml" <<EOF #cloud-config
ZSCALER:
  cc_url: "$cc_url"
DEV:
  api_key: "$api_key"
  username: "$username"
  password: "$password"
management_interface:
  name: "vtnet0"
  ip: "$mgmt_ip"
  netmask: "$mgmt_subnet"
  gateway: "$mgmt_gateway"
resolv_conf:
  nameservers: ["$dns_1", "$dns_2"]
  domain: "$dns_search"
EOF
fi

echo "YAML file created:" $output_yaml

#create the ISO file
genisoimage -o $output_iso -r $output_yaml
echo "ISO built - $output_iso"

#remove the user-data yaml file
rm $output_yaml

#attach the ISO to the VM
qm set $next_vmid -cdrom $output_iso
echo "ISO attached to CDROM"

#start the VM
qm start $next_vmid
echo "VM $next_vmid started"
