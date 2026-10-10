#!/usr/bin/env bash
# rebuild_iso.sh — пересобирает загрузочный ISO из iso_work/
set -euo pipefail

ISO_DIR="iso_work"
OUT_DIR="output"
OUT_ISO="$OUT_DIR/Windows.Tiny7.Patched.Slim.iso"

mkdir -p "$OUT_DIR"

echo "🔍 Detecting boot configuration..."

# ── Вариант A: EFI + BIOS (xorriso — предпочтительно) ───────────────────────
ELTORITO_BOOT=""
ELTORITO_CATALOG=""

if [ -f "$ISO_DIR/boot/etfsboot.com" ]; then
  ELTORITO_BOOT="$ISO_DIR/boot/etfsboot.com"
  ELTORITO_CATALOG="$ISO_DIR/boot.catalog"
fi

if command -v xorriso &>/dev/null; then
  echo "🔨 Building ISO with xorriso..."

  XORR_ARGS=(
    xorriso -as mkisofs
    -iso-level 3
    -full-iso9660-filenames
    -volid "WIN7_TINY_SLIM"
    -no-emul-boot
    -boot-load-seg 0x07C0
    -boot-load-size 8
  )

  if [ -n "$ELTORITO_BOOT" ]; then
    XORR_ARGS+=(
      -b "$(realpath --relative-to="$ISO_DIR" "$ELTORITO_BOOT")"
      -c "$(realpath --relative-to="$ISO_DIR" "$ELTORITO_CATALOG")"
    )
  fi

  # EFI support (если есть efi.img или efisys.bin)
  EFI_IMG=""
  for candidate in \
      "$ISO_DIR/efi/microsoft/boot/efisys.bin" \
      "$ISO_DIR/efi/boot/bootx64.efi" \
      "$ISO_DIR/boot/efisys.bin"; do
    [ -f "$candidate" ] && EFI_IMG="$candidate" && break
  done

  if [ -n "$EFI_IMG" ]; then
    REL_EFI="$(realpath --relative-to="$ISO_DIR" "$EFI_IMG")"
    XORR_ARGS+=(
      -eltorito-alt-boot
      -e "$REL_EFI"
      -no-emul-boot
    )
    echo "  + EFI boot: $REL_EFI"
  fi

  XORR_ARGS+=( -o "$OUT_ISO" "$ISO_DIR" )
  "${XORR_ARGS[@]}"

else
  # ── Вариант B: genisoimage (fallback) ───────────────────────────────────────
  echo "🔨 Building ISO with genisoimage (fallback)..."

  GEN_ARGS=(
    genisoimage
    -iso-level 3
    -full-iso9660-filenames
    -volid "WIN7_TINY_SLIM"
    -no-emul-boot
    -boot-load-seg 0x07C0
    -boot-load-size 8
  )

  if [ -n "$ELTORITO_BOOT" ]; then
    GEN_ARGS+=(
      -b "$(realpath --relative-to="$ISO_DIR" "$ELTORITO_BOOT")"
      -c "$(realpath --relative-to="$ISO_DIR" "$ELTORITO_CATALOG")"
    )
  fi

  GEN_ARGS+=( -o "$OUT_ISO" "$ISO_DIR" )
  "${GEN_ARGS[@]}"
fi

echo "✅ ISO built: $OUT_ISO ($(du -sh $OUT_ISO | cut -f1))"
