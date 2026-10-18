# DODO OS — AOSP vanilla вид + privacy + microG.
# Launcher: ползваме Trebuchet (вграден в LineageOS = AOSP launcher вид).
# Махнати: DodoLauncher/DodoIcons/Lawnchair — за чист vanilla AOSP вид.
# Pixel/DODO launcher-ите можем да върнем после ако поискаш.
PRODUCT_PACKAGES += FDroid AuroraStore Wasted DuressApp
# DODO self-check команда (реална системна проверка)
PRODUCT_PACKAGES += dodo-status
# DODO Boot Check app — показва реалната проверка като пръв екран при старт
PRODUCT_PACKAGES += DodoBootCheck
# microG (Google услуги в sandbox) — LineageOS 22.2 има вградена signature spoofing
PRODUCT_PACKAGES += GmsCore Companion GsfProxy
PRODUCT_BROKEN_VERIFY_USES_LIBRARIES := true

# ===== DODO boot анимация =====
# Официалният механизъм на LineageOS: казваме на техния bootanimation модул да
# ползва ГОТОВ файл (нашия) вместо да генерира. Така няма конфликт.
SOONG_CONFIG_NAMESPACES += lineage_bootanimation
SOONG_CONFIG_lineage_bootanimation += height width half_res prebuilt_file
SOONG_CONFIG_lineage_bootanimation_height := 1600
SOONG_CONFIG_lineage_bootanimation_width := 720
SOONG_CONFIG_lineage_bootanimation_half_res := false
SOONG_CONFIG_lineage_bootanimation_prebuilt_file := vendor/dodo/bootanimation.zip

# ===== ДИАГНОСТИКА: adb включен от старта =====
# За да хванем защо дисплеят е черен — adb работи без разрешение на черен екран.
PRODUCT_PRODUCT_PROPERTIES += \
    persist.sys.usb.config=adb \
    ro.adb.secure=0
