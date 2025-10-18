<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    @viteReactRefresh
    @vite('resources/js/app.jsx')
    <title>PRO Thesis</title>
</head>
<body>
    @inertia
</body>
</html>
