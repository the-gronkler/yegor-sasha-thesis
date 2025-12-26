import { useEffect, useCallback, useRef } from 'react';
import { XMarkIcon } from '@heroicons/react/24/outline';

interface ModalProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  children: React.ReactNode;
  shouldConfirmLeave?: boolean;
}

export default function Modal({
  isOpen,
  onClose,
  title,
  children,
  shouldConfirmLeave = false,
}: ModalProps) {
  const modalRef = useRef<HTMLDivElement>(null);

  const handleClose = useCallback(() => {
    if (shouldConfirmLeave) {
      if (
        !window.confirm(
          'You have unsaved changes. Are you sure you want to close?',
        )
      ) {
        return;
      }
    }
    onClose();
  }, [shouldConfirmLeave, onClose]);

  // Lock body scroll when modal is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    }
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [isOpen]);

  // Focus trap and Escape key handling
  useEffect(() => {
    if (!isOpen) return;

    // Store the element that had focus before the modal opened
    const previousActiveElement = document.activeElement as HTMLElement;

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        handleClose();
        return;
      }

      if (e.key === 'Tab' && modalRef.current) {
        const focusableElements = modalRef.current.querySelectorAll(
          'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])',
        );
        const firstElement = focusableElements[0] as HTMLElement;
        const lastElement = focusableElements[
          focusableElements.length - 1
        ] as HTMLElement;

        if (e.shiftKey) {
          if (document.activeElement === firstElement) {
            lastElement.focus();
            e.preventDefault();
          }
        } else {
          if (document.activeElement === lastElement) {
            firstElement.focus();
            e.preventDefault();
          }
        }
      }
    };

    window.addEventListener('keydown', handleKeyDown);

    // Focus the first element when modal opens
    // Delay is needed to ensure the modal is rendered and transition has started
    const FOCUS_DELAY_MS = 50;
    const timer = setTimeout(() => {
      if (modalRef.current) {
        const focusableElements = modalRef.current.querySelectorAll(
          'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])',
        );
        if (focusableElements.length > 0) {
          (focusableElements[0] as HTMLElement).focus();
        } else {
          modalRef.current.focus();
        }
      }
    }, FOCUS_DELAY_MS);

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      clearTimeout(timer);
      // Restore focus to the previous element when modal closes
      if (previousActiveElement) {
        previousActiveElement.focus();
      }
    };
  }, [isOpen, handleClose]);

  if (!isOpen) return null;

  return (
    <div
      className="modal-overlay"
      onClick={handleClose}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
      aria-label="Close modal"
    >
      <div
        className="modal-content"
        onClick={(e) => e.stopPropagation()}
        ref={modalRef}
        tabIndex={-1}
      >
        <div className="modal-header">
          {title && (
            <h3 id="modal-title" className="modal-title">
              {title}
            </h3>
          )}
          <button className="modal-close-btn" onClick={handleClose}>
            <XMarkIcon className="icon" />
          </button>
        </div>
        <div className="modal-body">{children}</div>
      </div>
    </div>
  );
}
