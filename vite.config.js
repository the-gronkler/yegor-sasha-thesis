import { defineConfig, loadEnv } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const host = env.APP_URL ? new URL(env.APP_URL).hostname : 'localhost';

  return {
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
        host: host,
      },
    },
    resolve: {
      alias: {
        '@': '/resources/js',
      },
    },
  };
});
