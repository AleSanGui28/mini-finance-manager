---
applyTo: "lib/features/**/*.dart"
---

Domain modeling rules:

- Prefer one Expense entity with type enum over separate entities unless requested.
- Never store confidential financial information.
- Card data may only store last 4 digits.
- Credit card shared limit is future functionality; do not implement unless requested.
- Repositories should expose watch* streams and add* methods.
