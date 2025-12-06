#!/bin/bash

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch master https://github.com/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout 8ad5f35a9013ca7c65e86e7aef92617903afeab0; cd -;		#autoconf-archive: backport patch for C++23 support

git clone --branch master https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git checkout eb48282ba6a7ddc100e7a17e3c7eedbd1d782a10; cd -;	#[openwrt-master][common][optee][Refactor OP-TEE early ta]

\cp -r my_files/w-defconfig mtk-openwrt-feeds/autobuild/unified/filogic/master/defconfig
\cp -r my_files/w-rules mtk-openwrt-feeds/autobuild/unified/filogic/rules
#\cp -r my_files/w-unified_rules mtk-openwrt-feeds/autobuild/unified/rules

\cp -r my_files/999-wozi-add-rtl8261be-support.patch openwrt/target/linux/mediatek/patches-6.12/

### tx_power patch - required for BE14 boards with defective eeprom flash
mkdir -p openwrt/package/kernel/mt76/patches && cp -r my_files/99999_tx_power_check.patch $_

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic log_file=make

exit 0

\cp -r configs/config.mm.relatek openwrt/.config

make menuconfig
make -j24 V=sc


============================ extension for Telit FN990 family

cd openwrt
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
