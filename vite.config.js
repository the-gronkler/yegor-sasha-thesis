import { defineConfig, loadEnv } from 'vite';
import laravel from 'laravel-vite-plugin';
import react from '@vitejs/plugin-react';
import fs from 'fs';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  const host = env.APP_URL ? new URL(env.APP_URL).hostname : 'localhost';

  // Configure HTTPS for local development if certs are available
  let httpsConfig = false;
  if (env.REVERB_TLS_CERT && env.REVERB_TLS_KEY) {
    const certPath = env.REVERB_TLS_CERT.replace(/^"|"$/g, ''); // Remove quotes if present
    const keyPath = env.REVERB_TLS_KEY.replace(/^"|"$/g, '');

    if (fs.existsSync(certPath) && fs.existsSync(keyPath)) {
      httpsConfig = {
        cert: fs.readFileSync(certPath),
        key: fs.readFileSync(keyPath),
      };
    }
  }

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
      https: httpsConfig,
      cors: true,
    },
    resolve: {
      alias: {
        '@': '/resources/js',
      },
    },
  };
});
