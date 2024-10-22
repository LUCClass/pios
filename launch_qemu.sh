#!/bin/bash

# This function kills qemu when we're finished debugging
cleanup() {
  killall qemu-system-aarch64
}

trap cleanup EXIT


screen -S qemu -d -m qemu-system-aarch64 -machine raspi3b -kernel kernel8.img -hda rootfs.img -S -s -serial null -serial stdio -monitor none -nographic -k en-us 


TERM=xterm gdb -x gdb_init_prot_mode.txt 



