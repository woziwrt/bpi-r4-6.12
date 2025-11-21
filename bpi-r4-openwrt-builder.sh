#!/bin/bash

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch master https://github.com/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout b29cf08a1eb6af799b2bdaf5cf655532b238d2eb; cd -;		#openssl: add MODULES_DIR MACRO for provider

git clone https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git checkout b65226d58ec5dc743de69c481745ef03188c4885; cd -;	#[openwrt-master][common][u-boot][Add mt7981 and mt7986 U-boot support]

#\cp -r my_files/feed_revision mtk-openwrt-feeds/autobuild/unified/
\cp -r my_files/w-1132-image-mediatek-filogic-add-bananapi-bpi-r4-lite-support.patch mtk-openwrt-feeds/master/patches-base/1132-image-mediatek-filogic-add-bananapi-bpi-r4-lite-support.patch
#\cp -r my_files/w-1133-image-mediatek-filogic-add-bananapi-bpi-r4-pro-support-sdcard.patch mtk-openwrt-feeds/master/patches-base/1133-image-mediatek-filogic-add-bananapi-bpi-r4-pro-support-sdcard.patch
\cp -r my_files/w-3410-boot-uboot-mediatek-bpi-r4-pro.patch mtk-openwrt-feeds/master/patches-base/3410-boot-uboot-mediatek-bpi-r4-pro.patch

\cp -r my_files/w-defconfig mtk-openwrt-feeds/autobuild/unified/filogic/master/defconfig
\cp -r my_files/w-rules mtk-openwrt-feeds/autobuild/unified/filogic/rules

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic log_file=make

exit 0

\cp -r configs/config.mm openwrt/.config
make menuconfig
make -j $(nproc) V=s


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
make -j $(nproc) V=s
