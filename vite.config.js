import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [
    laravel({
      input: ['resources/css/main.scss', 'resources/js/app.tsx'], // our entry
      refresh: true,
    }),
    react(),
  ],
  server: {
    host: '0.0.0.0',
    hmr: {
      host: 'yegor-sasha-thesis.test',
    },
  },
  resolve: {
    alias: {
      '@': '/resources/js',
    },
  },
});
