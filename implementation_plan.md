# Hybrid Home Services Platform — Implementation Plan

## Goal

Design and generate a complete, production-ready, monorepo codebase for a **Managed Hybrid Home Services** platform operating in the Egyptian market. The system consists of four sub-projects:

1. **Customer Mobile App** (Flutter + BLoC)
2. **Technician Mobile App** (Flutter + BLoC)
3. **Backend** (Firebase Cloud Functions + Firestore + GCP)
4. **Admin Dashboard** (React + Vite)

---

## 1. System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      CLIENTS                                │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │ Customer App │  │Technician App│  │ Admin Dashboard  │   │
│  │  (Flutter)   │  │  (Flutter)   │  │  (React + Vite)  │   │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘   │
└─────────┼─────────────────┼────────────────────┼────────────┘
          │                 │                    │
          ▼                 ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                   FIREBASE LAYER                            │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  Firebase    │  │  Firestore  │  │  Cloud Functions    │ │
│  │  Auth (OTP)  │  │  (Realtime) │  │  (Business Logic)   │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │  Cloud       │  │  FCM (Push  │  │  Crashlytics       │ │
│  │  Storage     │  │  Notifs)    │  │  (Monitoring)      │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                   GCP SERVICES                              │
│                                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────────┐ │
│  │ Google Maps  │  │ Cloud Tasks  │  │  Cloud Scheduler   │ │
│  │ Platform API │  │ (Job Queue)  │  │  (Cron Jobs)       │ │
│  └─────────────┘  └──────────────┘  └────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                 EXTERNAL SERVICES                           │
│  ┌─────────────┐  ┌──────────────────────────────────────┐  │
│  │   Paymob    │  │  VictoryLink / Unifonic (SMS OTP)    │  │
│  │  Payments   │  │                                      │  │
│  └─────────────┘  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow Summary

1. **Customer requests a job** → Flutter app sends request to Cloud Function → Function creates `jobs` doc in Firestore → Nearby online technicians are pinged via FCM
2. **Technician accepts** → Cloud Function updates job status → Customer receives real-time update via Firestore listener → Live tracking begins via `tech_telemetry` collection
3. **Invoicing** → Technician creates invoice with live camera receipt → Cloud Function validates → Customer receives approval modal via FCM + Firestore
4. **Payment** → Customer pays via Paymob or cash → Cloud Function processes commission split → Updates wallet balances in `wallets` collection
5. **Admin oversight** → React dashboard reads Firestore via Admin SDK → Manages disputes, users, and financials

---

## 2. Monorepo Project Structure

```
c:\Users\Hassan\StudioProjects\home_repair_services\
├── customer_app/                    # Flutter - Customer Mobile App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/
│   │   │   ├── app.dart
│   │   │   ├── routes.dart
│   │   │   └── theme.dart
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   ├── errors/
│   │   │   ├── network/
│   │   │   ├── utils/
│   │   │   └── widgets/            # Shared widgets
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   ├── data/
│   │   │   │   ├── domain/
│   │   │   │   └── presentation/
│   │   │   ├── home/
│   │   │   ├── booking/
│   │   │   ├── tracking/
│   │   │   ├── receipt/
│   │   │   ├── checkout/
│   │   │   └── profile/
│   │   └── l10n/                   # Arabic/English localization
│   ├── pubspec.yaml
│   └── test/
│
├── technician_app/                  # Flutter - Technician Mobile App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/
│   │   ├── core/
│   │   └── features/
│   │       ├── auth/
│   │       ├── onboarding/         # KYC verification
│   │       ├── dashboard/
│   │       ├── job_alert/
│   │       ├── job_execution/
│   │       ├── invoicing/          # Live camera + invoice
│   │       ├── wallet/
│   │       └── dispute/
│   ├── pubspec.yaml
│   └── test/
│
├── backend/                         # Firebase Cloud Functions
│   ├── functions/
│   │   ├── src/
│   │   │   ├── index.ts
│   │   │   ├── auth/
│   │   │   ├── jobs/
│   │   │   ├── payments/
│   │   │   ├── disputes/
│   │   │   ├── wallet/
│   │   │   ├── notifications/
│   │   │   └── admin/
│   │   ├── package.json
│   │   └── tsconfig.json
│   ├── firestore.rules
│   ├── firestore.indexes.json
│   ├── storage.rules
│   └── firebase.json
│
├── admin_dashboard/                 # React + Vite Web App
│   ├── src/
│   │   ├── main.tsx
│   │   ├── App.tsx
│   │   ├── components/
│   │   ├── pages/
│   │   │   ├── Dashboard.tsx
│   │   │   ├── Users.tsx
│   │   │   ├── Jobs.tsx
│   │   │   ├── Disputes.tsx
│   │   │   └── Finance.tsx
│   │   ├── hooks/
│   │   ├── services/
│   │   └── types/
│   ├── package.json
│   └── vite.config.ts
│
├── shared/                          # Shared Dart models (optional package)
│   ├── lib/
│   │   ├── models/
│   │   └── constants/
│   └── pubspec.yaml
│
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
│
├── README.md
├── Hybrid Home Services Business Model Blueprint.md
└── UI_UX Handoff Brief_ Home Repair App.md
```

