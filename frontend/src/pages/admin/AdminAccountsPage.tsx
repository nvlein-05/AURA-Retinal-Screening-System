import { useEffect, useMemo, useState } from 'react';
import toast from 'react-hot-toast';
import adminApi from '../../services/adminApi';
import { useAdminAuthStore } from '../../store/adminAuthStore';

type Tab = 'users' | 'doctors' | 'clinics';

export default function AdminAccountsPage() {
  const { admin, logoutAdmin } = useAdminAuthStore();
  const [tab, setTab] = useState<Tab>('users');
  const [search, setSearch] = useState('');
  const [loading, setLoading] = useState(false);
  const [rows, setRows] = useState<any[]>([]);
  const [selected, setSelected] = useState<any | null>(null);
  const [saving, setSaving] = useState(false);

  const endpoint = useMemo(() => {
    if (tab === 'users') return '/admin/users';
    if (tab === 'doctors') return '/admin/doctors';
    return '/admin/clinics';
  }, [tab]);

  const load = async () => {
    setLoading(true);
    try {
      const res = await adminApi.get(endpoint, { params: { search: search || undefined } });
      setRows(res.data || []);
    } catch (e: any) {
      toast.error(e?.response?.data?.message || e?.message || 'Không tải được dữ liệu');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    setSelected(null);
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tab]);

  const toggleActive = async (row: any) => {
    const isActive = !row.isActive;
    try {
      await adminApi.patch(`${endpoint}/${row.id}/status`, { isActive });
      setRows((prev) => prev.map((x) => (x.id === row.id ? { ...x, isActive } : x)));
      if (selected?.id === row.id) setSelected({ ...selected, isActive });
      toast.success(isActive ? 'Đã bật tài khoản' : 'Đã tắt tài khoản');
    } catch (e: any) {
      toast.error(e?.response?.data?.message || e?.message || 'Không cập nhật được');
    }
  };

  const save = async () => {
    if (!selected?.id) return;
    setSaving(true);
    try {
      await adminApi.put(`${endpoint}/${selected.id}`, selected);
      toast.success('Đã lưu');
      setSelected(null);
      await load();
    } catch (e: any) {
      toast.error(e?.response?.data?.message || e?.message || 'Không lưu được');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="min-h-screen bg-background-light dark:bg-background-dark p-6">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-2xl font-bold text-text-main dark:text-white">Admin Account Management</h1>
            <p className="text-sm text-text-secondary dark:text-gray-400">
              {admin ? `Xin chào, ${admin.firstName || admin.email}` : 'FR-31'}
            </p>
          </div>
          <button
            onClick={logoutAdmin}
            className="px-4 py-2 rounded-xl bg-red-500 text-white hover:bg-red-600 transition-colors"
          >
            Logout
          </button>
        </div>

        <div className="flex gap-2 mb-4">
          <TabButton active={tab === 'users'} onClick={() => setTab('users')}>Users</TabButton>
          <TabButton active={tab === 'doctors'} onClick={() => setTab('doctors')}>Doctors</TabButton>
          <TabButton active={tab === 'clinics'} onClick={() => setTab('clinics')}>Clinics</TabButton>
        </div>

        <div className="flex gap-2 mb-4">
          <input
            className="w-full max-w-md rounded-xl border border-gray-200 dark:border-white/10 bg-white dark:bg-surface-dark px-4 py-3 outline-none focus:ring-2 focus:ring-blue-500"
            placeholder="Tìm theo email/tên/username..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          <button
            onClick={load}
            disabled={loading}
            className="px-4 py-3 rounded-xl bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-60"
          >
            {loading ? 'Đang tải...' : 'Tìm'}
          </button>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          <div className="lg:col-span-2 bg-white dark:bg-surface-dark rounded-2xl shadow-soft overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 dark:bg-white/5 text-text-secondary dark:text-gray-300">
                <tr>
                  <th className="text-left p-3">Email</th>
                  <th className="text-left p-3">Tên</th>
                  <th className="text-left p-3">Active</th>
                  <th className="text-left p-3">Action</th>
                </tr>
              </thead>
              <tbody>
                {rows.map((r) => (
                  <tr key={r.id} className="border-t border-gray-100 dark:border-white/10">
                    <td className="p-3">{r.email}</td>
                    <td className="p-3">
                      {tab === 'clinics'
                        ? r.clinicName
                        : `${r.firstName || ''} ${r.lastName || ''}`.trim() || r.username || '-'}
                    </td>
                    <td className="p-3">
                      <span className={r.isActive ? 'text-green-600' : 'text-red-500'}>
                        {r.isActive ? 'Yes' : 'No'}
                      </span>
                    </td>
                    <td className="p-3 flex gap-2">
                      <button
                        className="px-3 py-1 rounded-lg bg-gray-100 dark:bg-white/10 hover:bg-gray-200 dark:hover:bg-white/15"
                        onClick={() => setSelected({ ...r })}
                      >
                        Edit
                      </button>
                      <button
                        className="px-3 py-1 rounded-lg bg-blue-600 text-white hover:bg-blue-700"
                        onClick={() => toggleActive(r)}
                      >
                        {r.isActive ? 'Disable' : 'Enable'}
                      </button>
                    </td>
                  </tr>
                ))}
                {rows.length === 0 && (
                  <tr>
                    <td className="p-4 text-text-secondary dark:text-gray-400" colSpan={4}>
                      Không có dữ liệu
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          <div className="bg-white dark:bg-surface-dark rounded-2xl shadow-soft p-5">
            <h2 className="text-lg font-semibold text-text-main dark:text-white mb-3">Edit</h2>
            {!selected ? (
              <p className="text-sm text-text-secondary dark:text-gray-400">Chọn 1 dòng để chỉnh sửa.</p>
            ) : (
              <div className="space-y-3">
                <ReadOnlyField label="ID" value={selected.id} />
                {tab === 'clinics' ? (
                  <>
                    <Field label="ClinicName" value={selected.clinicName || ''} onChange={(v) => setSelected({ ...selected, clinicName: v })} />
                    <Field label="Email" value={selected.email || ''} onChange={(v) => setSelected({ ...selected, email: v })} />
                    <Field label="Phone" value={selected.phone || ''} onChange={(v) => setSelected({ ...selected, phone: v })} />
                    <Field label="Address" value={selected.address || ''} onChange={(v) => setSelected({ ...selected, address: v })} />
                    <Field label="VerificationStatus" value={selected.verificationStatus || ''} onChange={(v) => setSelected({ ...selected, verificationStatus: v })} />
                  </>
                ) : (
                  <>
                    <Field label="Username" value={selected.username || ''} onChange={(v) => setSelected({ ...selected, username: v })} />
                    <Field label="FirstName" value={selected.firstName || ''} onChange={(v) => setSelected({ ...selected, firstName: v })} />
                    <Field label="LastName" value={selected.lastName || ''} onChange={(v) => setSelected({ ...selected, lastName: v })} />
                    <Field label="Email" value={selected.email || ''} onChange={(v) => setSelected({ ...selected, email: v })} />
                    {tab === 'doctors' && (
                      <Field label="LicenseNumber" value={selected.licenseNumber || ''} onChange={(v) => setSelected({ ...selected, licenseNumber: v })} />
                    )}
                  </>
                )}

                <div className="flex gap-2 pt-2">
                  <button
                    onClick={save}
                    disabled={saving}
                    className="flex-1 px-4 py-2 rounded-xl bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-60"
                  >
                    {saving ? 'Đang lưu...' : 'Save'}
                  </button>
                  <button
                    onClick={() => setSelected(null)}
                    disabled={saving}
                    className="px-4 py-2 rounded-xl bg-gray-100 dark:bg-white/10 hover:bg-gray-200 dark:hover:bg-white/15"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

function TabButton({ active, onClick, children }: { active: boolean; onClick: () => void; children: React.ReactNode }) {
  return (
    <button
      onClick={onClick}
      className={
        active
          ? 'px-4 py-2 rounded-xl bg-blue-600 text-white'
          : 'px-4 py-2 rounded-xl bg-white dark:bg-surface-dark text-text-main dark:text-white shadow-soft'
      }
    >
      {children}
    </button>
  );
}

function Field({ label, value, onChange }: { label: string; value: string; onChange: (v: string) => void }) {
  return (
    <div>
      <div className="text-xs font-medium text-text-secondary dark:text-gray-400 mb-1">{label}</div>
      <input
        className="w-full rounded-xl border border-gray-200 dark:border-white/10 bg-white dark:bg-surface-dark px-3 py-2 outline-none focus:ring-2 focus:ring-blue-500"
        value={value}
        onChange={(e) => onChange(e.target.value)}
      />
    </div>
  );
}

function ReadOnlyField({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <div className="text-xs font-medium text-text-secondary dark:text-gray-400 mb-1">{label}</div>
      <input
        className="w-full rounded-xl border border-gray-200 dark:border-white/10 bg-gray-50 dark:bg-white/5 px-3 py-2"
        value={value}
        readOnly
      />
    </div>
  );
}


