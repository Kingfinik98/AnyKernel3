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

    # ==========================================
    # [VORTEX ESPORT NATIVE INJECTION]
    # ==========================================
    ui_print " " "Injecting VorteX Esport Tweaks..."

    mkdir -p $RAMDISK/sbin
    cp -af $TMPDIR/vortex.sh $RAMDISK/sbin/
    chmod 755 $RAMDISK/sbin/vortex.sh

    patch_cmdline "init.rc" "
service vortex /sbin/vortex.sh
    class late_start
    user root
    oneshot
"

    patch_cmdline "init.rc" "
on property:sys.boot_completed=1
    start vortex
"
    # ==========================================

    write_boot
else
    flash_boot
fi

# ==========================================
# [ADRENO 830 SPOOF - GKI 5.10 ONLY]
# ==========================================
if [ "$kernel_version" == "5.10" ]; then
  ui_print " " "🎮 Applying Adreno 830 Spoof..."
  mount_vendor
  if [ -f "$TMPDIR/libgsl.so" ]; then
    mkdir -p $VEN/lib64
    cp -af "$TMPDIR/libgsl.so" "$VEN/lib64/libgsl.so"
    chmod 644 "$VEN/lib64/libgsl.so"
    chcon u:object_r:vendor_file:s0 "$VEN/lib64/libgsl.so" 2>/dev/null || true
    ui_print " " "✅ Adreno 830 spoof (libgsl.so) applied."
  else
    ui_print " " "⚠️ libgsl.so not found in zip, skipping."
  fi
  unmount_vendor
fi
# ==========================================

## end boot install
