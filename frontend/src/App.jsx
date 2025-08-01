// App.jsx
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Login from './Login';
import AdminPanel from './AdminPanel';
import BitsPayWallet from './BitsPayWallet';

const ProtectedRoute = ({ children, role }) => {
  const token = localStorage.getItem('jwt_token');
  const userRole = localStorage.getItem('user_role');

  // New addition for development mode
  const isDevelopment = process.env.NODE_ENV === 'development';
  if (isDevelopment && role === 'admin') {
    // In development, allow direct access to the admin panel
    return children;
  }

  if (!token || userRole !== role) {
    // If not authenticated or not the correct role, redirect to login
    return <Navigate to="/login" replace />;
  }

  return children;
};

const App = () => (
  <Router>
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/wallet" element={<BitsPayWallet />} />

      {/* This is the corrected route for the Admin Panel */}
      <Route
        path="/admin-panel"
        element={
          <ProtectedRoute role="admin">
            <AdminPanel />
          </ProtectedRoute>
        }
      />

      <Route path="/" element={<Navigate to="/login" replace />} />
      <Route path="*" element={<Navigate to="/login" replace />} />
    </Routes>
  </Router>
);

export default App;