import { FormEventHandler } from 'react';
import { Link, useForm } from '@inertiajs/react';

interface LoginFormProps {
  canResetPassword?: boolean;
  onSuccess?: () => void;
}

interface LoginFormData {
  email: string;
  password: string;
  remember: boolean;
}

export default function LoginForm({
  canResetPassword = false,
  onSuccess,
}: LoginFormProps) {
  const form = useForm<LoginFormData>({
    email: '',
    password: '',
    remember: false,
  });

  const submit: FormEventHandler = (e) => {
    e.preventDefault();
    form.post(window.route('login.store'), {
      onFinish: () => form.reset('password'),
      onSuccess: () => {
        onSuccess?.();
      },
    });
  };

  return (
    <form className="auth-form" onSubmit={submit}>
      <div className="form-group">
        <label htmlFor="email">Email Address</label>
        <input
          id="email"
          type="email"
          autoComplete="username"
          required
          className="form-input"
          value={form.data.email}
          onChange={(e) => form.setData('email', e.target.value)}
        />
        {form.errors.email && (
          <p className="error-message">{form.errors.email}</p>
        )}
      </div>

      <div className="form-group">
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          autoComplete="current-password"
          required
          className="form-input"
          value={form.data.password}
          onChange={(e) => form.setData('password', e.target.value)}
        />
        {form.errors.password && (
          <p className="error-message">{form.errors.password}</p>
        )}
      </div>

      <div className="form-actions">
        <label htmlFor="remember" className="remember-me">
          <input
            id="remember"
            type="checkbox"
            className="form-checkbox"
            checked={form.data.remember}
            onChange={(e) => form.setData('remember', e.target.checked)}
          />
          <span className="ml-2">Remember me</span>
        </label>

        {canResetPassword && (
          <Link
            href={window.route('password.request')}
            className="forgot-password"
          >
            Forgot your password?
          </Link>
        )}
      </div>

      <div>
        <button type="submit" disabled={form.processing} className="btn-submit">
          {form.processing ? 'Signing in...' : 'Sign In'}
        </button>
      </div>
    </form>
  );
}
