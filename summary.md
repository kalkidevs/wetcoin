# Project Summary: Sweatcoin Clone MVP

## What We Implemented

We have built a **Move-to-Earn** mobile application that incentivizes physical activity by converting users' daily steps into a digital currency. This currency can then be used to redeem real-world rewards from an in-app marketplace.

### Key Features:
1.  **Step Tracking & Synchronization**: The app tracks your daily steps using your phone's built-in health sensors (Google Fit on Android, HealthKit on iOS). It automatically syncs this data to our secure server.
2.  **Digital Wallet**: A digital wallet that holds your earned coins. You can view your current balance and a history of all your earnings and spendings.
3.  **Rewards Marketplace**: A section where you can browse available rewards (like gadgets, gift cards, or discounts), view their cost in coins, and redeem them if you have enough balance.
4.  **Secure Authentication**: Users can securely sign up and log in using their Google account.
5.  **Anti-Cheat System**: To ensure fairness, the conversion of steps to coins happens on our secure server, not on the phone. We have logic to prevent adding steps for future dates or backdating steps older than 48 hours.

## How We Implemented It

We used a modern, robust technology stack to ensure the app is fast, reliable, and secure.

### 1. Mobile App (Frontend)
-   **Framework**: We used **Flutter**, which allows the app to run smoothly on both Android and iOS from a single codebase.
-   **Architecture**: We followed **Clean Architecture** principles. This separates the code into three distinct layers:
    -   **Presentation**: What you see on the screen (UI).
    -   **Domain**: The business logic and rules of the app.
    -   **Data**: Handling data from the internet or local storage.
    This structure makes the app easier to test, maintain, and upgrade in the future.
-   **State Management**: We used **Riverpod** to manage the app's state (like user data, wallet balance), ensuring the UI updates instantly when data changes.
-   **Health Integration**: We integrated with the native health systems (Health Connect/Apple Health) to access step count data reliably.

### 2. Backend & Database
-   **Platform**: We used **Firebase**, a powerful backend-as-a-service platform by Google.
-   **Database (Firestore)**: A real-time cloud database to store user profiles, wallet balances, transaction history, and reward inventory.
-   **Server-Side Logic (Cloud Functions)**: This is the "brain" of our security.
    -   When your phone reports steps, it sends them to a **Cloud Function**.
    -   This function verifies the data (checking if the date is valid and reasonable).
    -   It then calculates exactly how many coins you earned (1 coin per 100 steps, capped at 150 coins/day).
    -   Finally, it updates your wallet balance in the database.
    -   **Why this is important**: By doing the math on the server, we prevent users from hacking the app to give themselves unlimited coins.

### 3. Key Workflows
-   **Syncing Steps**: The app runs a background service that periodically checks your steps and sends them to the server, ensuring your balance is up-to-date even if you don't open the app constantly.
-   **Redeeming Rewards**: When you click "Redeem", a secure transaction runs on the server to check if items are in stock and if you have enough coins. If yes, it deducts the coins and creates an order for you.
