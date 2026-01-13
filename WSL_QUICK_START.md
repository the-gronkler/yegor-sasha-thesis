# Quick Start - Install Mapbox Tilesets CLI in WSL

## You're Almost There! 🎉

You have:
✅ Python 3.12 on Windows  
✅ WSL 2 installed  
✅ Ubuntu installed in WSL

Now let's install the Mapbox Tilesets CLI in Ubuntu (WSL).

---

## Step 1: Open Ubuntu WSL

In PowerShell, run:

```powershell
wsl -d Ubuntu
```

This will open Ubuntu Linux terminal.

---

## Step 2: Navigate to Your Project

Once in Ubuntu, navigate to your Windows project folder:

```bash
cd /mnt/c/Studies/PRO_Thesis/yegor-sasha-thesis
```

**Explanation**: Windows drives are mounted in WSL under `/mnt/`:

- `C:\` → `/mnt/c/`
- `D:\` → `/mnt/d/`

---

## Step 3: Install Python and pip in Ubuntu

Run these commands in Ubuntu WSL terminal:

```bash
# Update package list
sudo apt update

# Install Python 3 and pip
sudo apt install python3 python3-pip -y
```

Enter your Ubuntu password when prompted (the one you just created: `test`).

---

## Step 4: Install Mapbox Tilesets CLI

```bash
pip3 install mapbox-tilesets
```

---

## Step 5: Verify Installation

```bash
tilesets --help
```

You should see the help text for the Tilesets CLI.

---

## Step 6: Export Restaurants from Laravel

Still in the Ubuntu WSL terminal:

```bash
# Make sure you're in the project directory
cd /mnt/c/Studies/PRO_Thesis/yegor-sasha-thesis

# Export restaurants
php artisan map:export-restaurants --format=ldgeojson
```

This will create `storage/app/map/restaurants.geojson`.

---

## Step 7: Set Your Mapbox Token

Before uploading, you need to set your Mapbox secret token as an environment variable:

```bash
export MAPBOX_ACCESS_TOKEN=sk.YOUR_SECRET_TOKEN_HERE
```

**Replace `sk.YOUR_SECRET_TOKEN_HERE`** with your actual Mapbox secret token (the one with `tilesets:write` scope).

---

## Step 8: Upload to Mapbox

Replace `<your-username>` with your actual Mapbox username (e.g., `the-gronkler`):

### A) Upload the source

```bash
tilesets upload-source <your-username> restaurants-source storage/app/map/restaurants.geojson
```

Example:

```bash
tilesets upload-source the-gronkler restaurants-source storage/app/map/restaurants.geojson
```

### B) Update the recipe

First, replace `{username}` in the recipe file with your actual username:

```bash
sed -i "s/{username}/the-gronkler/g" docs/mapbox-tileset-recipe.json
```

(Replace `the-gronkler` with your username)

### C) Create the tileset

```bash
tilesets create <your-username>.restaurants-clustered \
  --recipe docs/mapbox-tileset-recipe.json \
  --name "Restaurants Clustered"
```

Example:

```bash
tilesets create the-gronkler.restaurants-clustered \
  --recipe docs/mapbox-tileset-recipe.json \
  --name "Restaurants Clustered"
```

### D) Publish the tileset

```bash
tilesets publish <your-username>.restaurants-clustered
```

Example:

```bash
tilesets publish the-gronkler.restaurants-clustered
```

### E) Check the status

```bash
tilesets status <your-username>.restaurants-clustered
```

Wait until you see `"status": "success"` in the output. This may take 30 seconds to 5 minutes.

---

## Step 9: Update Your .env (Back in Windows)

Exit WSL by typing `exit` or pressing Ctrl+D.

Then in PowerShell, edit your `.env` file and uncomment/update:

```dotenv
MAPBOX_RESTAURANTS_TILESET=mapbox://your-username.restaurants-clustered
```

Replace `your-username` with your actual Mapbox username.

---

## Step 10: Test Your Map!

In PowerShell:

```powershell
php artisan serve
```

Visit http://localhost:8000 and you should see:

- Clusters at low zoom levels
- Individual restaurant points at high zoom
- Popup with details when clicking a point

---

## Complete Example (Copy-Paste Ready)

Here's the full sequence of commands for Ubuntu WSL (replace `the-gronkler` with your username):

```bash
# Navigate to project
cd /mnt/c/Studies/PRO_Thesis/yegor-sasha-thesis

# Install dependencies
sudo apt update
sudo apt install python3 python3-pip -y

# Install Tilesets CLI
pip3 install mapbox-tilesets

# Export restaurants
php artisan map:export-restaurants --format=ldgeojson

# Set Mapbox token (replace with your secret token)
export MAPBOX_ACCESS_TOKEN=sk.YOUR_SECRET_TOKEN_HERE

# Update recipe with your username
sed -i "s/{username}/the-gronkler/g" docs/mapbox-tileset-recipe.json

# Upload source
tilesets upload-source the-gronkler restaurants-source storage/app/map/restaurants.geojson

# Create tileset
tilesets create the-gronkler.restaurants-clustered \
  --recipe docs/mapbox-tileset-recipe.json \
  --name "Restaurants Clustered"

# Publish tileset
tilesets publish the-gronkler.restaurants-clustered

# Check status
tilesets status the-gronkler.restaurants-clustered
```

---

## Troubleshooting

### "cd /mnt/c/..." - No such file or directory

Make sure you're typing the full path:

```bash
cd /mnt/c/Studies/PRO_Thesis/yegor-sasha-thesis
```

Check if the mount exists:

```bash
ls /mnt
```

You should see `c` listed.

### "php: command not found" in WSL

PHP is installed on Windows, not Ubuntu. You have two options:

**Option A**: Use Windows PowerShell for PHP commands, WSL for Tilesets CLI:

1. In **PowerShell**: `php artisan map:export-restaurants`
2. In **WSL**: `tilesets upload-source ...`

**Option B**: Install PHP in Ubuntu:

```bash
sudo apt install php php-cli php-mbstring -y
```

### Permission denied when accessing Windows files

WSL should have access to Windows files under `/mnt/c/`. If you get permission errors, try:

```bash
# Navigate to your Windows home directory
cd ~

# Create a symbolic link to your project
ln -s /mnt/c/Studies/PRO_Thesis/yegor-sasha-thesis thesis

# Now access via:
cd ~/thesis
```

---

## Next Steps

After your tileset is published:

1. ✅ Update `.env` with `MAPBOX_RESTAURANTS_TILESET`
2. ✅ Restart `php artisan serve`
3. ✅ Test the map in your browser
4. ✅ Verify clusters appear when zoomed out
5. ✅ Verify individual points appear when zoomed in
6. ✅ Click a point to see the popup

---

## Pro Tip: Create an Alias

To make it easier to access your project in WSL, add this to `~/.bashrc`:

```bash
echo 'alias thesis="cd /mnt/c/Studies/PRO_Thesis/yegor-sasha-thesis"' >> ~/.bashrc
source ~/.bashrc
```

Now you can just type `thesis` in WSL to navigate to your project! 🚀
