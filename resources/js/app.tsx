import './bootstrap';
import '../css/main.scss';
import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { createInertiaApp } from '@inertiajs/react';
import { InertiaProgress } from '@inertiajs/progress';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import ErrorBoundary from '@/Components/UI/ErrorBoundary';
import { CartProvider } from '@/Contexts/CartContext';
import { Order } from '@/types/models';

const appName =
  window.document.getElementsByTagName('title')[0]?.innerText || 'Laravel';

createInertiaApp({
  title: (title) => `${title} - ${appName}`,
  resolve: (name) =>
    resolvePageComponent(
      `./Pages/${name}.tsx`,
      import.meta.glob('./Pages/**/*.tsx'),
    ),
  setup({ el, App, props }) {
    const root = createRoot(el);
    const cart = (props.initialPage.props.cart as Order[]) || null;

    root.render(
      <StrictMode>
        <ErrorBoundary>
          <CartProvider initialCart={cart}>
            <App {...props} />
          </CartProvider>
        </ErrorBoundary>
      </StrictMode>,
    );
  },
  progress: {
    color: '#4B5563',
  },
});

InertiaProgress.init();
