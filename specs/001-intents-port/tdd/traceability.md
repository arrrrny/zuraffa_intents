# Traceability: 001-intents-port

Coverage proof for `zfa tdd plan` (bug #846): every FR/AC requirement statement maps to a behavior row or an explicit manual declaration. Verify re-checks the hash — a spec edited after plan is drift (exit 3, re-plan required).

<!-- tdd:traceability
spec-hash: sha256:bff068cb8257fead761ec6d62bdd7bc51e5ef1a0c034be53ef2c49dfcd6ad31e
statements: 17
automated: 17
manual: 0
open-gaps: 0
-->

| requirement | line | statement | behavior | status |
| --- | --- | --- | --- | --- |
| AC-1 | 43 | 1. **Given** an adapter with a stored initial share, **When** | A1 | automated |
| AC-2 | 47 | 2. **Given** a stored initial share that was cleared via | A2 | automated |
| AC-3 | 52 | 3. **Given** a fresh adapter that never stored a share, **When** | A3 | automated |
| AC-4 | 80 | 1. **Given** a `recordSentMessage` call with all four arguments, **When** | A4 | automated |
| AC-5 | 87 | 2. **Given** two successive `recordSentMessage` calls (the second omitting | A5 | automated |
| AC-6 | 119 | 1. **Given** two listeners on `sharedMediaStream`, **When** a share is | A6 | automated |
| AC-7 | 122 | 2. **Given** a subscriber that attached after an earlier share was | A7 | automated |
| AC-8 | 127 | 3. **Given** a `ShareIntentService` over an in-memory port, **When** all | A8 | automated |
| FR-001 | 156 | - **FR-001**: `SharedAttachmentType` MUST expose exactly the four share | U1 | automated |
| FR-002 | 162 | - **FR-002**: `SharedAttachment` MUST be an immutable entity carrying the | U2 | automated |
| FR-003 | 167 | - **FR-003**: `SharedAttachment` MUST round-trip `toJson` → `fromJson` | U3 | automated |
| FR-004 | 170 | - **FR-004**: `SharedMedia` MUST be an immutable entity with the plugin's | U4 | automated |
| FR-005 | 181 | - **FR-005**: `SharedMedia.copyWith` MUST replace only the given fields | U5 | automated |
| FR-006 | 186 | - **FR-006**: The initial-share lifecycle on `ShareIntentPort` MUST work | U6 | automated |
| FR-007 | 193 | - **FR-007**: `recordSentMessage` MUST preserve the plugin's argument | U7 | automated |
| FR-008 | 201 | - **FR-008**: `sharedMediaStream` MUST be a broadcast stream: every | U8 | automated |
| FR-009 | 207 | - **FR-009**: `ShareIntentService` MUST be a thin facade over the port — | U9 | automated |

