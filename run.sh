#!/bin/bash
set -e

# الفلافور: consumer (appuser, default) أو merchant (appmerchant)
FLAVOR="${1:-consumer}"
case "$FLAVOR" in
  consumer) TARGET="lib/main.dart" ;;
  merchant) TARGET="lib/main_merchant.dart" ;;
  *) echo "Usage: ./run.sh [consumer|merchant]"; exit 1 ;;
esac

# 1. تنظيف كاش فلاتر القديم
echo "🧹 Cleaning Flutter cache..."
flutter clean

# 2. تحديث واعتماد حزم Pub المتوفرة
echo "📦 Getting pub packages..."
flutter pub get

# 3. الدخول لمجلد iOS لإعادة بناء الكاكوبودز من الصفر
echo "🍎 Rebuilding iOS Pods..."
(cd ios && rm -rf Pods Podfile.lock .symlinks && pod install)

# 4. تشغيل التطبيق بالفلافور المطلوب
echo "🚀 Running $FLAVOR app ($TARGET)..."
flutter run --flavor "$FLAVOR" -t "$TARGET"