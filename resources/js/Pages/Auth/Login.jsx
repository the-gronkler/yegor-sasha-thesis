import { Head, Link, useForm } from '@inertiajs/react';

export default function Login({ canResetPassword = false, status }) {
  const form = useForm({
    email: '',
    password: '',
    remember: false,
  });

  const submit = (e) => {
    e.preventDefault();
    form.post(window.route('login'), {
      onFinish: () => form.reset('password'),
    });
  };

  return (
    <>
      <Head title="Log In" />

      <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
        <div className="w-full max-w-md bg-white py-8 px-6 shadow-lg rounded-lg">

          <div className="text-center mb-6">
            <h2 className="text-3xl font-extrabold text-gray-900">Sign In</h2>
            <p className="mt-2 text-sm text-gray-600">
              Welcome back! Please sign in to your account.
            </p>
            {status && (
              <div className="mt-4 text-sm text-green-600">{status}</div>
            )}
          </div>

          <form className="space-y-6 mx-auto max-w-sm" onSubmit={submit}>
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                Email Address
              </label>
              <input
                id="email"
                type="email"
                autoComplete="username"
                required
                className="mt-1 block w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm placeholder-gray-400
                           focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={form.data.email}
                onChange={(e) => form.setData('email', e.target.value)}
              />
              {form.errors.email && (
                <p className="mt-1 text-xs text-red-600">{form.errors.email}</p>
              )}
            </div>

            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Password
              </label>
              <input
                id="password"
                type="password"
                autoComplete="current-password"
                required
                className="mt-1 block w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm placeholder-gray-400
                           focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm"
                value={form.data.password}
                onChange={(e) => form.setData('password', e.target.value)}
              />
              {form.errors.password && (
                <p className="mt-1 text-xs text-red-600">{form.errors.password}</p>
              )}
            </div>

            <div className="flex items-center justify-between">
              <label htmlFor="remember" className="flex items-center text-sm text-gray-700">
                <input
                  id="remember"
                  type="checkbox"
                  className="h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded"
                  checked={form.data.remember}
                  onChange={(e) => form.setData('remember', e.target.checked)}
                />
                <span className="ml-2">Remember me</span>
              </label>

              {canResetPassword && (
                <div className="text-sm">
                  <Link
                    href={window.route('password.request')}
                    className="font-medium text-indigo-600 hover:text-indigo-500"
                  >
                    Forgot your password?
                  </Link>
                </div>
              )}
            </div>

            <div>
              <button
                type="submit"
                disabled={form.processing}
                className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium
                           text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500
                           disabled:opacity-50"
              >
                {form.processing ? 'Signing in...' : 'Sign In'}
              </button>
            </div>
          </form>

          <div className="mt-6 text-center text-sm text-gray-600">
            Don’t have an account?{' '}
            <Link
              href={window.route('register')}
              className="font-medium text-indigo-600 hover:text-indigo-500"
            >
              Register
            </Link>
          </div>

        </div>
      </div>
    </>
  );
}
