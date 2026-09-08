# Verification status — 2026-09-08

This is a progress record, not a production release sign-off.

## Latest consumer checks

- The focused iOS checkout journey passed: real synthetic login, guest route replacement, login again, navigation tabs, adding a product, persisted quantity changes, and creation of a takeaway order with the expected product and total. Evidence: `/tmp/vips-consumer-checkout.log`.
- The three widget tests passed after fixing narrow-screen profile layouts. The profile regression scrolls to and taps Active, Done and Refunded, checking the selected filter and rendering exceptions. It also exposed and led to fixes for requirement labels, date controls and the sticky header height. Evidence: `/tmp/vips-profile-widget.log`.
- The fresh profile, notifications and settings simulator batch passed with zero Flutter errors (49 exploration records). This verifies the exercised navigation and rendering, not every nested action or business outcome. Earlier broader batches remain incomplete or failed on historical defects. Evidence: `/tmp/vips-consumer-profile-verified.log`.
- Earlier suite totals and Android builds below predate these latest UI edits. They are historical evidence, not verification of the current complete working tree.

## Confirmed

- Backend integration suite: **535 passed, 0 failed**, using `npm test` in `lib/vips-backend`. The runner creates a temporary local database and its own API process, then removes that database. It does not use the developer's existing database.
- Selected Flutter controller, network, business logic and widget suites: **535 passed**. The live integration test targeting port 3000 was deliberately excluded because it can modify an existing database.
- Flutter analysis: **no errors**, 106 reported issues, including four warnings in test files and informational lints.
- Android debug builds: consumer (`lib/main.dart`) and merchant (`lib/main_merchant.dart`) succeeded. These are debug APKs, not signed release packages.
- Static inventory: 969 callbacks, 288 literal API calls, 341 backend route entries; no empty callback bodies, unmatched literal API paths or undeclared literal named navigation targets detected.

The static inventory is in `action-inventory.json`, regenerated with `python3 scripts/audit-app-contracts.py`. It cannot prove that every button works. Dynamic URLs, argument-dependent navigation, visual layout, permissions and external provider responses require additional runtime checks.

## Regression coverage added

Session token migration/logout, late unauthorized responses, merchant password authentication, undelivered OTP failure, catalogue-based checkout, ownership validation, invalid quantities, stale checkout totals, concurrent order numbering and wallet spending, cancellation refunds, weekly package billing and renewal, and unavailable external service handling.

Cart regressions also verify concurrent additions, authoritative catalogue prices, refreshed saved-cart prices, exclusive versus inclusive tax, and rejection of fractional quantities.

Consecutive failed quantity updates restore the last server-confirmed quantity. A widget regression exercises all four consumer navigation tabs and the wallet button after removing an invalid reactive wrapper that prevented the navigation bar from rendering.

## iOS runtime findings

The consumer app runs on the iPhone 16e simulator against a disposable local API database. The navigation bar's invalid `Obx` wrapper and controller disposal during guest route replacement were fixed; the focused checkout journey verifies these navigation paths. The complete button walk has **not** passed. Its harness uses in-memory preferences, records dispatched gestures separately from asserted business outcomes, and fails on collected Flutter errors. Small route batches and a progress watchdog limit stalled runs. Other projects also use this simulator, so process cleanup must remain scoped to the test's own processes.

## Remaining verification and integration work

- Exercise both apps on devices, including authenticated merchant and customer flows. The automated suites above do not constitute a complete button-by-button UI test.
- Utility bills, mobile recharge and donations have no implemented provider adapter. They return an unavailable response without debiting the wallet. Supplying an API key alone does not enable a working integration. Provider documentation and a sandbox are needed to finish these flows.
- Verify email delivery, Firebase authentication, Paymee and PayPal with the intended environment and provider test accounts. No real payments or external messages were sent as part of these checks.
- Review external payment refunds and crash recovery across multi-document financial writes before production release. Local compensation and atomic wallet updates do not provide a full distributed transaction guarantee.
- Complete release signing, platform-specific device checks and deployment configuration after functional verification.

Local test output: `/tmp/vips-backend-tests.log`, `/tmp/vips-flutter-tests.log`, `/tmp/vips-flutter-analyze.log`, `/tmp/vips-build-consumer.log`, `/tmp/vips-build-merchant.log`. Temporary logs are not durable release evidence.
