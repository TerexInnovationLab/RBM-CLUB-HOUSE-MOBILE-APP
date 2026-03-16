# RBM Club House Staff Mobile App — Flutter Development Prompt (v2)

> **Purpose:** Feed directly into an AI coding tool (Cursor, GitHub Copilot, etc.) to generate a
> complete, production-quality Flutter mobile application for the Reserve Bank of Malawi Club
> House Digital Credit & Inventory Management System.

---

## SYSTEM CONTEXT

You are a senior Flutter engineer and system architect.

Generate a complete, production-quality Flutter mobile application called **RBM Club House
Staff App**. This app is used by staff members of the **Reserve Bank of Malawi (RBM)** to
manage their digital club credit wallet and track purchases at club house facilities.

The app connects to a centralized **Node.js / NestJS** backend API backed by a **PostgreSQL**
database. All business logic lives in the backend. The mobile app is a pure API consumer.

This is an **institutional-grade, security-critical** application operating within a central banking
environment. Every implementation decision must reflect enterprise-level quality, security, and
reliability. Sensitive financial and identity data must be protected at every layer.

---

## TECHNOLOGY STACK

| Category | Technology |
|---|---|
| Framework | Flutter 3+ |
| Design System | Material Design 3 |
| State Management | Riverpod (flutter_riverpod) |
| HTTP Client | Dio |
| Local Secure Storage | flutter_secure_storage |
| Authentication | JWT (stored in secure storage) |
| Biometric Auth | local_auth |
| Push Notifications | Firebase Cloud Messaging (FCM) |
| QR Code Generation | qr_flutter |
| Charts | fl_chart |
| Fonts | Roboto (Google Fonts) |

---

## PROJECT FOLDER STRUCTURE

Generate the project using this exact folder structure:

```
lib/
  core/
    constants/
      app_colors.dart
      app_typography.dart
      app_dimensions.dart
      app_strings.dart
      api_endpoints.dart
    services/
      api_service.dart
      auth_service.dart
      secure_storage_service.dart
      notification_service.dart
      biometric_service.dart
      session_manager.dart
    utils/
      validators.dart
      formatters.dart
      currency_formatter.dart
    theme/
      app_theme.dart

  features/
    auth/
      data/
        auth_repository.dart
      models/
        auth_request_model.dart
        auth_response_model.dart
      providers/
        auth_provider.dart
      screens/
        activation_screen.dart
        login_screen.dart
        set_pin_screen.dart
      widgets/
        pin_input_widget.dart
        pin_keypad_widget.dart

    dashboard/
      data/
        dashboard_repository.dart
      models/
        dashboard_summary_model.dart
      providers/
        dashboard_provider.dart
      screens/
        home_screen.dart
      widgets/
        balance_summary_card.dart
        quick_actions_row.dart
        recent_transactions_preview.dart
        monthly_progress_bar.dart

    wallet/
      data/
        wallet_repository.dart
      models/
        wallet_balance_model.dart
        monthly_summary_model.dart
        allocation_history_model.dart
      providers/
        wallet_provider.dart
      screens/
        wallet_detail_screen.dart
      widgets/
        wallet_cycle_card.dart
        spending_chart_widget.dart
        allocation_history_list.dart
        mini_statement_widget.dart

    transactions/
      data/
        transaction_repository.dart
      models/
        transaction_model.dart
        transaction_item_model.dart
        receipt_model.dart
      providers/
        transaction_provider.dart
      screens/
        transaction_list_screen.dart
        transaction_detail_screen.dart
        receipt_screen.dart
      widgets/
        transaction_list_item.dart
        transaction_filter_bar.dart
        receipt_detail_widget.dart

    card/
      data/
        card_repository.dart
      models/
        virtual_card_model.dart
      providers/
        card_provider.dart
      screens/
        virtual_card_screen.dart
        fullscreen_qr_screen.dart
      widgets/
        club_card_widget.dart
        card_actions_row.dart

    notifications/
      data/
        notification_repository.dart
      models/
        notification_model.dart
      providers/
        notification_provider.dart
      screens/
        notification_list_screen.dart
      widgets/
        notification_list_item.dart

    profile/
      data/
        profile_repository.dart
      models/
        staff_profile_model.dart
        trusted_device_model.dart
      providers/
        profile_provider.dart
      screens/
        profile_screen.dart
        change_pin_screen.dart
        settings_screen.dart
        trusted_devices_screen.dart
      widgets/
        profile_header_widget.dart
        settings_section_widget.dart

    help/
      screens/
        help_screen.dart
        faq_screen.dart
      widgets/
        faq_item_widget.dart

  shared/
    widgets/
      skeleton_loader.dart
      app_error_widget.dart
      empty_state_widget.dart
      rbm_app_bar.dart
      rbm_button.dart
      rbm_badge.dart
      offline_banner.dart
      confirmation_dialog.dart
      masked_text_widget.dart

  routes/
    app_router.dart
    route_names.dart

  main.dart
```

---

## DESIGN SYSTEM

### Color Palette

```dart
// lib/core/constants/app_colors.dart

class AppColors {
  // Primary Brand
  static const Color primaryBlue   = Color(0xFF003A8F); // Headers, nav bars, primary elements
  static const Color secondaryBlue = Color(0xFF0056B3); // Buttons, active states, CTAs

  // Backgrounds & Text
  static const Color white         = Color(0xFFFFFFFF); // Page backgrounds, content areas
  static const Color darkText      = Color(0xFF333333); // Body text and primary content
  static const Color lightGray     = Color(0xFFF4F6F8); // Input backgrounds, containers
  static const Color borderGray    = Color(0xFFE0E0E0); // Input borders, dividers

  // Semantic
  static const Color successGreen  = Color(0xFF2E7D32); // Credits, approved, positive states
  static const Color warningOrange = Color(0xFFF9A825); // Warnings, pending states
  static const Color errorRed      = Color(0xFFC62828); // Errors, declines, critical alerts

  // Dark Mode equivalents (used in dark ThemeData)
  static const Color darkBackground  = Color(0xFF121212);
  static const Color darkSurface     = Color(0xFF1E1E1E);
  static const Color darkCardBg      = Color(0xFF2C2C2C);
}
```