---

## 3. Database Design (Firestore)

### Collections

| Collection | Purpose | Key Fields |
|---|---|---|
| `users` | All user profiles | `uid`, `phone`, `email`, `role` (customer/technician/admin), `displayName`, `photoUrl`, `createdAt`, `isActive`, `fcmToken` |
| `technician_profiles` | Extended tech data | `userId`, `specialty[]`, `verificationStatus` (pending/approved/rejected), `idFrontUrl`, `idBackUrl`, `criminalRecordUrl`, `averageRating`, `totalJobs`, `isOnline`, `currentZone` |
| `jobs` | Job lifecycle | `jobId`, `customerId`, `technicianId`, `serviceCategory`, `status` (searching/accepted/en_route/arrived/in_progress/invoiced/approved/completed/disputed/cancelled), `location` (GeoPoint), `addressText`, `voiceNoteUrl`, `inspectionFee`, `laborItems[]`, `materialsCost`, `receiptImageUrl`, `totalAmount`, `platformFee`, `createdAt`, `updatedAt`, `isSurge`, `surgeMultiplier` |
| `tech_telemetry` | Live location | `techId`, `location` (GeoPoint), `geohash`, `heading`, `speed`, `updatedAt` |
| `wallets` | Financial balances | `userId`, `balance`, `creditLimit`, `currency`, `updatedAt` |
| `transactions` | Financial ledger | `walletId`, `userId`, `jobId`, `amount`, `type` (earning/commission/penalty/refund/payout/risk_fund), `description`, `createdAt` |
| `disputes` | Dispute records | `disputeId`, `jobId`, `reportedBy`, `reason`, `status` (open/investigating/resolved), `resolution`, `adminNotes`, `createdAt` |
| `pricing` | Server-controlled prices | `serviceCategory`, `items[]` ({itemId, name, price}), `inspectionFee`, `surgeMultiplier`, `updatedAt` |
| `notifications` | Push notification log | `userId`, `title`, `body`, `type`, `jobId`, `isRead`, `createdAt` |
| `risk_fund` | Platform risk fund | `balance`, `contributions[]`, `payouts[]`, `updatedAt` |

### Indexing Strategy
- `jobs`: Composite index on (`status`, `createdAt` DESC) for active job queries
- `jobs`: Composite index on (`technicianId`, `status`) for technician job history
- `tech_telemetry`: Index on `geohash` for proximity queries
- `transactions`: Composite index on (`walletId`, `createdAt` DESC) for ledger display
- `disputes`: Composite index on (`status`, `createdAt` DESC) for admin dashboard

### Offline Sync
- Firestore's built-in offline persistence enabled on both Flutter apps
- Critical job completion data cached in local SQLite via `sqflite` package
- Background sync service using `workmanager` package for deferred uploads
- Receipt images cached locally, uploaded when connectivity resumes

---

## 4. State Management

**BLoC pattern** for both Flutter apps:
- `flutter_bloc` for state management
- Feature-based BLoCs (AuthBloc, JobBloc, TrackingBloc, WalletBloc, etc.)
- Repository pattern for data layer abstraction
- `freezed` for immutable state/event classes

---

## 5. Critical Feature Implementation

### 5.1 Live Camera Enforcement (No Gallery)
- Use `camera` package directly (NOT `image_picker`)
- Custom camera screen with overlay showing receipt capture guide
- EXIF metadata validation on backend to confirm photo was taken live
- No gallery/file picker integration at all

### 5.2 Read-Only Pricing
- All prices fetched from `pricing` collection in Firestore
- Flutter UI renders prices in disabled/read-only text fields
- Cloud Functions validate submitted prices match server-side values
- No price modification allowed on client

### 5.3 Real-Time Tracking
- Technician app streams location updates to `tech_telemetry` collection
- Customer app listens to `tech_telemetry` doc via Firestore snapshot listener
- Google Maps Flutter plugin renders polyline route + animated marker
- Background location via `geolocator` package

### 5.4 Offline-First Job Completion
- Technician can complete job flow offline (SQLite local cache)
- `connectivity_plus` monitors network state
- `workmanager` performs background sync when online
- Conflict resolution: server timestamp wins, client data merged

### 5.5 Dynamic Receipt System
- Technician inputs material cost + captures live photo
- If materials exceed threshold (500 EGP), job pauses
- Cloud Function sends FCM push to customer for approval
- Customer sees modal with receipt photo + cost breakdown
- Approve/Reject triggers Cloud Function to update job status

### 5.6 Wallet & Ledger
- Each user has a `wallets` document with running balance
- Every financial action creates a `transactions` document
- Atomic operations via Firestore transactions (batch writes)
- Negative balance supported for technician cash collection model

### 5.7 Dispute System
- Technician presses "Panic" button → creates `disputes` document
- Cloud Function: blocks customer account, credits tech from Risk Fund
- Admin dashboard shows real-time dispute feed
- Resolution workflow with admin notes and status tracking

---

## 6. Execution Phases

