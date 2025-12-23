import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { useAdminAuthStore } from '../../store/adminAuthStore';

export default function AdminLoginPage() {
  const navigate = useNavigate();
  const { loginAdmin, isLoading, error, clearError } = useAdminAuthStore();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    clearError();
    const ok = await loginAdmin(email, password);
    if (ok) {
      toast.success('Đăng nhập admin thành công');
      navigate('/admin/accounts');
    } else {
      toast.error(error || 'Đăng nhập admin thất bại');
    }
  };

  return (
    <div className="min-h-screen bg-background-light dark:bg-background-dark flex items-center justify-center p-6">
      <div className="w-full max-w-md bg-white dark:bg-surface-dark rounded-2xl shadow-soft p-8">
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-text-main dark:text-white">Admin Login</h1>
          <p className="text-sm text-text-secondary dark:text-gray-400">
            Đăng nhập để quản lý Users / Doctors / Clinics (FR-31)
          </p>
        </div>

        <form onSubmit={onSubmit} className="space-y-4">
          <div>
            <label className="text-sm font-medium text-text-main dark:text-white">Email</label>
            <input
              className="mt-1 w-full rounded-xl border border-gray-200 dark:border-white/10 bg-white dark:bg-surface-dark px-4 py-3 outline-none focus:ring-2 focus:ring-blue-500"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </div>
          <div>
            <label className="text-sm font-medium text-text-main dark:text-white">Password</label>
            <input
              className="mt-1 w-full rounded-xl border border-gray-200 dark:border-white/10 bg-white dark:bg-surface-dark px-4 py-3 outline-none focus:ring-2 focus:ring-blue-500"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </div>

          {error && <p className="text-sm text-red-500">{error}</p>}

          <button
            type="submit"
            disabled={isLoading}
            className="w-full rounded-xl bg-blue-600 text-white py-3 font-semibold hover:bg-blue-700 transition-colors disabled:opacity-60"
          >
            {isLoading ? 'Đang đăng nhập...' : 'Đăng nhập'}
          </button>
        </form>

        <div className="mt-6 text-sm text-text-secondary dark:text-gray-400 flex justify-between">
          <Link to="/login" className="hover:underline">
            Về login người dùng
          </Link>
          <a href="/swagger" className="hover:underline">
            Swagger
          </a>
        </div>
      </div>
    </div>
  );
}


