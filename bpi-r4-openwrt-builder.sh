#!/bin/bash
set -euo pipefail

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch openwrt-25.12 https://github.com/openwrt/openwrt.git openwrt
cd openwrt; git checkout 85342bea07f65bdd9a22fc45a4c977c9aa42a5fb; cd -;		#wireguard-tools: fix script errors

git clone --branch master https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds
cd mtk-openwrt-feeds; git checkout c50841e9d1dd88fa9a73cb2a2c9ffc86ec4b5bd9; cd -;	#[kernel-6.12][mt7988][npu][refactor npu common patches]


cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt798x_rfb-wifi7_nic prepare

\cp -r ../my_files/w-Makefile openwrt/package/libs/musl-fts/Makefile
\cp -r ../my_files/wsdd2-Makefile openwrt/feeds/packages/net/wsdd2/Makefile
\cp -r ../my_files/9999-image-bpi-r4-sdcard.patch mtk-openwrt-feeds/25.12/patches-base


\cp -r ../my_files/sms-tool/ feeds/packages/utils/sms-tool
\cp -r ../my_files/modemdata-main/ feeds/packages/utils/modemdata 
\cp -r ../my_files/luci-app-modemdata-main/luci-app-modemdata/ feeds/luci/applications
\cp -r ../my_files/luci-app-lite-watchdog/ feeds/luci/applications
\cp -r ../my_files/luci-app-sms-tool-js-main/luci-app-sms-tool-js/ feeds/luci/applications

./scripts/feeds update -a
./scripts/feeds install -a

#\cp -r ../my_files/qmi.sh package/network/utils/uqmi/files/lib/netifd/proto/
#chmod -R 755 package/network/utils/uqmi/files/lib/netifd/proto
chmod -R 755 feeds/luci/applications/luci-app-modemdata/root
chmod -R 755 feeds/luci/applications/luci-app-sms-tool-js/root
chmod -R 755 feeds/packages/utils/modemdata/files/usr/share

\cp -r ../my_files/my_final_defconfig .config
make defconfig

bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt798x_rfb-wifi7_nic build


