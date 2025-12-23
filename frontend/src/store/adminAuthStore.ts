import { create } from "zustand";
import { persist } from "zustand/middleware";
import adminService, { AdminLoginResponse } from "../services/adminService";

type AdminProfile = AdminLoginResponse["admin"];

interface AdminAuthState {
  admin: AdminProfile | null;
  isAdminAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;

  loginAdmin: (email: string, password: string) => Promise<boolean>;
  logoutAdmin: () => void;
  clearError: () => void;
}

export const useAdminAuthStore = create<AdminAuthState>()(
  persist(
    (set) => ({
      admin: null,
      isAdminAuthenticated: adminService.isAuthenticated(),
      isLoading: false,
      error: null,

      loginAdmin: async (email: string, password: string) => {
        set({ isLoading: true, error: null });
        try {
          const res = await adminService.login(email, password);
          set({
            admin: res.admin,
            isAdminAuthenticated: true,
            isLoading: false,
          });
          return true;
        } catch (e: any) {
          const msg =
            e?.response?.data?.message ||
            e?.message ||
            "Đăng nhập admin thất bại";
          set({ error: msg, isLoading: false });
          return false;
        }
      },

      logoutAdmin: () => {
        adminService.logout();
        set({ admin: null, isAdminAuthenticated: false });
      },

      clearError: () => set({ error: null }),
    }),
    {
      name: "admin-auth-storage",
      partialize: (s) => ({
        admin: s.admin,
        isAdminAuthenticated: s.isAdminAuthenticated,
      }),
    }
  )
);
