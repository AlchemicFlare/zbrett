# ADR-0003 — `brett.core` owns the wire format and policy schema

**Status:** accepted (2026-07-18)

## Decision
`brett.core.wire`, `brett.core.codec`, `brett.core.policy` and
`brett.core.dictionary` are the **single contract**. Every other package imports
them; none redefines a field layout. `inline_max` is *derived from M3*, exposed
as `brett.core.wire.INLINE_MAX_CHARS` (None until measured) — never hardcoded
elsewhere.

`dict_allow` slots are **append-only**; the 4-bit index is reserved in the header
even with a single dictionary, because retrofitting it is a format break (MVP §6).

## Consequence
Changing the wire format is a deliberate, reviewed event, not a local edit in a
consumer. This is why the code is a monorepo (ADR-0001).
