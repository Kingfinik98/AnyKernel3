### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers
## iambouttacum @ gacorprjkt

### AnyKernel setup
# global properties
properties() { '
kernel.string=
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=1
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties


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
supported_kver='5.10'

# check current kernel version
kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}' | cut -f1-2 -d'.')
[ "$kernel_version" == "$supported_kver" ] && supported=true

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
