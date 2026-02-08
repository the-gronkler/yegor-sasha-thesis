import { ButtonHTMLAttributes } from 'react';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  className?: string;
  variant?: 'primary' | 'secondary';
}

export default function Button({
  className = '',
  disabled,
  children,
  variant = 'primary',
  ...props
}: ButtonProps) {
  const variantClass =
    variant === 'secondary' ? 'btn-secondary' : 'btn-primary';

  return (
    <button
      {...props}
      className={`${variantClass} ${disabled ? 'disabled' : ''} ${className}`}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
