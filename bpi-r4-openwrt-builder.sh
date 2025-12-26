#!/bin/bash

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch openwrt-25.12 https://github.com/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout 02f9e71dd2261d178f74ac93bff9d6eba216096c; cd -;		#OpenWrt v25.12.0-rc1: revert to branch defaults

git clone --branch master https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git checkout f221bd58827d0d56cf1c0c29a79cf338486f910b; cd -;	#[openwrt-25.12][common][bootloader][Rebase and update ATF&U-boot to MTK Q4 release]

#\cp -r my_files/w-defconfig mtk-openwrt-feeds/autobuild/unified/filogic/master/defconfig
\cp -r my_files/w-rules mtk-openwrt-feeds/autobuild/unified/filogic/rules

\cp -r my_files/999-wozi-add-rtl8261be-support.patch openwrt/target/linux/mediatek/patches-6.12/

### tx_power patch - required for BE14 boards with defective eeprom flash
mkdir -p openwrt/package/kernel/mt76/patches && cp -r my_files/99999_tx_power_check.patch $_

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic log_file=make

\cp -r configs/config.rc3.mm openwrt/.config
cd openwrt
make menuconfig
make -j$(nproc) V=s

exit 0


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

\cp -r ../configs/config.telit .config

#scripts/feeds uninstall crypto-eip pce tops-tool

make menuconfig
make -j24 V=sc
