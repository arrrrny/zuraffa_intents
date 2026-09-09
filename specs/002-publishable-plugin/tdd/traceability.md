# Traceability: 002-publishable-plugin

Coverage proof for `zfa tdd plan` (bug #846): every FR/AC requirement statement maps to a behavior row or an explicit manual declaration. Verify re-checks the hash — a spec edited after plan is drift (exit 3, re-plan required).

<!-- tdd:traceability
spec-hash: sha256:3d5a3051cb287faee3c6af456cc5c2891bac9be87c81323f539437cec2504435
statements: 20
automated: 20
manual: 0
open-gaps: 0
-->

| requirement | line | statement | behavior | status |
| --- | --- | --- | --- | --- |
| AC-1 | 50 | 1. **Given** a stored initial share on the native side, **When** | A1 | automated |
| AC-2 | 58 | 2. **Given** a `recordSentMessage` call, **When** the port sends over its | A2 | automated |
| AC-3 | 67 | 3. **Given** `resetInitialSharedMedia`, **When** the port sends a null | A3 | automated |
| AC-4 | 98 | 1. **Given** a native event carrying a wire map with percent-encoded | A4 | automated |
| AC-5 | 103 | 2. **Given** repeated access to `sharedMediaStream`, **When** two listeners | A5 | automated |
| AC-6 | 139 | 1. **Given** `registerShareIntentDependencies` on a fresh `GetIt`, | A6 | automated |
| AC-7 | 146 | 2. **Given** the ported native trees, **When** the consistency suite | A7 | automated |
| AC-8 | 153 | 3. **Given** the package tree, **When** the publish contract is checked, | A8 | automated |
| FR-001 | 180 | - **FR-001**: The package MUST be publish-ready for pub.dev: `pubspec.yaml` | U1 | automated |
| FR-002 | 190 | - **FR-002**: Wire-map fidelity — `sharedAttachmentWireMap` MUST produce | U2 | automated |
| FR-003 | 198 | - **FR-003**: The wire codec MUST be a `StandardMessageCodec` subclass that | U3 | automated |
| FR-004 | 207 | - **FR-004**: The iOS/macOS attachment-path quirk — attachment paths | U4 | automated |
| FR-005 | 215 | - **FR-005**: `getInitialSharedMedia` over the pigeon channel MUST map: a | U5 | automated |
| FR-006 | 222 | - **FR-006**: `recordSentMessage` MUST send the single-element envelope | U6 | automated |
| FR-005 | 229 | FR-005 semantics. | U5 | automated |
| FR-007 | 231 | - **FR-007**: `resetInitialSharedMedia` MUST send a null payload on its | U7 | automated |
| FR-008 | 235 | - **FR-008**: `sharedMediaStream` MUST be the `EventChannel | U8 | automated |
| FR-004 | 238 | FR-004 quirk, and MUST be a lazy singleton per port instance (repeated | U4 | automated |
| FR-009 | 242 | - **FR-009**: Platform wiring — `ShareIntentService.platform()` MUST be a | U9 | automated |
| FR-010 | 250 | - **FR-010**: Native port consistency — the ported native trees | U10 | automated |

