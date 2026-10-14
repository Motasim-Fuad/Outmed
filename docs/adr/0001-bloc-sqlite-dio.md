# ADR 0001: BLoC, SQLite, and Dio

OutMed keeps the existing screens and replaces GetX with raw BLoC (`flutter_bloc`), `get_it`, and `go_router`.

- State changes go through events. Widgets subscribe with `context.watch` / `BlocSelector`. `context.read` is for dispatching events. Navigation that depends on state lives in `BlocListener`.
- HTTP uses Dio with a refresh interceptor and two retries. The default `APP_ENV` is `mock`, so the app runs when the API host is down. `--dart-define=APP_ENV=dev` calls the configured base URL.
- Catalog rows are cached in SQLite (`sqflite`). The in-memory seed paints the first frame; `bindLocal` replaces it when the database has rows.
- Stripe uses only a publishable key on the client. The payment intent is created by `POST /api/payments/intent`. The secret key stays on the server.
- Firebase stays off unless `FIREBASE_ENABLED=true`, so a missing `google-services` file does not crash startup.
