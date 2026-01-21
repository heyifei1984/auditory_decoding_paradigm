# Agent Guidelines

Follow this repo's workflow:
1) Ingest legacy code under `legacy_paradigm/`.
2) Extract behavioral contract into `docs/contract.md`.
3) Implement PsychoPy rewrite under `psychopy/` using the contract.

When making changes:
- Prefer small, auditable edits.
- Document assumptions in `docs/decisions.md` if needed.
- Keep paths and filenames ASCII.
