import { useState } from 'react';
import { Button } from '../ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { ArrowLeft, Plus, Pill, Calendar, FileText, ClipboardList, Trash2 } from 'lucide-react';
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '../ui/dialog';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '../ui/select';

interface RemindersModuleProps {
  onBack: () => void;
}

interface Reminder {
  id: string;
  type: 'medication' | 'appointment' | 'prescription' | 'questionnaire';
  title: string;
  time: string;
  frequency: string;
  date?: string;
}

const reminderTypes = [
  { value: 'medication', label: 'Medikament', icon: Pill, color: 'from-blue-500 to-blue-600' },
  { value: 'appointment', label: 'Arzttermin', icon: Calendar, color: 'from-green-500 to-green-600' },
  { value: 'prescription', label: 'Rezept', icon: FileText, color: 'from-orange-500 to-orange-600' },
  { value: 'questionnaire', label: 'Fragebogen', icon: ClipboardList, color: 'from-purple-500 to-purple-600' },
];

export function RemindersModule({ onBack }: RemindersModuleProps) {
  const [reminders, setReminders] = useState<Reminder[]>([
    {
      id: '1',
      type: 'medication',
      title: 'Pramipexol',
      time: '20:00',
      frequency: 'Täglich',
    },
    {
      id: '2',
      type: 'appointment',
      title: 'Kontrolltermin Dr. Müller',
      time: '10:30',
      date: '2025-12-15',
      frequency: 'Einmalig',
    },
  ]);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [newReminder, setNewReminder] = useState<Partial<Reminder>>({
    type: 'medication',
    frequency: 'daily',
  });

  const handleAddReminder = () => {
    if (!newReminder.title || !newReminder.time) {
      alert('Bitte füllen Sie alle Pflichtfelder aus');
      return;
    }

    const reminder: Reminder = {
      id: Date.now().toString(),
      type: newReminder.type as Reminder['type'],
      title: newReminder.title,
      time: newReminder.time,
      frequency: newReminder.frequency || 'Täglich',
      date: newReminder.date,
    };

    setReminders([...reminders, reminder]);
    setDialogOpen(false);
    setNewReminder({ type: 'medication', frequency: 'daily' });
  };

  const handleDeleteReminder = (id: string) => {
    setReminders(reminders.filter((r) => r.id !== id));
  };

  const getReminderTypeInfo = (type: string) => {
    return reminderTypes.find((t) => t.value === type) || reminderTypes[0];
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-3xl mx-auto px-4 py-4">
          <Button variant="ghost" onClick={onBack}>
            <ArrowLeft className="w-4 h-4 mr-2" />
            Zurück zur Übersicht
          </Button>
        </div>
      </div>

      <div className="max-w-3xl mx-auto px-4 py-6">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h2 className="text-2xl mb-2">Erinnerungen</h2>
            <p className="text-gray-600">
              Verwalten Sie Ihre Medikamente, Termine und mehr
            </p>
          </div>
          <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
            <DialogTrigger asChild>
              <Button>
                <Plus className="w-4 h-4 mr-2" />
                Neu
              </Button>
            </DialogTrigger>
            <DialogContent>
              <DialogHeader>
                <DialogTitle>Neue Erinnerung</DialogTitle>
                <DialogDescription>
                  Erstellen Sie eine neue Erinnerung
                </DialogDescription>
              </DialogHeader>
              <div className="space-y-4 mt-4">
                <div className="space-y-2">
                  <Label htmlFor="type">Art der Erinnerung</Label>
                  <Select
                    value={newReminder.type}
                    onValueChange={(value) => setNewReminder({ ...newReminder, type: value as Reminder['type'] })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      {reminderTypes.map((type) => (
                        <SelectItem key={type.value} value={type.value}>
                          {type.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div className="space-y-2">
                  <Label htmlFor="title">Titel</Label>
                  <Input
                    id="title"
                    placeholder="z.B. Medikamentenname oder Terminbeschreibung"
                    value={newReminder.title || ''}
                    onChange={(e) => setNewReminder({ ...newReminder, title: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="time">Uhrzeit</Label>
                  <Input
                    id="time"
                    type="time"
                    value={newReminder.time || ''}
                    onChange={(e) => setNewReminder({ ...newReminder, time: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="date">Datum (optional für Termine)</Label>
                  <Input
                    id="date"
                    type="date"
                    value={newReminder.date || ''}
                    onChange={(e) => setNewReminder({ ...newReminder, date: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="frequency">Häufigkeit</Label>
                  <Select
                    value={newReminder.frequency}
                    onValueChange={(value) => setNewReminder({ ...newReminder, frequency: value })}
                  >
                    <SelectTrigger>
                      <SelectValue />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="daily">Täglich</SelectItem>
                      <SelectItem value="weekly">Wöchentlich</SelectItem>
                      <SelectItem value="monthly">Monatlich</SelectItem>
                      <SelectItem value="once">Einmalig</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <Button onClick={handleAddReminder} className="w-full">
                  Erinnerung hinzufügen
                </Button>
              </div>
            </DialogContent>
          </Dialog>
        </div>

        {reminders.length === 0 ? (
          <Card className="border-2 border-dashed">
            <CardContent className="pt-12 pb-12 text-center">
              <div className="w-16 h-16 mx-auto bg-gray-100 rounded-full flex items-center justify-center mb-4">
                <Plus className="w-8 h-8 text-gray-400" />
              </div>
              <p className="text-gray-500 mb-4">Noch keine Erinnerungen vorhanden</p>
              <Button variant="outline" onClick={() => setDialogOpen(true)}>
                Erste Erinnerung erstellen
              </Button>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-3">
            {reminders.map((reminder) => {
              const typeInfo = getReminderTypeInfo(reminder.type);
              const Icon = typeInfo.icon;

              return (
                <Card key={reminder.id} className="group hover:shadow-md transition-shadow">
                  <CardContent className="p-4">
                    <div className="flex items-center gap-4">
                      <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${typeInfo.color} flex items-center justify-center flex-shrink-0`}>
                        <Icon className="w-6 h-6 text-white" />
                      </div>
                      <div className="flex-1">
                        <h3 className="mb-1">{reminder.title}</h3>
                        <div className="flex items-center gap-4 text-sm text-gray-500">
                          <span>{typeInfo.label}</span>
                          <span>•</span>
                          <span>{reminder.time} Uhr</span>
                          {reminder.date && (
                            <>
                              <span>•</span>
                              <span>{new Date(reminder.date).toLocaleDateString('de-DE')}</span>
                            </>
                          )}
                          <span>•</span>
                          <span>{reminder.frequency}</span>
                        </div>
                      </div>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => handleDeleteReminder(reminder.id)}
                        className="opacity-0 group-hover:opacity-100 transition-opacity"
                      >
                        <Trash2 className="w-4 h-4 text-red-500" />
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
