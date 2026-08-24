#!/bin/bash
set -e

FLAVOR="${1:-consumer}"
SPLIT="${2:-yes}"

case "$FLAVOR" in
  consumer) TARGET="lib/main.dart" ;;
  merchant) TARGET="lib/main_merchant.dart" ;;
  *) echo "Usage: ./build_apk.sh [consumer|merchant] [yes|no]"; exit 1 ;;
esac

EXTRA_FLAGS=""
if [ "$SPLIT" = "yes" ]; then
  EXTRA_FLAGS="--split-per-abi"
fi

echo "📦 Building $FLAVOR release APK ($TARGET)..."
flutter build apk --release --flavor "$FLAVOR" -t "$TARGET" $EXTRA_FLAGS
