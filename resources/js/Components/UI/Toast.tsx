import { useEffect, useState } from 'react';
import { usePage } from '@inertiajs/react';
import {
  CheckCircleIcon,
  XCircleIcon,
  XMarkIcon,
} from '@heroicons/react/24/outline';
import { PageProps } from '@/types';

export default function Toast() {
  const { flash } = usePage<PageProps>().props;
  const [visible, setVisible] = useState(false);
  const [message, setMessage] = useState<string | null>(null);
  const [type, setType] = useState<'success' | 'error'>('success');

  useEffect(() => {
    if (flash.success) {
      setMessage(flash.success);
      setType('success');
      setVisible(true);
    } else if (flash.error) {
      setMessage(flash.error);
      setType('error');
      setVisible(true);
    }
  }, [flash]);

  useEffect(() => {
    if (visible) {
      const timer = setTimeout(() => {
        setVisible(false);
        // Clear message after fade-out animation completes
        setTimeout(() => setMessage(null), 300);
      }, 5000); // Auto-hide after 5 seconds

      return () => clearTimeout(timer);
    }
  }, [visible]);

  const handleClose = () => {
    setVisible(false);
    // Clear message after fade-out animation completes
    setTimeout(() => setMessage(null), 300);
  };

  if (!visible || !message) {
    return null;
  }

  return (
    <div
      className={`toast toast-${type} ${visible ? 'toast-visible' : ''}`}
      role={type === 'error' ? 'alert' : 'status'}
      aria-live={type === 'error' ? 'assertive' : 'polite'}
      aria-atomic="true"
    >
      <div className="toast-icon">
        {type === 'success' ? (
          <CheckCircleIcon className="icon" />
        ) : (
          <XCircleIcon className="icon" />
        )}
      </div>
      <div className="toast-content">
        <p className="toast-message">{message}</p>
      </div>
      <button
        type="button"
        onClick={handleClose}
        className="toast-close"
        aria-label="Close notification"
      >
        <XMarkIcon className="icon" />
      </button>
    </div>
  );
}
