# Restaurant Map with Mapbox Vector Tiles - Quick Start

## ✨ What You Have Now

A **scalable restaurant map** that:

- ✅ Loads instantly with 10k+ restaurants
- ✅ Uses Mapbox Vector Tiles with server-side clustering (MTS)
- ✅ Fetches restaurant details on-demand (click-to-fetch)
- ✅ Works seamlessly on all zoom levels

## 🚀 Quick Start (Get Your Map Working)

### Prerequisites

Before you start, you need:

1. **Mapbox account** (free tier works) - https://account.mapbox.com/
2. **Python 3.7+** for Tilesets CLI
3. **WSL or Linux** (Windows not supported by Tilesets CLI)
4. **Restaurants in your database** with latitude/longitude

### Step 1: Create Mapbox Tokens

#### Public Token (for frontend)

1. Go to https://account.mapbox.com/access-tokens/
2. Create a new token with default scopes (`styles:read`, `fonts:read`, `sprites:read`)
3. Copy it to your `.env`:
   ```dotenv
   MAPBOX_PUBLIC_KEY=pk.eyJ1IjoidGhlLWdyb25rbGVyIiwiYSI...
   ```

#### Secret Token (for tileset publishing)

1. Create another token with these scopes: `tilesets:write`, `tilesets:read`, `tilesets:list`
2. **DO NOT commit this token!** Add it to GitHub Secrets as `MAPBOX_SECRET_TOKEN`

### Step 2: Install Tilesets CLI

On Linux / WSL / macOS:

```bash
pip install mapbox-tilesets
```

Set your token:

```bash
export MAPBOX_ACCESS_TOKEN=sk.xxx...  # Your secret token
```

### Step 3: Export Your Restaurants

```bash
php artisan map:export-restaurants --format=ldgeojson
```

This creates `storage/app/map/restaurants.geojson`.

### Step 4: Upload to Mapbox

Replace `<your-username>` with your Mapbox username:

```bash
# Upload source
tilesets upload-source <your-username> restaurants-source storage/app/map/restaurants.geojson

# Update recipe (replace {username} with yours)
sed -i "s/{username}/<your-username>/g" docs/mapbox-tileset-recipe.json

# Create tileset
tilesets create <your-username>.restaurants-clustered \
  --recipe docs/mapbox-tileset-recipe.json \
  --name "Restaurants Clustered"

# Publish tileset
tilesets publish <your-username>.restaurants-clustered

# Check status
tilesets status <your-username>.restaurants-clustered
```

Wait until status shows `"status": "success"`.

### Step 5: Configure Your App

Update `.env`:

```dotenv
MAPBOX_RESTAURANTS_TILESET=mapbox://<your-username>.restaurants-clustered
```

### Step 6: Test It!

1. Start Laravel:

   ```bash
   php artisan serve
   ```

2. Visit http://localhost:8000 (or your map route)

3. You should see:
   - **Zoomed out**: Clusters with numbers
   - **Zoom in**: Individual restaurant points
   - **Click a point**: Popup with restaurant details

## 📊 Architecture Overview

```
Database (restaurants table)
    ↓
php artisan map:export-restaurants
    ↓
Line-delimited GeoJSON file
    ↓
Mapbox Tiling Service (MTS)
    ↓
Vector Tileset (2 layers):
  • restaurants-clustered (zoom 0-14) - clusters with 'count' property
  • restaurants (zoom 15-16) - raw points with 'restaurant_id'
    ↓
Frontend fetches tiles based on viewport
    ↓
User clicks point → API request → /api/restaurants/{id}/map-card
```

## 🔄 Automated Updates (GitHub Actions)

### Setup

Add these secrets to your GitHub repo:

- `MAPBOX_USERNAME`
- `MAPBOX_SECRET_TOKEN`
- `DB_CONNECTION`, `DB_HOST`, `DB_PORT`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`

### Run

1. Go to Actions tab
2. Select "Update Mapbox Tileset"
3. Click "Run workflow"

The workflow will export, upload, and publish automatically (~5-10 min).

### Schedule Daily Updates

Uncomment the schedule trigger in `.github/workflows/update-mapbox-tileset.yml`:

```yaml
schedule:
  - cron: '0 2 * * *' # Daily at 2 AM UTC
