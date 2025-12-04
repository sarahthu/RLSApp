import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Label } from './ui/label';
import { Switch } from './ui/switch';
import { Separator } from './ui/separator';
import {
  User,
  Lock,
  Palette,
  Shield,
  FileText,
  Bell,
  Moon,
  LogOut,
  ChevronRight,
  Settings,
} from 'lucide-react';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from './ui/dialog';

interface SettingsViewProps {
  username: string;
  onLogout: () => void;
}

export function SettingsView({ username, onLogout }: SettingsViewProps) {
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [darkModeEnabled, setDarkModeEnabled] = useState(false);
  const [isPasswordDialogOpen, setIsPasswordDialogOpen] = useState(false);
  const [isProfileDialogOpen, setIsProfileDialogOpen] = useState(false);
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  const handlePasswordChange = () => {
    if (newPassword !== confirmPassword) {
      alert('Die Passwörter stimmen nicht überein');
      return;
    }
    if (newPassword.length < 6) {
      alert('Das Passwort muss mindestens 6 Zeichen lang sein');
      return;
    }
    alert('Passwort erfolgreich geändert');
    setIsPasswordDialogOpen(false);
    setCurrentPassword('');
    setNewPassword('');
    setConfirmPassword('');
  };

  const colorThemes = [
    { name: 'Blau-Lila', gradient: 'from-blue-500 to-purple-600', active: true },
    { name: 'Grün-Türkis', gradient: 'from-green-500 to-teal-600', active: false },
    { name: 'Orange-Rot', gradient: 'from-orange-500 to-red-600', active: false },
    { name: 'Indigo-Blau', gradient: 'from-indigo-500 to-blue-600', active: false },
  ];

  return (
    <div className="pb-20">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-500 to-purple-600 text-white px-4 py-6">
        <div className="flex items-center gap-3 mb-2">
          <Settings className="w-6 h-6" />
          <h1 className="text-2xl">Einstellungen</h1>
        </div>
        <p className="text-blue-100">Verwalten Sie Ihr Profil und App-Einstellungen</p>
      </div>

      <div className="px-4 py-4 space-y-4">
        {/* Profil-Karte */}
        <Card>
          <CardContent className="p-6">
            <div className="flex items-center gap-4">
              <div className="w-16 h-16 rounded-full bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center text-white text-2xl">
                {username.charAt(0).toUpperCase()}
              </div>
              <div className="flex-1">
                <h3 className="text-lg mb-1">{username}</h3>
                <p className="text-sm text-gray-500">RLS DIGA Patient</p>
              </div>
              <Dialog open={isProfileDialogOpen} onOpenChange={setIsProfileDialogOpen}>
                <DialogTrigger asChild>
                  <Button variant="outline" size="sm">
                    Bearbeiten
                  </Button>
                </DialogTrigger>
                <DialogContent>
                  <DialogHeader>
                    <DialogTitle>Profil bearbeiten</DialogTitle>
                    <DialogDescription>
                      Aktualisieren Sie Ihre persönlichen Informationen
                    </DialogDescription>
                  </DialogHeader>
                  <div className="space-y-4 py-4">
                    <div className="space-y-2">
                      <Label htmlFor="name">Name</Label>
                      <Input id="name" defaultValue={username} />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="email">E-Mail</Label>
                      <Input id="email" type="email" placeholder="ihre@email.de" />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="phone">Telefon</Label>
                      <Input id="phone" type="tel" placeholder="+49 123 456789" />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="birthday">Geburtsdatum</Label>
                      <Input id="birthday" type="date" />
                    </div>
                    <Button className="w-full" onClick={() => setIsProfileDialogOpen(false)}>
                      Speichern
                    </Button>
                  </div>
                </DialogContent>
              </Dialog>
            </div>
          </CardContent>
        </Card>

        {/* Konto & Sicherheit */}
        <div>
          <h3 className="text-sm text-gray-500 mb-2 px-2">Konto & Sicherheit</h3>
          <Card>
            <CardContent className="p-0">
              <Dialog open={isPasswordDialogOpen} onOpenChange={setIsPasswordDialogOpen}>
                <DialogTrigger asChild>
                  <button className="w-full flex items-center gap-3 p-4 hover:bg-gray-50 transition-colors">
                    <div className="w-10 h-10 rounded-full bg-blue-100 flex items-center justify-center">
                      <Lock className="w-5 h-5 text-blue-600" />
                    </div>
                    <div className="flex-1 text-left">
                      <p className="mb-0.5">Passwort ändern</p>
                      <p className="text-sm text-gray-500">Aktualisieren Sie Ihr Passwort</p>
                    </div>
                    <ChevronRight className="w-5 h-5 text-gray-400" />
                  </button>
                </DialogTrigger>
                <DialogContent>
                  <DialogHeader>
                    <DialogTitle>Passwort ändern</DialogTitle>
                    <DialogDescription>
                      Geben Sie Ihr aktuelles und neues Passwort ein
                    </DialogDescription>
                  </DialogHeader>
                  <div className="space-y-4 py-4">
                    <div className="space-y-2">
                      <Label htmlFor="current-password">Aktuelles Passwort</Label>
                      <Input
                        id="current-password"
                        type="password"
                        value={currentPassword}
                        onChange={(e) => setCurrentPassword(e.target.value)}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="new-password">Neues Passwort</Label>
                      <Input
                        id="new-password"
                        type="password"
                        value={newPassword}
                        onChange={(e) => setNewPassword(e.target.value)}
                      />
                    </div>
                    <div className="space-y-2">
                      <Label htmlFor="confirm-password">Passwort bestätigen</Label>
                      <Input
                        id="confirm-password"
                        type="password"
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                      />
                    </div>
                    <Button className="w-full" onClick={handlePasswordChange}>
                      Passwort ändern
                    </Button>
                  </div>
                </DialogContent>
              </Dialog>
            </CardContent>
          </Card>
        </div>

        {/* Benachrichtigungen */}
        <div>
          <h3 className="text-sm text-gray-500 mb-2 px-2">Benachrichtigungen</h3>
          <Card>
            <CardContent className="p-4 space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-green-100 flex items-center justify-center">
                    <Bell className="w-5 h-5 text-green-600" />
                  </div>
                  <div>
                    <p className="mb-0.5">Push-Benachrichtigungen</p>
                    <p className="text-sm text-gray-500">Erinnerungen und Updates</p>
                  </div>
                </div>
                <Switch checked={notificationsEnabled} onCheckedChange={setNotificationsEnabled} />
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Erscheinungsbild */}
        <div>
          <h3 className="text-sm text-gray-500 mb-2 px-2">Erscheinungsbild</h3>
          <Card>
            <CardContent className="p-4 space-y-4">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-purple-100 flex items-center justify-center">
                    <Moon className="w-5 h-5 text-purple-600" />
                  </div>
                  <div>
                    <p className="mb-0.5">Dunkler Modus</p>
                    <p className="text-sm text-gray-500">Augenschonende Ansicht</p>
                  </div>
                </div>
                <Switch checked={darkModeEnabled} onCheckedChange={setDarkModeEnabled} />
              </div>

              <Separator />

              <div>
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-10 h-10 rounded-full bg-pink-100 flex items-center justify-center">
                    <Palette className="w-5 h-5 text-pink-600" />
                  </div>
                  <div>
                    <p className="mb-0.5">Farbschema</p>
                    <p className="text-sm text-gray-500">Wählen Sie Ihr bevorzugtes Design</p>
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-2">
                  {colorThemes.map((theme) => (
                    <button
                      key={theme.name}
                      className={`p-3 rounded-lg border-2 transition-all ${
                        theme.active ? 'border-blue-500' : 'border-gray-200'
                      }`}
                    >
                      <div
                        className={`h-8 rounded bg-gradient-to-r ${theme.gradient} mb-2`}
                      />
                      <p className="text-sm">{theme.name}</p>
                    </button>
                  ))}
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Rechtliches */}
        <div>
          <h3 className="text-sm text-gray-500 mb-2 px-2">Rechtliches</h3>
          <Card>
            <CardContent className="p-0">
              <button className="w-full flex items-center gap-3 p-4 hover:bg-gray-50 transition-colors border-b">
                <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center">
                  <Shield className="w-5 h-5 text-gray-600" />
                </div>
                <div className="flex-1 text-left">
                  <p>Datenschutzerklärung</p>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </button>

              <button className="w-full flex items-center gap-3 p-4 hover:bg-gray-50 transition-colors border-b">
                <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center">
                  <FileText className="w-5 h-5 text-gray-600" />
                </div>
                <div className="flex-1 text-left">
                  <p>Nutzungsbedingungen</p>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </button>

              <button className="w-full flex items-center gap-3 p-4 hover:bg-gray-50 transition-colors">
                <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center">
                  <FileText className="w-5 h-5 text-gray-600" />
                </div>
                <div className="flex-1 text-left">
                  <p>Impressum</p>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400" />
              </button>
            </CardContent>
          </Card>
        </div>

        {/* Abmelden */}
        <Card className="border-red-200">
          <CardContent className="p-4">
            <Button
              variant="destructive"
              className="w-full"
              onClick={onLogout}
            >
              <LogOut className="w-4 h-4 mr-2" />
              Abmelden
            </Button>
          </CardContent>
        </Card>

        {/* App-Version */}
        <div className="text-center text-sm text-gray-500 pb-4">
          RLS DIGA App Version 1.0.0
        </div>
      </div>
    </div>
  );
}
