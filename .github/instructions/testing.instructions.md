---
applyTo: "test/**/*.dart"
---

# Testing Instructions

Use Flutter standard testing tools unless explicitly requested otherwise.

Testing rules:

- Use `flutter_test`.
- Keep tests readable and focused.
- Prefer behavior tests over styling tests.
- Use descriptive group and test names.
- Avoid unnecessary mocks.
- Do not add testing dependencies unless explicitly requested.

Feature testing expectations:

- Domain models should have unit tests.
- Enums and label extensions should have unit tests.
- Repositories should have database tests when possible.
- Pages should have basic widget tests for rendering and validation.

For Drift repository tests:

- Prefer an in-memory database.
- Do not use the real local app database.
- Do not depend on user machine data.

Verification command:

```bash
flutter test
```
