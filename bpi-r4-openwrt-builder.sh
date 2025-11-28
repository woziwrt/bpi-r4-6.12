#!/bin/bash

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch master https://github.com/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout db51030324917eaee0d2749aeee1d5ae7b675d34; cd -;		#airoha: reorder I2C and UART patches

git clone https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git checkout 82b9d2bff0e72439178a1cb8b4fa09e31a66eac2; cd -;	#[kernel][common][eth][Fix issues detected by Coverity scan]

\cp -r my_files/w-defconfig.realtek mtk-openwrt-feeds/autobuild/unified/filogic/master/defconfig

rm -rf mtk-openwrt-feeds/master/patches-base/1132-image-mediatek-filogic-add-bananapi-bpi-r4-lite-support.patch
rm -rf mtk-openwrt-feeds/master/patches-base/1142-image-mediatek-filogic-mt7987a-rfb-03-add-spidev-overlays.patch
#\cp -r my_files/0001-w-scripts-feeds-support-subdir.patch  mtk-openwrt-feeds/autobuild/unified/scripts/master/patches/0001-scripts-feeds-support-subdir.patch
rm -rf mtk-openwrt-feeds/autobuild/unified/scripts/master/patches/0001-scripts-feeds-support-subdir.patch
rm -rf mtk-openwrt-feeds/master/files/target/linux/mediatek/patches-6.12/999-clk-01-clk-mediatek-fix-mt7987-infracfg-clk-driver.patch

##### phy-realtek: add rtl8251l, rtl8254b, rtl8261be, rtl8261n, rtl8264 and rtl8264b ##################
mkdir -p openwrt/package/firmware/realtek-phy-firmware  && cp -r my_files/realtek/realtek-phy-firmware/. $_
\cp -r my_files/realtek/netdevices.mk openwrt/package/kernel/linux/modules/netdevices.mk
\cp -r my_files/realtek/config-6.12 openwrt/target/linux/mediatek/config-6.12
mkdir -p openwrt/target/linux/mediatek/files/drivers/net/phy/realtek && cp -r my_files/realtek/phy_patch.c $_
\cp -r my_files/realtek/phy_patch.h openwrt/target/linux/mediatek/files/drivers/net/phy/realtek/phy_patch.h
\cp -r my_files/realtek/phy_patch_rtl826x.c openwrt/target/linux/mediatek/files/drivers/net/phy/realtek/phy_patch_rtl826x.c
\cp -r my_files/realtek/phy_patch_rtl826x.h openwrt/target/linux/mediatek/files/drivers/net/phy/realtek/phy_patch_rtl826x.h
\cp -r my_files/realtek/735-net-phy-realtek-cleanup-phyids.patch openwrt/target/linux/generic/hack-6.12/735-net-phy-realtek-cleanup-phyids.patch
\cp -r my_files/realtek/736-net-phy-realtek-add-rtl8251l-rtl8254b-rtl8261be-rtl8261n.patch openwrt/target/linux/generic/hack-6.12/736-net-phy-realtek-add-rtl8251l-rtl8254b-rtl8261be-rtl8261n.patch
\cp -r my_files/realtek/filogic_config-6.12 openwrt/target/linux/mediatek/filogic/config-6.12
\cp -r my_files/realtek/9999-w-realtek-filogic-image.patch mtk-openwrt-feeds/master/patches-base/9999-realtek-filogic-image.patch
\cp -r my_files/realtek/500-gsw-rtl8367s-mt7622-support.patch openwrt/target/linux/mediatek/patches-6.12/500-gsw-rtl8367s-mt7622-support.patch
rm -f openwrt/target/linux/generic/files/drivers/net/phy/rtl8261n/*
rm -f openwrt/target/linux/generic/hack-6.12/735-net-phy-realtek-rtl8261n.patch

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic log_file=make

exit 0



