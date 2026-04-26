#!/bin/bash
set -euo pipefail

OPENWRT_BRANCH="openwrt-25.12"
OPENWRT_COMMIT="00dcdd7451487dfb63c6c3bbd649a547c76e1a13"
OPENWRT_URL="https://github.com/openwrt/openwrt.git"

MTK_FEEDS_BRANCH="master"
MTK_FEEDS_COMMIT="95d10b2875cde36924023380ac098dd5664dcdf3"
MTK_FEEDS_URL="https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds"

USE_CACHE=false
VANILLA=false

# --- Patch flags (default: all enabled) ---
PATCH_SFP=true
PATCH_TX_POWER=true
PATCH_NVME=true
PATCH_REGDB=false        # off by default

# --- Usage ---

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --cache               Cache repos in ~/.cache, pull updates on subsequent runs, then copy to working dir

Patch selection:
  --vanilla             No patches and no custom files copied from my_files
  --all-patches         Apply all patches (including regdb)
  --patch-sfp           Apply SFP quirks patch          (999-sfp-10-additional-quirks.patch)
  --patch-tx-power      Apply TX power patch             (100-wifi-mt76-mt7996-Use-tx_power-from-default-fw-if-EEP.patch)
  --patch-nvme          Apply NVMe/BPI-R4 patches        (u-boot + DTS patches)
  --patch-regdb         Apply regdb wireless restrictions removal
  --no-patch-sfp        Skip SFP quirks patch
  --no-patch-tx-power   Skip TX power patch
  --no-patch-nvme       Skip NVMe/BPI-R4 patches

  -h, --help            Show this help message

Default behaviour (no patch flags): --patch-sfp --patch-tx-power --patch-nvme (regdb off)
EOF
    exit 1
}

# --- Argument parsing ---

for arg in "$@"; do
    case "$arg" in
        --cache)
            USE_CACHE=true
            ;;
        --vanilla)
            VANILLA=true
            PATCH_SFP=false
            PATCH_TX_POWER=false
            PATCH_NVME=false
            PATCH_REGDB=false
            ;;
        --all-patches)
            PATCH_SFP=true
            PATCH_TX_POWER=true
            PATCH_NVME=true
            PATCH_REGDB=true
            ;;
        --patch-sfp)        PATCH_SFP=true ;;
        --patch-tx-power)   PATCH_TX_POWER=true ;;
        --patch-nvme)       PATCH_NVME=true ;;
        --patch-regdb)      PATCH_REGDB=true ;;
        --no-patch-sfp)     PATCH_SFP=false ;;
        --no-patch-tx-power) PATCH_TX_POWER=false ;;
        --no-patch-nvme)    PATCH_NVME=false ;;
        -h|--help)          usage ;;
        *)
            echo "Unknown argument: $arg"
            usage
            ;;
    esac
done

echo "==> Build configuration:"
echo "    vanilla            : ${VANILLA}"
echo "    sfp quirks         : ${PATCH_SFP}"
echo "    tx power           : ${PATCH_TX_POWER}"
echo "    nvme/bpi-r4        : ${PATCH_NVME}"
echo "    regdb              : ${PATCH_REGDB}"

# --- Helper: clone or pull a repo in cache ---

cache_sync() {
    local url="$1"
    local branch="$2"
    local commit="$3"
    local dest="$4"

    if [ ! -d "${dest}/.git" ]; then
        echo "==> [CACHE] Cloning ${url} ..."
        git clone --branch "${branch}" "${url}" "${dest}"
    else
        echo "==> [CACHE] Pulling latest changes in ${dest} ..."
        cd "${dest}"
        git fetch origin
        git checkout "${branch}"
        git pull origin "${branch}"
        cd -
    fi

    echo "==> [CACHE] Checking out commit ${commit} ..."
    cd "${dest}"; git checkout "${commit}"; cd -
}

# --- Fetch repositories ---

if [ "${USE_CACHE}" = true ]; then
    CACHE_DIR="${HOME}/.cache/bpi-r4-openwrt-builder"
    OPENWRT_CACHE="${CACHE_DIR}/openwrt"
    MTK_FEEDS_CACHE="${CACHE_DIR}/mtk-openwrt-feeds"

    echo "==> Cache mode enabled. Cache directory: ${CACHE_DIR}"
    mkdir -p "${CACHE_DIR}"

    cache_sync "${OPENWRT_URL}"   "${OPENWRT_BRANCH}"   "${OPENWRT_COMMIT}"   "${OPENWRT_CACHE}"
    cache_sync "${MTK_FEEDS_URL}" "${MTK_FEEDS_BRANCH}" "${MTK_FEEDS_COMMIT}" "${MTK_FEEDS_CACHE}"

    echo "==> Copying repositories from cache to working directory..."
    rm -rf openwrt
    cp -r "${OPENWRT_CACHE}" openwrt

    rm -rf mtk-openwrt-feeds
    cp -r "${MTK_FEEDS_CACHE}" mtk-openwrt-feeds
