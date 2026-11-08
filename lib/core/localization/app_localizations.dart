import 'package:flutter/material.dart';

/// Comprehensive Localization class supporting Arabic (RTL) & English (LTR)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('ar'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  bool get isArabic => locale.languageCode == 'ar';

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App & Brand
      'appName': 'Mostafa Salama Delivery',
      'brandTagline': 'Authentic Egyptian Flavor • Express Delivery',
      'driverPortal': 'Driver Portal',

      // Auth
      'loginTitle': 'Driver Login',
      'loginSubtitle': 'Enter your credentials assigned by restaurant management',
      'email': 'Email Address',
      'emailHint': 'driver@mostafasalama.com',
      'password': 'Password',
      'passwordHint': '••••••••',
      'loginButton': 'Sign In',
      'loggingIn': 'Authenticating...',
      'logout': 'Sign Out',
      'logoutConfirmTitle': 'Confirm Sign Out',
      'logoutConfirmMsg': 'Are you sure you want to log out of your driver session?',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'invalidEmail': 'Please enter a valid email address',
      'passwordTooShort': 'Password must be at least 6 characters',
      'mustChangePasswordTitle': 'Security: Password Update Required',
      'mustChangePasswordMsg': 'Restaurant management requires you to set a new password upon first sign-in.',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'confirmNewPassword': 'Confirm New Password',
      'passwordsDoNotMatch': 'Passwords do not match',
      'updatePassword': 'Update Password',
      'passwordUpdated': 'Password updated successfully.',
      'accountDeactivated': 'Your account has been deactivated. Contact management.',

      // Dashboard
      'dashboard': 'Dashboard',
      'assignedOrders': 'Assigned Deliveries',
      'activeOrders': 'Active',
      'completedToday': 'Completed Today',
      'totalCompleted': 'Total Completed',
      'pendingOrders': 'Pending',
      'noOrdersFound': 'No orders found',
      'noOrdersDescription': 'You have no assigned deliveries under this status.',
      'refresh': 'Refresh',

      // Order Filters
      'filterAll': 'All',
      'filterPending': 'Pending',
      'filterPreparing': 'Preparing',
      'filterReady': 'Ready',
      'filterOutForDelivery': 'Out for Delivery',
      'filterDelivered': 'Delivered',

      // Order Card
      'orderNumber': 'Order #',
      'customer': 'Customer',
      'phone': 'Phone',
      'address': 'Delivery Address',
      'total': 'Total',
      'deliveryFee': 'Delivery Fee',
      'subtotal': 'Subtotal',
      'paymentMethod': 'Payment Method',
      'paymentStatus': 'Payment Status',
      'cashOnDelivery': 'Cash on Delivery',
      'itemsCount': 'Items',
      'viewDetails': 'View Order',
      'actionStartDelivery': 'Start Delivery',
      'actionAcceptOrder': 'Accept Order',
      'actionScanQr': 'Scan QR Code',

      // Order Statuses
      'status_pending': 'Pending',
      'status_confirmed': 'Confirmed',
      'status_preparing': 'Preparing',
      'status_out_for_delivery': 'Out for Delivery',
      'status_delivered': 'Delivered',
      'status_cancelled': 'Cancelled',

      // Order Details
      'orderDetails': 'Order Details',
      'customerInfo': 'Customer Information',
      'deliveryAddress': 'Delivery Address',
      'callCustomer': 'Call Customer',
      'openInMaps': 'Open Google Maps',
      'orderItems': 'Order Items',
      'orderSummary': 'Financial Summary',
      'notes': 'Delivery Notes & Instructions',
      'noNotes': 'No special instructions provided.',
      'orderTimeline': 'Order Lifecycle Timeline',
      'createdTime': 'Placed At',
      'assignedTime': 'Assigned At',
      'acceptedTime': 'Accepted At',
      'deliveredTime': 'Delivered At',
      'startingTrip': 'Starting delivery...',
      'acceptingOrder': 'Accepting order...',
      'tripStarted': 'Delivery trip started! You are now out for delivery.',

      // QR Scanner
      'scanDeliveryQr': 'Scan Delivery QR Code',
      'scanQrPrompt': 'Point camera at the customer\'s order QR code to confirm delivery',
      'cameraPermissionTitle': 'Camera Permission Needed',
      'cameraPermissionDesc': 'Camera access is required to scan customer QR codes and confirm drop-off.',
      'grantPermission': 'Grant Permission',
      'processingScan': 'Verifying QR Token with Restaurant Server...',
      'scanSuccessTitle': 'Order Delivered Successfully!',
      'scanSuccessDesc': 'Drop-off confirmed and recorded on restaurant servers.',
      'deliveryConfirmedAt': 'Delivered At',
      'deliveredBy': 'Driver',
      'backToDashboard': 'Back to Dashboard',
      'invalidQrCode': 'Invalid or unreadable QR code.',
      'duplicateScanPrevented': 'Duplicate scan prevented. Already submitted.',

      // Profile & Settings
      'profile': 'Driver Profile',
      'driverStatus': 'Account Status',
      'active': 'Active',
      'inactive': 'Inactive',
      'changePassword': 'Change Password',
      'language': 'Language',
      'arabic': 'العربية (Arabic)',
      'english': 'English',
      'appearance': 'Appearance',
      'themeDark': 'Dark Theme',
      'themeLight': 'Light Theme',
      'serverEnvironment': 'Server Connection',
      'currentServer': 'Connected Server',
      'version': 'Version',
    },
    'ar': {
      // App & Brand
      'appName': 'مصطفى سلامة - توصيل',
      'brandTagline': 'طعم مصري أصيل • توصيل سريع',
      'driverPortal': 'بوابة السائقين',

      // Auth
      'loginTitle': 'تسجيل دخول السائق',
      'loginSubtitle': 'أدخل بيانات الحساب المسلمة لك من إدارة المطعم',
      'email': 'البريد الإلكتروني',
      'emailHint': 'driver@mostafasalama.com',
      'password': 'كلمة المرور',
      'passwordHint': '••••••••',
      'loginButton': 'تسجيل الدخول',
      'loggingIn': 'جاري التحقق من الحساب...',
      'logout': 'تسجيل الخروج',
      'logoutConfirmTitle': 'تأكيد تسجيل الخروج',
      'logoutConfirmMsg': 'هل أنت متأكد من رغبتك في تسجيل الخروج من حساب السائق؟',
      'cancel': 'إلغاء',
      'confirm': 'تأكيد',
      'invalidEmail': 'يرجى إدخال بريد إلكتروني صحيح',
      'passwordTooShort': 'كلمة المرور يجب ألا تقل عن 6 أحرف',
      'mustChangePasswordTitle': 'أمان: يلزم تعيين كلمة مرور جديدة',
      'mustChangePasswordMsg': 'تتطلب إدارة المطعم تغيير كلمة المرور عند أول تسجيل دخول لك.',
      'currentPassword': 'كلمة المرور الحالية',
      'newPassword': 'كلمة المرور الجديدة',
      'confirmNewPassword': 'تأكيد كلمة المرور الجديدة',
      'passwordsDoNotMatch': 'كلمتا المرور غير متطابقتين',
      'updatePassword': 'تحديث كلمة المرور',
      'passwordUpdated': 'تم تحديث كلمة المرور بنجاح.',
      'accountDeactivated': 'تم تعطيل حسابك من قبل الإدارة. يرجى مراجعة المطعم.',

      // Dashboard
      'dashboard': 'لوحة التحكم',
      'assignedOrders': 'الطلبات المسندة إليك',
      'activeOrders': 'الطلبات النشطة',
      'completedToday': 'المكتملة اليوم',
      'totalCompleted': 'إجمالي المكتمل',
      'pendingOrders': 'قيد الانتظار',
      'noOrdersFound': 'لا توجد طلبات',
      'noOrdersDescription': 'لا توجد طلبات توصيل مسندة لك ضمن هذا التصنيف حالياً.',
      'refresh': 'تحديث',

      // Order Filters
      'filterAll': 'الكل',
      'filterPending': 'جديد',
      'filterPreparing': 'جاري التجهيز',
      'filterReady': 'جاهز',
      'filterOutForDelivery': 'في الطريق',
      'filterDelivered': 'تم التسليم',

      // Order Card
      'orderNumber': 'طلب رقم',
      'customer': 'العميل',
      'phone': 'الهاتف',
      'address': 'عنوان التوصيل',
      'total': 'الإجمالي',
      'deliveryFee': 'رسوم التوصيل',
      'subtotal': 'المجموع الفرعي',
      'paymentMethod': 'طريقة الدفع',
      'paymentStatus': 'حالة الدفع',
      'cashOnDelivery': 'دفع عند الاستلام',
      'itemsCount': 'أصناف',
      'viewDetails': 'تفاصيل الطلب',
      'actionStartDelivery': 'بدء التوصيل',
      'actionAcceptOrder': 'قبول الطلب',
      'actionScanQr': 'مسح كود التسليم',

      // Order Statuses
      'status_pending': 'قيد الانتظار',
      'status_confirmed': 'مؤكد',
      'status_preparing': 'جاري التجهيز',
      'status_out_for_delivery': 'جاري التوصيل',
      'status_delivered': 'تم التسليم بنجاح',
      'status_cancelled': 'ملغي',

      // Order Details
      'orderDetails': 'تفاصيل الطلب',
      'customerInfo': 'بيانات العميل',
      'deliveryAddress': 'عنوان التوصيل',
      'callCustomer': 'اتصال بالعميل',
      'openInMaps': 'فتح في خرائط جوجل',
      'orderItems': 'محتويات الطلب',
      'orderSummary': 'الملخص المالي',
      'notes': 'ملاحظات وتعليمات التوصيل',
      'noNotes': 'لا توجد ملاحظات خاصة من العميل.',
      'orderTimeline': 'المسار الزمني للطلب',
      'createdTime': 'وقت إنشاء الطلب',
      'assignedTime': 'وقت إسناد الطلب',
      'acceptedTime': 'وقت قبول السائق',
      'deliveredTime': 'وقت تأكيد التسليم',
      'startingTrip': 'جاري بدء رحلة التوصيل...',
      'acceptingOrder': 'جاري قبول الطلب...',
      'tripStarted': 'تم بدء التوصيل! الطلب الآن في الطريق للعميل.',

      // QR Scanner
      'scanDeliveryQr': 'مسح كود التسليم QR',
      'scanQrPrompt': 'وجه الكاميرا نحو كود الـ QR الخاص بطلب العميل لتأكيد التسليم',
      'cameraPermissionTitle': 'مطلوب إذن استخدام الكاميرا',
      'cameraPermissionDesc': 'يتطلب التطبيق الإذن للوصول للكاميرا لقراءة كود التسليم من شاشة العميل.',
      'grantPermission': 'منح الإذن',
      'processingScan': 'جاري التحقق من كود التسليم مع خادم المطعم...',
      'scanSuccessTitle': 'تم تسليم الأوردر بنجاح! 🎉',
      'scanSuccessDesc': 'تم تسجيل وتوثيق عملية التسليم رسمياً في نظام المطعم.',
      'deliveryConfirmedAt': 'وقت التسليم المؤكد',
      'deliveredBy': 'السائق المسؤول',
      'backToDashboard': 'العودة للوحة التحكم',
      'invalidQrCode': 'رمز QR غير صالح أو غير مقروء.',
      'duplicateScanPrevented': 'تم منع تكرار المسح. الطلب قيد المعالجة.',

      // Profile & Settings
      'profile': 'الملف الشخصي',
      'driverStatus': 'حالة الحساب',
      'active': 'نشط ومفعل',
      'inactive': 'غير مفعل',
      'changePassword': 'تغيير كلمة المرور',
      'language': 'لغة التطبيق',
      'arabic': 'العربية',
      'english': 'English (الإنجليزية)',
      'appearance': 'المظهر والشاشة',
      'themeDark': 'الوضع الداكن (الرسمي)',
      'themeLight': 'الوضع الفاتح',
      'serverEnvironment': 'خادم الاتصال',
      'currentServer': 'الخادم المتصل به',
      'version': 'الإصدار',
    },
  };

  String translate(String key) {
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ?? _localizedValues['ar']?[key] ?? key;
  }

  String orderStatusText(String status) {
    final key = 'status_${status.toLowerCase()}';
    return translate(key);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

