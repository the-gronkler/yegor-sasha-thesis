import { Head, Link, useForm } from '@inertiajs/react';

export default function Register({ canResetPassword = false }) {
  const form = useForm({
    name: '',
    surname: '',
    email: '',
    password: '',
    password_confirmation: '',
  });

  const submit = (e) => {
    e.preventDefault();
    form.post(window.route('register.store'), {
      onFinish: () => form.reset('password', 'password_confirmation'),
    });
  };

  return (
    <>
      <Head title="Register" />

      <div className="auth-page">
        <div className="auth-card">

          <div className="auth-header">
            <h2 className="auth-title">Sign Up</h2>
            <p className="auth-subtitle">
              Create your account to get started.
            </p>
          </div>

          <form className="auth-form" onSubmit={submit}>
            <div className="form-group">
              <label htmlFor="name">
                First Name
              </label>
              <input
                id="name"
                type="text"
                autoComplete="given-name"
                required
                className="form-input"
                value={form.data.name}
                onChange={(e) => form.setData('name', e.target.value)}
              />
              {form.errors.name && (
                <p className="error-message">{form.errors.name}</p>
              )}
            </div>

            <div className="form-group">
              <label htmlFor="surname">
                Last Name (Optional)
              </label>
              <input
                id="surname"
                type="text"
                autoComplete="family-name"
                className="form-input"
                value={form.data.surname}
                onChange={(e) => form.setData('surname', e.target.value)}
              />
              {form.errors.surname && (
                <p className="error-message">{form.errors.surname}</p>
              )}
            </div>

            <div className="form-group">
              <label htmlFor="email">
                Email Address
              </label>
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
              <label htmlFor="password">
                Password
              </label>
              <input
                id="password"
                type="password"
                autoComplete="new-password"
                required
                className="form-input"
                value={form.data.password}
                onChange={(e) => form.setData('password', e.target.value)}
              />
              {form.errors.password && (
                <p className="error-message">{form.errors.password}</p>
              )}
            </div>

            <div className="form-group">
              <label htmlFor="password_confirmation">
                Confirm Password
              </label>
              <input
                id="password_confirmation"
                type="password"
                autoComplete="new-password"
                required
                className="form-input"
                value={form.data.password_confirmation}
                onChange={(e) => form.setData('password_confirmation', e.target.value)}
              />
              {form.errors.password_confirmation && (
                <p className="error-message">{form.errors.password_confirmation}</p>
              )}
            </div>

            <div>
              <button
                type="submit"
                disabled={form.processing}
                className="btn-submit"
              >
                {form.processing ? 'Creating account...' : 'Sign Up'}
              </button>
            </div>
          </form>

          <div className="auth-footer">
            Already have an account?{' '}
            <Link
              href={window.route('login')}
              className="auth-link"
            >
              Sign In
            </Link>
          </div>

        </div>
      </div>
    </>
  );
}
