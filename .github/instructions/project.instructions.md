---
applyTo: "**"
---

# Mini Finance Manager Repository Instructions

This repository is a Flutter personal finance manager application.

Project goals:

- Offline-first
- Windows desktop first
- Android later
- No backend
- No hosting
- Drift + SQLite persistence

Preserve architecture:

- Feature-based structure
- domain / data / presentation separation
- shared code in lib/core
- database code in lib/core/database

Existing modules:

- Incomes
- Personal
- Expenses

Rules:

- Use English for code and comments.
- UI labels can be Spanish.
- Keep changes incremental and minimal.
- Preserve existing architectural patterns.
- Do not add dependencies unless explicitly requested.
- Do not add routing packages unless explicitly requested.
- Do not add state management packages unless explicitly requested.

Implementation behavior:
Before making changes:

1. Read existing project analysis markdown if present.
2. Inspect related files first.
3. Preserve patterns already in the repo.
4. Make smallest safe change possible.

Never:

- Refactor unrelated code
- Change architecture without approval
- Implement future features not requested
