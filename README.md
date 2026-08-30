# 💸 Kontri: Financial Contribution Tracker

> A cross-platform mobile application built with Flutter to streamline and automate group financial contributions (locally known as "Ambagan").

Managing group funds for events, outings, or shared bills can be a logistical nightmare. Kontri solves this by providing a clean, offline-first dashboard to track target budgets, automatically calculate individual shares, and monitor partial payments over custom frequencies (daily, weekly, monthly).

**Current version: `1.1.0`**

---

## ✨ What's New in v1.1.0

This release makes the payment frequency actually mean something, and adds evidence and reporting on top of it.

*   **🧮 Automatic Contribution Pace.** Picking a frequency now tells you the exact amount. Set a ₱10,000 budget running for one month and the New Plan sheet shows the pace live as you type — ₱2,500 weekly, ₱322.58 daily, ₱10,000 monthly. Each participant then sees *their own* share at *their own* cadence: ₱625.00 per week, 4 payments, ends Sep 30. Plans now carry a **start date** alongside the deadline, which is what makes "in one month" a number the app can divide.
*   **🚨 Missed Payments in Pesos.** The behind-on-payments warning now reports an amount, not just a count: *"₱600 behind · 6 missed monthly"*. It is derived from money owed rather than the number of times someone tapped Pay, so a single lump sum covering six months settles correctly and five ₱1 payments no longer read as caught up. Totals roll up to the plan and to the dashboard.
*   **📎 Proof of Payment.** Attach a receipt photo or screenshot to any payment, straight from the camera or the photo library. Thumbnails appear in the contribution ledger; tap one for a full-screen, pinch-to-zoom view.
*   **📄 PDF Summary Report.** Export a plan as a formatted PDF — summary figures, a per-participant table with per-period amounts and arrears, and the full payment ledger, with an option to append the proof images. Share, save or print it from the built-in preview.
*   **🗂️ Filter by Status.** Jump between **All / Behind / Paid** on any plan.
*   **🔐 Database Continuity.** Migrated from the unmaintained `isar` package to the community-maintained `isar_community` fork. **Existing data is preserved on upgrade** — the same engine and the same on-disk format, plus a one-time migration that backfills start dates and rebuilds the payment ledger from v1.0 records. This is covered by an automated upgrade probe that writes a database with v1.0's engine and reopens it with v1.1's.

---

## 📱 Current Features

*   **📊 Smart Dashboard & Event Folders:** Create custom funding events with specific target budgets, start dates and deadlines. The dashboard shows a visual progress ring of total collected funds across all events, plus a running total of anything overdue.
*   **🧮 Auto-Split Math:** Add participants to an event and Kontri automatically recalculates and evenly divides the target budget among everyone involved.
*   **⏱️ Custom Payment Frequencies:** Assign participants specific payment schedules (`1-Time`, `Daily`, `Weekly`, or `Monthly`) — each with its own automatically calculated per-period amount.
*   **🚨 Arrears Tracking:** Anyone who falls behind is highlighted with the exact peso amount owed and how many periods it represents.
*   **💰 Partial Payment Tracking:** Log partial payments with one-tap quick amounts (one period, catch-up, or full balance). Every contribution is kept as a structured, timestamped ledger entry.
*   **📎 Payment Proofs:** Photo or screenshot evidence attached per payment, stored locally on the device.
*   **📄 PDF Reports:** Shareable summary reports for group transparency.
*   **⚡ Offline-First Architecture:** Powered entirely by **Isar**, ensuring fast reads/writes and zero reliance on internet connectivity.
*   **🌗 Light & Dark Themes:** An iOS-flavoured Material 3 interface that adapts to either.

---

## 🛠️ Tech Stack

