# Merchant verification — 2026-09-08

Scope: `lib/appmerchant`, entrypoint `lib/main_merchant.dart`, flavor `merchant`.
This is a working verification record, not release approval.

## Confirmed

- Real iOS merchant sales journey **passed**: password sign-in, editing a product through the UI, backend read-back preserving promotion/tax/type/description, and loading actual customer orders. Log: `/tmp/vips-merchant-sales.log` (test runtime 38s; build 314.9s).
- Backend isolated integration suite: **535 passed / 0 failed**. Log: `/tmp/vips-merchant-backend-tests.log`. Port 3102 and its temporary database were separate from the simulator backend and removed on completion.
- Static merchant inventory: 410 callback sites and 136 literal API calls. All literal API calls match a registered backend route. This does not establish correct rendering, permissions or business outcomes.
- Merchant Flutter suites: **145 passed**, including product edit/resize, MongoDB customer identifier parsing, reactive dues balances, Gift Back layout/consent and the order filter sheet's reachable clear button. Log: `/tmp/vips-merchant-flutter-tests.log`.

## Fixes

- Product editing now initializes once per screen and restores promotional price, tax method, product type and variants. Previously these fields could revert on save, and a screen rebuild could replace typed edits with old values.
- Product edits retain the existing description, and new forms clear stale category, tax, type and promotional-price values.
- The product regression now passes on a narrow phone layout. Image selection status and tax dropdown width were also corrected after that test exposed overflow.
- Merchant orders now accept the backend's string customer ID. The previous integer field prevented real orders from loading; covered by a model regression.
- Removed a redundant reactive wrapper from dues summary; a widget regression verifies both balances update.
- Business profile and Gift Back controls now have a Material surface; Gift Back labels have bounded width. The second simulator batch exercised these screens without Flutter errors. Settings and staff sheets were also corrected.
- The second batch isolated the remaining 83px overflow to the order filter sheet. That sheet now uses the available height and scrolls; its widget regression passes. Fresh device verification is included in the finance batch.

## Runtime work

- Initial iOS core exploration visited home, orders, catalog, create bill, wallet and customers: 80 dispatched taps. It **failed**, exposing the defects above. Log: `/tmp/vips-merchant-buttons-core.log`; structured records: `merchant-simulator-actions.json`.
- Second batch: seven root screens, 53 dispatched taps, two instances of the same order filter overflow. Other exercised roots (dues, business switcher, Gift Back, settings, notifications, staff) emitted no Flutter errors. Five dynamic controls became unavailable during exploration and are not counted as verified. Log: `/tmp/vips-merchant-buttons-fixes.log`.
- Finance/inventory/credit batch is in progress: `/tmp/vips-merchant-buttons-finance.log`.
- Remaining routes, nested dialogs, actual product submission and order workflows still require device verification. Dispatched gestures alone must not be labeled business passes.
- Native camera/files/printing, provider payments and email delivery need dedicated checks. No real external payments or messages have been sent.
- Current signed release builds, deployment environment and production financial crash recovery are not verified by the local suite.