### Typography

```dart
// lib/core/constants/app_typography.dart
// Primary font: Roboto (Google Fonts). Fallback: Open Sans, Arial.

// Page Title:      24sp, Bold     — main screen headings
// Section Header:  18sp, SemiBold — section titles, card headers
// Sub-header:      16sp, Medium   — panel sub-headings
// Body Text:       14sp, Regular  — paragraphs, list items, descriptions
// Table / List:    13sp, Regular  — data rows
// Label / Caption: 12sp, Medium   — form labels, captions, badges
// Button Text:     14sp, Medium   — all actionable button labels
// Balance Display: 32sp, Bold     — prominent wallet balance figure
```

### Dimensions

```dart
// lib/core/constants/app_dimensions.dart
class AppDimensions {
  static const double paddingS      = 8.0;
  static const double paddingM      = 16.0;
  static const double paddingL      = 24.0;
  static const double paddingXL     = 32.0;
  static const double cardRadius    = 12.0;
  static const double buttonRadius  = 8.0;
  static const double minTouchTarget = 48.0; // WCAG minimum touch target
  static const double cardElevation = 2.0;
}
```

### Theme Configuration

```dart
// lib/core/theme/app_theme.dart

// Light Theme:
//   ColorScheme.fromSeed(seedColor: AppColors.primaryBlue), useMaterial3: true
//   AppBar: primaryBlue background, white title, white icons
//   ElevatedButton: secondaryBlue, white text, 48dp minHeight, borderRadius 8dp
//   InputDecoration: lightGray fill, borderGray outlined border, errorRed error border
//   Card: white background, 12dp borderRadius, elevation 2
//   BottomNavigationBar: primaryBlue selected, borderGray unselected

// Dark Theme:
//   ColorScheme.fromSeed(seedColor: AppColors.primaryBlue, brightness: Brightness.dark)
//   AppBar: darkSurface background
//   Card: darkCardBg background
//   BottomNavigationBar: primaryBlue selected, grey unselected

// Theme mode: controlled by user preference stored in flutter_secure_storage
// Default: system theme (ThemeMode.system)
```

---

## COMPLETE FEATURE SPECIFICATIONS

---

### MODULE 1: AUTHENTICATION

#### Overview
Staff accounts are pre-created by the HR system. The mobile app handles first-time activation,
then supports PIN-based and biometric login for daily use.

#### 1.1 Account Activation Flow (First-Time Only)
1. Staff receives their **Employee Number** and a **temporary one-time PIN** from HR via
   notification.
2. Staff downloads the RBM Club House app and launches it.
3. On first launch, app displays the **Activation Screen** with an "Activate Account" option.
4. Staff enters their **Employee Number** and **temporary PIN**.
5. App calls `POST /auth/activate` (Step 1) — backend verifies identity against HR records.
6. On success, staff is prompted to **set a new secure 6-digit PIN** of their choosing.
7. App calls `POST /auth/activate` (Step 2) with the new PIN to finalize activation.
8. App offers the option to **enable biometric login** (fingerprint or Face ID) if device
   supports it — check capability via `local_auth.isDeviceSupported()`.
9. Backend returns JWT access token + refresh token — stored in `flutter_secure_storage`.
10. App navigates to Home Dashboard with a success confirmation SnackBar.

#### 1.2 Regular Login Flow
1. Returning user opens the app.
2. If biometric is enabled AND device supports it: trigger `local_auth` prompt first.
3. On biometric success → silently exchange biometric confirmation for JWT (call
   `POST /auth/login` with a biometric flag).
4. Fallback or primary: user enters **Employee Number** and **6-digit PIN** on custom keypad.
5. App calls `POST /auth/login`.
6. On success: store tokens; navigate to Home.
7. On failure: show inline error with remaining attempt count.
8. After **5 consecutive failures**: lock the login form, show "Account locked — contact HR
   to unlock" message, and disable all login inputs.

#### 1.3 Session Management
- Auto-logout after **15 minutes of inactivity** — track last interaction timestamp.
- Show a **2-minute countdown warning dialog** before auto-logout.
- On timeout: clear all tokens from secure storage; navigate to Login with "Session expired"
  message.
- Silent token refresh via `POST /auth/refresh` using the refresh token before access token
  expiry — handled in the Dio `TokenRefreshInterceptor`.
- On any new device login: backend triggers a **Security Alert notification** to the staff
  member.

#### API Endpoints

```
POST /auth/activate
  Body (Step 1): { employeeNumber: string, temporaryPin: string }
  Body (Step 2): { employeeNumber: string, temporaryPin: string, newPin: string }
  Response: { accessToken: string, refreshToken: string, staffProfile: StaffProfile }

POST /auth/login
  Body: { employeeNumber: string, pin: string, biometric?: boolean }
  Response: { accessToken: string, refreshToken: string, staffProfile: StaffProfile }

POST /auth/refresh
  Body: { refreshToken: string }
  Response: { accessToken: string, refreshToken: string }

POST /auth/logout
  Headers: Authorization: Bearer <token>
  Body: { refreshToken: string, logoutAllDevices?: boolean }
  Response: { success: boolean }
```

#### Security: PIN Keypad Widget
- Build a **custom numeric keypad** (`pin_keypad_widget.dart`) — no system keyboard ever
  shown for PIN entry.
- PIN display uses masked dots (●●●●●●), never plaintext.
- Fields: `autocorrect: false`, `enableSuggestions: false`, `obscureText: true`.
- Keypad layout: 3×3 grid of digits (1–9), 0, backspace, confirm.

---

### MODULE 2: HOME DASHBOARD

#### Overview
The home screen is the primary view post-login. It gives staff an immediate, comprehensive
overview of their financial position for the current allocation cycle.

#### Screen Layout (top to bottom)

