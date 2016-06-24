#!/bin/bash

# Check hardcoded values in case of errors
# Ensure you are using full (not boot) ISO
# Check credentials in KS file

virt-install \
  --name rhel72ks \
  --memory 3072 \
  --disk path=/mnt/resource/images/rhel72ks.raw,format=raw,size=10 \
  --location  /var/lib/libvirt/images/rhel72.iso \
  --nographics \
  --network network=default \
  --initrd-inject=/mnt/resource/images/rhel72.ks \
  --extra-args="ks=file:/rhel72.ks no_timer_check console=tty0 console=ttyS0,115200n8" \
  --os-type=linux \
  --os-variant=rhel7