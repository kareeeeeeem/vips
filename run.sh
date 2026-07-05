#!/bin/bash

# 1. تنظيف كاش فلاتر القديم
echo "🧹 Cleaning Flutter cache..."
flutter clean

# 2. تحديث واعتماد حزم Pub المتوفرة
echo "📦 Getting pub packages..."
flutter pub get

# 3. الدخول لمجلد iOS لإعادة بناء الكاكوبودز من الصفر باستخدام بيئة FVM
echo "🍎 Rebuilding iOS Pods with FVM environment..."
cd ios
rm -rf Pods Podfile.lock .symlinks

# التعديل هنا: تشغيل pod install من خلال fvm لتوحيد الـ SDK Paths
exec pod install 

# 4. العودة للمجلد الرئيسي وتشغيل التطبيق
echo "🚀 Running App..."
cd ..
 flutter run