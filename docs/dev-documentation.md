# Developer Documentation

## Intro

This file stores technical documentation useful during development. If a PR introduces something that needs to be 'kept in mind' during development, it should also update this file

## Related Documents

- [Frontend Project Structure](./fe-project-structure.md)
- [TypeScript Guidelines](./ts-guidelines.md)
- [CSS Documentation](./css-documentation.md)

## Running the app

Install Herd, run the app with **HTTPS** mode, and run `npm run dev` command from project root to start the Vite development server. You will need to run the database separately though. Alternatively, you can run in docker, instructions below.

### Real-Time Features (WebSockets)

The application uses **Laravel Reverb** for real-time updates (e.g., order status changes, menu availability).

#### 1. Environment Configuration

Ensure your `.env` is configured for HTTPS (required if using Herd with SSL):

```dotenv
REVERB_APP_ID=572887
REVERB_APP_KEY=fm3thdwjbmmri8yjvcm3
REVERB_APP_SECRET=qvfvf3thb0apndkdqaaz
REVERB_HOST="yegor-sasha-thesis.test"
REVERB_PORT=8080
REVERB_SCHEME=https

# Point to your Herd SSL certificates
REVERB_TLS_CERT="C:/Users/<USER>/.config/herd/config/valet/Certificates/yegor-sasha-thesis.test.crt"
REVERB_TLS_KEY="C:/Users/<USER>/.config/herd/config/valet/Certificates/yegor-sasha-thesis.test.key"

VITE_REVERB_APP_KEY="${REVERB_APP_KEY}"
VITE_REVERB_HOST="${REVERB_HOST}"
VITE_REVERB_PORT="${REVERB_PORT}"
VITE_REVERB_SCHEME="${REVERB_SCHEME}"
```

#### 2. Start the WebSocket Server

Open a terminal and run:

```powershell
php artisan reverb:start
```

_Note: If you see SSL errors in the browser console, ensure you have accepted the certificate for port 8080 by visiting `https://yegor-sasha-thesis.test:8080` in your browser once._

#### 3. Start the Queue Worker

Events are broadcast asynchronously via the queue. Open a separate terminal and run:

```powershell
php artisan queue:work
```

### One-Command Startup

You can run Vite, Reverb, and the Queue Worker simultaneously using the following npm command:

```powershell
npm run dev:all
```

## Console commands

Custom artisan commands, to use type:

```powershell
php artisan <command-name>
```

### Database Seeding Commands

#### `mfs` - Migrate Fresh with Seed

**Description:** Wipes the database, reruns all migrations, and seeds the database with configurable data.

**Usage:**

```powershell
php artisan mfs [options]
```

**Options:**

- `--force`: Force the operation to run when in production
- `--restaurants=<number>`: Number of restaurants to seed (default: 10)
- `--customers=<number>`: Number of customers to seed (default: 15)
- `--employees-min=<number>`: Minimum employees per restaurant (default: 2)
- `--employees-max=<number>`: Maximum employees per restaurant (default: 14)
- `--orders-per-restaurant=<number>`: Number of orders per restaurant (default: 4)
- `--radius=<number>`: Radius in km for restaurant distribution (default: 10)

**Seeding order:** static data (allergens, order statuses) → restaurants (with menu items, food types, images) → admin user → customers → employees → orders (per restaurant) → reviews (1-14 per restaurant) → default employee.

**Examples:**

```powershell
# Default seeding
php artisan mfs

# Custom minimal setup
php artisan mfs --restaurants=5 --customers=3 --employees-min=1 --employees-max=2 --radius=5

# Force in production with heavy data
php artisan mfs --force --restaurants=50 --customers=100 --orders-per-restaurant=6
```

#### `seed:restaurants` - Seed Restaurants Only

**Description:** Seeds restaurants with natural clustered distribution around a center point.

**Usage:**

```powershell
php artisan seed:restaurants [options]
```

**Options:**

- `--center-lat=<float>`: Center latitude (default: 52.2297 - Warsaw)
- `--center-lon=<float>`: Center longitude (default: 21.0122 - Warsaw)
- `--radius=<float>`: Radius in km for distribution (default: 10)
- `--count=<number>`: Number of restaurants to seed (default: 10)

**Examples:**

```powershell
# Default Warsaw seeding
php artisan seed:restaurants

# Custom location and count
php artisan seed:restaurants --center-lat=50.0647 --center-lon=19.9450 --radius=5 --count=20
```

#### `seed:static-data` - Seed Static Data

**Description:** Seeds static data that doesn't change (allergens and order statuses).

**Usage:**

```powershell
php artisan seed:static-data
```

**Options:** None

**Example:**

```powershell
php artisan seed:static-data
```

### Other Commands

- `ziggy:generate`

  Generates the `resources/js/ziggy.js` file. Run this whenever you add or modify named routes in `routes/web.php` to make them available in the frontend.

## Running with Docker

### Prerequisites

- Docker Desktop installed and running.

### Quick Start

1.  **Configure Environment**:

    ```powershell
    cp .env.example .env
    ```

2.  **Start Application**:

    ```powershell
    docker-compose up -d --build
    ```

3.  **First Run Setup**:
    If this is your first time running the project, generate the app key:

    ```powershell
    docker-compose exec app php artisan key:generate
    ```

4.  **Access**:
    - App: [https://yegor-sasha-thesis.test](https://yegor-sasha-thesis.test)
    - Database: `127.0.0.1:3306`

### Stopping

```powershell
docker-compose down
```

## Local SSL Setup (HTTPS)

We use Caddy to serve the application over HTTPS locally (`https://yegor-sasha-thesis.test`). To avoid browser security warnings, you need to trust the self-signed certificate generated by Caddy.

**Note:** You only need to do this once (unless you delete the `caddy_data` Docker volume).

### 1. Export the Certificate

Run this command in your terminal while the containers are running:

```powershell
docker cp thesis-caddy:/data/caddy/pki/authorities/local/root.crt ./caddy-root.crt
```

### 2. Install/Trust the Certificate (Windows)

1.  Double-click the `caddy-root.crt` file in your project root.
2.  Click **Install Certificate...**.
3.  Select **Current User** and click **Next**.
4.  Select **"Place all certificates in the following store"**.
5.  Click **Browse...** and select **"Trusted Root Certification Authorities"**. (Critical Step!)
6.  Click **OK**, then **Next**, then **Finish**.
7.  Confirm the security warning by clicking **Yes**.

### 3. Restart Browser

Close and reopen your browser. The site should now be secure.

## Formatting

### Git Hooks (Automation)

We use **Husky** and **lint-staged** to automatically format files before they are committed.

- When you run `git commit`, only the **staged files** (the ones you added) will be formatted.
- If formatting changes are made, they are automatically added to the commit.
- This ensures that no unformatted code enters the repository.

- Theat means you dont need to run the commands below manually

### Frontend (JS/TS/CSS)

We use **Prettier** for code formatting. The configuration is located in [`.prettierrc`](../.prettierrc).

To format all frontend files, run:

```powershell
npm run format
```

### Backend (PHP)

We use **Laravel Pint** for PHP formatting. The configuration is located in [`pint.json`](../pint.json).

To format all PHP files, run:

```powershell
composer run format
```

Or the alias:

```powershell
npm run format:php
```

### Format Everything

To format both frontend and backend files in one go, run:

```powershell
npm run format:all
```

## Deployment

### Resetting Production Database

If you need to completely wipe and re-seed the production database (e.g., during initial setup or if the database state is corrupted), use the following command on the server:

```bash
docker compose run --rm --entrypoint="" app php artisan mfs --force
```

**Warning:** This will destroy all data in the production database.
