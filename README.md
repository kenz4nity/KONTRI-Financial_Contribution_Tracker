# 💸 Kontri: Financial Contribution Tracker

> A cross-platform mobile application built with Flutter to streamline and automate group financial contributions (locally known as "Ambagan"). 

Managing group funds for events, outings, or shared bills can be a logistical nightmare. Kontri solves this by providing a clean, offline-first dashboard to track target budgets, automatically calculate individual shares, and monitor partial payments over custom frequencies (daily, weekly, monthly). 

## Current Features

*   **📊 Smart Dashboard & Event Folders:** Create custom funding events with specific target budgets and deadlines. The dashboard provides a visual progress ring of total collected funds across all events.
*   **🧮 Auto-Split Math:** Simply add participants to an event, and Kontri automatically recalculates and evenly divides the target budget among everyone involved.
*   **⏱️ Custom Payment Frequencies:** Assign participants specific payment schedules (`1-Time`, `Daily`, `Weekly`, or `Monthly`). 
*   **🚨 Missed Payment Alerts:** The app calculates the time passed since a user was added. If they fall behind their chosen frequency, their card automatically highlights red and displays the exact number of missed payments.
*   **💰 Partial Payment Tracking:** Log partial payments easily. The app maintains a timestamped history of every drop-in contribution.
*   **📅 Calendar Integration:** Automatically pushes logged payments as events to the device's native calendar for seamless personal tracking.
*   **⚡ Offline-First Architecture:** Powered entirely by **Isar Database**, ensuring lightning-fast reads/writes and zero reliance on internet connectivity for current features.

## Tech Stack

*   **Framework:** Flutter (Dart)
*   **Database:** Isar (High-performance local NoSQL database)
*   **Platform Target:** Android (iOS & Windows ready)
*   **Key Plugins:** `device_calendar`, `flutter_launcher_icons`

## Future Roadmap (Scaling Plans)

While Kontri is currently an offline powerhouse, the next evolution of the app will focus on connectivity and seamless group collaboration:

- [ ] **Real-Time Cloud Sync:** Transitioning the local Isar database to a cloud backend (like Firebase or Supabase) to allow live data syncing across multiple devices.
- [ ] **Collaborative Group Viewing:** Allowing participants to download the app, join a specific folder via an invite link or code, and view their remaining balances in real-time.
- [ ] **Push Notifications:** Automated server-side reminders sent to participants when their daily, weekly, or monthly contribution is due.
- [ ] **Direct Payment Integrations:** Linking digital wallets (like Maya or GCash) via deep links/APIs so users can pay their remaining balance directly through the app.
- [ ] **Export Options:** Generating downloadable CSV or PDF reports for group transparency.

## Download the App (Android APK)

Don't want to build it from source? You can download the latest Android release directly to test the features!  

👉 **[Download Kontri_v1.0.apk via Google Drive](https://drive.google.com/drive/folders/1ML-N9TngdjvYb-jifTTa4hKayb401MhV?usp=sharing)**

*Note: You may need to enable "Install from Unknown Sources" in your Android settings to install the app directly from the downloaded file.*

## Running the Project Locally  

If you want to clone and run this project on your own machine:

1. Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2. Clone this repository:
   ```bash
   git clone [https://github.com/kenz4nity/KONTRI-Financial_Contribution_Tracker.git](https://github.com/kenz4nity/KONTRI-Financial_Contribution_Tracker.git)