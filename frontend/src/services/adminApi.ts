import axios, { AxiosError, InternalAxiosRequestConfig } from "axios";
import adminService from "./adminService";

const API_URL = import.meta.env.VITE_API_URL || "http://localhost:5000/api";

const adminApi = axios.create({
  baseURL: API_URL,
  timeout: 10000,
  headers: { "Content-Type": "application/json" },
});

adminApi.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = adminService.getToken();
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
  },
  (error) => Promise.reject(error)
);

adminApi.interceptors.response.use(
  (r) => r,
  (error: AxiosError) => {
    if (error.response?.status === 401) {
      adminService.logout();
    }
    return Promise.reject(error);
  }
);

export default adminApi;