```
┌─────────────────────────────────────┐
│  RBM App Bar  [🔔 badge]            │  ← notification bell with unread badge
├─────────────────────────────────────┤
│  WELCOME HEADER                     │
│  Good morning, John Banda           │
│  EMP-00123  ·  Grade G3  ·  Ops    │  ← from StaffProfile
├─────────────────────────────────────┤
│  BALANCE SUMMARY CARD (primaryBlue) │
│  Current Balance                    │
│  MWK 12,500.00          [👁 toggle] │  ← masked by default, eye icon to reveal
│  ─────────────────────────────────  │
│  Monthly Allocation   MWK 20,000    │
│  Amount Spent         MWK  7,500    │
│  Remaining Credit     MWK 12,500    │
│  Next Reset: 01 April 2026          │
│  ██████████░░░░░░░░░░  37.5% used   │  ← progress bar: green→orange→red
├─────────────────────────────────────┤
│  QUICK ACTIONS                      │
│  [My Card]  [Transactions] [Wallet] │
├─────────────────────────────────────┤
│  RECENT TRANSACTIONS (last 3)       │
│  Club House A · MWK 850 · 15 Mar    │
│  Club House B · MWK 1,200 · 14 Mar  │
│  Monthly Credit · MWK 20,000 · 1Mar │
│                     [ View All → ]  │
└─────────────────────────────────────┘
```

#### Balance Summary Card — Field Definitions
| Field | Source | Description |
|---|---|---|
| Current Balance | `wallet.currentBalance` | Real-time available credit |
| Monthly Allocation | `monthlySummary.allocatedAmount` | Total credit for current cycle |
| Amount Spent | `monthlySummary.spentAmount` | Total debits since last reset |
| Remaining Credit | `monthlySummary.remainingAmount` | Balance — updates after every transaction |
| Next Reset | `allocationCycle.periodEnd + 1 day` | Date of next monthly top-up |

#### Progress Bar Colour Logic
```dart
// Green:  remaining > 50% of allocation
// Orange: remaining between 20%–50%
// Red:    remaining < 20%
double pctRemaining = remaining / allocated;
Color barColor = pctRemaining > 0.5
    ? AppColors.successGreen
    : pctRemaining > 0.2
        ? AppColors.warningOrange
        : AppColors.errorRed;
```

#### API Endpoints
```
GET /wallet/balance
  Response: { walletId, currentBalance, walletStatus, currency }

GET /wallet/monthly-summary
  Response: { cycleName, periodStart, periodEnd, allocatedAmount, spentAmount, remainingAmount }

GET /transactions/recent
  Response: { transactions: Transaction[] }  // last 3
```

---

### MODULE 3: WALLET & BALANCE DETAILS

#### Overview
A dedicated Wallet screen (accessible from Quick Actions or bottom nav) that expands the
dashboard summary into a full financial breakdown including spending history and allocation
trends.

#### Screen Layout

```
┌─────────────────────────────────────┐
│  CURRENT CYCLE CARD                 │
│  Available Balance   MWK 12,500     │
│  Allocated This Month MWK 20,000    │
│  Total Spent         MWK  7,500     │
│  Remaining           MWK 12,500     │
│  Cycle: 01 Mar – 31 Mar 2026        │
│  Next Reset: 01 Apr 2026 (16 days)  │
│  ████████████░░░░░ 37.5% used       │
├─────────────────────────────────────┤
│  SPENDING BREAKDOWN                 │
│  [Bar chart — weekly spend]         │  ← fl_chart BarChart, last 4 weeks
├─────────────────────────────────────┤
│  MINI STATEMENT (last 10 entries)   │
│  15 Mar · Club House A · -MWK 850   │
│  14 Mar · Club House B · -MWK 1,200 │
│  01 Mar · Monthly Credit +MWK 20,000│
├─────────────────────────────────────┤
│  ALLOCATION HISTORY                 │
│  Mar 2026 · MWK 20,000 · Spent 18,200│
│  Feb 2026 · MWK 20,000 · Spent 20,000│
│  Jan 2026 · MWK 20,000 · Spent 15,750│
└─────────────────────────────────────┘
```

#### Wallet Screen Features
- Balance displayed prominently with mask/reveal toggle.
- Visual progress bar showing % of monthly budget consumed.
- **Bar chart** (fl_chart `BarChart`) — weekly spending for the current cycle, primaryBlue bars.
- **Mini statement** — last 10 wallet ledger entries; credits in `successGreen`, debits in
  `errorRed`.
- **Allocation history** — all previous monthly cycles with allocated and spent amounts.
- Pull-to-refresh to update all wallet data.

#### API Endpoints
```
GET /wallet/balance
  Response: { walletId, currentBalance, walletStatus, currency }

GET /wallet/monthly-summary
  Response: { cycleName, periodStart, periodEnd, allocatedAmount, spentAmount, remainingAmount }

GET /wallet/ledger
  Query: ?limit=10
  Response: { entries: WalletLedgerEntry[] }

GET /wallet/allocation-history
  Response: { history: AllocationHistory[] }
```

#### Data Models
```dart
class WalletBalance {
  final String walletId;
  final double currentBalance;
  final String walletStatus; // active | frozen | closed
  final String currency;     // MWK
}

class MonthlySummary {
  final String cycleName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double allocatedAmount;
  final double spentAmount;
  final double remainingAmount;
}

class WalletLedgerEntry {
  final String id;
  final String transactionType; // ALLOCATION | DEBIT | ADJUSTMENT | REVERSAL
  final double? debitAmount;
  final double? creditAmount;
  final double balanceBefore;
  final double balanceAfter;
  final DateTime createdAt;
}

class AllocationHistory {
  final String cycleName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double allocatedAmount;
  final double spentAmount;
}
```

---

### MODULE 4: VIRTUAL CLUB CARD

#### Overview
Staff present their **MyClub digital card** at the POS terminal. The attendant scans the QR
code to identify the staff member and initiate a transaction.

#### Card Screen Layout

