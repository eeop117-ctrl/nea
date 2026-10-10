#!/usr/bin/env bash
# rebuild_iso.sh — пересобирает загрузочный ISO из iso_work/
set -euo pipefail

ISO_DIR="iso_work"
OUT_DIR="output"
OUT_ISO="$OUT_DIR/Windows.Tiny7.Patched.Slim.iso"

mkdir -p "$OUT_DIR"

echo "🔍 Detecting boot configuration..."

ETFS=""
for f in \
    "$ISO_DIR/boot/etfsboot.com" \
    "$ISO_DIR/Boot/etfsboot.com"; do
  [ -f "$f" ] && ETFS="$f" && break
done

EFI=""
for f in \
    "$ISO_DIR/efi/microsoft/boot/efisys.bin" \
    "$ISO_DIR/efi/boot/bootx64.efi" \
    "$ISO_DIR/boot/efisys.bin" \
    "$ISO_DIR/Boot/efisys.bin"; do
  [ -f "$f" ] && EFI="$f" && break
done

echo "  BIOS boot : ${ETFS:-not found}"
echo "  EFI  boot : ${EFI:-not found}"

echo "🔨 Building ISO with xorriso..."

ARGS=(
  xorriso -as mkisofs
  -iso-level 3
  -full-iso9660-filenames
  -volid "WIN7_TINY_SLIM"
  -o "$OUT_ISO"
)

if [ -n "$ETFS" ]; then
  REL_ETFS="$(realpath --relative-to="$ISO_DIR" "$ETFS")"
  ARGS+=(
    -b "$REL_ETFS"
    -no-emul-boot
    -boot-load-size 8
  )
  echo "  + BIOS boot: $REL_ETFS"
fi

if [ -n "$EFI" ]; then
  REL_EFI="$(realpath --relative-to="$ISO_DIR" "$EFI")"
  ARGS+=(
    -eltorito-alt-boot
    -e "$REL_EFI"
    -no-emul-boot
  )
  echo "  + EFI boot: $REL_EFI"
fi

ARGS+=( "$ISO_DIR" )

"${ARGS[@]}"

echo "✅ ISO built: $OUT_ISO ($(du -sh "$OUT_ISO" | cut -f1))"
