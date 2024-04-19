#!/bin/bash
# written using proxmox 7.3.3
# Variable file containing additional data
source ./bc-vm-variables.txt


##########
#Start of Functions#

# Function to validate hypervisor input
validate_hypervisor() {
    local hypervisor_type="$1"
    if [[ "$hypervisor_type" =~ ^[1-3]$ ]]; then
        return 0  # Valid input
    else
        return 1  # Invalid input
    fi
}

# Function to set int_name based on hypervisor type
set_int_name() {
    local hypervisor_type="$1"
    if [ "$hypervisor_type" = "1" ]; then
        int_name0="vmx0"
        int_name1="vmx1"
    elif [ "$hypervisor_type" = "2" ]; then
        int_name0="vtnet0"
        int_name1="vtnet1"
    elif [ "$hypervisor_type" = "3" ]; then
        int_name0="hn0"
        int_name1="hn1"
    fi
}

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


#End of Function Definitions#
##########

##########
# Get the hypervisor type from user and set the interface name accordingly
while true; do
    echo "What Hypervisor are you going to use for this ISO?"
    echo "Enter 1 for VMWare"
    echo "Enter 2 for KVM"
    echo "Enter 3 for Microsoft HyperV"
    read -p "Enter your choice: " hypervisor_type
    validate_hypervisor "$hypervisor_type"
    if [ $? -eq 0 ]; then
        set_int_name "$hypervisor_type"
        break
    else
        echo "Invalid input! Please enter a number between 1 and 3."
    fi
done

echo "You chose hypervisor type: $hypervisor_type"

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


# setting output directories and iso name
template_name=$(echo "${cc_url}" | awk -F'\\?name=' '{print $2}')
echo "Template name: ${template_name}"

output_yaml="./user-data"
output_iso="./userdata_${template_name}.iso"

# Outputting to YAML file

if [[ "$is_appc" =~ ^(yes|true)$ ]]; then
    cat > "$output_yaml" <<EOF #cloud-config
ZSCALER:
  cc_url: "$cc_url"
DEV:
  api_key: "$api_key"
  username: "$username"
  password: "$password"
management_interface:
  name: "$int_name0"
  ip: "$mgmt_ip"
  netmask: "$mgmt_subnet"
  gateway: "$mgmt_gateway"
control_interface:
  name: "$int_name1"
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
  name: "$int_name0"
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
