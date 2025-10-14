#!/bin/bash

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch master https://github.com/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout 5edf6a4c25d6e5fc9046d4e5533b79b07bcb3ef4; cd -;		#ath79: whr-g301n: remove custon wifi LED

git clone https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git 89f9cb071fe99ffdd4d08b70bd22ef03f68481d8; cd -;	#[kernel-6.12][common][spim-nand][Change full ubi version dtso naming]

echo "89f9cb" > mtk-openwrt-feeds/autobuild/unified/feed_revision

#\cp -r my_files/w-rules mtk-openwrt-feeds/autobuild/unified/filogic/rules
\cp -r my_files/w-unified_rules mtk-openwrt-feeds/autobuild/unified/rules

rm -rf openwrt/package/network/utils/iw/patches/*
rm -rf openwrt/package/network/services/hostapd/patches/*
rm -rf openwrt/package/network/services/hostapd/src
rm -rf openwrt/package/kernel/mac80211/patches/*
rm -rf openwrt/package/kernel/mt76/src/*
rm -rf openwrt/package/network/config/wifi-scripts/files

#\cp -r my_files/0001-1-wozi-trace.h-strlcpy-strscpy-replacement.patch mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/kernel/mt76/patches/
\cp -r my_files/0011-wozi-mtk-mt76-add-debug-tools.patch mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/kernel/mt76/patches/0011-mtk-mt76-add-debug-tools.patch

\cp -a mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/network/services/hostapd/patches/. openwrt/package/network/services/hostapd/patches/ 
\cp -r mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/network/services/hostapd/files/. openwrt/package/network/services/hostapd/files/
\cp -a mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/network/utils/iw/patches/. openwrt/package/network/utils/iw/patches/
\cp -a mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/kernel/mac80211/patches/. openwrt/package/kernel/mac80211/patches/
\cp -a mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/kernel/mt76/src/. openwrt/package/kernel/mt76/src/
\cp -a mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/kernel/mt76/patches openwrt/package/kernel/mt76/patches
\cp -a mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/network/config/wifi-scripts/files openwrt/package/network/config/wifi-scripts/files
#\cp -a mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/network/config/netifd/patches openwrt/package/network/config/netifd/patches


### required & thermal zone 
\cp -r my_files/1007-wozi-arch-arm64-dts-mt7988a-add-thermal-zone.patch mtk-openwrt-feeds/24.10/patches-base/

sed -i 's/CONFIG_PACKAGE_perf=y/# CONFIG_PACKAGE_perf is not set/' mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/defconfig
sed -i 's/CONFIG_PACKAGE_perf=y/# CONFIG_PACKAGE_perf is not set/' mtk-openwrt-feeds/autobuild/autobuild_5.4_mac80211_release/mt7988_wifi7_mac80211_mlo/.config
sed -i 's/CONFIG_PACKAGE_perf=y/# CONFIG_PACKAGE_perf is not set/' mtk-openwrt-feeds/autobuild/autobuild_5.4_mac80211_release/mt7986_mac80211/.config

#\cp -r my_files/3703-wozi- 6.12.45-remove-uci-duplicate-ports.patch mtk-openwrt-feeds/autobuild/unified/filogic/master/patches-base

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt7988_rfb-mt7996 log_file=make

exit 0

cd openwrt
\cp -r ../configs/6.12.config .config
make menuconfig
make -i -j1 V=sc | tee finalmake.txt


