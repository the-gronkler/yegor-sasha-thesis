<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: [__DIR__.'/../routes/web.php', __DIR__.'/../routes/auth.php'],
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        if (env('APP_ENV') === 'production') {
            // TODO: add these to .env file and configure properly
            $trustedProxies = env('TRUSTED_PROXIES');
            $trustedProxies = $trustedProxies !== null && $trustedProxies !== ''
                ? array_map('trim', explode(',', $trustedProxies))
                : null;

            $middleware->trustProxies(at: $trustedProxies);
        } else {
            // generally not a big problem since we are using Caddy
            $middleware->trustProxies(at: '*');
        }

        $middleware->web(prepend: [
            \App\Http\Middleware\HandleInertiaRequests::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
