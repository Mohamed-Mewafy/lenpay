import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lenpay/l10n/app_localizations.dart';
import 'package:lenpay/ui/auth/email_verification.dart';
import 'package:lenpay/ui/auth/login.dart';
import 'package:lenpay/ui/navbar/navbar.dart';
import 'package:lenpay/ui/onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'firebase_options.dart';

/// Checks if Firebase emulators are actually reachable on the given host/port.
/// This is more reliable than trying to detect if we are on an emulator/simulator.
Future<bool> _isEmulatorRunning(String host, int port) async {
  try {
    final socket = await Socket.connect(
      host,
      port,
      timeout: const Duration(seconds: 1),
    );
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<bool> balanceVisibilityNotifier = ValueNotifier(true);

/// Simple lifecycle observer to cancel the connectivity subscription
/// when the app is detached (terminated).
class _AppLifecycleObserver extends WidgetsBindingObserver {
  final StreamSubscription<dynamic> subscription;
  _AppLifecycleObserver(this.subscription);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      subscription.cancel();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Configure Firestore persistence and cache for offline support
  final firestore = FirebaseFirestore.instance;
  firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Manage Firestore network based on connectivity to prevent
  // WriteStream/QUIC errors during network transitions.
  // Debounced: waits 1.5s before acting to avoid rapid toggle storms
  // when switching between WiFi and cellular.
  late final StreamSubscription<List<ConnectivityResult>> connectivitySub;
  bool wasOffline = false;
  Timer? connectivityDebounce;
  connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
    connectivityDebounce?.cancel();
    connectivityDebounce = Timer(const Duration(milliseconds: 1500), () {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (!hasConnection) {
        wasOffline = true;
        firestore.disableNetwork().catchError((_) {});
        debugPrint('📴 Connectivity lost — Firestore network disabled');
      } else {
        if (wasOffline) {
          wasOffline = false;
          firestore.enableNetwork().catchError((_) {});
          debugPrint('🌐 Connectivity restored — Firestore network enabled');
        }
      }
    });
  });
  // Ensure cleanup on app termination (best-effort in Flutter).
  WidgetsBinding.instance.addObserver(_AppLifecycleObserver(connectivitySub));

  // Use Firebase emulators ONLY when they are actually running (reachable).
  // This works for physical devices, Android emulators, and iOS simulators.
  if (kDebugMode && !kIsWeb) {
    try {
      final String emulatorHost = Platform.isAndroid ? '10.0.2.2' : 'localhost';
      final bool emulatorRunning = await _isEmulatorRunning(emulatorHost, 9099);
      if (emulatorRunning) {
        FirebaseFunctions.instance.useFunctionsEmulator(emulatorHost, 5001);
        FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
        FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8081);
        debugPrint('🔥 Using Firebase emulators at $emulatorHost');
      } else {
        debugPrint('🔥 Using PRODUCTION Firebase (emulators not reachable)');
      }
    } catch (e) {
      debugPrint('Firebase emulator setup error: $e');
    }
  }
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // 1. Load Theme
  final String? theme = prefs.getString('themeMode');
  if (theme != null) {
    themeNotifier.value = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  // 2. Load Balance Visibility
  final bool? isVisible = prefs.getBool('balanceVisibility');
  if (isVisible != null) {
    balanceVisibilityNotifier.value = isVisible;
  }

  // 3. Load locale
  final String? localeCode = prefs.getString(AppLocalizations.localeKey);
  if (localeCode != null && localeCode.isNotEmpty) {
    localeNotifier.value = Locale(localeCode);
  }

  // 4. Determine Initial Route
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // 5. Check Firebase Auth state for email verification
  Widget initialScreen;
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  if (isFirstTime) {
    initialScreen = const Onboarding();
  } else if (firebaseUser != null && !firebaseUser.emailVerified) {
    initialScreen = EmailVerificationPage(email: firebaseUser.email ?? '');
  } else if (isLoggedIn && firebaseUser != null) {
    initialScreen = const MainNavigation();
  } else {
    initialScreen = const Login();
  }

  runApp(MyApp(initialScreen: initialScreen));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, Locale currentLocale, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              locale: currentLocale,
              localeResolutionCallback: (locale, supportedLocales) {
                if (locale == null) return currentLocale;
                for (final supported in supportedLocales) {
                  if (supported.languageCode == locale.languageCode) {
                    return supported;
                  }
                }
                return currentLocale;
              },
              theme: ThemeData(
                brightness: Brightness.light,
                scaffoldBackgroundColor: const Color(0xFFF8F9FA),
                cardColor: Colors.white,
                primaryColor: const Color(0xFF673AB7),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF673AB7),
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
              ),
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                scaffoldBackgroundColor: const Color(0xFF0F111A),
                cardColor: const Color(0xFF1C1F2E),
                primaryColor: const Color(0xFF9575CD),
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF673AB7),
                  brightness: Brightness.dark,
                  surface: const Color(0xFF1C1F2E),
                ),
                useMaterial3: true,
              ),
              themeMode: currentMode,
              home: initialScreen,
            );
          },
        );
      },
    );
  }
}
