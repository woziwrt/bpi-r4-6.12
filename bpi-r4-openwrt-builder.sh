#!/bin/bash

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch master https://github.com/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout e112fd8e59e37ae323fdaebb74bdd6084176d8e4; cd -;		#mt76: scripts/feeds: implement support for --root option

git clone https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git checkout 718ab32d40c2e82fadc882c035e665a79a14c082; cd -;	#[openwrt-master][MAC80211][wed][Fix wed patch fail]

echo "718ab3" > mtk-openwrt-feeds/autobuild/unified/feed_revision

#\cp -r my_files/w-rules mtk-openwrt-feeds/autobuild/unified/filogic/rules
\cp -r my_files/w-unified_rules mtk-openwrt-feeds/autobuild/unified/rules

\cp -r my_files/w-remove_list.txt mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/master/remove_list.txt 
#\cp -r configs/basic.defconfig mtk-openwrt-feeds/autobuild/unified/filogic/master/defconfig

\cp -r my_files/wozi_files/. mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/master/files/

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt7988_rfb-mt7996 prepare log_file=prepare

bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt7988_rfb-mt7996 build log_file=build

bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt7988_rfb-mt7996 release log_file=release

exit 0

\cp -r configs/config.mm.dbg openwrt/.config

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

\cp -r configs/config.telit.ext .config

make menuconfig
make -i -j1 V=sc | tee finalmake.txt
