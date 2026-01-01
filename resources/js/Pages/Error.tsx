import { Link, Head } from '@inertiajs/react';
import {
  ExclamationTriangleIcon,
  HomeIcon,
  ArrowLeftIcon,
} from '@heroicons/react/24/outline';
import { useAuth } from '@/Hooks/useAuth';

interface Props {
  status: number;
}

export default function Error({ status }: Props) {
  const { isEmployee } = useAuth();

  const title =
    {
      503: '503: Service Unavailable',
      500: '500: Server Error',
      404: '404: Page Not Found',
      403: '403: Forbidden',
      401: '401: Unauthorized',
    }[status] || 'Error';

  const description =
    {
      503: 'Sorry, we are doing some maintenance. Please check back soon.',
      500: 'Whoops, something went wrong on our servers.',
      404: 'Sorry, the page you are looking for could not be found.',
      403: 'Sorry, you are not authorized to access this page.',
      401: 'Sorry, you need to be logged in to access this page.',
    }[status] || 'An unexpected error occurred.';

  // Determine redirection based on user role
  const homeRoute = isEmployee ? 'employee.index' : 'map.index';
  const homeLabel = isEmployee ? 'Back to Dashboard' : 'Back to Map';

  return (
    <div className="error-page">
      <Head title={title} />
      <div className="error-page__container">
        <div className="error-page__icon-wrapper">
          <div className="error-page__icon-bg">
            <ExclamationTriangleIcon className="error-page__icon" />
          </div>
        </div>

        <h1 className="error-page__code">{status}</h1>
        <h2 className="error-page__title">{title}</h2>
        <p className="error-page__description">{description}</p>

        <div className="error-page__actions">
          <button
            onClick={() => {
              if (window.history.length > 1) {
                window.history.back();
              } else {
                window.location.href = route(homeRoute);
              }
            }}
            className="error-page__btn-back"
          >
            <ArrowLeftIcon className="error-page__btn-icon" />
            Go Back
          </button>

          <Link href={route(homeRoute)} className="error-page__btn-home">
            <HomeIcon className="error-page__btn-icon" />
            {homeLabel}
          </Link>
        </div>
      </div>
    </div>
  );
}
