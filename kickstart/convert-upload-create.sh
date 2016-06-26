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

# Create a container

azure storage container create img -c "DefaultEndpointsProtocol=https;AccountName=testborisb2;AccountKey==="

# Create VM Image

azure vm image create RHEL72lab1 --blob-url $storageaccountname/img/rhel72lab1 --os Linux /var/lib/libvirt/images/rhel72.vhd

# Create VM from that image

azure vm create -z Standard_D1_v2 --location "South Central US" --ssh 22 test-$storageaccountname-rh1001 RHEL72lab1 azureuser

# Check its status

azure vm list

# Delete the VM

azure vm delete test-$storageaccountname-rh1001 -b

