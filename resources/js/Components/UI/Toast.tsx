import { useEffect, useState, useRef } from 'react';
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

  // Track all timers for proper cleanup (browser setTimeout returns number)
  const timersRef = useRef<number[]>([]);

  // Helper to clear all timers
  const clearAllTimers = () => {
    timersRef.current.forEach((timer) => clearTimeout(timer));
    timersRef.current = [];
  };

  useEffect(() => {
    if (flash.success || flash.error) {
      // Clear any existing timers
      clearAllTimers();

      // Hide existing toast first
      setVisible(false);

      // Wait for exit animation if toast was already visible
      const resetTimer = setTimeout(
        () => {
          if (flash.success) {
            setMessage(flash.success);
            setType('success');
          } else if (flash.error) {
            setMessage(flash.error);
            setType('error');
          }

          // Delay setting visible to allow CSS transition to trigger
          const showTimer = setTimeout(() => setVisible(true), 10);
          timersRef.current.push(showTimer);
        },
        message ? 50 : 0,
      ); // Wait 50ms if message exists, 0ms if new

      timersRef.current.push(resetTimer);

      return clearAllTimers;
    }
  }, [flash]);

  useEffect(() => {
    if (visible) {
      const hideTimer = setTimeout(() => {
        setVisible(false);

        // Clear message after fade-out animation completes
        const clearTimer = setTimeout(() => setMessage(null), 400);
        timersRef.current.push(clearTimer);
      }, 5000); // Auto-hide after 5 seconds

      timersRef.current.push(hideTimer);

      return () => {
        clearTimeout(hideTimer);
        timersRef.current = timersRef.current.filter((t) => t !== hideTimer);
      };
    }
  }, [visible]);

  const handleClose = () => {
    clearAllTimers();
    setVisible(false);

    // Clear message after fade-out animation completes
    const clearTimer = setTimeout(() => setMessage(null), 400);
    timersRef.current.push(clearTimer);
  };

  if (!message) {
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
