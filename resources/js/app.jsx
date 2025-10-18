import './bootstrap';
import React from 'react';
import { createRoot } from 'react-dom/client';
import { createInertiaApp } from '@inertiajs/react';
import { InertiaProgress } from '@inertiajs/progress';

const pages = import.meta.glob('./Pages/**/*.jsx');

createInertiaApp({
  resolve: name => {
    const importPage = pages[`./Pages/${name}.jsx`];
    if (!importPage) {
      throw new Error(`Unknown page ${name}`);
    }
    return importPage();
  },
  setup({ el, App, props, plugin }) {
    const root = createRoot(el);
    root.render(
      <React.StrictMode>
        <App {...props} />
      </React.StrictMode>
    );
  },
});

InertiaProgress.init();
