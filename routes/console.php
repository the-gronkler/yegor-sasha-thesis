<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Symfony\Component\Console\Output\ConsoleOutput;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command(
    'mfs {--force : Force the operation to run when in production}',
    fn () => Artisan::call('migrate:fresh', [
        '--path' => 'database/migrations/*',
        '--seed' => true,
        '--force' => $this->option('force'),
        '--no-interaction' => true,
    ], new ConsoleOutput
    )
)->describe('Runs migrate:fresh with seed, including migrations from all subdirectories');
