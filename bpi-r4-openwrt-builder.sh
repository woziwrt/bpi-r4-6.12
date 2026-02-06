#!/bin/bash

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch openwrt-25.12 https://github.com/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout 9bf33c02d5c4dc9cb50bfaa2c23bb4398a99c49d; cd -;		#kernel: bump 6.12 to 6.12.68

git clone --branch master https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git checkout 8a91c67871bc747187aedc169867378e8564f007; cd -;	#[uboot][common][bsp][upgrade to mtk-openwrt/u-boot 2026-01-23 release]

#\cp -r my_files/feed_revision mtk-openwrt-feeds/autobuild/unified/

#\cp -r my_files/w-defconfig mtk-openwrt-feeds/autobuild/unified/filogic/master/defconfig
\cp -r my_files/w-rules mtk-openwrt-feeds/autobuild/unified/filogic/rules

\cp -r my_files/w-defconfig mtk-openwrt-feeds/autobuild/unified/filogic/25.12/defconfig
\cp -r my_files/w-rules mtk-openwrt-feeds/autobuild/unified/filogic/rules
\cp -r my_files/w-Makefile openwrt/package/libs/musl-fts/Makefile

### tx_power patch - required for BE14 boards with defective eeprom flash
\cp -r my_files/99999_tx_power_check.patch openwrt/package/kernel/mt76/patches

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt798x_rfb-wifi7_nic log_file=make

exit 0

cd openwrt
\cp -r ../my_files/w-filogic.mk target/linux/mediatek/image/filogic.mk
#\cp -r ../configs/mtk_test.nocrypto.config openwrt/.config
#\cp -r ../configs/mtk_test.crypto.config openwrt/.config
#make menuconfig
#make -j$(nproc) V=s

#exit 0


#============================ extension for Telit FN990 family

#cd openwrt
\cp -r ../my_files/sms-tool/ feeds/packages/utils/sms-tool
\cp -r ../my_files/modemdata-main/ feeds/packages/utils/modemdata 
\cp -r ../my_files/luci-app-modemdata-main/luci-app-modemdata/ feeds/luci/applications
\cp -r ../my_files/luci-app-lite-watchdog/ feeds/luci/applications
\cp -r ../my_files/luci-app-sms-tool-js-main/luci-app-sms-tool-js/ feeds/luci/applications

./scripts/feeds update -a
./scripts/feeds install -a

\cp -r ../my_files/qmi.sh package/network/utils/uqmi/files/lib/netifd/proto/
chmod -R 755 package/network/utils/uqmi/files/lib/netifd/proto
chmod -R 755 feeds/luci/applications/luci-app-modemdata/root
chmod -R 755 feeds/luci/applications/luci-app-sms-tool-js/root
chmod -R 755 feeds/packages/utils/modemdata/files/usr/share

\cp -r ../configs/config.02022026 .config

#scripts/feeds uninstall crypto-eip pce tops-tool

make menuconfig
make -j24 V=sc
