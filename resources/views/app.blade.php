<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    @routes
    @viteReactRefresh
    @vite('resources/js/app.tsx')
    @inertiaHead
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>PRO Thesis</title>
    <style>
        #app-loading-error  {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: white;
            z-index: 9999;
            padding: 2rem;
            text-align: center;
            font-family: system-ui, -apple-system, sans-serif;
        }

        #app-loading-error h1 {
            color: #ef4444;
            margin-bottom: 1rem;
        }

        #app-loading-error p {
            color: #374151;
            margin-bottom: 0.5rem;
        }

        #app-loading-error pre {
            background: #f3f4f6;
            padding: 1rem;
            border-radius: 0.5rem;
            overflow-x: auto;
            text-align: left;
            margin: 1rem auto;
            max-width: 800px;
            font-size: 0.875rem;
        }

        #app-loading-error button {
            background: #3b82f6;
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 0.25rem;
            cursor: pointer;
            font-size: 1rem;
        }

        #app-loading-error button:hover {
            background: #2563eb;
        }
    </style>
</head>

<body>
    <div id="app-loading-error">
        <h1>Application Failed to Start</h1>
        <p>We encountered an error while loading the application resources.</p>
        <pre id="error-details"></pre>
        <button onclick="window.location.reload()">Reload Page</button>
    </div>

    <script>
        window.addEventListener('error', function(e) {
            // Check for resource load errors (link/script tags)
            if (e.target && (e.target.tagName === 'LINK' || e.target.tagName === 'SCRIPT')) {
                const errorDiv = document.getElementById('app-loading-error');
                const details = document.getElementById('error-details');
                if (errorDiv && details) {
                    errorDiv.style.display = 'block';
                    const url = e.target.src || e.target.href;
                    details.textContent =
                        `Failed to load resource: ${url}\n\nThis usually means a file is missing or has a syntax error (e.g. SCSS compilation failed).`;
                }
            }
        }, true); // Capture phase is required for resource errors
    </script>

    @inertia
</body>

</html>
