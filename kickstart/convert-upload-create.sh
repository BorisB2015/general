# Hardcoded to begin with
# TODO: convert to a runnable script


infile=rhel72
outfile=rhel72
  
qemu-img convert \
	-f  raw \
	-O vpc -o subformat=fixed  \
${infile}.raw ${outfile}.vhd

azure vm image create RHEL72 --blob-url docker113/img/rhel72 --os Linux ./rhel72.vhd
	
azure vm create -z Standard_D1_v2 --location "South Central US" --ssh 22 test-vm-rh1001 RHEL72 azureuser

