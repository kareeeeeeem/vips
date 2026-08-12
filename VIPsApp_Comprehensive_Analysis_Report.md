# 📱 تحليل شامل لمشروع VIPs

---

## 🎯 ما هو المشروع دا؟

**VIPs** هو تطبيق Loyalty & Rewards Platform — يعني منصة مكافآت وولاء للعملاء.
الهدف منه إن العميل يشتري من التجار المسجلين في المنظومة ويكسب نقاط (Points/VPS)، ويستخدمها في مزايا كتير.

المشروع عنده **تطبيقين مختلفين** داخل نفس الكود:
1. 🧑‍💼 **تطبيق المستخدم العادي (User App)** — يبدأ من `main.dart`
2. 🏪 **تطبيق التاجر (Merchant App)** — يبدأ من `main_merchant.dart`

---

## 🏗️ البنية التقنية

### الـ Stack التقني

| الجزء | التقنية |
|-------|---------|
| الـ Framework | Flutter (Dart) |
| State Management | GetX (`get: ^4.7.2`) |
| HTTP Client | Dio + http package |
| قاعدة البيانات (Backend) | MongoDB |
| الـ Backend | Node.js + Express |
| المصادقة | JWT (JSON Web Tokens) |
| التخزين المحلي | SharedPreferences + FlutterSecureStorage |
| الـ Design Size | 375×812 (iPhone reference) |

---

## 📁 هيكل المجلدات

```
vips/
├── lib/
│   ├── main.dart                  ← نقطة دخول تطبيق المستخدم
│   ├── main_merchant.dart         ← نقطة دخول تطبيق التاجر
│   │
│   ├── appuser/                   ← كل كود تطبيق المستخدم
│   │   ├── core/                  ← الطبقة الأساسية (API, Constants, Utils)
│   │   ├── design_system/         ← الألوان والأحجام والـ UI tokens
│   │   ├── modules/               ← شاشات التطبيق (42 module!)
│   │   └── routes/                ← routing التطبيق
│   │
│   ├── appmerchant/               ← كل كود تطبيق التاجر
│   │   ├── core/
│   │   ├── modules/               ← 26 module للتاجر
│   │   └── routes/
│   │
│   ├── core/                      ← مشترك بين التطبيقين
│   │   └── services/
│   │       └── api_service.dart   ← API service بديل (Dio-based)
│   │
│   └── vips-backend/              ← الـ Backend (Node.js) موجود جوه المشروع!
│       ├── index.js               ← نقطة دخول السيرفر
│       ├── models/                ← نماذج قاعدة البيانات
│       ├── routes/                ← API endpoints
│       └── middleware/            ← المصادقة والـ middleware
│
└── assets/
    ├── images/
    └── icons/
```

---

## 📱 تطبيق المستخدم (User App)

### شاشات التطبيق (42 Module)

| اسم الشاشة | الوظيفة |
|-----------|---------|
| `splash` | شاشة البداية — تتحقق من Login وتوجه للصفحة المناسبة |
| `onboarding` | شاشة الترحيب للمستخدمين الجدد |
| `login` / `signup` | تسجيل الدخول / إنشاء حساب |
| `verification` | التحقق من رقم الهاتف |
| `createpin` | إنشاء رقم PIN للأمان |
| `forgot_password` / `reset_password` | استعادة كلمة المرور بـ OTP |
| `success_account` | رسالة نجاح إنشاء الحساب |
| `main_app` | الحاوية الرئيسية (Bottom Navigation) |
| `home` | الصفحة الرئيسية مع الكاروسيل والعروض |
| `search` | البحث عن تجار وعروض |
| `notifications` | الإشعارات |
| `profile` | بروفايل المستخدم |
| `edit_profile` | تعديل بيانات الملف الشخصي |
| `settings` | إعدادات التطبيق |
| `transactions_extract` | كشف حساب المعاملات المالية |
| `credit` | شاشة الرصيد والمحفظة |
| `gift` | إرسال واستقبال هدايا |
| `coupon` | الكوبونات والخصومات |
| `spin_wheel` | عجلة الحظ للمكافآت |
| `expense_to_reward` | تحويل المصروفات لنقاط |
| `vIPsClub` / `vips_club_history` | نادي VIPs ومميزاته |
| `packages` | باقات الاشتراك |
| `bills` / `pay_bills` | فواتير الخدمات |
| `shipping` | خدمات الشحن |
| `mobile` | شحن المحمول |
| `order` | الطلبات |
| `checkout` | إتمام عملية الشراء |
| `Cart` | سلة التسوق |
| `promotions` | العروض الترويجية |
| `donation` | التبرعات |
| `teams` | الفرق (ربما MLM أو referral) |
| `report` | التقارير |
| `vendor_home` / `vendor_order` | واجهة البائع البسيط |
| `QR_scanner` | مسح الـ QR |
| `delivery_driver` / `delivery_order_details` | خدمة التوصيل |
| `contact` | التواصل |

