# Mostafa Salama — Flutter Delivery Driver Mobile Application

<p align="center">
  <img src="assets/images/logo_preview.png" alt="Mostafa Salama Logo" width="120" onerror="this.style.display='none'"/>
  <br/>
  <b>Official Mobile Application Exclusively for Delivery Drivers of Mostafa Salama Restaurant</b>
  <br/>
  <i>تطبيق مناديب وسائقي التوصيل الرسمي لمطعم مصطفى سلامة</i>
</p>

---

## 🌟 Overview

This Flutter application is built exclusively for the delivery drivers of the **Mostafa Salama** restaurant, integrating directly with the existing Laravel backend and production website ([https://mostafasalama.com](https://mostafasalama.com)).

### Key Principles
- **Single Source of Truth:** Direct integration with the existing Laravel backend and Sanctum authentication. Driver accounts are provisioned exclusively via the Restaurant Admin Dashboard (`/admin/delivery`).
- **Zero Duplicate Infrastructure:** Does not create separate databases or registration systems.
- **Strict Brand Fidelity:** Replicates the official visual identity of Mostafa Salama (Golden Amber `#F5A900`, Deep Charcoal `#08090B`, `#15171A`, and Cairo typography).
- **Full Bilingual RTL/LTR Support:** Seamlessly localized in **Arabic (العربية)** and **English** with instant switching.
- **High-Security QR Delivery Confirmation:** Camera scanner powered by `mobile_scanner` with pessimistic double-scan prevention and backend HMAC token validation.

---

## 🏗️ Technical Architecture

```
lib/
├── core/
│   ├── constants/
│   │   ├── api_constants.dart          # Endpoints, error codes, and timeouts
│   │   ├── app_colors.dart             # Official Mostafa Salama color palette
│   │   └── app_strings.dart
│   ├── errors/
│   │   └── app_exception.dart          # Structured error handling & localized errors
│   ├── localization/
│   │   ├── app_localizations.dart      # Full Arabic & English string dictionaries
│   │   └── app_language_provider.dart  # Dynamic runtime language switcher (RTL/LTR)
│   ├── network/
│   │   ├── api_client.dart             # Centralized Dio HTTP service
│   │   └── auth_interceptor.dart       # Sanctum token injection & auto-expiry handler
│   ├── storage/
│   │   └── storage_service.dart        # Encrypted storage (FlutterSecureStorage + SharedPreferences)
│   ├── theme/
│   │   └── app_theme.dart              # Official Dark (default) & Light Material 3 themes
│   └── utils/
│       └── app_formatters.dart         # Currency (EGP), dates, phone dialer, and Google Maps
├── features/
│   ├── auth/
│   │   ├── login_screen.dart           # Driver credentials login & validation
│   │   └── change_password_dialog.dart # Mandatory first-login & profile password updater
│   ├── dashboard/
│   │   ├── dashboard_screen.dart       # Main command center with live metrics
│   │   └── widgets/
│   │       ├── stat_card.dart          # Counter card widget
│   │       ├── order_card.dart         # Order delivery card with direct quick actions
│   │       ├── status_filter_bar.dart  # Horizontal category filter tabs
│   │       └── empty_orders_view.dart  # Empty state view
│   ├── orders/
│   │   ├── order_details_screen.dart   # Full order details & lifecycle action bar
│   │   └── widgets/
│   │       ├── order_status_timeline.dart # Lifecycle progress stepper
│   │       ├── customer_info_card.dart    # Customer contact & 1-tap call/maps
│   │       ├── order_items_list.dart      # Kitchen item breakdown & quantities
│   │       └── order_summary_card.dart    # Subtotal, delivery fee, notes, & payment
│   ├── profile/
│   │   └── profile_screen.dart         # Driver profile, stats, language & theme toggles
│   └── qr_scanner/
│       ├── qr_scanner_screen.dart      # High-performance mobile scanner with laser overlay
│       ├── delivery_success_screen.dart # Drop-off confirmation receipt & celebration
│       └── widgets/
│           └── scanner_overlay_painter.dart # Golden corner brackets & animated scan beam
├── models/
│   ├── driver_model.dart               # Authenticated driver entity
│   ├── order_model.dart                # Order, Customer, and OrderItem models
│   ├── delivery_stats_model.dart       # Driver operational performance counters
│   └── api_response_model.dart         # Generic API response and pagination wrapper
├── providers/
│   ├── auth_provider.dart              # Authentication & session lifecycle state
│   ├── orders_provider.dart            # Assigned orders, search, and filtering
│   ├── order_details_provider.dart     # Single order management
│   ├── qr_scanner_provider.dart        # QR debounce, token extraction, and submission
│   └── theme_provider.dart             # Dark/Light mode state management
├── shared/
│   └── widgets/
│       ├── app_button.dart             # Primary action button with loading states
│       ├── app_text_field.dart         # Input fields with visibility toggles
│       ├── brand_logo.dart             # Restaurant crest and typography
│       ├── confirm_dialog.dart         # Confirmation modal dialog
│       └── status_badge.dart           # Pill-shaped order status badge
└── main.dart                           # App root, MultiProvider registration, and AuthGate
```

---

## 📡 API Endpoints Integration

| Action | Method | Endpoint | Description |
| :--- | :--- | :--- | :--- |
| **Login** | `POST` | `/api/delivery/login` | Authenticates driver, issues Bearer token |
| **Logout** | `POST` | `/api/delivery/logout` | Revokes current Sanctum token |
| **Driver Profile & Stats** | `GET` | `/api/delivery/me` | Retrieves driver info and operational stats |
| **Change Password** | `POST` | `/api/delivery/change-password` | Updates driver password |
| **List Orders** | `GET` | `/api/delivery/orders` | Retrieves assigned orders with filtering |
| **Order Details** | `GET` | `/api/delivery/orders/{id}` | Full order breakdown and customer data |
| **Accept Order** | `POST` | `/api/delivery/orders/{id}/accept` | Advances status to `preparing` |
| **Start Delivery** | `POST` | `/api/delivery/orders/{id}/start` | Advances status to `out_for_delivery` |
| **Confirm QR Delivery** | `POST` | `/api/delivery/orders/confirm-qr` | Finalizes delivery via customer QR scan |

---

## 📲 Order Lifecycle Progression

```
[ pending / confirmed ] ──> ( Driver Accepts ) ──> [ preparing ]
                                                       │
                                            ( Driver Starts Trip )
                                                       ▼
[ delivered ] <── ( Driver Scans Customer QR ) <── [ out_for_delivery ]
```

---

## 🚀 Setup & Execution Guide

### Prerequisites
1. **Flutter SDK:** Flutter 3.11+ / Dart 3.11+ installed and configured on your machine.
2. **Android Studio / Xcode** for emulator and physical device deployment.

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run Unit & Model Tests
```bash
flutter test test/delivery_app_test.dart
```

### 3. Run Static Code Analyzer
```bash
flutter analyze lib
```
*(Code is verified with 0 errors and 0 warnings!)*

### 4. Run on Device / Emulator
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

---

## 📦 Build Instructions

### Android Build (APK & AAB)

#### 1. Build Production Split or Universal APK
```bash
# Universal APK (ideal for direct testing/installation)
flutter build apk --release

# Split APKs (reduced download size per CPU architecture)
flutter build apk --split-per-abi --release
```
Output location:
`build/app/outputs/flutter-apk/app-release.apk`

#### 2. Build Google Play App Bundle (AAB)
```bash
flutter build appbundle --release
```
Output location:
`build/app/outputs/bundle/release/app-release.aab`

---

### iOS Build

#### 1. Build iOS Archive (on macOS)
```bash
flutter build ipa --release
```
Output location:
`build/ios/ipa/MostafaSalamaDelivery.ipa`

#### 2. Open in Xcode for Code Signing
```bash
open ios/Runner.xcworkspace
```
1. Select your target: **Runner**.
2. Go to **Signing & Capabilities**.
3. Select your **Team** and Provisioning Profile.
4. Product -> Archive -> Distribute App.

---

## 🔔 Push Notifications (Firebase Cloud Messaging)

If Firebase Cloud Messaging (FCM) is configured in your Laravel backend:
1. Place `google-services.json` in `android/app/`.
2. Place `GoogleService-Info.plist` in `ios/Runner/`.
3. Add `firebase_messaging` to `pubspec.yaml`.
4. When a notification with `{ "order_id": 42 }` is tapped, route directly to `OrderDetailsScreen(orderId: 42)`.

---

## 🛡️ Security Features
- **Zero Local DB Mutation:** Order state is never mutated locally without authoritative backend validation.
- **Race Condition Immunity:** Double-scan prevention locks UI and camera stream simultaneously during verification.
- **Secure Token Storage:** All authentication tokens are stored in Android Keystore / iOS Keychain via `flutter_secure_storage`.
- **Role Isolation:** Backend restricts access solely to authenticated delivery drivers.

---

<p align="center">
  <b>Mostafa Salama Restaurant (مطعم مصطفى سلامة)</b><br/>
  © 2026 All Rights Reserved
</p>
