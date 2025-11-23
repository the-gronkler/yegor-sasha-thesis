<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    @viteReactRefresh
    @vite('resources/js/app.jsx')
    @inertiaHead
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>PRO Thesis</title>
</head>
<body>
    @inertia
</body>
</html>
