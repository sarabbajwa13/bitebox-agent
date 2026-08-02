# BiteBox Agent — Store/Agent App

Business/agent side ka Flutter **Android/iOS** app. Client (BiteBox web) se aaye
orders yahan **receive** hote hain — agent unhe **accept/reject** karta hai,
status aage badhata hai (preparing → out for delivery → delivered), aur apne
store ka **visibility radius** set karta hai (jiske andar wale customers ko store
dikhta hai).

> Abhi **mock/in-memory** data pe chal raha hai (client app se live connection
> Firebase ke baad). Code centralized + repository-pattern pe hai — client app
> jaisa — taaki Firebase dono apps ko ek hi backend pe jod de.

## Run karna

```bash
flutter pub get
flutter run              # booted Android emulator ya iOS simulator pe
```

> iOS simulator ke liye Xcode select hona chahiye:
> `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

## Architecture (centralized control — client jaisa)

| Kya badalna hai | Kahan |
| --- | --- |
| Colors / theme | `lib/config/app_theme.dart` |
| Labels / text | `lib/config/app_strings.dart` |
| Business name, radius min/max/default | `lib/config/app_config.dart` |
| Asset paths | `lib/config/app_assets.dart` |

```
lib/
├── config/        → theme, strings, assets, config
├── models/        → order (Order + OrderStatus), store_settings
├── data/repositories/
│    ├── agent_repository.dart        → abstract interface
│    └── mock_agent_repository.dart   → abhi ka mock backend
├── providers/     → auth, orders, settings
├── ui/
│   ├── screens/   → login, home_shell (bottom nav), orders,
│   │                order_detail, store_settings
│   └── widgets/   → common (StatusChip, EmptyState, helpers)
└── main.dart      → providers + auth gate (login / home)
```

## Features

- **Login** (static abhi) — store name + phone.
- **Orders** (bottom nav) — filter: **New / Active / Completed**. New order pe
  Accept/Reject; active order pe status advance. New-orders count ka badge.
- **Order detail** — customer, items, total, actions.
- **Store settings** — **visibility radius slider** (1–20 km), open/closed
  toggle, save, logout.
- **Demo** — "Simulate new order" FAB se naya incoming order aata hai (client
  app connect hone tak testing ke liye).

## Firebase connect (baad me)

1. `FirebaseAgentRepository` banao jo `AgentRepository` implement kare.
2. `lib/main.dart` me `MockAgentRepository()` → `FirebaseAgentRepository()`.
3. Client app bhi isi backend pe order likhega — tab orders real-time aayenge,
   accept/reject/status client ke tracking screen pe live dikhega, aur radius
   client ki store visibility control karega.
4. `AppConfig.useMockData = false`.

`OrderStatus` enum client app se match karta hai (same schema).
# bitebox-agent
