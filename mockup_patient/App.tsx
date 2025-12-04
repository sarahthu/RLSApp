import { useState } from 'react';
import { LoginPage } from './components/LoginPage';
import { ActivationPage } from './components/ActivationPage';
import { Dashboard } from './components/Dashboard';

type AppState = 'login' | 'activation' | 'dashboard';

export default function App() {
  const [appState, setAppState] = useState<AppState>('login');
  const [username, setUsername] = useState('');

  const handleLogin = (user: string) => {
    setUsername(user);
    setAppState('activation');
  };

  const handleActivation = () => {
    setAppState('dashboard');
  };

  const handleLogout = () => {
    setUsername('');
    setAppState('login');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      {appState === 'login' && <LoginPage onLogin={handleLogin} />}
      {appState === 'activation' && (
        <ActivationPage username={username} onActivation={handleActivation} />
      )}
      {appState === 'dashboard' && (
        <Dashboard username={username} onLogout={handleLogout} />
      )}
    </div>
  );
}
