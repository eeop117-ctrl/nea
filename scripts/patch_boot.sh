#!/usr/bin/env bash
# patch_boot.sh — оптимизирует boot.wim (WinPE загрузчик)
set -euo pipefail

BOOT_WIM="iso_work/sources/boot.wim"

if [ ! -f "$BOOT_WIM" ]; then
  echo "⚠️  boot.wim not found — skipping"
  exit 0
fi

echo "🔧 Recompressing boot.wim..."
sudo wimoptimize --recompress --compress=LZX "$BOOT_WIM"

echo "✅ boot.wim done: $(du -sh $BOOT_WIM | cut -f1)"
