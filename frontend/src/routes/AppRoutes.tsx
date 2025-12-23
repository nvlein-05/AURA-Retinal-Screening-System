import { Routes, Route, Navigate } from 'react-router-dom';
import ProfilePage from '../pages/user/ProfilePage';

const AppRoutes = () => {
  return (
    <Routes>
      <Route path="/profile" element={<ProfilePage />} />
      <Route path="/" element={<Navigate to="/profile" replace />} />
      <Route path="*" element={<div>404 - Not found</div>} />
    </Routes>
  );
};

export default AppRoutes;

