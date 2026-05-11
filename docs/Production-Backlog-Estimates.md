# Production Backlog With Estimates (iPhone)

## Assumptions
- 1 iOS engineer = 1 dev-day.
- iOS target: 17+.
- UI/UX design system is provided.
- QA is included in each task estimate.

## Epic 1 - Core Data and Domain
1. `E1-T1` SwiftData schema hardening (migrations, indexes, constraints) - 2d
2. `E1-T2` Repository layer and transactional operations - 2d
3. `E1-T3` Unit tests for outfit rules and planning logic - 2d
4. `E1-T4` Seed strategy and sample data switch for debug/release - 1d

Subtotal: 7d

## Epic 2 - Wardrobe Capture
1. `E2-T1` Camera capture flow with retries and errors - 2d
2. `E2-T2` Gallery import and image compression pipeline - 2d
3. `E2-T3` Background removal integration point (ML-ready abstraction) - 3d
4. `E2-T4` Fast add UX (one-screen mode + presets) - 2d
5. `E2-T5` Batch scan mode (10+ items in session) - 3d

Subtotal: 12d

## Epic 3 - Outfit Builder and Recommendation
1. `E3-T1` Slot-based outfit builder with conflict checks - 3d
2. `E3-T2` Recommendation engine v1 (weather + season + formality) - 3d
3. `E3-T3` Favorites, duplication, and quick actions - 2d
4. `E3-T4` Edge-case tests (empty categories, unavailable items) - 1d

Subtotal: 9d

## Epic 4 - Planner and Daily Flow
1. `E4-T1` Weekly calendar planner and day assignment - 2d
2. `E4-T2` Morning flow "what to wear now" - 2d
3. `E4-T3` Wear tracking and auto status transitions - 2d
4. `E4-T4` Local notifications for planned outfits - 2d

Subtotal: 8d

## Epic 5 - Weather and External Integration
1. `E5-T1` Weather API client hardening (retry, timeout, cache) - 2d
2. `E5-T2` Location permission UX and fallback behavior - 1d
3. `E5-T3` Offline snapshot cache and stale-data policy - 2d

Subtotal: 5d

## Epic 6 - Privacy, Security, and Sync
1. `E6-T1` Face ID app lock and secure unlock states - 2d
2. `E6-T2` iCloud sync architecture and merge strategy - 4d
3. `E6-T3` Privacy policy screens and consent tracking - 1d

Subtotal: 7d

## Epic 7 - Quality and Release
1. `E7-T1` Crash/analytics instrumentation - 2d
2. `E7-T2` UI polish and accessibility pass - 3d
3. `E7-T3` Performance optimization (large wardrobe dataset) - 2d
4. `E7-T4` TestFlight pipeline and release checklist - 2d

Subtotal: 9d

## Total
- Estimated delivery: **57 dev-days**
- With 2 iOS engineers in parallel: ~6-7 calendar weeks
- With 1 iOS engineer: ~11-12 calendar weeks

## Critical Path
1. Epic 1 -> Epic 2 -> Epic 3 -> Epic 4
2. Epic 5 runs in parallel after Epic 1
3. Epic 6 starts after Epic 1, finishes before release
4. Epic 7 starts gradually from sprint 2 and closes last

## MVP Release Cut
- Must-have before TestFlight:
  - E1-T1..T4
  - E2-T1..T4
  - E3-T1..T2
  - E4-T1..T3
  - E5-T1..T2
  - E7-T1, E7-T2

## Stretch (post-v1)
1. Style AI with explainable scoring.
2. Trip capsule planner.
3. Shared household wardrobe.
