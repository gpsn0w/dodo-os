#!/usr/bin/env bash
# ============================================================================
#  🦤 DODO OS — главен автоматичен билд (LineageOS 22.2, OnePlus N100 / billie2)
#  Прави ВСИЧКО само: досваля източника, вгражда DODO добавките + privacy
#  приложенията, компилира готовия ROM. Пуска се във фонов режим.
# ============================================================================
set -u
export PATH="$HOME/bin:$PATH"
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
export CCACHE_EXEC=$(command -v ccache || true)

ROOT=~/dodo-build/lineage
EXTRAS=~/dodo-build/dodo-extras          # DODO launcher/dialer/icons/bootanim
PRIVAPPS=~/"claude code"                 # F-Droid / Aurora / Wasted / Duress
DEVICE=billie2
JOBS=6                                   # умерено, за да не гръмне RAM+swap

say(){ echo; echo "==== [$(date +%H:%M:%S)] $* ===="; echo; }

cd "$ROOT" || { echo "Няма $ROOT"; exit 1; }

# --- 1) Досваляне с повторни опити (мрежата може да пада) -------------------
say "СВАЛЯНЕ на източника (repo sync, с повторни опити)"
SYNC_OK=0
for i in 1 2 3 4 5 6 7 8; do
  echo ">>> опит $i за repo sync ..."
  if ~/bin/repo sync -c -j"$JOBS" --force-sync --no-clone-bundle --no-tags --optimized-fetch; then
    SYNC_OK=1; echo ">>> repo sync успешен."; break
  fi
  echo ">>> sync прекъсна, пробвам пак след 20с ..."; sleep 20
done
if [ "$SYNC_OK" -ne 1 ]; then
  echo "!!! repo sync не успя след 8 опита. Спирам преди билда."; exit 2
fi

# --- 2) DODO персонализация: вграждаме APK-та + boot анимация ---------------
say "ВГРАЖДАНЕ на DODO добавки + privacy приложения (vendor/dodo)"
VD="$ROOT/vendor/dodo"
rm -rf "$VD"; mkdir -p "$VD"
echo 'LOCAL_PATH := $(call my-dir)' > "$VD/Android.mk"
PKGS=""

add_apk(){  # $1=път до apk  $2=име на модул
  [ -z "${1:-}" ] && return 0
  [ ! -f "$1" ] && { echo "  (пропускам, липсва: $1)"; return 0; }
  cp "$1" "$VD/$2.apk"
  cat >> "$VD/Android.mk" <<MK

include \$(CLEAR_VARS)
LOCAL_MODULE := $2
LOCAL_MODULE_CLASS := APPS
LOCAL_SRC_FILES := $2.apk
LOCAL_CERTIFICATE := PRESIGNED
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_SUFFIX := \$(COMMON_ANDROID_PACKAGE_SUFFIX)
include \$(BUILD_PREBUILT)
MK
  PKGS="$PKGS $2"
  echo "  + $2  ←  $(basename "$1")"
}

pick(){ find "$1" -maxdepth 1 -type f -iname "$2" 2>/dev/null | head -1; }

# DODO добавки (визия)
add_apk "$(pick "$EXTRAS" '*launcher*.apk')" DodoLauncher
add_apk "$(pick "$EXTRAS" '*dialer*.apk')"   DodoDialer
add_apk "$(pick "$EXTRAS" '*icon*.apk')"     DodoIcons
# Privacy приложения
add_apk "$(pick "$PRIVAPPS" 'F-Droid*.apk')"     FDroid
add_apk "$(pick "$PRIVAPPS" 'AuroraStore*.apk')" AuroraStore
add_apk "$(pick "$PRIVAPPS" 'Wasted*.apk')"      Wasted
add_apk "$(pick "$PRIVAPPS" 'duress*.apk')"      DuressApp

# boot анимация
BOOT="$(pick "$EXTRAS" '*ootanimation*.zip')"; [ -z "$BOOT" ] && BOOT="$(pick "$EXTRAS" '*boot*.zip')"
{
  echo "# Автоматично генериран — DODO добавки + privacy приложения."
  [ -n "$BOOT" ] && echo 'LOCAL_PATH := $(call my-dir)'
  [ -n "$PKGS" ] && echo "PRODUCT_PACKAGES +=$PKGS"
  [ -n "$BOOT" ] && echo 'PRODUCT_COPY_FILES += $(LOCAL_PATH)/bootanimation.zip:$(TARGET_COPY_OUT_PRODUCT)/media/bootanimation.zip'
} > "$VD/dodo.mk"
[ -n "$BOOT" ] && { cp "$BOOT" "$VD/bootanimation.zip"; echo "  + boot анимация ← $(basename "$BOOT")"; }

# Закачаме към продукта на устройството
DEV_MK="$(find "$ROOT/device/oneplus/$DEVICE" -maxdepth 1 -name "lineage_${DEVICE}.mk" 2>/dev/null | head -1)"
[ -z "$DEV_MK" ] && DEV_MK="$(find "$ROOT/device/oneplus/$DEVICE" -maxdepth 1 -name "*_${DEVICE}.mk" 2>/dev/null | head -1)"
if [ -n "$DEV_MK" ] && ! grep -q "vendor/dodo/dodo.mk" "$DEV_MK"; then
  printf '\n# DODO добавки + privacy приложения\n$(call inherit-product-if-exists, vendor/dodo/dodo.mk)\n' >> "$DEV_MK"
  echo "  ✓ закачих vendor/dodo/dodo.mk към $(basename "$DEV_MK")"
elif [ -z "$DEV_MK" ]; then
  echo "  !!! Не намерих lineage_${DEVICE}.mk — добавките може да не влязат."
fi

# --- 3) Билд ----------------------------------------------------------------
say "БИЛД (mka bacon) — най-дългата част"
source build/envsetup.sh
lunch "lineage_${DEVICE}-userdebug" || { echo "!!! lunch се провали"; exit 3; }
mka bacon -j"$JOBS" || { echo "!!! Билдът се провали — виж грешките по-горе"; exit 4; }

# --- 4) Готово --------------------------------------------------------------
OUT="$ROOT/out/target/product/${DEVICE}"
say "ГОТОВО 🦤"
ls -lah "$OUT"/lineage-*.zip 2>/dev/null && echo "^^^ Това е Dodo OS ROM-ът за флашване!" \
  || echo "Няма .zip в $OUT — виж лога за грешки."
