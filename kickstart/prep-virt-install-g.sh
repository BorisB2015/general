#!/bin/bash

# Check hardcoded values in case of errors
# Ensure you are using full (not boot) ISO
# Check credentials in KS file

# no_timer_check, noreboot required for workaround of https://bugzilla.redhat.com/show_bug.cgi?id=502058

virt-install \
  --name rhel72gs \
  --memory 3072 \
  --disk path=/mnt/resource/images/rhel72gs.raw,format=raw,size=10 \
  --location  /var/lib/libvirt/images/rhgs31u2.iso \
  --nographics \
  --network network=default \
  --initrd-inject=/mnt/resource/images/rhel72gs.ks \
  --extra-args="ks=file:/rhel72gs.ks no_timer_check console=tty0 console=ttyS0,115200n8" \
  --os-type=linux \
  --os-variant=rhel7 \
  --noreboot