> [!IMPORTANT]
> Given the enormous scope, I will generate the codebase in **11 ordered phases**, each producing real, production-level code files. I will proceed phase by phase.

| Phase | What Gets Built | Estimated Files |
|---|---|---|
| **Phase 1** | Shared models + constants package | ~10 files |
| **Phase 2** | Backend: Firebase project config, Firestore rules, Cloud Functions (auth, jobs, payments, disputes, wallet, notifications) | ~25 files |
| **Phase 3** | Customer App: Project scaffold, theme, routing, core utilities | ~15 files |
| **Phase 4** | Customer App: Auth feature (OTP + Google Sign-In) | ~12 files |
| **Phase 5** | Customer App: Home, Booking (map + voice note), Live Tracking | ~20 files |
| **Phase 6** | Customer App: Receipt approval, Checkout, Rating, Profile | ~15 files |
| **Phase 7** | Technician App: Project scaffold, theme, routing, core utilities | ~15 files |
| **Phase 8** | Technician App: Auth, KYC Onboarding, Dashboard | ~15 files |
| **Phase 9** | Technician App: Job Alert, Job Execution, Invoicing (live camera), Wallet, Dispute | ~25 files |
| **Phase 10** | Admin Dashboard: React + Vite project, all pages | ~20 files |
| **Phase 11** | CI/CD, DevOps configs, README | ~8 files |

**Total: ~180 files of production code**

---

## 7. Technology Choices Summary

| Layer | Technology | Rationale |
|---|---|---|
| Mobile Framework | Flutter 3.x + Dart | Cross-platform, premium UI, single codebase per app |
| State Management | BLoC (flutter_bloc) | Predictable state, testable, industry standard |
| Backend | Firebase Cloud Functions (TypeScript) | Serverless, auto-scaling, tight Firebase integration |
| Database | Cloud Firestore | Real-time sync, offline support, flexible schema |
| Auth | Firebase Auth (Phone OTP + Google) | Native phone auth with OTP, easy Google Sign-In |
| Storage | Firebase Cloud Storage | Secure file uploads (receipt images, voice notes, KYC docs) |
| Push Notifications | Firebase Cloud Messaging (FCM) | Reliable cross-platform push |
| Maps | Google Maps Flutter Plugin + Platform API | Live tracking, geofencing, distance matrix |
| Payments | Paymob API | Egyptian market leader, supports cards + e-wallets |
| Admin Dashboard | React + Vite + TypeScript | Fast development, rich ecosystem |
| Offline Cache | sqflite + workmanager | Local persistence + background sync |
| CI/CD | GitHub Actions | Automated testing + deployment |

---

## 8. Security & Edge Cases

### Handled Scenarios
- **No Internet**: Offline-first architecture with local SQLite cache + background sync
- **Fake Receipts**: Live camera only (no gallery), EXIF validation, timestamp verification
- **Payment Failures**: 3-retry mechanism → fallback to cash → Risk Fund compensation for technician
- **Customer Refuses to Pay**: Dispute button → account block → negative wallet balance → Risk Fund payout to tech
- **Location Spoofing**: Geofence validation on backend (Cloud Function checks distance between tech and job location)
- **Rate Limiting**: Cloud Functions enforce request rate limits
- **Data Validation**: All inputs validated on both client and server

### Firestore Security Rules
- Users can only read/write their own data
- Technicians can only update jobs assigned to them
- Prices are read-only for all non-admin roles
- Admin role verified via custom claims

---

## 9. User Review Required

> [!IMPORTANT]
> **Scope Confirmation**: This plan generates ~180 files of production code across 4 sub-projects. The execution will span multiple responses. Please confirm you want to proceed with ALL phases.

> [!WARNING]
> **Firebase Project**: You will need to create a Firebase project and configure it manually (API keys, google-services.json, etc.). The codebase will include placeholder configs that you'll replace.

> [!IMPORTANT]
> **Paymob Integration**: The payment integration will use Paymob's API structure, but you'll need your own Paymob merchant credentials. I'll include the integration scaffolding with clear TODO markers.

---

## 10. Open Questions

1. **App Name/Brand**: What should the app be called? (affects package names, bundle IDs, display names)
2. **Initial Geofence Zone**: Should I hardcode Nozha 2 coordinates as the initial operating zone, or make it configurable from the admin dashboard?
3. **SMS OTP Provider**: Should I implement VictoryLink or Unifonic integration, or use Firebase Phone Auth as the primary OTP mechanism for MVP?
4. **Paymob Environment**: Do you want sandbox/test mode integration, or should I structure it for production keys from the start?
5. **Language**: Should the apps default to Arabic (RTL) with English support, or English with Arabic support?

---

## 11. Verification Plan

### Automated Tests
- Dart unit tests for BLoC logic and repository layer
- Widget tests for critical UI flows (receipt modal, camera screen)
- Cloud Functions unit tests with Firebase emulator
- `flutter analyze` for static analysis

### Manual Verification
- Firebase emulator suite for local testing
- Both Flutter apps build successfully for Android (debug APK)
- Admin dashboard builds and runs with `npm run dev`
- All file paths and imports are consistent across the monorepo
