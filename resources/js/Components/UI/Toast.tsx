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

  // All timers:
  const timersRef = useRef<number[]>([]);
  const lastFlashRef = useRef<{ success?: string; error?: string }>({});

  // Helper to clear all timers
  const clearAllTimers = () => {
    timersRef.current.forEach((timer) => clearTimeout(timer));
    timersRef.current = [];
  };

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      clearAllTimers();
    };
  }, []);

  useEffect(() => {
    // Check if we have a new flash message (different from the last one we showed)
    const hasNewSuccess =
      flash.success && flash.success !== lastFlashRef.current.success;
    const hasNewError =
      flash.error && flash.error !== lastFlashRef.current.error;

    if (hasNewSuccess || hasNewError) {
      // Update our ref to track this message
      lastFlashRef.current = { success: flash.success, error: flash.error };

      // Clear any existing timers
      clearAllTimers();

      // Hide existing toast first
      setVisible(false);

      // Wait for exit animation if toast was already visible
      const resetTimer = setTimeout(() => {
        if (flash.success) {
          setMessage(flash.success);
          setType('success');
        } else if (flash.error) {
          setMessage(flash.error);
          setType('error');
        }

        // Delay setting visible to allow CSS transition to trigger
        const showTimer = setTimeout(() => {
          setVisible(true);
        }, 10);
        timersRef.current.push(showTimer);
      }, 50);

      timersRef.current.push(resetTimer);
    }
  }, [flash.success, flash.error]);

  useEffect(() => {
    if (visible) {
      const hideTimer = setTimeout(() => {
        setVisible(false);

        // Clear message after fade-out animation completes
        const clearTimer = setTimeout(() => {
          setMessage(null);
        }, 400);
        timersRef.current.push(clearTimer);
      }, 5000); // Auto-hide after 5 seconds

      timersRef.current.push(hideTimer);

      return () => {
        // clear timer elements
        clearTimeout(hideTimer);
        timersRef.current = timersRef.current.filter((t) => t !== hideTimer);
      };
    }
  }, [visible]);

  const handleClose = () => {
    clearAllTimers();
    setVisible(false);

    // Clear message after fade-out animation completes
    const clearTimer = setTimeout(() => {
      setMessage(null);
    }, 400);
    timersRef.current.push(clearTimer);
  };

  if (!message) {
    return <div style={{ display: 'none' }} />;
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
