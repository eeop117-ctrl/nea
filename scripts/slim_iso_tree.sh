#!/usr/bin/env bash
# slim_iso_tree.sh — убирает лишнее из дерева ISO (вне WIM)
set -euo pipefail

ISO_DIR="iso_work"

echo "🧹 Slimming ISO tree..."

# Compatibility / upgrade files — не нужны для чистой установки
rm -rf "$ISO_DIR/upgrade"            2>/dev/null || true
rm -rf "$ISO_DIR/compat"             2>/dev/null || true

# support/logging/debug-tools (если есть)
rm -rf "$ISO_DIR/support/logging"    2>/dev/null || true

# Лишние autorun-мусорки
rm -f  "$ISO_DIR/autorun.inf"        2>/dev/null || true
rm -f  "$ISO_DIR/setup.exe"          2>/dev/null || true  # дублируется внутри WIM

# Thumbs.db, desktop.ini и другой мусор
find "$ISO_DIR" -name "Thumbs.db" -delete 2>/dev/null || true
find "$ISO_DIR" -name "desktop.ini" -delete 2>/dev/null || true
find "$ISO_DIR" -name "*.log" -delete 2>/dev/null || true

echo "✅ ISO tree cleaned: $(du -sh $ISO_DIR | cut -f1)"
