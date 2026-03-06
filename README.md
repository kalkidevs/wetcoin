<div align="center">

# 🏃 Sweatcoin India

### Walk. Earn. Redeem.

**Turn your daily steps into real rewards.**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?logo=mongodb&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth-FFCA28?logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-blue)

</div>

---

## 🌟 What is Sweatcoin India?

Sweatcoin India is a **fitness rewards app** that converts your daily walking steps into **SWC coins** — redeemable for real products and offers. Built with a modern Flutter frontend and a robust Node.js backend, it integrates with **Google Fit / Health Connect** (Android) and **Apple Health** (iOS) to track your activity seamlessly.

> 💡 **The idea is simple:** Walk more → Earn more → Redeem rewards.

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🚶 **Step Tracking** | Auto-syncs with Google Fit / Health Connect / Apple Health |
| 🪙 **Coin Earning** | Earn 1 SWC for every 100 steps (max 150/day) |
| 🎁 **Rewards Store** | Browse and redeem coins for real products |
| 💰 **Wallet** | Track balance, transaction history, lifetime stats |
| 🏆 **Achievements** | Milestone badges from First Steps (1K) to Legend (100K) |
| 🌙 **Dark Mode** | Beautiful dark theme with Lottie toggle animation |
| 🔐 **Google Sign-In** | Secure authentication via Firebase + JWT backend |
| 📊 **Weekly Trends** | 7-day step history chart |

---

## 📱 Screenshots

> *Run the app to see the premium UI with gradient hero headers, glassmorphic cards, animated progress rings, and smooth transitions.*

---

## 🏗️ Tech Stack

### Frontend (Flutter)
- **State Management:** Riverpod
- **Animations:** flutter_animate + Lottie
- **Health Data:** `health` package (Health Connect + Apple Health)
- **Auth:** Firebase Auth (Google Sign-In)
- **HTTP:** http package with JWT token management

### Backend (Node.js)
- **Framework:** Express.js
- **Database:** MongoDB Atlas (Mongoose ODM)
- **Auth:** Firebase Admin SDK + JWT
- **API:** RESTful with paginated endpoints

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.x+)
- Node.js (18+)
- MongoDB Atlas account
- Firebase project with Auth enabled

### 1. Clone the repo
```bash
git clone https://github.com/your-username/sweatcoin-india.git
cd sweatcoin-india
```

### 2. Backend Setup
```bash
cd backend
npm install
```

Create a `.env` file in `backend/`:
```env
PORT=3000
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret
```

Place your Firebase service account key at `backend/serviceAccountKey.json`.

```bash
npm start
```

### 3. Flutter Setup
```bash
cd flutter_app
flutter pub get
```

Create a `.env` file in `flutter_app/`:
```env
API_BASE_URL=http://your-server-ip:3000
```

```bash
flutter run
```

---

## 📂 Project Structure

```
sweatcoin/
├── backend/                    # Node.js REST API
│   ├── models/                 # Mongoose schemas (User, Transaction, Reward, Order)
│   ├── routes/                 # API routes (auth, sync, wallet, rewards)
│   ├── middleware/              # JWT authentication middleware
│   └── server.js               # Express entry point
│
├── flutter_app/                # Flutter mobile app
│   └── lib/
│       ├── core/               # Theme, design system, services
│       │   ├── theme/          # Colors, typography, design tokens
│       │   └── services/       # API service, connection service
│       ├── features/           # Feature modules
│       │   ├── auth/           # Google Sign-In + JWT auth
│       │   ├── health_sync/    # Step tracking + sync
│       │   ├── wallet/         # Coin balance + transactions
│       │   ├── rewards/        # Reward browsing + redemption
│       │   ├── profile/        # User profile + settings
│       │   └── orders/         # Order tracking
│       └── shared/             # Reusable widgets
│
└── README.md
```

---

## 🔌 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/auth/verify-token` | Verify Firebase token → issue JWT |
| `POST` | `/api/sync` | Sync daily steps + earn coins |
| `GET` | `/api/wallet/balance` | Get coin balance + lifetime stats |
| `GET` | `/api/wallet/transactions` | Paginated transaction history |
| `GET` | `/api/rewards` | List available rewards |
| `POST` | `/api/rewards/redeem` | Redeem coins for a reward |

All endpoints (except auth) require `Authorization: Bearer <JWT>` header.

---

## 🎨 Design Philosophy

- **Premium Aesthetic** — Gradient hero headers, glassmorphic cards, animated progress rings
- **Google Fit Inspired** — Clean layout, strong visual hierarchy, metric-focused
- **Indian Design Accents** — Warm saffron tones, gold coin colors, vibrant gradients
- **60fps Performance** — Optimized animations with flutter_animate, no jank

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ by [TheGujaratStore.com](https://thegujaratstore.com)

**⭐ Star this repo if you found it useful!**

</div>