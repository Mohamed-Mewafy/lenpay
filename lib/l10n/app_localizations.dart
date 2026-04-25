import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

class AppLocalizations {
  static const String localeKey = 'locale';

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  static Future<void> setLocale(Locale locale) async {
    localeNotifier.value = locale;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(localeKey, locale.languageCode);
  }

  static String translate(BuildContext context, String key) {
    final String languageCode = localeNotifier.value.languageCode;
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  static String translateFormat(
    BuildContext context,
    String key,
    Map<String, String> args,
  ) {
    String translated = translate(context, key);
    args.forEach((argKey, argValue) {
      translated = translated.replaceAll('{$argKey}', argValue);
    });
    return translated;
  }

  static Future<void> toggleLocale() async {
    final Locale nextLocale = localeNotifier.value.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    await setLocale(nextLocale);
  }

  static String nextLanguageName(BuildContext context) {
    final String nextLanguageCode = localeNotifier.value.languageCode == 'ar'
        ? 'en'
        : 'ar';
    final String key = nextLanguageCode == 'en' ? 'English' : 'Arabic';
    return translate(context, key);
  }

  static bool get isRTL => localeNotifier.value.languageCode == 'ar';

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'Welcome Back': 'Welcome Back',
      'Sign in to your account to continue':
          'Sign in to your account to continue',
      'Email Address': 'Email Address',
      'Password': 'Password',
      'Forgot Password?': 'Forgot Password?',
      'Sign In': 'Sign In',
      "Don't have an account?": "Don't have an account?",
      'Sign Up': 'Sign Up',
      'Welcome to\nLenPay Wallet': 'Welcome to\nLenPay Wallet',
      'The most secure and easy way to manage your finances, pay bills, and transfer money instantly.':
          'The most secure and easy way to manage your finances, pay bills, and transfer money instantly.',
      'Get Started': 'Get Started',
      'Create Account': 'Create Account',
      'Join LenPay and start managing your finances easily':
          'Join LenPay and start managing your finances easily',
      'Full Name': 'Full Name',
      'Phone Number': 'Phone Number',
      'Already have an account?': 'Already have an account?',
      'Please fill in all fields': 'Please fill in all fields',
      'Phone number must start with country code (e.g., +20)':
          'Phone number must start with country code (e.g., +20)',
      'Password must be at least 6 characters.':
          'Password must be at least 6 characters.',
      'Account created successfully. Verification email sent.':
          'Account created successfully. Verification email sent.',
      'Email already in use.': 'Email already in use.',
      'Password is too weak.': 'Password is too weak.',
      'Please enter a valid email address.':
          'Please enter a valid email address.',
      'Email sign-up is not enabled.': 'Email sign-up is not enabled.',
      'Creating your account...': 'Creating your account...',
      'Saving your profile...': 'Saving your profile...',
      'Saved account locally. Sending verification email...':
          'Saved account locally. Sending verification email...',
      'Sending verification email...': 'Sending verification email...',
      'Verification email sent. Please check your inbox.':
          'Verification email sent. Please check your inbox.',
      'Verification email sent. Profile save failed, please log in after verifying your email.':
          'Verification email sent. Profile save failed, please log in after verifying your email.',
      'Verification email sent!': 'Verification email sent!',
      'Go to Sign In': 'Go to Sign In',
      'Try Again': 'Try Again',
      'An error occurred': 'An error occurred',
      'Connection timeout. Please check your internet connection.':
          'Connection timeout. Please check your internet connection.',
      'Your email is not verified yet. Please verify your email before signing in.':
          'Your email is not verified yet. Please verify your email before signing in.',
      'No user found for that email.': 'No user found for that email.',
      'Wrong password provided.': 'Wrong password provided.',
      'The email address is badly formatted.':
          'The email address is badly formatted.',
      'Settings': 'Settings',
      'Account': 'Account',
      'Edit Profile': 'Edit Profile',
      'Security & Privacy': 'Security & Privacy',
      'Application': 'Application',
      'Dark Mode': 'Dark Mode',
      'Notifications': 'Notifications',
      'Biometric Login': 'Biometric Login',
      'Help Center': 'Help Center',
      'About LenPay': 'About LenPay',
      'Logout Account': 'Logout Account',
      'Support': 'Support',
      'Language': 'Language',
      'Change Language': 'Change Language',
      'Switch to {language}': 'Switch to {language}',
      'English': 'English',
      'Arabic': 'Arabic',
      'Profile updated successfully!': 'Profile updated successfully!',
      'Failed to update: {error}': 'Failed to update: {error}',
      'Profile Photo': 'Profile Photo',
      'Take Photo': 'Take Photo',
      'Choose from Gallery': 'Choose from Gallery',
      'Remove Photo': 'Remove Photo',
      'Selecting image...': 'Selecting image...',
      'Profile photo updated!': 'Profile photo updated!',
      'Location': 'Location',
      'Enter {label}': 'Enter {label}',
      'My Wallet': 'My Wallet',
      'Quick Actions': 'Quick Actions',
      'Send': 'Send',
      'Receive': 'Receive',
      'Bills': 'Bills',
      'Savings': 'Savings',
      'Vouchers': 'Vouchers',
      'Recent Operations': 'Recent Operations',
      'No operations yet': 'No operations yet',
      'Recharge Wallet': 'Recharge Wallet',
      'Enter Amount': 'Enter Amount',
      'Select Payment Method': 'Select Payment Method',
      'Visa / Mastercard': 'Visa / Mastercard',
      'Apple Pay': 'Apple Pay',
      'PayPal Wallet': 'PayPal Wallet',
      'Recharge process started!': 'Recharge process started!',
      'Finalize Recharge': 'Finalize Recharge',
      'Pay Your {service} Bill': 'Pay Your {service} Bill',
      'Consumer ID / Account No.': 'Consumer ID / Account No.',
      'Enter your 12-digit number': 'Enter your 12-digit number',
      'Amount to Pay': 'Amount to Pay',
      'Pay Now': 'Pay Now',
      'Payment Successful': 'Payment Successful',
      'Your {service} bill has been paid successfully.':
          'Your {service} bill has been paid successfully.',
      'Done': 'Done',
      'Today': 'Today',
      'Yesterday': 'Yesterday',
      'Salary Received': 'Salary Received',
      'New login detected on Chrome Windows. Was this you?':
          'New login detected on Chrome Windows. Was this you?',
      'Security Alert': 'Security Alert',
      'Transfer Received': 'Transfer Received',
      'System Update': 'System Update',
      'LenPay v2.4 is now available with new features!':
          'LenPay v2.4 is now available with new features!',
      'Transaction History': 'Transaction History',
      'All': 'All',
      'Income': 'Income',
      'Expenses': 'Expenses',
      'Home': 'Home',
      'Wallet': 'Wallet',
      'Operations': 'Operations',
      'Offers': 'Offers',
      'All Services': 'All Services',
      'Mobile Charge': 'Mobile Charge',
      'Restaurant': 'Restaurant',
      'Hotel': 'Hotel',
      'Wifi': 'Wifi',
      'Electricity': 'Electricity',
      'Ticket': 'Ticket',
      'Store': 'Store',
      'See All': 'See All',
      'Recharge': 'Recharge',
      'Travel': 'Travel',
      'Shopping': 'Shopping',
      'Favorite Services': 'Favorite Services',
      'Financial Tools': 'Financial Tools',
      'Many offers waiting for you, get it now':
          'Many offers waiting for you, get it now',
      'Buy Now': 'Buy Now',
      'Order Now': 'Order Now',
      'Pay': 'Pay',
      'User': 'User',
      'Unknown': 'Unknown',
      'Verify Your Email': 'Verify Your Email',
      'Email Verified!': 'Email Verified!',
      'We sent a verification link to': 'We sent a verification link to',
      'Please click the link in the email to verify your account.':
          'Please click the link in the email to verify your account.',
      'Your email has been verified successfully. Redirecting...':
          'Your email has been verified successfully. Redirecting...',
      "I've Verified My Email": "I've Verified My Email",
      'Checking...': 'Checking...',
      'Resend Verification Email': 'Resend Verification Email',
      'Resend in {seconds}s': 'Resend in {seconds}s',
      'Back to Sign In': 'Back to Sign In',
      'Sign Out': 'Sign Out',
      'Email verified successfully!': 'Email verified successfully!',
      'Email not verified yet. Please check your inbox and click the link.':
          'Email not verified yet. Please check your inbox and click the link.',
      'Verification code sent to your email.':
          'Verification code sent to your email.',
      'Enter the 6-digit code sent to': 'Enter the 6-digit code sent to',
      'Resend Code': 'Resend Code',
      'Verify': 'Verify',
      'Please enter the 6-digit code': 'Please enter the 6-digit code',
      'Verification email resent. Please check your inbox.':
          'Verification email resent. Please check your inbox.',
      'Account created successfully. Verification code sent.':
          'Account created successfully. Verification code sent.',
      'Failed to send code': 'Failed to send code',
      'Invalid code': 'Invalid code',
      'Too many requests. Please try again later.':
          'Too many requests. Please try again later.',
      'Session expired. Please sign in again.':
          'Session expired. Please sign in again.',
    },
    'ar': {
      'Welcome Back': 'مرحبا بعودتك',
      'Sign in to your account to continue': 'سجل الدخول إلى حسابك للمتابعة',
      'Email Address': 'البريد الإلكتروني',
      'Password': 'كلمة المرور',
      'Forgot Password?': 'هل نسيت كلمة المرور؟',
      'Sign In': 'تسجيل الدخول',
      "Don't have an account?": 'ليس لديك حساب؟',
      'Sign Up': 'إنشاء حساب',
      'Welcome to\nLenPay Wallet': 'مرحبًا بك في\nمحفظة لين باي',
      'The most secure and easy way to manage your finances, pay bills, and transfer money instantly.':
          'الطريقة الأكثر أمانًا وسهولة لإدارة أموالك، دفع الفواتير، وتحويل الأموال على الفور.',
      'Get Started': 'ابدأ الآن',
      'Create Account': 'إنشاء حساب',
      'Join LenPay and start managing your finances easily':
          'انضم إلى لين باي وابدأ في إدارة أموالك بسهولة',
      'Full Name': 'الاسم الكامل',
      'Phone Number': 'رقم الهاتف',
      'Already have an account?': 'هل لديك حساب بالفعل؟',
      'Please fill in all fields': 'الرجاء ملء جميع الحقول',
      'Phone number must start with country code (e.g., +20)':
          'يجب أن يبدأ رقم الهاتف بمفتاح الدولة (مثل +20)',
      'Password must be at least 6 characters.':
          'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.',
      'Account created successfully. Verification email sent.':
          'تم إنشاء الحساب بنجاح. تم إرسال رسالة التحقق.',
      'Email already in use.': 'البريد الإلكتروني مستخدم بالفعل.',
      'Password is too weak.': 'كلمة المرور ضعيفة جدًا.',
      'Please enter a valid email address.':
          'الرجاء إدخال عنوان بريد إلكتروني صالح.',
      'Email sign-up is not enabled.': 'تسجيل البريد الإلكتروني غير مفعل.',
      'Creating your account...': 'جارٍ إنشاء الحساب...',
      'Saving your profile...': 'جارٍ حفظ ملفك الشخصي...',
      'Saved account locally. Sending verification email...':
          'تم حفظ الحساب محليًا. جارٍ إرسال بريد التحقق...',
      'Sending verification email...': 'جارٍ إرسال بريد التحقق...',
      'Verification email sent. Please check your inbox.':
          'تم إرسال بريد التحقق. يرجى التحقق من صندوق الوارد.',
      'Verification email sent. Profile save failed, please log in after verifying your email.':
          'تم إرسال بريد التحقق. فشل حفظ الملف الشخصي، يرجى تسجيل الدخول بعد التحقق من بريدك.',
      'Verification email sent!': 'تم إرسال بريد التحقق!',
      'Go to Sign In': 'اذهب لتسجيل الدخول',
      'Try Again': 'حاول مرة أخرى',
      'An error occurred': 'حدث خطأ',
      'Connection timeout. Please check your internet connection.':
          'انتهت مهلة الاتصال. يرجى التحقق من اتصال الإنترنت.',
      'Your email is not verified yet. Please verify your email before signing in.':
          'بريدك الإلكتروني غير موثّق بعد. يرجى التحقق من بريدك قبل تسجيل الدخول.',
      'No user found for that email.':
          'لم يتم العثور على مستخدم بهذا البريد الإلكتروني.',
      'Wrong password provided.': 'كلمة المرور خاطئة.',
      'The email address is badly formatted.':
          'عنوان البريد الإلكتروني غير صالح.',
      'Settings': 'الإعدادات',
      'Account': 'الحساب',
      'Edit Profile': 'تعديل الملف الشخصي',
      'Security & Privacy': 'الأمان والخصوصية',
      'Application': 'التطبيق',
      'Dark Mode': 'الوضع الداكن',
      'Notifications': 'الإشعارات',
      'Biometric Login': 'تسجيل الدخول ببصمة',
      'Help Center': 'مركز المساعدة',
      'About LenPay': 'عن لين باي',
      'Logout Account': 'تسجيل الخروج',
      'Support': 'الدعم',
      'Language': 'اللغة',
      'Change Language': 'تغيير اللغة',
      'Switch to {language}': 'التبديل إلى {language}',
      'English': 'الإنجليزية',
      'Arabic': 'العربية',
      'Profile updated successfully!': 'تم تحديث الملف الشخصي بنجاح!',
      'Failed to update: {error}': 'فشل التحديث: {error}',
      'Profile Photo': 'صورة الملف الشخصي',
      'Take Photo': 'التقاط صورة',
      'Choose from Gallery': 'اختر من المعرض',
      'Remove Photo': 'حذف الصورة',
      'Selecting image...': 'جارٍ اختيار الصورة...',
      'Profile photo updated!': 'تم تحديث صورة الملف الشخصي!',
      'Location': 'الموقع',
      'Enter {label}': 'أدخل {label}',
      'My Wallet': 'محفظتي',
      'Quick Actions': 'إجراءات سريعة',
      'Send': 'إرسال',
      'Receive': 'استلام',
      'Bills': 'فواتير',
      'Savings': 'مدخرات',
      'Vouchers': 'قسائم',
      'Recent Operations': 'العمليات الأخيرة',
      'No operations yet': 'لا توجد عمليات بعد',
      'Recharge Wallet': 'إعادة شحن المحفظة',
      'Enter Amount': 'أدخل المبلغ',
      'Select Payment Method': 'اختر طريقة الدفع',
      'Visa / Mastercard': 'فيزا / ماستر كارد',
      'Apple Pay': 'آبل باي',
      'PayPal Wallet': 'باي بال',
      'Recharge process started!': 'بدأت عملية الشحن!',
      'Finalize Recharge': 'إنهاء الشحن',
      'Pay Your {service} Bill': 'ادفع فاتورة {service}',
      'Consumer ID / Account No.': 'رقم العميل / الحساب',
      'Enter your 12-digit number': 'أدخل رقمك المكون من 12 رقمًا',
      'Amount to Pay': 'المبلغ المطلوب دفعه',
      'Pay Now': 'ادفع الآن',
      'Payment Successful': 'تم الدفع بنجاح',
      'Your {service} bill has been paid successfully.':
          'تم دفع فاتورة {service} بنجاح.',
      'Done': 'تم',
      'Today': 'اليوم',
      'Yesterday': 'أمس',
      'Salary Received': 'تم استلام الراتب',
      'New login detected on Chrome Windows. Was this you?':
          'تم الكشف عن تسجيل دخول جديد على كروم ويندوز. هل هذا أنت؟',
      'Security Alert': 'تنبيه أمني',
      'Transfer Received': 'تم استلام التحويل',
      'System Update': 'تحديث النظام',
      'LenPay v2.4 is now available with new features!':
          'تطبيق لين باي إصدار 2.4 متاح الآن مع ميزات جديدة!',
      'Transaction History': 'سجل المعاملات',
      'All': 'الكل',
      'Income': 'الدخل',
      'Expenses': 'المصروفات',
      'Home': 'الرئيسية',
      'Wallet': 'المحفظة',
      'Operations': 'العمليات',
      'Offers': 'العروض',
      'All Services': 'جميع الخدمات',
      'Mobile Charge': 'شحن الجوال',
      'Restaurant': 'مطعم',
      'Hotel': 'فندق',
      'Wifi': 'واي فاي',
      'Electricity': 'الكهرباء',
      'Ticket': 'تذكرة',
      'Store': 'المتجر',
      'See All': 'عرض الكل',
      'Recharge': 'شحن',
      'Travel': 'السفر',
      'Shopping': 'تسوق',
      'Favorite Services': 'الخدمات المفضلة',
      'Financial Tools': 'الأدوات المالية',
      'Many offers waiting for you, get it now':
          'الكثير من العروض في انتظارك، احصل عليها الآن',
      'Buy Now': 'اشتر الآن',
      'Order Now': 'اطلب الآن',
      'Pay': 'ادفع',
      'User': 'المستخدم',
      'Unknown': 'غير معروف',
      'Setting': 'الإعدادات',
      'Verify Your Email': 'تحقق من بريدك الإلكتروني',
      'Email Verified!': 'تم التحقق من البريد!',
      'We sent a verification link to': 'لقد أرسلنا رابط التحقق إلى',
      'Please click the link in the email to verify your account.':
          'يرجى الضغط على الرابط في البريد الإلكتروني للتحقق من حسابك.',
      'Your email has been verified successfully. Redirecting...':
          'تم التحقق من بريدك الإلكتروني بنجاح. جارٍ التحويل...',
      "I've Verified My Email": 'لقد تحققت من بريدي',
      'Checking...': 'جارٍ الفحص...',
      'Resend Verification Email': 'إعادة إرسال بريد التحقق',
      'Resend in {seconds}s': 'إعادة الإرسال خلال {seconds} ثانية',
      'Back to Sign In': 'العودة لتسجيل الدخول',
      'Sign Out': 'تسجيل الخروج',
      'Email verified successfully!': 'تم التحقق من البريد الإلكتروني بنجاح!',
      'Email not verified yet. Please check your inbox and click the link.':
          'لم يتم التحقق من البريد بعد. يرجى التحقق من صندوق الوارد والضغط على الرابط.',
      'Verification code sent to your email.':
          'تم إرسال كود التحقق إلى بريدك الإلكتروني.',
      'Enter the 6-digit code sent to':
          'أدخل الكود المكون من 6 أرقام المرسل إلى',
      'Resend Code': 'إعادة إرسال الكود',
      'Verify': 'تحقق',
      'Please enter the 6-digit code': 'الرجاء إدخال الكود المكون من 6 أرقام',
      'Verification email resent. Please check your inbox.':
          'تم إعادة إرسال بريد التحقق. يرجى التحقق من صندوق الوارد.',
      'Account created successfully. Verification code sent.':
          'تم إنشاء الحساب بنجاح. تم إرسال كود التحقق.',
      'Failed to send code': 'فشل إرسال الكود',
      'Invalid code': 'كود غير صالح',
      'Too many requests. Please try again later.':
          'طلبات كثيرة جدًا. يرجى المحاولة لاحقًا.',
      'Session expired. Please sign in again.':
          'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.',
    },
  };
}

extension TranslateExtension on String {
  String tr(BuildContext context) => AppLocalizations.translate(context, this);
}
