<?php

namespace App\Console\Commands;

use App\Models\Restaurant;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Storage;

class ExportRestaurantsForTileset extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'map:export-restaurants
                            {--format=ldgeojson : Output format (ldgeojson or geojson)}
                            {--output= : Custom output path (defaults to storage/app/map/restaurants.{ext})}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Export restaurant locations for Mapbox Tileset upload (MTS)';

    /**
     * Execute the console command.
     */
    public function handle(): int
    {
        $format = $this->option('format');
        $customOutput = $this->option('output');

        if (! in_array($format, ['ldgeojson', 'geojson'])) {
            $this->error('Invalid format. Use "ldgeojson" (recommended) or "geojson".');

            return self::FAILURE;
        }

        $this->info("Exporting restaurants in {$format} format...");

        // Fetch restaurants with coordinates
        $restaurants = Restaurant::query()
            ->whereNotNull('latitude')
            ->whereNotNull('longitude')
            ->select('id', 'name', 'latitude', 'longitude')
            ->get();

        if ($restaurants->isEmpty()) {
            $this->warn('No restaurants with coordinates found.');

            return self::SUCCESS;
        }

        $this->info("Found {$restaurants->count()} restaurants with coordinates.");

        // Determine output path
        $ext = $format === 'ldgeojson' ? 'geojson' : 'geojson';
        $defaultPath = "map/restaurants.{$ext}";
        $outputPath = $customOutput ?? $defaultPath;

        // Ensure directory exists
        $directory = dirname($outputPath);
        if ($directory !== '.' && ! Storage::exists($directory)) {
            Storage::makeDirectory($directory);
        }

        // Generate content based on format
        if ($format === 'ldgeojson') {
            $content = $this->generateLineDelimitedGeoJSON($restaurants);
        } else {
            $content = $this->generateGeoJSON($restaurants);
        }

        // Write to storage
        Storage::put($outputPath, $content);

        $fullPath = Storage::path($outputPath);
        $this->info("✓ Exported to: {$fullPath}");
        $this->info('File size: '.number_format(strlen($content) / 1024, 2).' KB');

        // Display next steps
        $this->newLine();
        $this->comment('Next steps:');
        $this->line('1. Ensure you have a Mapbox token with tilesets:write scope');
        $this->line('2. Run the GitHub Actions workflow to upload and publish the tileset');
        $this->line('3. Or manually upload using Tilesets CLI (in WSL/Linux):');
        $this->line("   tilesets upload-source <username> restaurants-source \"{$fullPath}\"");
        $this->line('   tilesets publish <username>.restaurants-clustered');
        $this->newLine();

        return self::SUCCESS;
    }

    /**
     * Generate line-delimited GeoJSON (recommended by Mapbox for large datasets).
     *
     * Each line is a separate Feature object (NOT a FeatureCollection).
     */
    private function generateLineDelimitedGeoJSON($restaurants): string
    {
        $lines = [];

        foreach ($restaurants as $restaurant) {
            $feature = [
                'type' => 'Feature',
                'geometry' => [
                    'type' => 'Point',
                    'coordinates' => [
                        (float) $restaurant->longitude,
                        (float) $restaurant->latitude,
                    ],
                ],
                'properties' => [
                    'restaurant_id' => (string) $restaurant->id, // Store as string for consistency
                    'name' => $restaurant->name, // Useful for debugging in Mapbox Studio
                ],
            ];

            $lines[] = json_encode($feature, JSON_UNESCAPED_UNICODE);
        }

        return implode("\n", $lines);
    }

    /**
     * Generate GeoJSON FeatureCollection.
     *
     * Line-delimited is preferred by Mapbox, but FeatureCollection also works.
     */
    private function generateGeoJSON($restaurants): string
    {
        $features = $restaurants->map(function ($restaurant) {
            return [
                'type' => 'Feature',
                'geometry' => [
                    'type' => 'Point',
                    'coordinates' => [
                        (float) $restaurant->longitude,
                        (float) $restaurant->latitude,
                    ],
                ],
                'properties' => [
                    'restaurant_id' => (string) $restaurant->id,
                    'name' => $restaurant->name,
                ],
            ];
        });

        return json_encode([
            'type' => 'FeatureCollection',
            'features' => $features->toArray(),
        ], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
    }
}