---

## 🏪 تطبيق التاجر (Merchant App)

### شاشات التاجر (26 Module)

| اسم الشاشة | الوظيفة |
|-----------|---------|
| `merchant_auth` | تسجيل دخول التاجر |
| `business_registration` | تسجيل بيانات المتجر |
| `merchant_home` | لوحة التحكم الرئيسية |
| `merchant_orders` | إدارة الطلبات |
| `merchant_catalog` | كتالوج المنتجات |
| `merchant_stock` | إدارة المخزون |
| `merchant_billing` | إصدار الفواتير |
| `merchant_wallet` | المحفظة المالية |
| `merchant_finance` | لوحة التحكم المالي |
| `merchant_customers` | إدارة العملاء |
| `merchant_cashiers` | إدارة الكاشيرية |
| `merchant_hrm` | إدارة الموارد البشرية |
| `merchant_assets` | إدارة الأصول |
| `merchant_dues` | المستحقات والديون |
| `merchant_tax` | الضرائب |
| `merchant_ads` | الإعلانات |
| `merchant_gift_back` | نظام Gift Back للعملاء |
| `merchant_credit` | الائتمان |
| `merchant_reviews` | تقييمات العملاء |
| `merchant_notifications` | الإشعارات |
| `merchant_settings` | الإعدادات |
| `merchant_subscription` | اشتراكات الخطط |
| `merchant_partnership` | الشراكات |
| `merchant_barcode` | توليد الباركود |
| `merchant_profile_manager` | إدارة بروفايل المتجر |

---

## 🎨 نظام التصميم (Design System)

### الألوان الرئيسية

| الاسم | القيمة | الاستخدام |
|-------|--------|-----------|
| `AppPrimaryColor` | `#FA6B25` | البرتقالي الأساسي |
| `Appblou` | `#00205C` | الأزرق الداكن |
| `AppYellow` | `RGB(255,196,3)` | الأصفر |
| `appWhite` | أبيض | |
| `AppBlackColor` | أسود | |

### الـ Fonts المستخدمة
- **Poppins** — الخط الأساسي في معظم الشاشات
- **Roboto** — محدد في AppConstants
- **SF Pro Display** — محدد في تطبيق التاجر

### الـ Design Reference
- حجم التصميم: **375 × 812** pixels (iPhone 12/13 standard)
- يستخدم `flutter_screenutil` لضمان التوافق مع كل أحجام الشاشات

---

## 🌐 الـ Backend

### السيرفر
- **Node.js + Express** يعمل على **Port 3000**
- **MongoDB** قاعدة البيانات
- **JWT** للمصادقة (صالح 7 أيام)

### API Endpoints

#### 🔐 `/api/auth` — المصادقة

| Method | Endpoint | الوظيفة |
|--------|---------|---------|
| POST | `/register` | إنشاء حساب جديد |
| POST | `/login` | تسجيل الدخول |
| GET | `/me` | بيانات المستخدم الحالي |
| PUT | `/update-profile` | تحديث البروفايل |
| POST | `/forgot-password` | إرسال OTP (6 أرقام، صالح 15 دقيقة) |
| POST | `/reset-password` | إعادة تعيين كلمة المرور |

#### 🏪 `/api/merchant` — التاجر

| Method | Endpoint | الوظيفة |
|--------|---------|---------|
| GET | `/dashboard` | إجمالي المبيعات والمصاريف والمكافآت |
| GET | `/transactions` | قائمة المعاملات مع pagination |
| POST | `/transaction` | تسجيل معاملة جديدة |
| GET | `/customers` | قائمة العملاء |
| GET | `/stats` | إحصائيات اليوم والشهر |

#### 🎁 `/api/rewards` — المكافآت

| Method | Endpoint | الوظيفة |
|--------|---------|---------|
| GET | `/coupons` | قائمة الكوبونات |
| POST | `/expense-to-reward` | تحويل مصروف لنقاط (10% كمكافأة) |
| POST | `/apply-coupon` | تطبيق كوبون |
| GET | `/gift-vouchers` | قسائم الهدايا (Carrefour, 2B, FiT&F) |
| POST | `/send-gift` | إرسال هدية |
| POST | `/spin-wheel` | لعبة عجلة الحظ (50 → 1000 نقطة) |

#### 📋 `/api/content` — المحتوى

