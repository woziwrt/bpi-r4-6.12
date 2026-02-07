rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch openwrt-25.12 https://github.com/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout 2151b98144069e4c48b5996f21d934ae6a812031; cd -;		#apk: backport upstream fix for invalid fetch timestamps

git clone --branch master https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git checkout d5e5ac68356e67c90973434414c13e50c7fa4036; cd -;	#[openwrt-25][common][bsp][Add initial support for memory dump]

\cp -r my_files/w-defconfig mtk-openwrt-feeds/autobuild/unified/filogic/25.12/defconfig
#\cp -r my_files/w-rules mtk-openwrt-feeds/autobuild/unified/filogic/rules
\cp -r my_files/w-Makefile openwrt/package/libs/musl-fts/Makefile

\cp -r my_files/9999-image-bpi-r4-sdcard.patch mtk-openwrt-feeds/25.12/patches-base
#tx_power patch - required for BE14 boards with defective eeprom flash
\cp -r my_files/99999_tx_power_check.patch openwrt/package/kernel/mt76/patches

\cp -r my_files/wsdd2-Makefile openwrt/feeds/packages/net/wsdd2/Makefile

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-mt798x_rfb-wifi7_nic log_file=make

exit 0
