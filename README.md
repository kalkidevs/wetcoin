<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=180&section=header&text=SweatCoin%20Clone&fontSize=42&fontColor=fff&animation=twinkling&fontAlignY=32&desc=Move-to-Earn%20%7C%20Flutter%20%2B%20Firebase&descAlignY=52&descAlign=50" width="100%"/>

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=for-the-badge&logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![Riverpod](https://img.shields.io/badge/Riverpod-State%20Mgmt-00BCD4?style=for-the-badge&logo=flutter&logoColor=white)](https://riverpod.dev)

<br/>

[![GitHub Stars](https://img.shields.io/github/stars/yourusername/sweatcoin-clone?style=social)](https://github.com/yourusername/sweatcoin-clone/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/yourusername/sweatcoin-clone?style=social)](https://github.com/yourusername/sweatcoin-clone/network/members)
[![GitHub Issues](https://img.shields.io/github/issues/yourusername/sweatcoin-clone)](https://github.com/yourusername/sweatcoin-clone/issues)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

<br/>

> **A full-stack Move-to-Earn mobile application** — convert your daily steps into spendable digital currency and redeem real-world rewards. Built with Flutter, Firebase, and a server-side anti-cheat engine.

<br/>

[Features](#-features) · [Architecture](#-architecture) · [Tech Stack](#-tech-stack) · [Getting Started](#-getting-started) · [Screenshots](#-screenshots) · [Contributing](#-contributing)

</div>

---

## 📖 About the Project

SweatCoin Clone is a production-grade, open-source **Move-to-Earn** app that demonstrates how to build a real-world fitness rewards ecosystem from scratch. It integrates natively with **Apple HealthKit** and **Google Fit**, runs a background sync service, and uses Firebase Cloud Functions to validate step data server-side — preventing fraudulent submissions before any coins are credited.

This project is ideal for Flutter developers who want to explore:
- Deep platform integration (HealthKit / Google Fit)
- Clean Architecture at scale in Flutter
- Serverless backend logic with Firebase Cloud Functions
- Anti-cheat / data validation patterns for fitness apps

---

## ✨ Features

| Feature | Details |
|---|---|
| 👟 **Step Tracking** | Native integration with HealthKit (iOS) and Google Fit (Android) |
| 🔄 **Background Sync** | Persistent background service keeps steps updated even when the app is closed |
| 💰 **Digital Wallet** | Real-time coin balance, transaction history, and animated balance updates |
| 🛍️ **Rewards Marketplace** | Browse and redeem rewards; purchase flow with order confirmation |
| 🔐 **Secure Auth** | Google Sign-In via Firebase Authentication |
| 🛡️ **Anti-Cheat Engine** | Server-side Cloud Functions validate reported steps against historical data |
| 📱 **Cross-Platform** | Runs on iOS and Android from a single codebase |

---

## 🏛️ Architecture

This project follows **Clean Architecture** principles, separating concerns into three distinct layers for maximum testability and scalability.

```
lib/
├── core/                   # App-wide utilities, theme, constants, routing
│   ├── theme/
│   ├── config/
│   └── utils/
│
├── features/               # Self-contained, feature-first modules
│   ├── auth/               # Google Sign-In, session management
│   │   ├── data/           # Firebase Auth data sources & repo impl
│   │   ├── domain/         # Auth entities & use cases
│   │   └── presentation/   # Login screen, auth state notifier
│   │
│   ├── health_sync/        # Step tracking & background sync
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── wallet/             # Coin balance & transaction history
│   ├── rewards/            # Rewards marketplace & browsing
│   └── orders/             # Purchase flow & order management
│
└── shared/                 # Reusable widgets & UI components
```

**Data flow:** `UI → Riverpod Notifier → Use Case → Repository → Data Source (Firebase / HealthKit)`

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| **UI** | Flutter (Dart) | Cross-platform mobile UI |
| **State Management** | Riverpod | Reactive, compile-safe state |
| **Backend** | Firebase Cloud Functions (TypeScript) | Anti-cheat, coin crediting logic |
| **Database** | Cloud Firestore | Real-time NoSQL data sync |
| **Authentication** | Firebase Auth + Google Sign-In | Secure user identity |
| **Health Data** | HealthKit / Google Fit | Native step tracking |
| **Architecture** | Clean Architecture | Separation of concerns |

---

## 📱 Screenshots

| Home | Wallet | Rewards |
|:---:|:---:|:---:|
| <img src="docs/screenshots/home.png" width="200" alt="Home Screen"/> | <img src="docs/screenshots/wallet.png" width="200" alt="Wallet"/> | <img src="docs/screenshots/rewards.png" width="200" alt="Rewards"/> |

> Screenshots coming soon. Run the app locally to see it in action!

---

## 🚀 Getting Started

### Prerequisites

Make sure you have the following installed:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or higher)
- [Dart SDK](https://dart.dev/get-dart) (bundled with Flutter)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Android Studio or Xcode (for emulator/simulator)
- A Firebase project with Blaze (pay-as-you-go) plan *(required for Cloud Functions)*

### Installation

**1. Clone the repository**
```bash
git clone https://github.com/yourusername/sweatcoin-clone.git
cd sweatcoin-clone
```

**2. Install Flutter dependencies**
```bash
cd flutter_app
flutter pub get
```

**3. Configure Firebase**

```bash
# Log in to Firebase
firebase login

# Initialize Firebase in the project
firebase init
```

Then, in the Firebase Console:
- Enable **Authentication** → Google Sign-In
- Enable **Firestore**
- Enable **Cloud Functions**
- Download `google-services.json` → place in `flutter_app/android/app/`
- Download `GoogleService-Info.plist` → place in `flutter_app/ios/Runner/`

**4. Deploy Cloud Functions**
```bash
cd functions
npm install
firebase deploy --only functions
```

**5. Run the app**
```bash
cd flutter_app
flutter run
```

### Health Permissions

- **iOS**: Add `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` to `Info.plist`
- **Android**: Add `android.permission.ACTIVITY_RECOGNITION` to `AndroidManifest.xml`

---

## ⚙️ How the Anti-Cheat System Works

1. The client reports a step count batch to a Firestore collection.
2. A Cloud Function triggers on write and validates the submission:
   - Compares reported steps against previous recorded values.
   - Checks for physiologically impossible step deltas.
   - Cross-references timestamps against session history.
3. If validation passes, coins are credited to the user's wallet atomically.
4. Invalid submissions are flagged and discarded without crediting coins.

---

## 🗺️ Roadmap

- [x] Core step tracking (HealthKit + Google Fit)
- [x] Background sync service
- [x] Digital wallet + transaction history
- [x] Rewards marketplace
- [x] Server-side anti-cheat validation
- [ ] Leaderboard & social challenges
- [ ] Push notifications for milestones
- [ ] Widget support (iOS & Android)
- [ ] Apple Watch / Wear OS companion app

---

## 🤝 Contributing

Contributions are what make the open-source community great. Any contributions you make are **greatly appreciated**.

1. Fork the project
2. Create your feature branch: `git checkout -b feat/amazing-feature`
3. Commit your changes: `git commit -m 'feat: add amazing feature'`
4. Push to the branch: `git push origin feat/amazing-feature`
5. Open a Pull Request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for coding standards and the pull request process.

---

## 📄 License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for more information.

---

## 📬 Contact

**Your Name** · [LinkedIn](https://linkedin.com/in/yourprofile) · [Twitter/X](https://twitter.com/yourhandle) · your.email@example.com

**Project Link:** [https://github.com/yourusername/sweatcoin-clone](https://github.com/yourusername/sweatcoin-clone)

---

<div align="center">

If this project helped you, please consider giving it a ⭐ — it helps others find it!

<img src="https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=100&section=footer" width="100%"/>

</div>