| Method | Endpoint | الوظيفة |
|--------|---------|---------|
| GET | `/hot-deals` | العروض الساخنة |
| GET | `/ending-soon-deals` | عروض توشك على الانتهاء |
| GET | `/outings` | الأنشطة والخروجات |
| GET | `/trending-merchants` | التجار الأكثر شيوعاً |

#### 💳 `/api/services` — الخدمات

| Method | Endpoint | الوظيفة |
|--------|---------|---------|
| GET | `/bills` | أنواع الفواتير |
| POST | `/pay-bill` | دفع فاتورة من المحفظة |

#### 🛒 خدمات أخرى
- `/api/cart` — سلة التسوق
- `/api/order` — الطلبات
- `/api/favorites` — المفضلة
- `/api/user` — بيانات المستخدم

---

## 🗄️ نماذج قاعدة البيانات (MongoDB Models)

### 👤 User
```
- fullName, email, phone, password (hashed bcrypt)
- role: customer | merchant | agent | admin
- storeName, storeAddress, storeCategory (للتجار)
- logo, brandColor, isTrending, discountPercentage (للتجار)
- walletBalance, walletPoints (المحفظة والنقاط)
- favorites[], cart[]
- profileImage, isVerified, isActive
- resetPasswordToken, resetPasswordExpires (لـ OTP)
- timestamps: createdAt, updatedAt
```

### 💰 Transaction
```
- userId, merchantId
- type: income | expense | reward | gift_back
- amount, currency, description, status
- reference (مرجع فريد)
- timestamps
```

### باقي النماذج
- **Coupon** — الكوبونات
- **GiftVoucher** — قسائم الهدايا
- **Deal** — العروض
- **Outing** — الأنشطة والخروجات
- **Product** — المنتجات
- **Subscription** — الاشتراكات
- **BillService** — خدمات الفواتير

---

## 🔄 تدفق التطبيق (App Flow)

```
App Start
    ↓
[Splash Screen]
    ↓
هل في Token محفوظ؟
    ├── نعم → [Main App] (الصفحة الرئيسية)
    └── لا  → [Onboarding] → [Login/Signup] → [Verification] → [Create PIN] → [Main App]

Main App (Bottom Navigation):
    ├── 🏠 Home       → Carousel + Hot Deals + Outings + Trending Merchants
    ├── 🛒 Cart/Shop  → سلة التسوق
    ├── 🎁 Rewards    → النقاط والكوبونات وعجلة الحظ
    └── 👤 Profile    → البروفايل والإعدادات
```

---

## 🔧 طبقة الـ API (بالتفصيل)

### في تطبيق المستخدم — عندنا اتنين clients!

#### 1. `ApiClient` (`appuser/core/api/api_client.dart`)
- الأقدم والأكثر استخداماً في الكود
- يستخدم الـ `http` package العادي
- Base URL: `https://6ammart-admin.6amtech.com` ← ده URL خارجي لمنصة 6amMart!
- يرفع الـ Auth Token في الـ Headers تلقائياً
- Timeout: 30 ثانية

#### 2. `ApiService` (`core/services/api_service.dart`)
- الأحدث — يستخدم **Dio** package
- Base URL: `http://localhost:3000/api` ← ده URL الـ Backend الخاص
- Singleton Pattern
- يحفظ الـ Token في SharedPreferences
- عنده Interceptors للـ Logging

> ⚠️ **ملاحظة مهمة:** المشروع بيستخدم اتنين APIs مختلفين — واحد للمنصة الخارجية (6amMart) وواحد للـ Backend الخاص. ده يشير إلى مرحلة انتقال من المنصة الخارجية للـ Backend الخاص.

---

## 🌍 دعم اللغات (Translations)

- يستخدم نظام الترجمة المدمج في GetX
- يدعم اللغة العربية (`ar_SA`) والإنجليزية (`en_US`) والفرنسية (`fr_FR`)
- `AppTranslations` class موجودة في `appuser/core/translations/`

---

## 📦 المكتبات الرئيسية (Dependencies)