```
┌─────────────────────────────────────┐
│        RESERVE BANK OF MALAWI       │
│           MyClub Card               │
│  ─────────────────────────────────  │
│  John Banda              EMP-00123  │
│  Grade G3  ·  Operations Dept       │
│  ─────────────────────────────────  │
│        [ ██ QR CODE ██ ]            │
│   Unique QR token for POS scanning  │
│  ─────────────────────────────────  │
│  ● ACTIVE   Balance: MWK 12,500     │
│  Issued: 01 Jan 2026                │
│  Last used: Club House A, 15 Mar    │
├─────────────────────────────────────┤
│  CARD ACTIONS                       │
│  [Full QR]  [Lock Card]  [History]  │
└─────────────────────────────────────┘
```

#### Card Information Displayed
| Field | Source |
|---|---|
| Staff full name | `staffProfile.firstName + lastName` |
| Employee number | `staffProfile.employeeNumber` |
| Grade and department | `staffProfile.gradeName`, `staffProfile.departmentName` |
| QR code | Encodes `virtualCard.cardToken` via `qr_flutter` |
| Card status badge | `virtualCard.status` — Active (green) / Suspended (orange) / Revoked (red) |
| Current balance preview | `wallet.currentBalance` — masked by default |
| Issue date | `virtualCard.issuedAt` |
| Last used | From last approved transaction |

#### Card Actions
1. **Full-Screen QR** — Navigates to `FullscreenQrScreen` with brightness raised to maximum
   for easy POS scanning in low-light environments.
2. **Lock Card** — Calls `POST /card/lock`; prevents all POS transactions. Shows confirmation
   dialog before locking. Locked state shown with orange badge.
3. **Transaction History** — Quick link to `TransactionListScreen` filtered to card activity.
4. **Request Reissue** — Calls `POST /card/reissue` if the card token is suspected
   compromised; requires PIN re-verification.
5. **Hide/Reveal Details** — Tap to toggle sensitive details (balance, last-used location).

#### Brightness Management
```dart
// On entering VirtualCardScreen and FullscreenQrScreen:
//   WakelockPlus.enable() — prevent screen sleep
//   SystemChrome.setSystemUIOverlayStyle(dark icons for readability)
// On leaving:
//   WakelockPlus.disable() — restore normal behaviour
```

#### API Endpoints
```
GET /card/details
  Response: { cardId, cardToken, status, staffName, employeeNumber,
              gradeName, departmentName, issuedAt, lastUsedAt, lastUsedLocation }

POST /card/lock
  Body: { pin: string }
  Response: { cardId, status: "suspended" }

POST /card/unlock
  Body: { pin: string }
  Response: { cardId, status: "active" }

POST /card/reissue
  Body: { pin: string, reason: string }
  Response: { cardId, cardToken, issuedAt }
```

#### Data Model: VirtualCard
```dart
class VirtualCard {
  final String cardId;
  final String cardToken;
  final String status;           // active | suspended | revoked
  final String staffName;
  final String employeeNumber;
  final String gradeName;
  final String departmentName;
  final DateTime issuedAt;
  final DateTime? lastUsedAt;
  final String? lastUsedLocation;
}
```

---

### MODULE 5: TRANSACTIONS

#### Overview
A complete, filterable record of all wallet activity. Every purchase, credit, and adjustment is
listed in reverse chronological order with full detail on tap.

#### Transaction List Screen Layout
```
┌─────────────────────────────────────┐
│  FILTER BAR                         │
│  [All] [Purchases] [Credits] [Date] │  ← toggle chips + date range picker
│  [Amount Range]  [Search location]  │
│  24 transactions this month         │
├─────────────────────────────────────┤
│  TRANSACTION LIST (infinite scroll) │
│  Club House A                       │
│  MWK 850 · 15 Mar 2026 · 14:32     │
│  3 items                ✓ Approved  │
│  ─────────────────────────────────  │
│  Monthly Credit                     │
│  MWK 20,000 · 01 Mar 2026          │
│  Allocation             ✓ Credited  │
│  ─────────────────────────────────  │
│  Club House A                       │
│  MWK 430 · 28 Feb 2026             │
│  2 items                ✗ Declined  │
└─────────────────────────────────────┘
```

#### Transaction List Item Fields
| Field | Description |
|---|---|
| Merchant / Location | Club house name or "Monthly Credit" for allocations |
| Transaction Amount | Debits in `errorRed`; credits in `successGreen` |
| Date and Time | Full ISO timestamp formatted as `dd MMM yyyy · HH:mm` |
| Status Badge | Approved (green) / Declined (red) / Pending (orange) / Reversed (orange) |
| Transaction Type | PURCHASE / ALLOCATION / ADJUSTMENT / REVERSAL |
| Balance After | Wallet balance immediately after the transaction |
| Item Count | e.g., "3 items" — for PURCHASE transactions |

#### Filter Options
- **Type filter**: All, Purchases, Credits, Adjustments (toggle chip bar)
- **Date range**: Calendar date picker (start date + end date)
- **Amount range**: Min amount and max amount numeric inputs
- **Search**: Free-text search by merchant or location name

#### Transaction Detail Screen
On tapping a transaction row, navigate to `TransactionDetailScreen` showing:
- Full transaction header (number, date, location, status)
- Itemized list of purchased products with quantity, unit price, line total
- Payment summary (subtotal, total charged, balance before, balance after)
- Link to the **Digital Receipt** for approved transactions

#### API Endpoints
```
GET /transactions
  Query: ?page=1&limit=20&type=PURCHASE&startDate=2026-03-01&endDate=2026-03-31
         &minAmount=0&maxAmount=50000&search=club+house+a
  Response: { data: Transaction[], total, page, limit, totalPages }

GET /transactions/:id
  Response: TransactionDetail (includes items + receipt)
```

#### Data Models
```dart
class Transaction {
  final String id;
  final String transactionNumber;
  final DateTime occurredAt;
  final double totalAmount;
  final String status;           // approved | declined | reversed | pending
  final String transactionType;  // PURCHASE | ALLOCATION | ADJUSTMENT | REVERSAL
  final String merchantLocation;
  final int? itemCount;
  final double balanceAfter;
}

class TransactionDetail {
  final String id;
  final String transactionNumber;
  final DateTime occurredAt;
  final double totalAmount;
  final String status;
  final String transactionType;
  final String merchantLocation;
  final double balanceBefore;
  final double balanceAfter;
  final List<TransactionItem> items;
  final DigitalReceipt? receipt;
}

class TransactionItem {
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
}
```