| Layer | Choice |
| --- | --- |
| **Framework** | Flutter (Dart) |
| **Database** | [`isar_community`](https://pub.dev/packages/isar_community) — maintained fork of Isar 3, local NoSQL |
| **PDF** | `pdf` + `printing` (bundled Noto Sans, so `₱` renders correctly) |
| **Images** | `image_picker` |
| **Other** | `device_calendar`, `intl`, `path_provider`, `timezone` |
| **Platform Target** | Android (iOS & Windows ready) |

## 🗂️ Project Structure

v1.1 split the original single-file app into modules:

```
lib/
├── logic/schedule.dart          Pure period/pace/arrears maths (no Flutter imports — unit tested)
├── models/                      Isar collections: ContriFolder, Participant, PaymentRecord, AppMeta
├── data/
│   ├── isar_service.dart        Database open + one-time v1.0 → v1.1 migration
│   └── contribution_repository.dart  Every database write; single source of the split rule
├── services/                    PDF report, proof-image storage, calendar sync
├── screens/                     Dashboard, folder detail, PDF preview, proof viewer
├── widgets/                     Shared sheet chrome, buttons, pace + arrears widgets
└── theme/app_theme.dart         Colour, type and radius tokens
```

---

## 🧪 Testing

```bash
flutter test
```

52 tests cover the contribution maths, the v1.0 → v1.1 database migration, PDF generation, and the widgets that display the new figures.

There is also a two-step **upgrade probe** that verifies a database written by v1.0's Isar engine still opens under v1.1's. It runs as two processes because the native core can only be initialised once per process:

```bash
flutter test tool/upgrade_probe/step1_write_with_v1_engine_test.dart
flutter test tool/upgrade_probe/step2_read_with_v11_engine_test.dart
```

---

## 🚀 Future Roadmap (Scaling Plans)

While Kontri is currently an offline powerhouse, the next evolution of the app will focus on connectivity and seamless group collaboration:

- [x] **PDF Export:** Downloadable summary reports for group transparency. *(v1.1.0)*
- [ ] **CSV / Excel Export:** Spreadsheet-friendly output alongside the PDF.
- [ ] **Real-Time Cloud Sync:** Transitioning the local Isar database to a cloud backend (like Firebase or Supabase) to allow live data syncing across multiple devices.
- [ ] **Collaborative Group Viewing:** Allowing participants to download the app, join a specific folder via an invite link or code, and view their remaining balances in real-time.
- [ ] **Push Notifications:** Automated server-side reminders sent to participants when their daily, weekly, or monthly contribution is due.
- [ ] **Direct Payment Integrations:** Linking digital wallets (like Maya or GCash) via deep links/APIs so users can pay their remaining balance directly through the app.

## ⚠️ Known Limitations

*   **Calendar sync is currently inactive.** The code that mirrors payments into the device calendar is present, but `READ_CALENDAR`/`WRITE_CALENDAR` are not declared in the Android manifest and the `NSCalendars*` keys are absent from `Info.plist`, so the write is refused on both platforms. The failure is now logged rather than silently swallowed.
*   **Release builds are signed with the debug keystore** and the application ID is still `com.example.kontri_financial_contribution_tracker`. Both need addressing before a Play Store listing.

---

## 📥 Download the App (Android APK)

Don't want to build it from source? You can download the latest Android release directly to test the features!

👉 **[Download Kontri v1.1.0 (Android APK) via Google Drive](https://drive.google.com/drive/folders/1ML-N9TngdjvYb-jifTTa4hKayb401MhV?usp=sharing)**

*Note: You may need to enable "Install from Unknown Sources" in your Android settings to install the app directly from the downloaded file.*

> Installing v1.1.0 over an existing v1.0 install keeps all of your existing plans, participants and payments. Do **not** uninstall first — uninstalling clears the local database.

---

## 💻 Running the Project Locally

If you want to clone and run this project on your own machine:

1. Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

2. Clone this repository:

   ```bash
   git clone https://github.com/kenz4nity/KONTRI-Financial_Contribution_Tracker.git
   cd KONTRI-Financial_Contribution_Tracker
   ```

3. Fetch the dependencies:

   ```bash
   flutter pub get
   ```

4. Run the app on a connected device or emulator:

   ```bash
   flutter run
   ```

### Regenerating database code

The Isar collection code (`lib/models/*.g.dart`) is committed to the repository, so a plain checkout builds without it. If you change anything inside `lib/models/`, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Building a release

```bash
flutter build appbundle          # for the Play Store
flutter build apk --split-per-abi  # smaller per-device APKs for direct distribution
```

A single fat APK (`flutter build apk --release`) is around 63 MB because it bundles native libraries for every ABI; the split builds are substantially smaller.
