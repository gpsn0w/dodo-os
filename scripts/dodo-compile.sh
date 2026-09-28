#!/usr/bin/env bash
# 🦤 DODO OS — само компилацията (сорсът е свален, добавките са вградени).
# БЕЗ 'set -u' — LineageOS envsetup.sh не работи под nounset.
cd ~/dodo-build/lineage || { echo "няма lineage дърво"; exit 1; }

export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
export CCACHE_EXEC=$(command -v ccache)
ccache -M 50G >/dev/null 2>&1

echo "==== [$(date +%H:%M:%S)] Настройвам build средата ===="
source build/envsetup.sh
echo "==== [$(date +%H:%M:%S)] breakfast billie2 ===="
breakfast billie2 || { echo "!!! breakfast се провали"; exit 2; }

echo "==== [$(date +%H:%M:%S)] Компилирам ROM-а (mka bacon -j6) — най-дългото ===="
mka bacon -j6
RC=$?

OUT=~/dodo-build/lineage/out/target/product/billie2
echo
if [ $RC -eq 0 ] && ls "$OUT"/lineage-*.zip >/dev/null 2>&1; then
  echo "==== [$(date +%H:%M:%S)] ✅✅ ГОТОВО! ROM-ът е: ===="
  ls -lah "$OUT"/lineage-*.zip
else
  echo "==== [$(date +%H:%M:%S)] ❌ Билдът приключи с код $RC — виж грешките по-горе ===="
fi
