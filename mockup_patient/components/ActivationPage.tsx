import { useState } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { KeyRound } from 'lucide-react';

interface ActivationPageProps {
  username: string;
  onActivation: () => void;
}

export function ActivationPage({ username, onActivation }: ActivationPageProps) {
  const [activationCode, setActivationCode] = useState('');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!activationCode) {
      setError('Bitte geben Sie einen Freischaltcode ein');
      return;
    }

    // Mock activation validation
    if (activationCode.length >= 6) {
      onActivation();
    } else {
      setError('Ungültiger Freischaltcode');
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center p-4">
      <Card className="w-full max-w-md shadow-xl">
        <CardHeader className="text-center space-y-4">
          <div className="mx-auto w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
            <KeyRound className="w-8 h-8 text-white" />
          </div>
          <CardTitle className="text-2xl">Freischaltung erforderlich</CardTitle>
          <CardDescription>
            Willkommen zurück, {username}! <br />
            Bitte geben Sie Ihren Freischaltcode ein.
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="activationCode">Freischaltcode</Label>
              <Input
                id="activationCode"
                type="text"
                placeholder="Freischaltcode eingeben"
                value={activationCode}
                onChange={(e) => setActivationCode(e.target.value)}
                className="text-center tracking-wider"
              />
            </div>
            {error && (
              <div className="text-red-500 text-sm text-center">{error}</div>
            )}
            <Button type="submit" className="w-full">
              Freischalten
            </Button>
            <p className="text-sm text-gray-500 text-center mt-4">
              Haben Sie Ihren Code nicht erhalten? Kontaktieren Sie Ihren Arzt oder die Support-Hotline.
            </p>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
