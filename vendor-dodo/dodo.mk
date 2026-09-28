# Автоматично генериран — DODO добавки + privacy + microG + Pixel.
PRODUCT_PACKAGES += DodoLauncher DodoDialer DodoIcons FDroid AuroraStore Wasted DuressApp
# microG (Google услуги в sandbox) — LineageOS 22.2 има вградена signature spoofing
PRODUCT_PACKAGES += GmsCore Companion GsfProxy
# Pixel-стил launcher
PRODUCT_PACKAGES += Lawnchair
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