| المكتبة | الغرض |
|---------|-------|
| `get: ^4.7.2` | State Management + Navigation + DI |
| `dio: ^5.9.0` | HTTP Client قوي |
| `flutter_screenutil: ^5.9.3` | Responsive Design |
| `carousel_slider: ^5.1.1` | Carousel في الهوم |
| `flutter_secure_storage: ^9.2.4` | تخزين آمن للـ Tokens |
| `shared_preferences` | تخزين بيانات بسيطة |
| `firebase_auth` | مصادقة Firebase |
| `google_sign_in: ^6.2.1` | تسجيل دخول بـ Google |
| `flutter_facebook_auth` | تسجيل دخول بـ Facebook |
| `sign_in_with_apple` | تسجيل دخول بـ Apple |
| `mobile_scanner: ^7.1.3` | مسح QR/Barcode |
| `qr_flutter` | توليد QR codes |
| `glassmorphism: ^3.0.0` | تأثيرات بصرية |
| `pinput: ^5.0.2` | إدخال الـ PIN/OTP |
| `image_picker` | اختيار صور |
| `file_picker` | اختيار ملفات |
| `local_auth` | البصمة/Face ID |
| `share_plus` | مشاركة المحتوى |
| `cached_network_image` | تحميل الصور بكفاءة |
| `intl: ^0.20.2` | تنسيق التواريخ والأرقام |
| `auto_size_text: ^3.0.0` | ضبط حجم النص تلقائياً |
| `ticket_widget: ^1.0.2` | شكل التذكرة |
| `dotted_border` | حدود منقطة |

---

## 🏛️ نمط البرمجة (Architecture Pattern)

المشروع يتبع نمط **GetX MVC**:

```
كل Module فيه:
├── controllers/   ← المنطق والـ Business Logic (GetxController)
├── views/         ← الـ UI (GetView<Controller>)
├── models/        ← نماذج البيانات
└── bindings/      ← Dependency Injection (Get.lazyPut)
```

---

## ⚙️ الـ Backend Configuration

```env
PORT=3000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/vips_db
JWT_SECRET=vips_super_secret_key_...
JWT_EXPIRES_IN=7d
```

> ⚠️ **تحذير أمني:** الـ JWT_SECRET موجود في ملف `.env` غير مشفر! لازم يتغير قبل النشر على الإنتاج.

---

## 🎮 الخصائص المميزة للمشروع

### 1. نظام المكافآت (Rewards System)
- كل مصروف = 10% نقاط مكافأة (`expense-to-reward`)
- عجلة الحظ تعطي من 50 لـ 1000 نقطة (`spin-wheel`)
- كوبونات خصومات قابلة للتطبيق

### 2. نظام الهدايا (Gift System)
- إرسال هدايا لأرقام هواتف أخرى بالرصيد
- قسائم شراء جاهزة من Carrefour و2B وFiT&F

### 3. Gift Back للتجار
- التاجر يقدر يعمل Gift Back لعملائه من خلال تطبيق التاجر

### 4. نادي VIPs
- مستوى من مستويات الولاء للعملاء المميزين

### 5. تعدد الأدوار
- **Customer** / **Merchant** / **Agent** / **Admin**
- كل دور عنده تجربة مختلفة في التطبيق

### 6. دفع الفواتير
- دفع فواتير الخدمات مباشرة من المحفظة

### 7. مسح QR
- استخدام الـ QR للمعاملات بين العملاء والتجار
- باركود توليد من جانب التاجر

### 8. الـ Home Screen
- كاروسيل إعلاني بـ Auto-Scroll كل 3 ثواني
- Hot Deals — عروض ساخنة من الـ API
- Ending Soon Deals — عروض على وشك الانتهاء
- Outings — أنشطة وخروجات
- Trending Merchants — تجار مميزون

---

## 🚨 ملاحظات مهمة وإشكاليات

| الإشكالية | التفاصيل |
|-----------|---------|
| **اتنين HTTP Clients** | `ApiClient` يشاور على 6amMart الخارجي، `ApiService` يشاور على البيكند الخاص — تضارب محتمل |
| **Base URL فارغة** | في `AppConstants` الـ `API_BASE_URL = ''` فارغة |
| **JWT Secret مكشوف** | موجود في `.env` كـ plain text |
| **Comments بالفرنسي** | جزء من الكود عليه comments بالفرنسي — يشير إلى imported code |
| **No Tests** | مفيش Unit Tests أو Integration Tests |
| **TODOs كتير** | أكثر من 20 TODO في الكود لفيتشرز مش متكملة |

---

## 📊 ملخص إجمالي

| الجانب | التفاصيل |
|--------|---------|
| **نوع التطبيق** | Loyalty & Rewards Platform |
| **المنصة** | iOS + Android (Flutter Cross-platform) |
| **عدد شاشات User App** | 42 شاشة |
| **عدد شاشات Merchant App** | 26 شاشة |
| **إجمالي الشاشات** | ~68 شاشة |
| **البيئة المستهدفة** | السوق العربي |
| **مرحلة التطوير** | Under Development |
| **اللون الأساسي** | `#FA6B25` (برتقالي حار) |
| **عملة النقاط الداخلية** | VPS (VIPs Points System) |
| **دعم اللغات** | عربي / إنجليزي / فرنسي |
| **تسجيل الدخول** | Email + Google + Facebook + Apple |

---

*تم إعداد هذا التحليل بتاريخ: 8 يوليو 2026*
