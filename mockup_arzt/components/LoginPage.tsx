import { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Activity, AlertCircle, Shield } from 'lucide-react';
import { Alert, AlertDescription } from './ui/alert';

interface LoginPageProps {
  onLogin: (username: string, password: string) => boolean;
}

export function LoginPage({ onLogin }: LoginPageProps) {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!username || !password) {
      setError('Bitte geben Sie Benutzername und Passwort ein.');
      return;
    }

    const success = onLogin(username, password);
    if (!success) {
      setError('Ungültige Anmeldedaten. Bitte versuchen Sie es erneut.');
    }
  };

  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <header className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 bg-gradient-to-br from-indigo-600 to-indigo-700 rounded-lg flex items-center justify-center shadow-md">
              <Activity className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-xl">DiGA Arzt-Portal</h1>
              <p className="text-xs text-gray-500">Restless-Legs-Syndrom Management</p>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <div className="flex-1 flex items-center justify-center bg-gradient-to-br from-indigo-50 via-white to-blue-50 p-4">
        <div className="w-full max-w-6xl grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Left Side - Information */}
          <div className="space-y-6">
            <div>
              <h2 className="text-4xl mb-4">Willkommen im DiGA Arzt-Portal</h2>
              <p className="text-xl text-gray-600">
                Professionelles Management für Patienten mit Restless-Legs-Syndrom
              </p>
            </div>

            <div className="space-y-4">
              <div className="flex gap-4">
                <div className="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center shrink-0">
                  <Activity className="w-6 h-6 text-indigo-600" />
                </div>
                <div>
                  <h3 className="text-lg mb-1">Patientenüberwachung</h3>
                  <p className="text-gray-600">
                    Überwachen Sie RLS-Symptome, Fragebögen und Tagebucheinträge Ihrer Patienten in Echtzeit
                  </p>
                </div>
              </div>

              <div className="flex gap-4">
                <div className="w-12 h-12 bg-indigo-100 rounded-lg flex items-center justify-center shrink-0">
                  <Shield className="w-6 h-6 text-indigo-600" />
                </div>
                <div>
                  <h3 className="text-lg mb-1">Sichere Datenverarbeitung</h3>
                  <p className="text-gray-600">
                    DSGVO-konforme Speicherung und Verarbeitung sensibler Gesundheitsdaten
                  </p>
                </div>
              </div>
            </div>

            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 text-sm">
              <p className="text-blue-900">
                <strong>Hinweis:</strong> Diese Plattform ist ausschließlich für medizinisches Fachpersonal bestimmt.
              </p>
            </div>
          </div>

          {/* Right Side - Login Form */}
          <Card className="w-full shadow-xl">
            <CardHeader className="space-y-3">
              <CardTitle className="text-center text-2xl">Anmeldung</CardTitle>
              <CardDescription className="text-center">
                Melden Sie sich mit Ihren Zugangsdaten an
              </CardDescription>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="username">Benutzername</Label>
                  <Input
                    id="username"
                    type="text"
                    placeholder="Ihr Benutzername"
                    value={username}
                    onChange={(e) => setUsername(e.target.value)}
                    autoComplete="username"
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="password">Passwort</Label>
                  <Input
                    id="password"
                    type="password"
                    placeholder="Ihr Passwort"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    autoComplete="current-password"
                  />
                </div>

                {error && (
                  <Alert variant="destructive">
                    <AlertCircle className="h-4 w-4" />
                    <AlertDescription>{error}</AlertDescription>
                  </Alert>
                )}

                <Button type="submit" className="w-full">
                  Anmelden
                </Button>

                <div className="space-y-2 pt-4">
                  <p className="text-sm text-gray-500 text-center">
                    Demo-Zugang: Beliebige Anmeldedaten verwenden
                  </p>
                  <div className="text-xs text-center text-gray-400">
                    <a href="#" className="hover:text-indigo-600">Passwort vergessen?</a>
                    {' • '}
                    <a href="#" className="hover:text-indigo-600">Support kontaktieren</a>
                  </div>
                </div>
              </form>
            </CardContent>
          </Card>
        </div>
      </div>

      {/* Footer */}
      <footer className="bg-white border-t py-6">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col sm:flex-row justify-between items-center gap-4 text-sm text-gray-500">
            <p>&copy; 2025 DiGA Arzt-Portal. Alle Rechte vorbehalten.</p>
            <div className="flex gap-4">
              <a href="#" className="hover:text-gray-900">Datenschutz</a>
              <a href="#" className="hover:text-gray-900">Impressum</a>
              <a href="#" className="hover:text-gray-900">Support</a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}