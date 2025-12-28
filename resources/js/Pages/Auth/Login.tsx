import { Head } from '@inertiajs/react';
import { PageProps } from '@/types';
import LoginForm from '@/Components/Auth/LoginForm';
import AuthFooter from '@/Components/Auth/AuthFooter';

interface LoginProps extends PageProps {
  canResetPassword?: boolean;
}

export default function Login({ canResetPassword = false }: LoginProps) {
  return (
    <>
      <Head title="Log In" />

      <div className="auth-page">
        <div className="auth-card">
          <div className="auth-header">
            <h2 className="auth-title">Sign In</h2>
            <p className="auth-subtitle">
              Welcome back! Please sign in to your account.
            </p>
          </div>

          <LoginForm canResetPassword={canResetPassword} />

          <AuthFooter target="register" />
        </div>
      </div>
    </>
  );
}
