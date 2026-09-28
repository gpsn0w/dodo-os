# 🦤 Dodo OS

**Privacy-focused, open-source Android за OnePlus Nord N100 (billie2).**

Dodo OS е custom Android дистрибуция, базирана на **LineageOS 22.2 (Android 15)**,
построена от източник специално за **OnePlus Nord N100 (BE2013 / billie2)**.
Целта: частен, de-Googled телефон по подразбиране — Google услугите работят само
в **sandbox** (microG) — вдъхновено от GrapheneOS.

> ⚠️ **Честна бележка:** bootloader-ът на N100 **не може да се заключи пак с твой
> ключ**, затова Dodo OS не дава verified boot като GrapheneOS на Pixel. Това е
> силен *privacy* ROM, не заместител на хардуерната сигурност на Graphene.

## Устройство
| | |
|---|---|
| Телефон | OnePlus Nord N100 |
| Модел | BE2013 |
| Кодово име | **billie2** |
| Чип | Snapdragon 460 (SM4250 / bengal) |
| База | LineageOS 22.2 (Android 15) |
| Нужен firmware | OxygenOS **11.0.15** |

## Какво има вътре
- 📶 **Работещо WiFi** (модулът `qca_cld3_wlan.ko` е компилиран вътре)
- 📦 **microG** — Google услуги в sandbox (Google работи, без Google проследяване)
- 🎨 **Lawnchair** (Pixel launcher) + DODO launcher / dialer / икони
- 🔒 **F-Droid**, **Aurora Store** (Play анонимно), **Wasted** (авто-изтриване),
  **Duress** (паник изтриване)
- 🎬 Собствена **DODO boot анимация**
- 🔐 Криптиране по подразбиране, изолирани профили, USB-C защита при заключен

## Документация
- 📖 [Как е направено (пълен дневник + капани)](docs/КАК-Е-НАПРАВЕНО.md)
- 🗺️ [Roadmap](docs/ROADMAP.md)
- 🔒 [Функции за сигурност](docs/SECURITY.md)
- 📲 [Флашване](scripts/README.md)

## Структура на repo-то
| Папка | За какво е |
|-------|-----------|
| `vendor-dodo/` | Конфигурация за вграждане на приложенията (Android.mk + dodo.mk) |
| `manifest/` | repo манифести (billie2 local manifest) |
| `scripts/` | Билд + флашване скриптове |
| `overlays/` | Privacy overlay настройки |
| `patches/` | Спецификации на privacy функции |
| `docs/` | Документация |
| `prebuilt-apps/` | Конфигурация за pre-installed приложенията |

## Сайт
🌐 **https://gpsn0w.github.io/oneplus/**

## Лиценз
Apache License 2.0 — виж [`LICENSE`](LICENSE), както AOSP/LineageOS.

---
*Направено с 🦤 и грижа за приватността. Не е свързано с Google, OnePlus,
LineageOS или GrapheneOS.*
