# Sweatcoin App - Project Explanation

## What is this project?

This is a **Sweatcoin** mobile application - a fitness app that tracks your steps and rewards you with digital coins for walking. Think of it like a game where you earn points (coins) for being active and walking around.

## Why is the sync button showing an error?

The error message you're seeing:
```
Syncing steps for 2026-02-25: 0
Firebase Functions Error: not-found - NOT_FOUND
syncSteps function not deployed or accessible. Using fallback.
```

**In simple terms:** The app is trying to send your step data to the cloud (like sending a text message), but the "text messaging service" isn't set up yet.

### Technical explanation:
- Your phone tracks steps locally (like writing in a notebook)
- When you tap "Sync", the app tries to send this data to the cloud servers
- The cloud server needs special programs called "Firebase Functions" to receive this data
- These programs haven't been uploaded to the cloud yet
- So the app can't send the data, but it won't crash - it just shows a warning

### What this means for you:
- ✅ The app still tracks your steps locally
- ✅ You can still see your progress and stats
- ❌ Steps won't be saved to the cloud (if you uninstall the app, you might lose data)
- ❌ You won't earn coins until this is fixed

## Project Structure Explained

### 📱 **Flutter App (flutter_app/)**
This is the main mobile application that users interact with.

#### **Core Files:**
- **`main.dart`** - The starting point of the app (like the front door of a house)
- **`app.dart`** - Sets up the overall app structure and navigation
- **`pubspec.yaml`** - Lists all the libraries and dependencies the app needs (like a shopping list)

#### **Theme & Design (core/theme/)**
- **`app_colors.dart`** - Defines all the colors used in the app
- **`app_theme.dart`** - Sets up fonts, button styles, and overall look
- **`app_typography.dart`** - Controls text sizes and fonts

#### **Features (features/)**
The app is organized into different features:

##### **1. Health Sync (health_sync/)**
- **What it does:** Tracks your steps and syncs with the cloud
- **Key files:**
  - `sync_service.dart` - Handles sending step data to cloud (this is where the error is)
  - `health_service.dart` - Talks to your phone's step counter
  - `home_screen.dart` - The main dashboard you see when you open the app

##### **2. Authentication (auth/)**
- **What it does:** Handles user login and registration
- **Key files:**
  - `login_screen.dart` - The login page
  - `auth_wrapper.dart` - Checks if user is logged in

##### **3. Rewards (rewards/)**
- **What it does:** Shows what you can buy with your earned coins
- **Key files:**
  - `rewards_screen.dart` - Shows available rewards
  - `redeem_reward.dart` - Handles purchasing rewards

##### **4. Profile (profile/)**
- **What it does:** Shows user information and settings
- **Key files:**
  - `profile_screen.dart` - User profile page

##### **5. Wallet (wallet/)**
- **What it does:** Shows your coin balance and transaction history
- **Key files:**
  - `wallet_screen.dart` - Shows your coin balance

##### **6. Orders (orders/)**
- **What it does:** Tracks purchases made with coins

#### **Shared Components (shared/widgets/)**
Reusable building blocks used throughout the app:
- **`app_card.dart`** - Styled containers for displaying information
- **`animated_progress_circle.dart`** - The circular progress bar showing step goals
- **`animated_gradient_background.dart`** - Animated background effects
- **`app_loading_animation.dart`** - Loading spinners and animations

### ☁️ **Firebase Functions (functions/)**
This is the "cloud brain" of the app that runs on Google's servers.

#### **What it does:**
- Receives step data from users' phones
- Calculates how many coins users earn
- Stores user data securely
- Handles purchases and rewards

#### **Key files:**
- **`index.ts`** - Contains all the cloud functions:
  - `syncSteps` - Receives step data (this is the one causing the error)
  - `redeemReward` - Handles reward purchases
  - `getWallet` - Retrieves user's coin balance

## How the App Works (Step by Step)

### 1. **User Opens App**
- App checks if user is logged in
- If not, shows login screen
- If yes, shows main dashboard

### 2. **Step Tracking**
- App asks phone for step data
- Shows steps in circular progress bar
- Calculates calories burned, distance walked
- Updates in real-time

### 3. **Syncing Steps**
- User taps "Sync" button
- App tries to send step data to cloud
- Cloud calculates coins earned
- Updates user's balance

### 4. **Earning Coins**
- Every 100 steps = 1 coin
- Maximum 150 coins per day (15,000 steps)
- Coins added to user's wallet

### 5. **Redeeming Rewards**
- User browses available rewards
- Selects reward and confirms purchase
- App deducts coins from wallet
- Order is processed

## Current Problem & Solution

### **Problem:**
The "syncSteps" function in the cloud isn't deployed, so users can't earn coins.

### **Temporary Fix (Already Applied):**
- App won't crash when sync fails
- Shows friendly error message
- Continues to track steps locally

### **Permanent Solution:**
1. Upgrade Firebase project to paid plan
2. Deploy the cloud functions
3. Users can then sync and earn coins

## Files Modified to Fix the Error

### **1. sync_service.dart**
- Added error handling for when cloud function isn't available
- App now gracefully handles the "not found" error
- Returns fallback response instead of crashing

### **2. home_screen.dart**
- Updated sync button to show user-friendly error messages
- Different messages for different types of errors
- Maintains app functionality even when sync fails

## Summary for Non-Technical Users

Think of this app like a **fitness game**:

1. **You walk** → **App tracks steps** → **You earn coins**
2. **You sync** → **Coins saved to cloud** → **You can spend them**
3. **Current issue:** The "save to cloud" part isn't working yet
4. **Good news:** The app still tracks your steps and won't crash
5. **Next step:** Developer needs to set up the cloud service

The error message you see is just the app telling you: "I tried to save your steps to the cloud, but that service isn't ready yet. Don't worry, I'm still tracking your steps locally!"