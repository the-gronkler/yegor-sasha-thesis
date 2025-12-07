<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    @viteReactRefresh
    @vite('resources/js/app.tsx')
    @inertiaHead
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>PRO Thesis</title>
</head>

<body>
    @inertia
</body>

</html>
