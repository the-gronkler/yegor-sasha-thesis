<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Symfony\Component\HttpKernel\Exception\HttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: [
            __DIR__.'/../routes/customer.php',
            __DIR__.'/../routes/auth.php',
            __DIR__.'/../routes/employee.php',
        ],
        commands: __DIR__.'/../routes/console.php',
        channels: __DIR__.'/../routes/channels.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        if (env('APP_ENV') === 'production') {
            $trustedProxies = env('TRUSTED_PROXIES');
            $trustedProxies = $trustedProxies !== null && $trustedProxies !== ''
                ? array_map('trim', explode(',', $trustedProxies))
                : null;

            $middleware->trustProxies(at: $trustedProxies);
        } else {
            // generally not a big problem since we are using Caddy
            $middleware->trustProxies(at: '*');
        }

        $middleware->web(append: [
            \App\Http\Middleware\HandleInertiaRequests::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        $exceptions->render(function (HttpException $e, Request $request) {
            $status = $e->getStatusCode();

            if ($status === 419) {
                return redirect()->route('login')
                    ->with('status', 'Your session has expired. Please log in again.');
            }

            if (in_array($status, [401, 403, 404, 429, 500, 503])) {
                return Inertia::render('Error', ['status' => $status])
                    ->toResponse($request)
                    ->setStatusCode($status);
            }
        });
    })->create();
