#!/bin/bash
set -euo pipefail

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch openwrt-25.12 https://github.com/openwrt/openwrt.git openwrt
cd openwrt; git checkout 85342bea07f65bdd9a22fc45a4c977c9aa42a5fb; cd -;		#wireguard-tools: fix script errors

git clone --branch master https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds
cd mtk-openwrt-feeds; git checkout 05b3d27f0beade745e2c4d699c60e45667420e62; cd -;	#[kernel-6.12][mt7987/mt7988][i2.5Gphy][net: phy: mtk-2p5ge: Fix write_mmd callback check]

\cp -r my_files/w-defconfig mtk-openwrt-feeds/autobuild/unified/filogic/25.12/defconfig
\cp -r my_files/1130-image-mediatek-filogic-add-bananapi-bpi-r4-pro-support.patch mtk-openwrt-feeds/25.12/patches-base
\cp -r my_files/1133-image-mediatek-filogic-add-bananapi-bpi-r4-support.patch mtk-openwrt-feeds/25.12/patches-base
\cp -r my_files/999-sfp-10-additional-quirks.patch mtk-openwrt-feeds/25.12/files/target/linux/mediatek/patches-6.12

\cp -r my_files/9999-image-bpi-r4-sdcard.patch mtk-openwrt-feeds/25.12/patches-base

### tx_power check Gilly_1970's patch - for defective BE14 boards with defective eeprom flash
#\cp -r my_files/0140-wifi-mt76-mt7996-use-mt76_get_txpower_cur.patch mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/25.12/files/package/kernel/mt76/patches

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt798x_rfb-wifi7_nic prepare

\cp -r ../my_files/w-Makefile package/libs/musl-fts/Makefile
\cp -r ../my_files/wsdd2-Makefile feeds/packages/net/wsdd2/Makefile


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


