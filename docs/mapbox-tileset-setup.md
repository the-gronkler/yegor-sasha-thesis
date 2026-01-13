# Mapbox Vector Tiles Setup Guide

This guide walks you through setting up the restaurant map with Mapbox Vector Tiles and clustering.

## Prerequisites

- Mapbox account (free tier works)
- Python 3.7+ (for Tilesets CLI)
- WSL or Linux environment (Windows is not officially supported by Tilesets CLI)
- Laravel application with restaurants in database

## Step 1: Create Mapbox Access Tokens

You need **two tokens** with different scopes:

### Public Token (Frontend)

1. Go to https://account.mapbox.com/access-tokens/
2. Click "Create a token"
3. Name: `Public Token - Restaurants Map`
4. Scopes: `styles:read`, `fonts:read`, `sprites:read` (default public scopes)
5. Copy token → Add to `.env` as `MAPBOX_PUBLIC_KEY=pk.xxx...`

### Secret Token (Tilesets CLI)

1. Click "Create a token"
2. Name: `Secret Token - Tilesets`
3. Scopes: **Check these boxes:**
   - `tilesets:write`
   - `tilesets:read`
   - `tilesets:list`
4. Copy token → Add to GitHub Secrets as `MAPBOX_SECRET_TOKEN`
5. ⚠️ **Never commit this token to git!**

## Step 2: Install Tilesets CLI

### On Linux / WSL / macOS:

```bash
pip install mapbox-tilesets
```

### Verify installation:

```bash
tilesets --help
```

### Set your access token:

```bash
export MAPBOX_ACCESS_TOKEN=sk.xxx...  # Your secret token
```

## Step 3: Export Restaurant Data

Run the Laravel export command:

```bash
php artisan map:export-restaurants --format=ldgeojson
```

This creates `storage/app/map/restaurants.geojson` with line-delimited GeoJSON (recommended by Mapbox).

**Output example:**

```
Found 1234 restaurants with coordinates.
✓ Exported to: /path/to/storage/app/map/restaurants.geojson
File size: 156.78 KB
```

## Step 4: Upload Tileset Source

Upload the exported file as a tileset source:

```bash
tilesets upload-source <your-username> restaurants-source storage/app/map/restaurants.geojson
```

Replace `<your-username>` with your Mapbox username (found at https://account.mapbox.com/).

**Example:**

```bash
tilesets upload-source the-gronkler restaurants-source storage/app/map/restaurants.geojson
```

## Step 5: Create and Publish Tileset

### Update the recipe file

Edit `docs/mapbox-tileset-recipe.json` and replace `{username}` with your Mapbox username:

```json
{
  "version": 1,
  "layers": {
    "restaurants-clustered": {
      "source": "mapbox://tileset-source/YOUR-USERNAME/restaurants-source",
      ...
    },
    "restaurants": {
      "source": "mapbox://tileset-source/YOUR-USERNAME/restaurants-source",
      ...
    }
  }
}
```

### Create the tileset

```bash
tilesets create <your-username>.restaurants-clustered \
  --recipe docs/mapbox-tileset-recipe.json \
  --name "Restaurants Clustered"
```

### Publish the tileset

```bash
tilesets publish <your-username>.restaurants-clustered
```

**Processing time**: 30 seconds to 5 minutes depending on dataset size.

### Check status

```bash
tilesets status <your-username>.restaurants-clustered
```

Wait until status shows `"status": "success"`.

## Step 6: Configure Laravel

Update your `.env`:

```dotenv
MAPBOX_PUBLIC_KEY=pk.eyJ1IjoidGhlLWdyb25rbGVyIiwiYSI...
MAPBOX_RESTAURANTS_TILESET=mapbox://your-username.restaurants-clustered
```

Replace `your-username` with your actual Mapbox username.

## Step 7: Test the Map

1. Start your Laravel server:

   ```bash
   php artisan serve
   ```

2. Visit the map page (e.g., `http://localhost:8000`)

3. You should see:
   - Clustered circles at low zoom levels
   - Individual restaurant points at high zoom
   - Popup with restaurant details when clicking a point

### Debugging

If restaurants don't appear:

1. **Check browser console** for errors
2. **Verify tileset URL** in Network tab:
   - Should load from `https://api.mapbox.com/v4/...`
3. **Inspect tileset** in Mapbox Studio:
   - https://studio.mapbox.com/tilesets/your-username.restaurants-clustered/
4. **Check layer names** in browser DevTools:
   - Layers should be `restaurants-clustered` and `restaurants`

## Step 8: Set Up GitHub Actions (Automated Updates)

### Add GitHub Secrets

Go to your repo → Settings → Secrets and variables → Actions → New repository secret:

- `MAPBOX_USERNAME`: Your Mapbox username
- `MAPBOX_SECRET_TOKEN`: Your secret token (sk.xxx...)
- Database credentials: `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`

### Run the workflow

1. Go to Actions tab in GitHub
2. Select "Update Mapbox Tileset"
3. Click "Run workflow"

The workflow will:

- Export restaurants from database
- Upload to Mapbox
- Publish tileset
- ~5-10 minutes total

### Schedule automatic updates

Uncomment the `schedule` trigger in `.github/workflows/update-mapbox-tileset.yml`:

```yaml
on:
  workflow_dispatch:
  schedule:
    - cron: '0 2 * * *' # Daily at 2 AM UTC
```

## Updating Restaurants

When you add/update/delete restaurants:

### Option A: Manual update (development)

```bash
# 1. Export
php artisan map:export-restaurants

# 2. Upload
tilesets upload-source <your-username> restaurants-source storage/app/map/restaurants.geojson --replace

# 3. Publish
tilesets publish <your-username>.restaurants-clustered

# 4. Wait for processing
tilesets status <your-username>.restaurants-clustered
```

### Option B: Automated (production)

Trigger the GitHub Actions workflow manually or wait for scheduled run.

## Troubleshooting

### "tilesets: command not found"

**Solution**: Ensure Python 3 and pip are installed, then `pip install mapbox-tilesets`.

### "Windows is not supported"

**Solution**: Use WSL (Windows Subsystem for Linux):

```bash
wsl
cd /mnt/c/path/to/your/project
pip install mapbox-tilesets
```

### "Invalid token" errors

**Solution**: Make sure you're using the **secret token** (sk.xxx...) not the public token (pk.xxx...).

### Restaurants not appearing on map

**Checklist**:

- [ ] Tileset status is "success" (check with `tilesets status`)
- [ ] `.env` has correct `MAPBOX_RESTAURANTS_TILESET` value
- [ ] Browser console shows no errors
- [ ] Network tab shows tileset loading (should see requests to api.mapbox.com/v4/)

### Click events not working

**Check**:

- [ ] `interactiveLayerIds` includes `['clusters', 'unclustered-point']`
- [ ] API endpoint `/api/restaurants/{id}/map-card` returns data
- [ ] Browser console for click handler errors

## Cost Estimate

Mapbox pricing (as of 2026):

- **Free tier**: 50,000 map loads/month, 50 GB tile requests/month
- **Vector tiles**: Included in free tier
- **Tilesets API**: Unlimited updates

For typical usage with 10k restaurants and 1k daily users:

- **Cost**: $0/month (well within free tier)

## Next Steps

- Read `docs/vector-tiles-implementation.md` for architecture details
- Customize cluster styling in `resources/js/Components/Shared/mapStyles.ts`
- Add filters/search to `MapController@index`
- Implement real-time updates with WebSocket overlay
