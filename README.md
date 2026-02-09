# OpenWrt build for Banana Pi BPI-R4 (kernel 6.12)

This repository contains a script and a GitHub Actions workflow to build OpenWrt 25.12 for Banana Pi BPI‑R4 (MT7988, Wi‑Fi 7) using the MediaTek SDK.

Goal: you do not need a local build machine. You can trigger the build on GitHub and download ready-to-use images. Advanced users can tweak the config if they want.

---

## 1. Just want a ready-made image?

If you only want a prebuilt firmware for BPI‑R4:

1. Open the “Actions” tab in this repository.
2. Select the workflow “Build OpenWrt (BPI-R4, kernel 6.12)”.
3. Click “Run workflow” and confirm.

After the workflow finishes:

1. Open the “Releases” tab.
2. Download the latest release (tag bpi-r4-latest).

Important files in the release:

- ``openwrt-mediatek-filogic-bananapi_bpi-r4-squashfs-sysupgrade.itb`` – sysupgrade from an existing OpenWrt.
- ``openwrt-mediatek-filogic-bananapi_bpi-r4-sdcard.img.gz`` – SD card image.
- ``sha256sums`` – checksums for verification.

You do not need to change anything in the repository for this use case.

---

## 2. Add/remove a few packages (GitHub only)

You can slightly customize the firmware by editing the final config file directly on GitHub.
The build still runs on GitHub’s servers, not on your machine.

Step 1 – Open the config file

1. In this repository, open the directory “my_files”.
2. Click on the file “my_final_defconfig”.

Step 2 – Edit the config on GitHub

1. Click the pencil icon (“Edit this file”).
2. In the file you will see lines like:
  
   ``CONFIG_PACKAGE_iperf3=y``  
   ``CONFIG_PACKAGE_htop is not set``
  
   Meaning:
   
   - ``CONFIG_PACKAGE_xyz=y`` → package enabled.
   - ``CONFIG_PACKAGE_xyz is not set`` → package disabled.

4. To enable a package, change:

   ``CONFIG_PACKAGE_htop is not set``

   to:

   ``CONFIG_PACKAGE_htop=y``

5. To disable a package, change:

   ``CONFIG_PACKAGE_iperf3=y``

   to:

   ``CONFIG_PACKAGE_iperf3 is not set``

6. Important: only change lines starting with “CONFIG_PACKAGE_”.
   Do not touch kernel / target / MTK SDK options unless you really know what you are doing.

7. At the bottom of the page click “Commit changes” to save the file.

Step 3 – Trigger a new build

1. Go to the “Actions” tab.
2. Run the workflow “Build OpenWrt (BPI-R4, kernel 6.12)” again.
3. After it finishes, download the latest release as in section 1.

About dependencies

The build script copies “my_final_defconfig” to “.config” and then runs:

   ``make defconfig``

The OpenWrt build system automatically fills in missing options and dependencies.
If you only toggle a few CONFIG_PACKAGE_… options, the build should stay consistent.

---

## 3. Local build (optional, advanced)

If you prefer to build locally on Linux:

Requirements (example: Ubuntu 22.04)

- around 120 GB free disk space.
- basic build tools and libraries:
   ```
   sudo apt-get update  
   sudo apt-get install -y \
     build-essential clang flex bison g++ gawk gcc-multilib g++-multilib \
     gettext libncurses-dev libssl-dev python3-distutils python3-setuptools \
     rsync swig unzip zlib1g-dev file wget libelf-dev ccache git
   ```
Clone and build
   ```
   git clone https://github.com/woziwrt/bpi-r4-6.12.git  
   cd bpi-r4-6.12  
   chmod +x ./bpi-r4-openwrt-builder.sh  
   ./bpi-r4-openwrt-builder.sh  
   ```
After the script finishes, images are in:

   ``openwrt/bin/targets/mediatek/filogic/``

---

## 4. Repository contents

- ``bpi-r4-openwrt-builder.sh`` – main build script (clone OpenWrt + MTK, prepare, build, apply config).
- ``my_files/`` – custom config (my_final_defconfig), patches, custom packages and LuCI apps.
- ``.github/workflows/`` – GitHub Actions workflow:
  - frees disk space,
  - runs the build script,
  - cleans build output,
  - uploads artifacts,
  - creates a release with only the relevant BPI‑R4 files,
  - keeps only the latest release.

---

## 5. Notes

- This build is for Banana Pi BPI‑R4 only.
- For simple custom builds, change only CONFIG_PACKAGE_… lines in my_final_defconfig.
- OpenWrt and MTK SDK commits are pinned; updating them requires manual work.