---

### MODULE 6: DIGITAL RECEIPTS

#### Overview
Every approved purchase automatically generates a digital receipt stored in the backend and
accessible within the app. Receipts are the official record of each transaction.

#### Receipt Screen Layout (styled as a clean thermal receipt)
```
┌─────────────────────────────────────┐
│     RESERVE BANK OF MALAWI          │
│         Club House A                │
│  Receipt No: RCP-20260315-0042      │
│  15 March 2026  ·  14:32:05         │
│  Trans Ref: TXN-2026-0042           │
├─────────────────────────────────────┤
│  ITEMS PURCHASED                    │
│  Bottled Water  ×2  @ 200   MWK 400 │
│  Sandwich       ×1  @ 850   MWK 850 │
│  Orange Juice   ×1  @ 600   MWK 600 │
├─────────────────────────────────────┤
│  Subtotal                MWK 1,850  │
│  Total Charged           MWK 1,850  │
│  ─────────────────────────────────  │
│  Balance Before         MWK 12,500  │
│  Balance After          MWK 10,650  │
├─────────────────────────────────────┤
│  [ Download PDF ]  [ Share ]        │
│  [ Report Issue ]                   │
└─────────────────────────────────────┘
```

#### Receipt Actions
1. **Download PDF** — Generate a receipt PDF on-device using `pdf` package; save to
   Downloads.
2. **Share** — Share receipt (as PDF or formatted text) via `share_plus` system share sheet.
3. **Report Issue** — Opens a dialog to flag the transaction for admin review; calls
   `POST /transactions/:id/report`.

#### API Endpoint
```
GET /transactions/:id
  Response includes receipt: {
    receiptId, receiptNumber, salesTransactionId,
    receiptData: {
      items: ReceiptItem[],
      totalAmount, balanceBefore, balanceAfter,
      posLocation, occurredAt
    },
    createdAt
  }

POST /transactions/:id/report
  Body: { reason: string, description: string }
  Response: { ticketId: string, message: string }
```

#### Data Model: DigitalReceipt
```dart
class DigitalReceipt {
  final String receiptId;
  final String receiptNumber;
  final String salesTransactionId;
  final List<ReceiptItem> items;
  final double totalAmount;
  final double balanceBefore;
  final double balanceAfter;
  final String posLocation;
  final DateTime occurredAt;
}

class ReceiptItem {
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double lineTotal;
}
```

---

### MODULE 7: NOTIFICATIONS

#### Overview
Real-time push notifications keep staff informed of every account event. All notifications are
also stored in an in-app notification centre, retained for **90 days**.

#### Notification Types
| Type | Trigger | Example Message |
|---|---|---|
| `TRANSACTION` | Purchase approved | "You spent MWK 850 at Club House A. Balance: MWK 10,650" |
| `TRANSACTION_DECLINED` | Purchase declined | "Transaction declined — insufficient balance. Balance: MWK 200" |
| `ALLOCATION` | Monthly credit loaded | "Your March 2026 credit of MWK 20,000 has been loaded." |
| `LOW_BALANCE` | Balance below threshold | "Low balance alert: MWK 1,500 remaining." |
| `SECURITY_ALERT` | New device login detected | "New device login detected. If this wasn't you, contact HR." |
| `SYSTEM` | HR announcement | "Club House A will be closed on 18 March 2026." |

#### Push Notification Setup
- Use **Firebase Cloud Messaging (FCM)**.
- On first login, register device via `POST /devices/register` with FCM token, platform, and
  `deviceIdentifier`.
- Refresh FCM token on `onTokenRefresh` and re-register with backend.
- Handle three app states:
  - **Foreground** (`FirebaseMessaging.onMessage`): show in-app banner overlay at top.
  - **Background tap** (`FirebaseMessaging.onMessageOpenedApp`): navigate to related content.
  - **Terminated tap** (`getInitialMessage`): navigate on app launch.

#### Deep-Link Navigation on Tap
| Notification Type | Navigation Target |
|---|---|
| `TRANSACTION` | `ReceiptScreen` for `referenceId` |
| `TRANSACTION_DECLINED` | `TransactionDetailScreen` for `referenceId` |
| `ALLOCATION` | `HomeScreen` (refresh balance) |
| `LOW_BALANCE` | `WalletDetailScreen` |
| `SECURITY_ALERT` | `TrustedDevicesScreen` |
| `SYSTEM` | `NotificationListScreen` |

#### In-App Notification List Features
- Unread count badge on bell icon in AppBar and on notification tab.
- Unread items shown with a `primaryBlue` left-border accent and light blue background tint.
- **Mark as read** on tap; **Mark all as read** button at top.
- Swipe-to-dismiss individual notifications.
- Empty state when no notifications exist.

#### API Endpoints
```
GET /notifications
  Query: ?page=1&limit=20
  Response: { data: AppNotification[], unreadCount, total }

POST /notifications/:id/read
  Response: { success: boolean }

POST /notifications/read-all
  Response: { success: boolean, updatedCount: number }

POST /devices/register
  Body: { fcmToken: string, platform: "android"|"ios", deviceIdentifier: string }
  Response: { deviceId: string }

DELETE /devices/:deviceId
  Response: { success: boolean }
```

#### Data Model: AppNotification
```dart
class AppNotification {
  final String id;
  final String notificationType;
  final String title;
  final String message;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;
}
```

---

### MODULE 8: PROFILE & SETTINGS

#### Overview
Staff can view their HR-registered profile, manage security settings, control notification
preferences, and manage trusted devices.

