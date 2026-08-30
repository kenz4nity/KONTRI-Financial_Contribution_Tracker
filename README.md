# 💸 Kontri: Financial Contribution Tracker

> A cross-platform mobile application built with Flutter to streamline and automate group financial contributions (locally known as "Ambagan"). 

Managing group funds for events, outings, or shared bills can be a logistical nightmare. Kontri solves this by providing a clean, offline-first dashboard to track target budgets, automatically calculate individual shares, and monitor partial payments over custom frequencies (daily, weekly, monthly). 

## What's New in v1.1.0

*   Picking a frequency now shows you the exact amount. A ₱10,000 budget running for one month works out to ₱2,500 a week, and each participant sees their own share on their own schedule.
*   Missed payments are counted in pesos. Skip six months of a ₱100 monthly plan and it tells you you're ₱600 behind.
*   You can attach a photo or screenshot as proof of payment.
*   Any plan can be exported as a PDF summary report.
*   The database moved to the maintained `isar_community` fork. Installing over v1.0 keeps everything you already have.

## Current Features

*   **📊 Smart Dashboard & Event Folders:** Create funding events with a target budget, a start date and a deadline. The dashboard shows a progress ring of total funds collected, along with anything currently overdue.
*   **🧮 Auto-Split Math:** Add participants and Kontri divides the target budget evenly between them, recalculating whenever someone joins or leaves.
*   **⏱️ Custom Payment Frequencies:** Give each participant their own schedule (`1-Time`, `Daily`, `Weekly`, or `Monthly`), and the app works out what a single period costs them.
*   **🚨 Missed Payment Alerts:** Anyone falling behind is flagged with the amount they owe and how many payments that represents.
*   **💰 Partial Payment Tracking:** Log partial payments using one-tap amounts for a single period, the catch-up total, or the full balance. Every contribution is kept as a timestamped entry you can review or delete.
*   **📎 Proof of Payment:** Attach a receipt photo or screenshot to any payment, then tap it for a full-screen, zoomable view.
*   **📄 PDF Reports:** Export a plan as a summary report to share with the group, with the option to include the attached proof images.
*   **⚡ Offline-First Architecture:** Powered entirely by **Isar**, ensuring fast reads/writes and zero reliance on internet connectivity.
*   **🌗 Light and Dark Themes:** An iOS-flavoured interface that follows whichever you prefer.

## Tech Stack

*   **Framework:** Flutter (Dart)
*   **Database:** [`isar_community`](https://pub.dev/packages/isar_community) (maintained fork of Isar, local NoSQL)
*   **Platform Target:** Android (iOS & Windows ready)
*   **Key Plugins:** `pdf`, `printing`, `image_picker`, `device_calendar`, `flutter_launcher_icons`

## Project Structure

v1.0 was a single 1,400-line `main.dart`. v1.1 splits it into modules:

```
lib/
├── logic/      Contribution maths, kept in pure Dart so it can be unit tested
├── models/     Isar collections
├── data/       Database setup, the v1.0 migration, and every write
├── services/   PDF export, proof-image storage, calendar sync
├── screens/    Dashboard, folder detail, PDF preview, proof viewer
├── widgets/    Shared sheets, buttons and badges
└── theme/      Colours, type and spacing
```

## Future Roadmap (Scaling Plans)

While Kontri is currently an offline powerhouse, the next evolution of the app will focus on connectivity and seamless group collaboration:

- [x] **Export Options:** Generating downloadable PDF reports for group transparency. *(done in v1.1.0)*
- [ ] **CSV / Excel Export:** Spreadsheet-friendly output alongside the PDF.
- [ ] **Real-Time Cloud Sync:** Transitioning the local Isar database to a cloud backend (like Firebase or Supabase) to allow live data syncing across multiple devices.
- [ ] **Collaborative Group Viewing:** Allowing participants to download the app, join a specific folder via an invite link or code, and view their remaining balances in real-time.
- [ ] **Push Notifications:** Automated server-side reminders sent to participants when their daily, weekly, or monthly contribution is due.
- [ ] **Direct Payment Integrations:** Linking digital wallets (like Maya or GCash) via deep links/APIs so users can pay their remaining balance directly through the app.

## Download the App (Android APK)

Don't want to build it from source? You can download the latest Android release directly to test the features!  

👉 **[Download Kontri v1.1.0 (Android APK) via Google Drive](https://drive.google.com/drive/folders/1ML-N9TngdjvYb-jifTTa4hKayb401MhV?usp=sharing)**

*Note: You may need to enable "Install from Unknown Sources" in your Android settings to install the app directly from the downloaded file.*

Already running v1.0? Install v1.1.0 straight over it and your plans, participants and payments carry across. Don't uninstall first, as that clears the local database.

## Running the Project Locally  

If you want to clone and run this project on your own machine:

1. Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.

2. Clone this repository:

   ```bash
   git clone https://github.com/kenz4nity/KONTRI-Financial_Contribution_Tracker.git
   cd KONTRI-Financial_Contribution_Tracker
   ```

3. Install the dependencies and run it:

   ```bash
   flutter pub get
   flutter run
   ```

To build an installable APK, use `flutter build apk --split-per-abi`. The per-device APKs it produces are much smaller than the single combined one.

The generated Isar code in `lib/models/` is committed, so a fresh clone builds as-is. If you change anything in there, regenerate it with `dart run build_runner build --delete-conflicting-outputs`.

Run the tests with `flutter test`.
