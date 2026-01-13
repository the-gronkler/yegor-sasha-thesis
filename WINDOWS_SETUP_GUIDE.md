# Windows Setup Guide for Mapbox Tilesets

## ⚠️ Important: Windows Limitation

The Mapbox Tilesets CLI is **not officially supported on Windows**. You have three options:

## Option 1: Use WSL (Windows Subsystem for Linux) - RECOMMENDED

This is the easiest way to run the Tilesets CLI on Windows.

### Step 1: Install WSL

Open PowerShell as Administrator and run:

```powershell
wsl --install
```

Restart your computer when prompted.

### Step 2: Open WSL

After restart, search for "Ubuntu" in Start Menu and open it.

### Step 3: Install Python and pip in WSL

```bash
sudo apt update
sudo apt install python3 python3-pip -y
```

### Step 4: Install Mapbox Tilesets CLI

```bash
pip3 install mapbox-tilesets
```

### Step 5: Navigate to Your Project

```bash
cd /mnt/c/Studies/PRO_Thesis/yegor-sasha-thesis
```

### Step 6: Export and Upload

```bash
# Set your Mapbox token (use your secret token sk.xxx...)
export MAPBOX_ACCESS_TOKEN=sk.xxx...

# Export restaurants
php artisan map:export-restaurants --format=ldgeojson

# Upload source (replace <your-username> with your Mapbox username)
tilesets upload-source <your-username> restaurants-source storage/app/map/restaurants.geojson

# Create tileset
tilesets create <your-username>.restaurants-clustered \
  --recipe docs/mapbox-tileset-recipe.json \
  --name "Restaurants Clustered"

# Publish tileset
tilesets publish <your-username>.restaurants-clustered

# Check status
tilesets status <your-username>.restaurants-clustered
```

---

## Option 2: Use GitHub Actions (No Local Setup Needed)

This is the **easiest option** if you don't want to install WSL.

### Step 1: Add GitHub Secrets

Go to your GitHub repo → Settings → Secrets and variables → Actions → New repository secret:

Add these secrets:

- `MAPBOX_USERNAME` - Your Mapbox username (e.g., `the-gronkler`)
- `MAPBOX_SECRET_TOKEN` - Your Mapbox secret token (starts with `sk.`)
- Database credentials (if using a hosted DB):
  - `DB_CONNECTION=mariadb`
  - `DB_HOST=your-host`
  - `DB_PORT=3306`
  - `DB_DATABASE=yegor_sasha_thesis`
  - `DB_USERNAME=your-username`
  - `DB_PASSWORD=your-password`

### Step 2: Prepare Your Recipe

Edit `docs/mapbox-tileset-recipe.json` and replace `{username}` with your actual Mapbox username.

### Step 3: Commit and Push Your Code

```powershell
git add .
git commit -m "Add Mapbox tileset configuration"
git push
```

### Step 4: Run the Workflow

1. Go to your GitHub repo
2. Click the "Actions" tab
3. Select "Update Mapbox Tileset" workflow
4. Click "Run workflow" button
5. Wait 5-10 minutes for completion

### Step 5: Configure Your .env

After the workflow succeeds, update your `.env`:

```dotenv
MAPBOX_RESTAURANTS_TILESET=mapbox://your-username.restaurants-clustered
```

Restart your Laravel server and test the map!

---

## Option 3: Install Python on Windows (Not Recommended)

If you really want to try installing on Windows directly (may have issues):

### Step 1: Install Python

1. Download Python 3.11+ from https://www.python.org/downloads/
2. **IMPORTANT**: Check "Add Python to PATH" during installation
3. Restart PowerShell after installation

### Step 2: Verify Installation

```powershell
python --version
pip --version
```

### Step 3: Install Mapbox Tilesets CLI

```powershell
pip install mapbox-tilesets
```

**Note**: This may fail or have compatibility issues on Windows. If it fails, use Option 1 (WSL) instead.

---

## Recommended Approach

For the **best experience**, use:

1. **Development**: Option 1 (WSL) - Run commands locally as needed
2. **Production**: Option 2 (GitHub Actions) - Automated updates

## Quick Start with GitHub Actions

If you just want to **get your map working now** without installing anything:

1. Edit `docs/mapbox-tileset-recipe.json` - replace `{username}` with yours
2. Add GitHub secrets (see Option 2, Step 1)
3. Run the GitHub Actions workflow
4. Update `.env` with tileset ID
5. Test your map!

**Time needed**: ~15 minutes (most of it is waiting for the workflow to run)

---

## Testing the Map

After your tileset is published (via any option), test it:

1. Update `.env`:

   ```dotenv
   MAPBOX_RESTAURANTS_TILESET=mapbox://your-username.restaurants-clustered
   ```

2. Start Laravel:

   ```powershell
   php artisan serve
   ```

3. Visit http://localhost:8000

You should see:

- Clusters at low zoom
- Individual points at high zoom
- Popup on click

---

## Troubleshooting

### "wsl: command not found"

You need Windows 10 version 2004 or higher. Check your Windows version:

```powershell
winver
```

Update Windows if needed, then try `wsl --install` again.

### GitHub Actions Workflow Fails

Check:

- All secrets are added correctly
- `docs/mapbox-tileset-recipe.json` has your username (not `{username}`)
- Your Mapbox token has `tilesets:write` scope

### Tileset Published but No Restaurants Appear

Check:

1. Browser console for errors
2. Network tab - should see requests to `api.mapbox.com/v4/`
3. Tileset URL in `.env` matches your username

---

## Need Help?

If you're stuck:

1. **Use Option 2 (GitHub Actions)** - It's the simplest and works without any local setup
2. Check the workflow logs in GitHub Actions for error messages
3. Verify your Mapbox tokens and secrets are correct

The GitHub Actions approach is **production-ready** and what you'll use for updates anyway, so it's a great choice even for initial setup!
