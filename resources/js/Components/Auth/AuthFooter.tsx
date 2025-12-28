import { Link } from '@inertiajs/react';

interface AuthFooterProps {
  target: 'register' | 'login';
  onClick?: () => void;
}

export default function AuthFooter({ target, onClick }: AuthFooterProps) {
  const isRegisterTarget = target === 'register';
  const routeName = isRegisterTarget ? 'register' : 'login';
  const linkText = isRegisterTarget ? 'Register' : 'Sign In';
  const text = isRegisterTarget
    ? "Don't have an account? "
    : 'Already have an account? ';

  return (
    <div className="auth-footer">
      {text}
      <Link
        href={window.route(routeName)}
        className="auth-link"
        onClick={onClick}
      >
        {linkText}
      </Link>
    </div>
  );
}