#### Profile Screen Layout
```
┌─────────────────────────────────────┐
│  PROFILE HEADER                     │
│  [Avatar with initials]             │
│  John Banda  ·  EMP-00123           │
│  Operations  ·  Grade G3            │
├─────────────────────────────────────┤
│  MY INFORMATION (read-only)         │
│  Email:   j.banda@rbm.mw            │
│  Phone:   +265 99x xxx xxx  [masked]│
│  Status:  ● Active                  │
├─────────────────────────────────────┤
│  SECURITY                           │
│  Change PIN              [ > ]      │
│  Biometric Login     [ON toggle]    │
│  Trusted Devices         [ > ]      │
├─────────────────────────────────────┤
│  NOTIFICATIONS                      │
│  Purchases           [ON toggle]    │
│  Allocations         [ON toggle]    │
│  Alerts              [ON toggle]    │
│  System Messages     [ON toggle]    │
├─────────────────────────────────────┤
│  APP PREFERENCES                    │
│  Dark Mode           [toggle]       │
│  Language            [English >]    │
├─────────────────────────────────────┤
│  SESSION                            │
│  [ Logout from this device ]        │
│  [ Logout from all devices ]        │
└─────────────────────────────────────┘
```

#### Profile Information (Read-Only)
All data sourced from HR system — staff cannot edit name, employee number, department, or
grade. Phone number is editable via `PUT /profile/update`.

#### 8.1 Change PIN Flow
1. User enters current 6-digit PIN (verified locally and server-side).
2. User enters new 6-digit PIN.
3. User re-enters new PIN for confirmation.
4. Client validates: new PIN ≠ current PIN; both entries match.
5. Calls `POST /profile/change-pin`.
6. On success: SnackBar confirmation; navigate back to Profile.
7. On failure: inline error; allow retry.

#### 8.2 Biometric Toggle
- Check device capability with `local_auth.isDeviceSupported()` and
  `local_auth.canCheckBiometrics`.
- If not supported: show "Biometric not available on this device" — disable toggle.
- On enable: require PIN verification first; then store biometric preference in
  `flutter_secure_storage`.
- On disable: clear biometric preference; PIN-only login going forward.

#### 8.3 Trusted Devices Screen
- Lists all devices registered to the account from `GET /devices`.
- Each entry shows: device platform (iOS/Android icon), registration date, last active.
- Current device highlighted with a "This device" badge.
- **Remove device** button: calls `DELETE /devices/:deviceId` with PIN confirmation dialog.
  Removing a device de-registers its FCM token.

#### 8.4 Logout Options
- **Logout from this device**: calls `POST /auth/logout` with current refresh token; clears
  local secure storage; navigates to Login.
- **Logout from all devices**: calls `POST /auth/logout` with `logoutAllDevices: true`; same
  local cleanup.

#### API Endpoints
```
GET /profile
  Response: { staffId, employeeNumber, firstName, lastName,
              departmentName, gradeName, email, phoneNumber, status }

PUT /profile/update
  Body: { phoneNumber?: string }
  Response: StaffProfile

POST /profile/change-pin
  Body: { currentPin: string, newPin: string }
  Response: { success: boolean }

GET /devices
  Response: { devices: TrustedDevice[] }

DELETE /devices/:deviceId
  Body: { pin: string }
  Response: { success: boolean }
```

#### Data Models
```dart
class StaffProfile {
  final String staffId;
  final String employeeNumber;
  final String firstName;
  final String lastName;
  final String departmentName;
  final String gradeName;
  final String email;
  final String? phoneNumber;
  final String status;
}

class TrustedDevice {
  final String deviceId;
  final String deviceIdentifier;
  final String platform;     // iOS | Android
  final DateTime registeredAt;
  final DateTime? lastActiveAt;
  final bool isCurrentDevice;
}
```

---

### MODULE 9: HELP & SUPPORT

#### Overview
An in-app help centre so staff can resolve common issues without leaving the app.

#### Help Screen — Content Sections
1. **Frequently Asked Questions** — Expandable `ExpansionTile` list covering:
   - How do I check my wallet balance?
   - How does monthly credit allocation work and when does it reset?
   - How do I present my virtual card at the POS?
   - How do I download or share a digital receipt?
   - How do I lock or unlock my virtual card?
   - What happens if my PIN is entered incorrectly 5 times?
   - How do I reset my PIN if I've forgotten it?
   - Who do I contact if a transaction looks incorrect?
2. **Usage Guide** — Step-by-step guide (illustrated cards) on:
   - Presenting the virtual card QR code at POS
   - Reading your monthly spending summary
   - Viewing and downloading receipts
3. **Contact Support**:
   - HR contact (email + phone) — for account/grade queries
   - IT Helpdesk (email + phone) — for technical issues
   - **Submit Support Ticket** — in-app form calling `POST /support/ticket`
   - Link to IT support portal (opens in-app web view)

#### API Endpoint
```
POST /support/ticket
  Body: { subject: string, description: string, category: "ACCOUNT"|"TECHNICAL"|"TRANSACTION" }
  Response: { ticketId: string, message: string }
```

---

## NAVIGATION & ROUTING

### Bottom Navigation Bar
Five tabs — visible on all post-authentication screens:

| Index | Tab | Icon | Screen |
|---|---|---|---|
| 0 | Home | `home` | `HomeScreen` |
| 1 | Transactions | `receipt_long` | `TransactionListScreen` |
| 2 | Card | `credit_card` | `VirtualCardScreen` |
| 3 | Wallet | `account_balance_wallet` | `WalletDetailScreen` |
| 4 | Profile | `person` | `ProfileScreen` |

Active tab: `AppColors.primaryBlue`. Inactive: `AppColors.borderGray`. Labels shown.

### Named Routes (GoRouter)
```dart
// lib/routes/route_names.dart
const String routeSplash           = '/';
const String routeActivation       = '/activate';
const String routeSetPin           = '/activate/set-pin';
const String routeLogin            = '/login';
const String routeHome             = '/home';
const String routeWallet           = '/wallet';
const String routeTransactions     = '/transactions';
const String routeTransactionDetail = '/transactions/:id';
const String routeReceipt          = '/transactions/:id/receipt';
const String routeCard             = '/card';
const String routeFullscreenQr     = '/card/qr';
const String routeNotifications    = '/notifications';
const String routeProfile          = '/profile';
const String routeChangePin        = '/profile/change-pin';
const String routeSettings         = '/profile/settings';
const String routeTrustedDevices   = '/profile/devices';
const String routeHelp             = '/help';
const String routeFaq              = '/help/faq';
```