else
    rm -rf openwrt
    rm -rf mtk-openwrt-feeds
    git clone --branch "${OPENWRT_BRANCH}" "${OPENWRT_URL}" openwrt
    cd openwrt; git checkout "${OPENWRT_COMMIT}"; cd -;     #firmware: Add support for Airoha EN7581/AN7583 NPU variant firmware
    git clone --branch "${MTK_FEEDS_BRANCH}" "${MTK_FEEDS_URL}" mtk-openwrt-feeds
    cd mtk-openwrt-feeds; git checkout "${MTK_FEEDS_COMMIT}"; cd -;    #[openwrt-25][common][doc][Update documentation for OpenWrt 25.12]
fi

# --- Patches and modifications ---

if [ "${PATCH_SFP}" = true ]; then
    echo "==> Applying SFP quirks patch..."
    \cp -r my_files/999-sfp-10-additional-quirks.patch mtk-openwrt-feeds/25.12/files/target/linux/mediatek/patches-6.12
fi

if [ "${PATCH_TX_POWER}" = true ]; then
    echo "==> Applying TX power patch..."
    \cp -r my_files/100-wifi-mt76-mt7996-Use-tx_power-from-default-fw-if-EEP.patch mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/25.12/files/package/kernel/mt76/patches
fi

if [ "${PATCH_REGDB}" = true ]; then
    echo "==> Applying regdb wireless restrictions removal..."
    rm -rf openwrt/package/firmware/wireless-regdb/patches/*.*
    rm -rf mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/25.12/files/package/firmware/wireless-regdb/patches/*.*
    \cp -r my_files/500-tx_power.patch mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/25.12/files/package/firmware/wireless-regdb/patches
    \cp -r my_files/regdb.Makefile openwrt/package/firmware/wireless-regdb/Makefile
fi

# --- Build ---

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt798x_rfb-wifi7_nic prepare

if [ "${PATCH_NVME}" = true ]; then
    echo "==> Applying NVMe/BPI-R4 patches..."
    \cp -r ../my_files/453-w-add-bpi-r4-nvme-dtso.patch target/linux/mediatek/patches-6.12/
    \cp -r ../my_files/450-w-nand-mmc-add-bpi-r4.patch package/boot/uboot-mediatek/patches/450-add-bpi-r4.patch
    \cp -r ../my_files/451-w-add-bpi-r4-nvme.patch package/boot/uboot-mediatek/patches/451-add-bpi-r4-nvme.patch
    \cp ../my_files/452-w-add-bpi-r4-nvme-rfb.patch package/boot/uboot-mediatek/patches/452-add-bpi-r4-nvme-rfb.patch
    \cp ../my_files/454-w-add-bpi-r4-nvme-env.patch package/boot/uboot-mediatek/patches/454-add-bpi-r4-nvme-env.patch
    \cp -r ../my_files/w-nand-mmc-filogic.mk target/linux/mediatek/image/filogic.mk
    echo "CONFIG_BLK_DEV_NVME=y" >> target/linux/mediatek/filogic/config-6.12
fi

if [ "${VANILLA}" = false ]; then
    echo "==> Copying custom packages and files from my_files..."
    \cp -r ../my_files/sms-tool/ feeds/packages/utils/sms-tool
    \cp -r ../my_files/modemdata-main/ feeds/packages/utils/modemdata
    \cp -r ../my_files/luci-app-modemdata-main/luci-app-modemdata/ feeds/luci/applications
    \cp -r ../my_files/luci-app-lite-watchdog/ feeds/luci/applications
    \cp -r ../my_files/luci-app-sms-tool-js-main/luci-app-sms-tool-js/ feeds/luci/applications
fi

./scripts/feeds update -a
./scripts/feeds install -a

if [ "${VANILLA}" = false ]; then
    \cp -r ../my_files/qmi.sh package/network/utils/uqmi/files/lib/netifd/proto/
    chmod -R 755 package/network/utils/uqmi/files/lib/netifd/proto
    chmod -R 755 feeds/luci/applications/luci-app-modemdata/root
    chmod -R 755 feeds/luci/applications/luci-app-sms-tool-js/root
    chmod -R 755 feeds/packages/utils/modemdata/files/usr/share
    \cp -r ../configs/my_final_defconfig .config
fi

make defconfig
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt798x_rfb-wifi7_nic build
