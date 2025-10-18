import './bootstrap';
import React from 'react';
import { createRoot } from 'react-dom/client';
import { createInertiaApp } from '@inertiajs/react';
import { InertiaProgress } from '@inertiajs/progress';

const pages = import.meta.glob('./Pages/**/*.jsx', { eager: true });

createInertiaApp({
  resolve: name => {
    const page = pages[`./Pages/${name}.jsx`];
    if (!page) {
      throw new Error(`Unknown page ${name}`);
    }
    return page;
  },
  setup({ el, App, props, plugin }) {
    const root = createRoot(el);
    // If plugin is needed:
    // root.render(<App {...props} />);
    root.render(
      <React.StrictMode>
        <App {...props} />
      </React.StrictMode>
    );
  },
});

InertiaProgress.init();
