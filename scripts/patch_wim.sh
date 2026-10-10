#!/usr/bin/env bash
# patch_wim.sh — патчит install.wim: убирает лишние компоненты, оптимизирует
set -euo pipefail

WIM="iso_work/sources/install.wim"

if [ ! -f "$WIM" ]; then
  echo "❌ install.wim not found at $WIM"
  exit 1
fi

echo "📋 Image info:"
wiminfo "$WIM"

# Работаем с образом #1 (первый (и обычно единственный) индекс в Tiny7)
IDX=1

echo "🔧 Mounting install.wim index $IDX..."
mkdir -p /tmp/wim_mount
sudo wimmount "$WIM" $IDX /tmp/wim_mount

echo "🗑️  Removing optional / bloat components..."

# Справочники / помощь Windows (экономит ~30–60 MB)
sudo rm -rf /tmp/wim_mount/Windows/Help || true

# Темы Aero (уже урезаны в Tiny7, но на всякий случай)
sudo find /tmp/wim_mount/Windows/Resources/Themes \
  -mindepth 1 -maxdepth 1 \
  -not -name "aero" -not -name "Classic" \
  -exec rm -rf {} + 2>/dev/null || true

# Лишние шрифты (оставляем только латиницу + кириллицу)
KEEP_FONTS="arial* calibri* cour* segoe* tahoma* times* verdana* times*
            micro* wingding* symbol* consol* lucon*"
sudo bash -c "
  cd /tmp/wim_mount/Windows/Fonts
  for f in *.ttf *.fon *.otf; do
    keep=0
    for pattern in $KEEP_FONTS; do
      case \"\$f\" in \$pattern) keep=1; break;; esac
    done
    [ \$keep -eq 0 ] && rm -f \"\$f\" && echo \"  removed font: \$f\"
  done
" || true

# Медиа-примеры (Sample Music/Pictures/Videos)
sudo rm -rf /tmp/wim_mount/Users/Public/Music/Sample\ Music || true
sudo rm -rf /tmp/wim_mount/Users/Public/Pictures/Sample\ Pictures || true
sudo rm -rf /tmp/wim_mount/Users/Public/Videos/Sample\ Videos || true

# IE кеши и временные файлы внутри образа
sudo find /tmp/wim_mount/Windows/Temp -mindepth 1 -delete 2>/dev/null || true

# Лишние языковые пакеты (оставляем en-US + ru-RU)
sudo bash -c "
  for dir in /tmp/wim_mount/Windows/System32/*/; do
    bn=\$(basename \"\$dir\")
    case \"\$bn\" in
      en-US|ru-RU) ;;
      ??-??|??-???|??-????|??-?????-*) rm -rf \"\$dir\" && echo \"  removed lang: \$bn\";;
    esac
  done
" 2>/dev/null || true

echo "📦 Unmounting and rebuilding WIM..."
sudo wimunmount --commit /tmp/wim_mount

echo "🗜️  Recompressing install.wim (LZX solid)..."
sudo wimoptimize --recompress --compress=LZX "$WIM"

echo "✅ install.wim patched: $(du -sh $WIM | cut -f1)"
