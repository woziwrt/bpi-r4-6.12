#!/bin/bash
set -euo pipefail

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch openwrt-25.12 https://github.com/openwrt/openwrt.git openwrt
cd openwrt; git checkout 74bf3689ea6326dcdd3386c46b70e4877ea3347e; cd -;		#kernel: backport pppoe improvements

git clone --branch master https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds
cd mtk-openwrt-feeds; git checkout e39de5680a2e945a6d420e9f9f95cef8d4f99506; cd -;	#[openwrt-24][MAC80211][WiFi7][Update MP4.2 critical patches]

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