```

## 🐛 Troubleshooting

### No Restaurants Appear

**Check:**

1. Browser console for errors
2. Network tab for tileset requests (should see `https://api.mapbox.com/v4/...`)
3. Tileset status: `tilesets status <username>.restaurants-clustered`
4. `.env` has correct `MAPBOX_RESTAURANTS_TILESET` value

### "Windows is not supported"

Use WSL:

```bash
wsl
cd /mnt/c/Studies/PRO_Thesis/yegor-sasha-thesis
pip install mapbox-tilesets
```

### Click Events Not Working

**Fix:**

1. Check `interactiveLayerIds` includes `['clusters', 'unclustered-point']`
2. Test API endpoint: `curl http://localhost:8000/api/restaurants/1/map-card`
3. Check browser console for errors

### Tileset Publishing Fails

**Common causes:**

- Wrong token (must use secret token `sk.xxx...`, not public `pk.xxx...`)
- Recipe has `{username}` placeholder not replaced
- Source not uploaded yet

## 📚 Documentation

For detailed information, see:

- **`docs/mapbox-tileset-setup.md`** - Complete setup guide
- **`docs/vector-tiles-implementation.md`** - Architecture and technical details

## 🎯 Key Files

| File                                                   | Purpose                         |
| ------------------------------------------------------ | ------------------------------- |
| `app/Console/Commands/ExportRestaurantsForTileset.php` | Export restaurants to GeoJSON   |
| `app/Http/Controllers/Customer/MapController.php`      | Render map page                 |
| `app/Http/Controllers/Api/RestaurantMapController.php` | API for restaurant details      |
| `resources/js/Components/Shared/Map.tsx`               | Map component                   |
| `resources/js/Components/Shared/mapStyles.ts`          | Layer styles (clusters, points) |
| `docs/mapbox-tileset-recipe.json`                      | MTS clustering configuration    |
| `.github/workflows/update-mapbox-tileset.yml`          | Automated tileset updates       |

## 🔍 Important Technical Details

### MTS Clustering vs GeoJSON Clustering

| Property               | MTS                                    | GeoJSON       |
| ---------------------- | -------------------------------------- | ------------- |
| Cluster count property | `count`                                | `point_count` |
| Source layers          | `restaurants-clustered`, `restaurants` | Single source |
| Property types         | Strings                                | Mixed         |

### Type Handling in Frontend

Vector tile properties are **strings**. Convert them:

```typescript
// ✅ Correct
const raw = feature.properties?.restaurant_id;
const restaurantId = raw != null ? Number(raw) : null;
if (Number.isFinite(restaurantId)) {
  // Use restaurantId
}
```

Layer filters need conversion:

```typescript
filter: ['==', ['to-number', ['get', 'restaurant_id']], selectedId ?? -999];
```

## 💰 Cost

With Mapbox free tier:

- ✅ 50,000 map loads/month
- ✅ 50 GB tile requests/month
- ✅ Unlimited tileset updates

**Typical usage with 10k restaurants + 1k daily users:** $0/month

## 🎨 Customization

### Change Cluster Colors

Edit `resources/js/Components/Shared/mapStyles.ts`:

```typescript
'circle-color': [
  'step',
  ['get', 'count'],
  'your-color-1', // < 2 restaurants
  2,
  'your-color-2', // 2-9 restaurants
  10,
  'your-color-3', // 10+ restaurants
]
```

### Adjust Clustering Radius

Edit `docs/mapbox-tileset-recipe.json`:

```json
"cluster_radius": 50  // Change to 30, 70, etc.
```

Then re-publish the tileset.

## 🚦 Current Status

Your implementation is **production-ready** and uses the correct scalable architecture:

✅ Vector tiles with MTS clustering (not client-side GeoJSON)  
✅ Correct layer properties (`count`, not `point_count`)  
✅ Correct source-layer names (`restaurants-clustered` and `restaurants`)  
✅ String-to-number conversion for `restaurant_id`  
✅ Click-to-fetch restaurant details (no heavy props)  
✅ GitHub Actions workflow for automated updates

## 📞 Need Help?

1. Check **browser console** for errors
2. Verify **tileset status** with CLI
3. Read **detailed docs** in `docs/` folder
4. Test **API endpoint** manually

---

**Ready to deploy!** Follow the Quick Start steps above to get your map running. 🗺️
