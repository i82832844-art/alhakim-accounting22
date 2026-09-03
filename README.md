# الحكيم للمحاسبة

تطبيق Flutter لإدارة محل الاتصالات: المنتجات، الباركود، الجرد، المبيعات، والفواتير.

## الحالة الحالية
- Arabic RTL + Material 3
- SQLite محلية
- إدارة المنتجات والأسعار والكميات
- مسح الباركود وإنشاء منتج عند عدم وجوده
- تصوير المنتج
- بحث سريع بالاسم والباركود والماركة والموديل
- مبيعات بسلة، التحقق من المخزون، وإنقاص الكمية داخل Transaction واحدة
- إجمالي مبيعات اليوم ولوحة مؤشرات أولية
- GitHub Actions لبناء Android APK

## تشغيل المشروع
```bash
flutter pub get
flutter analyze
flutter run
```

## بناء APK
```bash
flutter build apk --release
```

أو استخدم GitHub Actions من تبويب Actions.

## بنية مهمة
- `lib/core/database` قاعدة البيانات
- `lib/models` النماذج
- `lib/services` الوصول للبيانات ومنطق البيع
- `lib/screens` الواجهات
- `.github/workflows/android.yml` بناء APK آليًا

## Android
المشروع يحتوي الآن على مشروع Android أصلي داخل `android/` مع دعم الكاميرا لمسح الباركود.
الـAPK التجريبي يخرج من GitHub Actions باسم `app-release.apk`.


## ملاحظة البناء
GitHub Actions يعيد توليد ملفات Android الرسمية عند كل Build لضمان توافقها مع نسخة Flutter المستخدمة، ثم يضيف صلاحية الكاميرا ويبني APK Release.
