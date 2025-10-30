#!/bin/bash

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch master https://github.com/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout df950f4cfddd6696fe72f51d4260152f08bd643f; cd -;		#prereq: use staging_dir's compiler

git clone https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git checkout 3cb1207fb1473880fe6ab9ea85dd50e8781c14ce; cd -;	#[kernel-6.12][common][Enable spidev config]

#\cp -r my_files/feed_revision mtk-openwrt-feeds/autobuild/unified/

#\cp -r my_files/w-rules mtk-openwrt-feeds/autobuild/unified/filogic/rules
#\cp -r my_files/w-unified_rules mtk-openwrt-feeds/autobuild/unified/rules

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic log_file=make

exit 0

\cp -r configs/config.mm.dbg openwrt/.config		#Modemmanager+other extension
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

\cp -r ../configs/config.telit.ext .config

scripts/feeds uninstall crypto-eip pce tops-tool

make menuconfig
make -j $(nproc) V=s
