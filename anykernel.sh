### AnyKernel install

# boot shell variables
BLOCK=boot;
IS_SLOT_DEVICE=auto;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;
NO_BLOCK_DISPLAY=1;
NO_MAGISK_CHECK=1;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# variables
supported=false
# Loop to check if the current kernel version is in the supported_kvers list
supported_kvers='5.10 6.1 6.6'

# check current kernel version
kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}' | cut -f1-2 -d'.')

# 
for ver in $supported_kvers; do
  if [ "$kernel_version" == "$ver" ]; then
    supported=true
    break
  fi
done

if ! $supported; then
  abort "- Unsupported kernel version: $kernel_version, abort."
fi

# boot install
split_boot
if [ -f "split_img/ramdisk.cpio" ]; then
    unpack_ramdisk
    write_boot
else
    flash_boot
fi
## end boot install
