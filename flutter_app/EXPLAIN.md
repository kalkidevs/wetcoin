# Sweatcoin Clone MVP - Project Documentation

## Project Goal & Scope

**Sweatcoin Clone MVP** is a Flutter-based mobile application that replicates the core functionality of the popular Sweatcoin app. The application allows users to:

- **Track Steps**: Automatically sync daily step counts from device health APIs (Health Connect on Android, HealthKit on iOS).
- **Earn Coins**: Convert steps into virtual currency (SWC) at a configurable rate (1 coin per 100 steps, max 150 coins/day).
- **Redeem Rewards**: Browse and redeem virtual coins for physical rewards.
- **View Wallet**: Track coin balance and transaction history.
- **User Authentication**: Secure login via Google Sign-In.

**Scope**: This is an MVP focused on core step tracking, coin earning, and reward redemption. It includes a Flutter frontend and Firebase backend (Firestore + Cloud Functions).

## Technology Stack Summary

### Frontend (Flutter)
- **Framework**: Flutter 3.1+ (Dart SDK)
- **State Management**: Riverpod (Provider pattern)
- **Architecture**: Clean Architecture (Presentation, Domain, Data layers)
- **UI/UX**: Custom design system with Material 3, Lottie animations, gradient backgrounds
- **Key Packages**:
  - `flutter_riverpod`: State management
  - `firebase_auth`, `cloud_firestore`, `cloud_functions`: Firebase integration
  - `health`: Health Connect/HealthKit integration
  - `pedometer`: Real-time step tracking fallback
  - `lottie`: Animated assets
  - `flutter_animate`: Micro-animations
  - `cached_network_image`: Image caching
  - `workmanager`: Background sync
  - `google_sign_in`: Authentication
  - `fpdart`: Functional programming (Either monad for error handling)

### Backend (Firebase)
- **Authentication**: Firebase Auth (Google Sign-In)
- **Database**: Cloud Firestore (NoSQL)
- **Serverless Functions**: Firebase Cloud Functions (Node.js/TypeScript)
- **Storage**: Firestore collections for users, rewards, orders, wallet transactions
- **Background Processing**: WorkManager for periodic sync tasks

### Development Tools
- **Environment**: `.env` configuration
- **Code Quality**: `analysis_options.yaml` with lints
- **Build**: Standard Flutter build system

## Current State Analysis (What's Working Well)

### ✅ Successfully Implemented

1. **Robust Authentication Flow**
   - Google Sign-In integration with proper error handling
   - User document creation on first login
   - Auth state management with Riverpod
   - Secure token handling

2. **Step Tracking & Health Integration**
   - Health Connect (Android) and HealthKit (iOS) integration
   - Pedometer fallback for real-time updates
   - Permission handling and user guidance
   - Daily step aggregation

3. **Backend Sync System**
   - Cloud Function `syncSteps` with comprehensive validation
   - Rate limiting and duplicate prevention
   - Device ID tracking for security
   - Timestamp validation to prevent replay attacks
   - Proper transaction handling for atomic operations

4. **Reward System**
   - Reward catalog management via Firestore
   - Redemption workflow with order creation
   - Stock management and validation
   - Transaction logging

5. **Wallet & Transaction History**
   - Real-time balance updates
   - Transaction ledger with earn/spend categorization
   - Pagination support for history

6. **UI/UX Excellence**
   - Custom design system with consistent theming
   - Smooth animations and micro-interactions
   - Responsive layouts with proper spacing
   - Loading states and error handling
   - Dark/light theme support

7. **State Management Architecture**
   - Clean separation of concerns
   - Provider pattern for dependency injection
   - Async state management for data fetching
   - Error handling with Failure types

8. **Background Processing**
   - WorkManager integration for periodic sync
   - Proper initialization and task registration

## Critical Issues & Risks (What's Wrong/Will Not Work)

### 🔴 **Critical Issues**

1. **Missing Use Case Implementations**
   - `GetActiveRewards` use case class is missing
   - `RedeemReward` use case implementation incomplete
   - Domain layer interfaces not fully implemented

2. **Provider Dependencies Not Resolved**
   - `authServiceProvider` referenced but not defined
   - `walletRepositoryProvider` used without proper definition
   - Circular dependencies in provider chain

3. **Incomplete Data Models**
   - Reward model lacks proper fromJson/toJson serialization
   - Missing error handling in data conversion
   - No validation for reward data integrity

4. **Backend Function Issues**
   - `getWallet` function returns incorrect field name (`data` vs `transactions`)
   - Missing error handling for Firestore permission issues
   - No validation for reward stock updates

### 🟡 **Architecture Problems**

1. **Tight Coupling**
   - Direct Firebase imports in data layer
   - UI components directly accessing repositories
   - Missing abstraction for external services

2. **Error Handling Inconsistencies**
   - Mixed error types (Exceptions vs Failures)
   - Inconsistent error propagation
   - Missing error recovery mechanisms

3. **Security Concerns**
   - No input sanitization in Cloud Functions
   - Missing rate limiting on client side
   - Device ID validation insufficient

### 🟢 **Performance & Maintainability**

1. **Code Quality Issues**
   - Some widgets have mixed concerns (UI + business logic)
   - Missing unit tests
   - Limited integration testing
   - No code generation for models

2. **Scalability Concerns**
   - No pagination for large step history
   - Missing caching strategy for rewards
   - No offline support for step data

## Technical Debt Assessment

### High Priority
- Implement missing use case classes
- Fix provider dependency chain
- Add proper error handling throughout
- Complete data model serialization

### Medium Priority
- Add input validation and sanitization
- Implement proper caching strategy
- Add unit and integration tests
- Improve security measures

### Low Priority
- Code generation for models
- Performance optimization
- Offline support implementation
- Advanced analytics integration

## Recommendations for Next Steps

1. **Complete Core Implementation**
   - Finish use case implementations
   - Fix provider dependencies
   - Add missing error handling

2. **Improve Architecture**
   - Add proper abstraction layers
   - Implement consistent error handling
   - Separate concerns more clearly

3. **Enhance Security**
   - Add input validation
   - Implement proper rate limiting
   - Improve authentication flow

4. **Add Testing**
   - Unit tests for business logic
   - Integration tests for API calls
   - UI tests for critical flows

5. **Performance Optimization**
   - Implement caching
   - Add pagination
   - Optimize image loading

This MVP has a solid foundation with excellent UI/UX and good architectural intentions, but requires completion of core business logic and improved error handling to be production-ready.