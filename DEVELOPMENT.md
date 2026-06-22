# Development Setup

This guide covers how to set up the project locally, run the backend, populate the database with seed data, and run the mobile app.

---

## Prerequisites

| Component | Version | Purpose |
|-----------|---------|---------|
| Rust | Latest stable | Backend API |
| PostgreSQL | 16+ | Database |
| Flutter | 3.22+ (stable) | Mobile app |
| Docker | Any recent version | Optional PostgreSQL container |

---

## 1. Environment Configuration

Copy the example environment file and adjust it for your setup:

```bash
cp .env.example .env
```

### Default `.env` values

```env
APP__SERVER_HOST=127.0.0.1
APP__SERVER_PORT=3000
APP__LOG_LEVEL=info
APP__DATABASE_URL=postgres://postgres:postgres@localhost:5432/house_hunting
```

- `APP__DATABASE_URL` must point to a running PostgreSQL instance.
- The project uses the `config` crate with `__` as the separator, so environment variables map directly to the struct fields.

---

## 2. Database Setup

### Option A: Docker (Recommended)

Start a PostgreSQL container with a single command:

```bash
docker run -d \
  --name house-hunting-db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=house_hunting \
  -p 5432:5432 \
  postgres:16-alpine
```

### Option B: Local PostgreSQL

If you already have PostgreSQL installed, create the database manually:

```bash
psql -U postgres -c "CREATE DATABASE house_hunting;"
```

Make sure your `APP__DATABASE_URL` matches your local credentials.

---

## 3. Build the Backend

From the project root:

```bash
cargo build
```

This compiles the server and all binaries, including the seed script.

---

## 4. Run Database Migrations

Migrations are embedded in the binary and run automatically when the server starts, but you can also trigger them manually by running the server once:

```bash
cargo run
```

The server will connect to the database, verify the connection, and apply any pending migrations. On success, you will see:

```
INFO Database connection verified successfully.
INFO Database migrations completed successfully.
INFO Server starting on http://127.0.0.1:3000
```

---

## 5. Seed the Database

The project includes a seed binary that populates the `houses` table with 22 realistic Cameroon rental listings.

### Run the seed script

```bash
cargo run --bin seed
```

### What the seed script does

- Connects to the database using the same `APP__DATABASE_URL` configuration.
- Runs migrations if they have not already been applied.
- Checks whether the `houses` table already contains rows.
- If rows exist, it **truncates the table and restarts the identity sequence** so the script can be run repeatedly without duplicate entries.
- Inserts 22 sample houses across multiple Cameroon cities (Yaoundé, Douala, Buea, Limbe, Bamenda, Bafoussam, Kumba, Maroua, Ngaoundéré, Garoua).

### Re-seeding

You can run the seed script as many times as you like. It is idempotent by design:

```bash
cargo run --bin seed
```

Each run will clear existing seed data and insert fresh records.

---

## 6. Run the Backend Server

```bash
cargo run
```

The API server starts on `http://127.0.0.1:3000` by default.

### Verify the server is running

```bash
curl http://127.0.0.1:3000/health
```

Expected response:

```json
{"status":"ok"}
```

---

## 7. Run the Flutter App

The Flutter mobile app lives in the same repository. Ensure Flutter is installed and on your `PATH`.

```bash
flutter pub get
flutter run
```

To run on a specific device or emulator, list available targets first:

```bash
flutter devices
flutter run -d <device_id>
```

---

## 8. Running Tests

### Backend (Rust)

```bash
cargo test
```

Tests verify the database connection, migrations, table schema, indexes, and basic CRUD operations. They require a PostgreSQL instance to be available and configured via `APP__DATABASE_URL`.

### Mobile (Flutter)

```bash
flutter test
```

---

## 9. Common Commands

| Command | Purpose |
|---------|---------|
| `cargo run` | Start the backend server |
| `cargo run --bin seed` | Populate the database with sample data |
| `cargo test` | Run Rust tests |
| `cargo clippy --all-targets --all-features` | Run the linter |
| `cargo fmt` | Format Rust code |
| `flutter pub get` | Install Flutter dependencies |
| `flutter run` | Run the mobile app |
| `flutter test` | Run Flutter tests |
| `flutter build apk` | Build an Android release APK |

---

## 10. Troubleshooting

### Database connection errors

- Confirm PostgreSQL is running (`pg_isready -h localhost -p 5432`).
- Verify `APP__DATABASE_URL` has the correct username, password, and database name.
- If using Docker, ensure the container port is mapped to the host (`-p 5432:5432`).

### Migration failures

- Check that the database user has permission to create tables and indexes.
- If a migration is partially applied, drop and recreate the database, then restart the server:

```bash
docker exec -it house-hunting-db psql -U postgres -c "DROP DATABASE house_hunting; CREATE DATABASE house_hunting;"
```

### Seed script fails

- Ensure the server has been started at least once so the `houses` table exists (or migrations have run).
- Check the database connection string is exported or present in `.env`.

---

## 11. Architecture Notes

- **Backend:** Rust (Axum + SQLx + PostgreSQL)
- **Mobile:** Flutter (Dart)
- **Database:** PostgreSQL with embedded SQLx migrations
- **Configuration:** Environment variables via `config` crate (prefix `APP__`)
- **Seed data:** Realistic Cameroon rental listings for frontend development without manual data entry
