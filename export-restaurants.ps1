# Run this in PowerShell to export restaurants and prepare for WSL upload

Write-Host "=== Exporting Restaurants for Mapbox Tileset ===" -ForegroundColor Cyan
Write-Host ""

# Export restaurants using Laravel
Write-Host "Step 1: Exporting restaurants from database..." -ForegroundColor Yellow
php artisan map:export-restaurants --format=ldgeojson

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Export successful!" -ForegroundColor Green
    Write-Host ""

    # Check if file was created
    $filePath = "storage\app\map\restaurants.geojson"
    if (Test-Path $filePath) {
        $fileSize = (Get-Item $filePath).Length / 1KB
        Write-Host "✓ File created: $filePath" -ForegroundColor Green
        Write-Host "  Size: $([math]::Round($fileSize, 2)) KB" -ForegroundColor Gray
        Write-Host ""

        Write-Host "=== Next Steps ===" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "1. Open Ubuntu WSL:" -ForegroundColor White
        Write-Host "   wsl -d Ubuntu" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. Navigate to project:" -ForegroundColor White
        Write-Host "   cd /mnt/c/Studies/PRO_Thesis/yegor-sasha-thesis" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3. Install Mapbox Tilesets CLI (first time only):" -ForegroundColor White
        Write-Host "   sudo apt update && sudo apt install python3 python3-pip -y" -ForegroundColor Gray
        Write-Host "   pip3 install mapbox-tilesets" -ForegroundColor Gray
        Write-Host ""
        Write-Host "4. Set your Mapbox token:" -ForegroundColor White
        Write-Host "   export MAPBOX_ACCESS_TOKEN=sk.YOUR_SECRET_TOKEN" -ForegroundColor Gray
        Write-Host ""
        Write-Host "5. Upload and publish (replace 'your-username'):" -ForegroundColor White
        Write-Host "   sed -i 's/{username}/your-username/g' docs/mapbox-tileset-recipe.json" -ForegroundColor Gray
        Write-Host "   tilesets upload-source your-username restaurants-source $filePath" -ForegroundColor Gray
        Write-Host "   tilesets create your-username.restaurants-clustered --recipe docs/mapbox-tileset-recipe.json --name 'Restaurants Clustered'" -ForegroundColor Gray
        Write-Host "   tilesets publish your-username.restaurants-clustered" -ForegroundColor Gray
        Write-Host ""
        Write-Host "See WSL_QUICK_START.md for detailed instructions!" -ForegroundColor Cyan

    } else {
        Write-Host "✗ File not created at $filePath" -ForegroundColor Red
        Write-Host "  Make sure you have restaurants with lat/lng in your database." -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Export failed!" -ForegroundColor Red
    Write-Host "  Check the error message above." -ForegroundColor Yellow
}

