# Hardcoded to begin with
# TODO: convert to a runnable script


infile=rhel72
outfile=rhel72

# Resize Raw if needed - should be aligned to 1 MB boundary in size

MB=$((1024*1024))
size=$(qemu-img info -f raw --output json ${infile}.raw | \
          gawk 'match($0, /"virtual-size": ([0-9]+),/, val) {print val[1]}')
rounded_size=$((($size/$MB + 1)*$MB))
 
echo $size
echo $rounded_size
qemu-img resize ${infile}.raw $rounded_size

# Convert to VHD	
  
qemu-img convert \
	-f  raw \
	-O vpc -o subformat=fixed  \
${infile}.raw ${outfile}.vhd


# Upload image and provision a VM

# Login
azure login
# follow up in UI with code
azure account list

# Set to your AzurePass if you have more than one subscription
azure account set <GUID>

# Verify
azure account list

# Set ASM mode explicitly, check docs for explanation
azure config mode asm

# Check storage accounts
azure storage account list

# Create one in South Central US - this is where the lab is
# azure storage account create testborisb2 --location "South Central US" --type LRS

# Must be globally unique, 63 chars low case, letters and digits only
storageaccountname=testborisb2

azure storage account create $storageaccountname --location "South Central US" --type LRS 

# Check storage accounts
azure storage account list

# Get storage account connection string

azure storage account connectionstring show $storageaccountname

# conn=`azure storage account connectionstring show $storageaccountname --json \
#	| awk  -F '"' '/(DefaultEndpointsProtocol.*==)/ {print $4}'`

# For ARM need a RG also, e.g.
#conn=`azure storage account connectionstring show foobarblah1 --resource-group test-dse-rg --json \
#    | awk  -F '"' '/(DefaultEndpointsProtocol.*==)/ {print $4}'`

# Create a container

azure storage container create img -c "DefaultEndpointsProtocol=https;AccountName=testborisb2;AccountKey==="

# Create VM Image

azure vm image create RHEL72lab1 --blob-url $storageaccountname/img/rhel72lab1.vhd --os Linux /var/lib/libvirt/images/rhel72.vhd

# Create VM Image - Gluster

azure vm image create RHEL72gs1 --blob-url $storageaccountname/img/rhel72gs1.vhd --os Linux /var/lib/libvirt/images/rhel72gs.vhd

# Create VM from that image

azure vm create -z Standard_D1_v2 --location "South Central US" --ssh 22 test-$storageaccountname-rh1001 RHEL72lab1 azureuser

# Create VM from the Gluster image

azure vm create -z Standard_D1_v2 --location "South Central US" --ssh 22 test-$storageaccountname-rh1001 RHEL72gs1 azureuser

# Check its status

azure vm list

# Delete the VM

azure vm delete test-$storageaccountname-rh1001 -b


### Azure Resource Manager ###

azure config mode arm

# Task: Upload image to ARM storage account

# Create Resource Group
azure group create Gluster-RG SouthCentralUS

# Create Storage Account 
azure storage account create --sku-name LRS --location SouthCentralUS --kind Storage borisbrhgs --resource-group Gluster-RG

# Get its connection string
azure storage account connectionstring show borisbrhgs -g Gluster-RG