### Route Guards
```dart
// GoRouter redirect logic:
// 1. If tokens absent in secure storage → redirect to /login
// 2. If account not yet activated → redirect to /activate
// 3. If session timestamp > 15 min ago → clear tokens → redirect to /login
//    (with query param: ?reason=session_expired)
// 4. If wallet status is "frozen" → show frozen banner on Home; block Card tab
```

---

## API SERVICE LAYER

### Base Dio Configuration
```dart
// lib/core/services/api_service.dart

// BaseOptions:
//   baseUrl: from --dart-define (separate dev/prod values)
//   connectTimeout: Duration(seconds: 30)
//   receiveTimeout: Duration(seconds: 30)
//   headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' }

// Interceptors (applied in order):
//   1. AuthInterceptor       — attach Authorization: Bearer <accessToken>
//   2. TokenRefreshInterceptor — on 401: try POST /auth/refresh silently;
//                                on refresh failure: logout and redirect to /login
//   3. LoggingInterceptor    — debug builds only; never log tokens
//   4. ErrorInterceptor      — map all HTTP/network errors to AppException
```

### Error Handling
```dart
sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

class NetworkException    extends AppException { ... } // No connectivity
class TimeoutException    extends AppException { ... } // Request timed out
class UnauthorizedException extends AppException { ... } // 401 — logout
class ForbiddenException  extends AppException { ... } // 403
class NotFoundException   extends AppException { ... } // 404
class ServerException     extends AppException { ... } // 5xx
class ValidationException extends AppException {       // 422
  final Map<String, List<String>> fieldErrors;
}

// Every screen handles four states via Riverpod AsyncValue:
// AsyncLoading → SkeletonLoader
// AsyncData    → Content
// AsyncError   → AppErrorWidget (with Retry)
// (empty data) → EmptyStateWidget
```

### Secure Storage Keys
```dart
// lib/core/services/secure_storage_service.dart
const String keyAccessToken        = 'rbm_access_token';
const String keyRefreshToken       = 'rbm_refresh_token';
const String keyEmployeeNumber     = 'rbm_employee_number';
const String keyBiometricEnabled   = 'rbm_biometric_enabled';
const String keyLastActivityTime   = 'rbm_last_activity_ts';
const String keyLoginAttempts      = 'rbm_login_attempts';
const String keyThemeMode          = 'rbm_theme_mode';
const String keyNotificationPrefs  = 'rbm_notification_prefs';
const String keyActivationComplete = 'rbm_activation_complete';
```

---

## SECURITY REQUIREMENTS

Implement every item below without exception. This is a central banking application.

| Requirement | Implementation Detail |
|---|---|
| JWT Auth | `Authorization: Bearer <token>` on all requests via Dio `AuthInterceptor` |
| Secure Token Storage | `flutter_secure_storage` exclusively — never SharedPreferences or Hive unencrypted |
| Custom PIN Keypad | `PinKeypadWidget` — numeric grid, no system keyboard; masked dots display |
| PIN Hashing | PIN is hashed client-side before transmission (SHA-256); never sent as plaintext |
| Biometric Auth | `local_auth` — fingerprint + Face ID; biometric data never leaves device hardware |
| Session Timeout | 15-min inactivity auto-logout; 2-min countdown warning dialog |
| Background Masking | Black overlay on `AppLifecycleState.paused`/`hidden`; lifted on `resumed` |
| Balance Masking | Balance masked (●●●●●●) by default; eye icon to reveal temporarily |
| Card Detail Masking | Sensitive card fields hidden by default; single tap to reveal |
| HTTPS Only | Enforce in Dio `BaseOptions`; reject any non-HTTPS URL at compile time |
| TLS 1.3 | Configure Dio to enforce minimum TLS 1.3 for all API connections |
| Certificate Pinning | Pin SSL certificate in Dio `onBadCertificate`; reject unmatched certificates |
| New Device Alert | Backend sends `SECURITY_ALERT` notification on unrecognized device login |
| Account Lockout | Disable login after 5 failed PIN attempts; display admin-unlock message |
| No Local Caching | Sensitive financial data (balances, transactions) never written to disk cache |
| No Autocomplete | PIN fields: `autocorrect: false`, `enableSuggestions: false`, `obscureText: true` |
| Screen Recording Block | `FLAG_SECURE` on Android (`FlutterWindowManager`); equivalent on iOS |
| Logout All Devices | `POST /auth/logout` with `logoutAllDevices: true` invalidates all refresh tokens |

---

## STATE MANAGEMENT (RIVERPOD)

Use Riverpod with `AsyncValue` for all async operations. Structure every feature identically:

```dart
// 1. Service provider (singleton)
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// 2. Repository provider
final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.read(apiServiceProvider));
});

// 3. Data provider (FutureProvider or AsyncNotifierProvider)
final walletBalanceProvider = FutureProvider.autoDispose<WalletBalance>((ref) {
  return ref.read(walletRepositoryProvider).getBalance();
});

// 4. In screens — always handle all AsyncValue states:
ref.watch(walletBalanceProvider).when(
  loading: () => const BalanceCardSkeleton(),
  error: (e, _) => AppErrorWidget(error: e, onRetry: () => ref.refresh(walletBalanceProvider)),
  data: (balance) => BalanceSummaryCard(balance: balance),
);
```

---

## LOADING STATES & UX POLISH

- **Skeleton Loaders** (`shimmer` package): balance card, transaction list rows, profile header,
  notification list — all use shimmer skeletons on initial load.
- **Pull-to-Refresh**: `RefreshIndicator` on all list and detail screens.
- **Infinite Scroll**: Transaction list loads next page when within 200px of bottom;
  `CircularProgressIndicator` at list footer during page fetch.
- **Offline Banner**: Persistent `errorRed` banner at screen top when offline
  (`connectivity_plus`); auto-dismisses when connection restores.
- **Empty States**: `EmptyStateWidget` with icon, title, and subtitle for each screen context
  (e.g., "No transactions yet" / "No notifications").
