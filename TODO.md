# Firebase Network Error Fix - TODO

## Problem
1. `WriteStream Stream error: 'Unavailable: Network connectivity changed'` — Firestore aborts on network transition.
2. `quic_crypto_session_state_serialize TLS ticket does not fit (12137 > 6144)` — iOS QUIC overflow on rapid reconnects.

## Root Causes
- Firestore initialized without cache/persistence settings.
- No network state monitoring to pause/resume Firestore during connectivity changes.
- No retry logic for Firestore writes beyond `initializeUserData`.
- StreamBuilders do not handle `snapshot.hasError` for Firestore streams.

## Steps
- [x] 1. Add `connectivity_plus: ^6.1.4` to `pubspec.yaml`
- [x] 2. Update `lib/main.dart` — Configure Firestore persistence, cache, and network management via connectivity listener
- [x] 3. Update `lib/data/firebase_service.dart` — Add exponential backoff retry helper for all writes
- [x] 4. Update `lib/ui/main/widget/operations.dart` — Handle StreamBuilder errors with retry UI
- [x] 5. Update `lib/ui/main/widget/operations_list.dart` — Handle StreamBuilder errors with retry UI
- [x] 6. Update `lib/ui/submain_page/settings.dart` — Handle StreamBuilder errors with retry UI
- [x] 7. Run `flutter pub get`
- [x] 8. Run `cd ios && pod install --repo-update`

