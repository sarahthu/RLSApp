import { useState } from 'react';
import { LoginPage } from './components/LoginPage';
import { Dashboard } from './components/Dashboard';
import { PatientDetail } from './components/PatientDetail';
import { Header } from './components/Header';
import { Footer } from './components/Footer';

export interface Patient {
  id: string;
  name: string;
  dateOfBirth: string;
  lastContact: string;
  riskLevel: 'high' | 'medium' | 'low';
  rlsScore: number;
  hasNewData: boolean;
}

function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [selectedPatientId, setSelectedPatientId] = useState<string | null>(null);
  const [doctorName] = useState('Dr. Schmidt');

  const handleLogin = (username: string, password: string) => {
    // Mock login - in production würde hier eine echte Authentifizierung stattfinden
    if (username && password) {
      setIsLoggedIn(true);
      return true;
    }
    return false;
  };

  const handleLogout = () => {
    setIsLoggedIn(false);
    setSelectedPatientId(null);
  };

  const handleSelectPatient = (patientId: string) => {
    setSelectedPatientId(patientId);
  };

  const handleBackToDashboard = () => {
    setSelectedPatientId(null);
  };

  if (!isLoggedIn) {
    return <LoginPage onLogin={handleLogin} />;
  }

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <Header 
        onLogout={handleLogout} 
        showLogout={true}
        currentPage={selectedPatientId ? 'patient' : 'dashboard'}
      />
      
      <main className="flex-1">
        {selectedPatientId ? (
          <PatientDetail
            patientId={selectedPatientId}
            onBack={handleBackToDashboard}
            doctorName={doctorName}
          />
        ) : (
          <Dashboard
            onSelectPatient={handleSelectPatient}
            doctorName={doctorName}
          />
        )}
      </main>

      <Footer />
    </div>
  );
}

export default App;