- **Error States**: `AppErrorWidget` card with error message and **Retry** button.
- **Success Feedback**: `ScaffoldMessenger` SnackBar with `successGreen` background.
- **Confirmation Dialogs**: All destructive actions (lock card, logout, remove device) require
  a `ConfirmationDialog` before proceeding.
- **Page Transitions**: Slide transitions for push navigation; fade for tab switches.
- **Splash Screen**: RBM logo on `primaryBlue` background; max 2-second display; route
  decision based on token validity.
- **Dark Mode**: Fully supported via `AppTheme.darkTheme`; preference persisted in secure
  storage; toggled from Profile > App Preferences.

---

## CURRENCY FORMATTING

```dart
// lib/core/utils/currency_formatter.dart
// All monetary values: Malawian Kwacha (MWK), 2 decimal places

import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'en_MW',
    symbol: 'MWK ',
    decimalDigits: 2,
  );

  static String format(double amount) => _formatter.format(amount);
  // Output: "MWK 12,500.00"

  static String formatCompact(double amount) =>
      'MWK ${NumberFormat.compact(locale: 'en').format(amount)}';
  // Output: "MWK 12.5K"
}
```

---

## FIREBASE CLOUD MESSAGING

```dart
// lib/core/services/notification_service.dart

// Initialization (call from main.dart after Firebase.initializeApp):
// 1. Request notification permissions — iOS + Android 13+ (POST /notification/request)
// 2. Get FCM token: FirebaseMessaging.instance.getToken()
// 3. Register device: POST /devices/register with token + platform + deviceIdentifier
// 4. Listen for token refresh: FirebaseMessaging.instance.onTokenRefresh → re-register

// Message handlers:
// Foreground  → FirebaseMessaging.onMessage.listen → show in-app banner overlay
// Background  → FirebaseMessaging.onMessageOpenedApp.listen → navigate to content
// Terminated  → FirebaseMessaging.instance.getInitialMessage() → navigate on launch

// Deep-link routing (see Module 7 — Deep-Link Navigation table above)
```

---

## pubspec.yaml DEPENDENCIES

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod: ^2.5.x
  riverpod_annotation: ^2.3.x

  # Networking
  dio: ^5.4.x

  # Secure storage
  flutter_secure_storage: ^9.2.x

  # Authentication
  local_auth: ^2.1.x

  # Firebase
  firebase_core: ^3.3.x
  firebase_messaging: ^15.1.x

  # QR code
  qr_flutter: ^4.1.x

  # Charts
  fl_chart: ^0.68.x

  # PDF generation
  pdf: ^3.10.x
  printing: ^5.12.x

  # Fonts
  google_fonts: ^6.2.x

  # Internationalisation & formatting
  intl: ^0.19.x

  # Connectivity
  connectivity_plus: ^6.0.x

  # Navigation
  go_router: ^14.2.x

  # Skeleton loaders
  shimmer: ^3.0.x

  # File sharing
  share_plus: ^10.0.x

  # Screen wake lock (virtual card brightness)
  wakelock_plus: ^1.2.x

  # Screen security (FLAG_SECURE)
  flutter_windowmanager: ^0.2.x

  # Image caching
  cached_network_image: ^3.3.x

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.x
  mockito: ^5.4.x
  build_runner: ^2.4.x
  riverpod_generator: ^2.3.x
```

---

## CODE QUALITY STANDARDS

- `analysis_options.yaml` with `flutter_lints` enabled; zero lint warnings in production code.
- All public classes, methods, and providers must have dartdoc comments.
- No magic strings — all user-facing strings in `AppStrings`; all API paths in `ApiEndpoints`.
- No magic numbers — all spacing, sizing, and radius values in `AppDimensions`.
- All `DateTime` values stored and transmitted as **ISO 8601 UTC** strings; displayed in
  local time using `intl` formatting.
- All monetary values as `double` (2 decimal places), always formatted via `CurrencyFormatter`.
- Environment separation via `--dart-define=ENV=dev|prod`; base URL and certificate pin
  vary per environment.
- Repository pattern strictly enforced: providers call repositories; repositories call Dio; Dio
  never called directly from UI or provider layer.
- No business logic in widgets — all logic in providers or repositories.

---

## DELIVERABLES CHECKLIST

Generate every file listed below:

- [ ] `pubspec.yaml` with all dependencies
- [ ] `analysis_options.yaml`
- [ ] `lib/core/` — all constants, services (api, auth, storage, notification, biometric,
      session), utils (validators, formatters, currency), theme (light + dark)
- [ ] `lib/features/auth/` — activation screen, login screen, set-pin screen, pin keypad widget,
      auth provider, auth repository
- [ ] `lib/features/dashboard/` — home screen, balance summary card, quick actions row,
      recent transactions preview, monthly progress bar, dashboard provider, repository
- [ ] `lib/features/wallet/` — wallet detail screen, spending chart, allocation history list,
      mini statement, wallet provider, repository
- [ ] `lib/features/transactions/` — transaction list screen, transaction detail screen, receipt
      screen, filter bar widget, transaction provider, repository
- [ ] `lib/features/card/` — virtual card screen, fullscreen QR screen, card actions row,
      card provider, repository
- [ ] `lib/features/notifications/` — notification list screen, FCM setup, notification provider,
      repository
- [ ] `lib/features/profile/` — profile screen, change pin screen, settings screen, trusted
      devices screen, profile provider, repository
- [ ] `lib/features/help/` — help screen, FAQ screen, FAQ item widget
- [ ] `lib/shared/widgets/` — skeleton loader, app error widget, empty state widget, offline
      banner, RBM app bar, RBM button, RBM badge, confirmation dialog, masked text widget
- [ ] `lib/routes/app_router.dart` — GoRouter config with redirect guards
- [ ] `lib/routes/route_names.dart` — all named route constants
- [ ] `lib/main.dart` — ProviderScope, Firebase init, theme (light/dark), GoRouter, splash

---

*End of RBM Club House Staff App — Flutter Development Prompt v2*
*Reserve Bank of Malawi — Confidential*
