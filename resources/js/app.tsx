import './bootstrap';
import '../css/main.scss';
import { StrictMode, ReactNode } from 'react';
import { createRoot } from 'react-dom/client';
import { createInertiaApp } from '@inertiajs/react';
import { InertiaProgress } from '@inertiajs/progress';
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers';
import ErrorBoundary from '@/Components/UI/ErrorBoundary';
import { CartProvider } from '@/Contexts/CartContext';
import { LoginModalProvider } from '@/Contexts/LoginModalContext';
import { Order } from '@/types/models';
import { composeProviders, ProviderWrapper } from '@/Utils/composeProviders';

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

    // List of providers to compose.
    // Add new providers here to wrap the application.
    const providers: ProviderWrapper[] = [
      (children) => <ErrorBoundary>{children}</ErrorBoundary>,
      (children) => <CartProvider initialCart={cart}>{children}</CartProvider>,
      (children) => <LoginModalProvider>{children}</LoginModalProvider>,
    ];

    const WrappedApp = composeProviders(providers, <App {...props} />);

    root.render(<StrictMode>{WrappedApp}</StrictMode>);
  },
  progress: {
    color: '#4B5563',
  },
});

InertiaProgress.init();
