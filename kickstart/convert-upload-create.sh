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

azure vm image create RHEL72 --blob-url docker113/img/rhel72 --os Linux ./rhel72.vhd
	
azure vm create -z Standard_D1_v2 --location "South Central US" --ssh 22 test-vm-rh1001 RHEL72 azureuser

