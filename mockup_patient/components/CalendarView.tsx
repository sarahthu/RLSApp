import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { Calendar, FileText, ClipboardList, Clock, ChevronLeft, ChevronRight, Edit, ArrowLeft, Lock, Eye } from 'lucide-react';
import { Button } from './ui/button';

interface CalendarEntry {
  date: string;
  type: 'diary' | 'questionnaire' | 'reminder';
  title: string;
  content?: string;
  isPrivate?: boolean;
  answers?: Record<string, string>;
}

interface CalendarViewProps {
  username: string;
}

export function CalendarView({ username }: CalendarViewProps) {
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth());
  const [selectedYear, setSelectedYear] = useState(new Date().getFullYear());
  const [selectedDate, setSelectedDate] = useState<string | null>(null);

  // Mock-Daten für Demonstration - aktualisiert auf Dezember 2025
  const mockEntries: CalendarEntry[] = [
    {
      date: '2025-12-01',
      type: 'diary',
      title: 'Tagebucheintrag - Schlaf',
      content: 'Schlafqualität: Gut (4/5)\nStunden geschlafen: 7-8 Stunden\nEinschlafschwierigkeiten: Nein\n\nZusätzliche Notizen: Hatte heute eine gute Nacht. Bin entspannt eingeschlafen.',
      isPrivate: false,
    },
    {
      date: '2025-12-01',
      type: 'questionnaire',
      title: 'IRLSS Fragebogen ausgefüllt',
      content: 'Score: 18/40 - Moderate Symptome',
    },
    {
      date: '2025-12-02',
      type: 'diary',
      title: 'Tagebucheintrag - Ernährung',
      content: 'Ernährung: Gut (4/5)\nWasser: Ausreichend\nKoffein: 2 Tassen Kaffee am Vormittag\n\nZusätzliche Notizen: Habe versucht weniger Kaffee zu trinken.',
      isPrivate: true,
    },
    {
      date: '2025-12-02',
      type: 'reminder',
      title: 'Medikament eingenommen',
      content: 'Abendmedikation um 20:00 Uhr',
    },
    {
      date: '2025-12-03',
      type: 'diary',
      title: 'Tagebucheintrag - Sport & Bewegung',
      content: 'Aktivität: Sehr gut (5/5)\nSport: 30 Min Spaziergang\nKörperliches Befinden: Gut\n\nZusätzliche Notizen: Spaziergang hat gut getan, fühle mich entspannter.',
      isPrivate: false,
    },
    {
      date: '2025-12-05',
      type: 'diary',
      title: 'Tagebucheintrag - Seelisches Wohlbefinden',
      content: 'Stimmung: Mittel (3/5)\nStress: Etwas gestresst\nEntspannung: Ja, 20 Min Meditation',
      isPrivate: false,
    },
  ];

  const getEntriesByDate = (date: string) => {
    return mockEntries.filter((entry) => entry.date === date);
  };

  const getDaysInMonth = (month: number, year: number) => {
    return new Date(year, month + 1, 0).getDate();
  };

  const getFirstDayOfMonth = (month: number, year: number) => {
    return new Date(year, month, 1).getDay();
  };

  const daysInMonth = getDaysInMonth(selectedMonth, selectedYear);
  const firstDay = getFirstDayOfMonth(selectedMonth, selectedYear);
  const today = new Date().getDate();
  const currentMonth = new Date().getMonth();
  const currentYear = new Date().getFullYear();

  const monthNames = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];

  const dayNames = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];

  const getTypeIcon = (type: string) => {
    switch (type) {
      case 'diary':
        return <FileText className="w-5 h-5" />;
      case 'questionnaire':
        return <ClipboardList className="w-5 h-5" />;
      case 'reminder':
        return <Clock className="w-5 h-5" />;
      default:
        return null;
    }
  };

  const getTypeBadge = (type: string) => {
    switch (type) {
      case 'diary':
        return 'Tagebuch';
      case 'questionnaire':
        return 'Fragebogen';
      case 'reminder':
        return 'Erinnerung';
      default:
        return '';
    }
  };

  const getTypeColor = (type: string) => {
    switch (type) {
      case 'diary':
        return 'from-blue-500 to-blue-600';
      case 'questionnaire':
        return 'from-purple-500 to-purple-600';
      case 'reminder':
        return 'from-green-500 to-green-600';
      default:
        return 'from-gray-500 to-gray-600';
    }
  };

  const handlePreviousMonth = () => {
    if (selectedMonth === 0) {
      setSelectedMonth(11);
      setSelectedYear(selectedYear - 1);
    } else {
      setSelectedMonth(selectedMonth - 1);
    }
  };

  const handleNextMonth = () => {
    if (selectedMonth === 11) {
      setSelectedMonth(0);
      setSelectedYear(selectedYear + 1);
    } else {
      setSelectedMonth(selectedMonth + 1);
    }
  };

  const handleDateClick = (dateStr: string) => {
    const entries = getEntriesByDate(dateStr);
    if (entries.length > 0) {
      setSelectedDate(dateStr);
    }
  };

  // Detailansicht für ausgewähltes Datum
  if (selectedDate) {
    const entries = getEntriesByDate(selectedDate);
    const displayDate = new Date(selectedDate + 'T00:00:00');

    return (
      <div className="pb-20">
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-500 to-purple-600 text-white px-4 py-6">
          <Button
            variant="ghost"
            onClick={() => setSelectedDate(null)}
            className="text-white hover:bg-white/20 mb-3 -ml-2"
          >
            <ArrowLeft className="w-4 h-4 mr-2" />
            Zurück zum Kalender
          </Button>
          <div className="flex items-center gap-3 mb-2">
            <Calendar className="w-6 h-6" />
            <h1 className="text-2xl">
              {displayDate.toLocaleDateString('de-DE', {
                weekday: 'long',
                day: 'numeric',
                month: 'long',
                year: 'numeric',
              })}
            </h1>
          </div>
          <p className="text-blue-100">{entries.length} Eintrag{entries.length > 1 ? 'e' : ''}</p>
        </div>

        <div className="px-4 py-4 space-y-4">
          {entries.map((entry, index) => (
            <Card key={index} className="overflow-hidden">
              <div className={`h-2 bg-gradient-to-r ${getTypeColor(entry.type)}`} />
              <CardHeader>
                <div className="flex items-start justify-between gap-3">
                  <div className="flex items-start gap-3 flex-1">
                    <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${getTypeColor(entry.type)} flex items-center justify-center text-white flex-shrink-0`}>
                      {getTypeIcon(entry.type)}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center gap-2 mb-1">
                        <Badge variant="secondary" className="text-xs">
                          {getTypeBadge(entry.type)}
                        </Badge>
                        {entry.isPrivate !== undefined && (
                          <Badge variant={entry.isPrivate ? 'destructive' : 'default'} className="text-xs">
                            {entry.isPrivate ? (
                              <>
                                <Lock className="w-3 h-3 mr-1" />
                                Privat
                              </>
                            ) : (
                              <>
                                <Eye className="w-3 h-3 mr-1" />
                                Geteilt
                              </>
                            )}
                          </Badge>
                        )}
                      </div>
                      <CardTitle className="text-lg">{entry.title}</CardTitle>
                    </div>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                {entry.content && (
                  <div className="whitespace-pre-wrap text-gray-700 bg-gray-50 p-4 rounded-lg">
                    {entry.content}
                  </div>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      </div>
    );
  }

  // Kalenderansicht
  return (
    <div className="pb-20">
      {/* Header */}
      <div className="bg-gradient-to-r from-blue-500 to-purple-600 text-white px-4 py-6">
        <div className="flex items-center gap-3 mb-2">
          <Calendar className="w-6 h-6" />
          <h1 className="text-2xl">Kalender</h1>
        </div>
        <p className="text-blue-100">Ihre Einträge und Aktivitäten im Überblick</p>
      </div>

      <div className="px-4 py-4 space-y-4">
        {/* Monatsanzeige */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <Button
                variant="outline"
                size="sm"
                onClick={handlePreviousMonth}
                className="h-8 w-8 p-0"
              >
                <ChevronLeft className="w-4 h-4" />
              </Button>
              <div className="text-center">
                <CardTitle className="mb-0">
                  {monthNames[selectedMonth]} {selectedYear}
                </CardTitle>
              </div>
              <Button
                variant="outline"
                size="sm"
                onClick={handleNextMonth}
                className="h-8 w-8 p-0"
              >
                <ChevronRight className="w-4 h-4" />
              </Button>
            </div>
            <CardDescription className="text-center">Tippen Sie auf einen Tag mit ✏️ um Einträge zu sehen</CardDescription>
          </CardHeader>
          <CardContent>
            {/* Wochentage */}
            <div className="grid grid-cols-7 gap-1 mb-2">
              {dayNames.map((day) => (
                <div key={day} className="text-center text-sm text-gray-500 py-2">
                  {day}
                </div>
              ))}
            </div>

            {/* Kalendertage */}
            <div className="grid grid-cols-7 gap-1">
              {/* Leere Zellen vor dem ersten Tag */}
              {Array.from({ length: firstDay === 0 ? 6 : firstDay - 1 }).map((_, i) => (
                <div key={`empty-${i}`} className="aspect-square" />
              ))}

              {/* Tage des Monats */}
              {Array.from({ length: daysInMonth }).map((_, i) => {
                const day = i + 1;
                const dateStr = `${selectedYear}-${String(selectedMonth + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
                const entries = getEntriesByDate(dateStr);
                const isToday = day === today && selectedMonth === currentMonth && selectedYear === currentYear;
                const hasEntries = entries.length > 0;

                return (
                  <button
                    key={day}
                    onClick={() => handleDateClick(dateStr)}
                    disabled={!hasEntries}
                    className={`aspect-square flex flex-col items-center justify-center relative rounded-lg border transition-all ${
                      isToday
                        ? 'bg-blue-100 border-blue-500 border-2'
                        : hasEntries
                        ? 'bg-purple-50 border-purple-300 shadow-sm hover:shadow-md hover:bg-purple-100 cursor-pointer active:scale-95'
                        : 'border-gray-200 cursor-default'
                    }`}
                  >
                    <span className={`text-sm ${isToday ? 'font-bold text-blue-600' : hasEntries ? 'font-semibold text-purple-700' : 'text-gray-600'}`}>
                      {day}
                    </span>
                    {hasEntries && (
                      <div className="absolute top-1 right-1">
                        <Edit className="w-3.5 h-3.5 text-purple-600" />
                      </div>
                    )}
                    {hasEntries && entries.length > 1 && (
                      <div className="absolute bottom-1 left-1/2 transform -translate-x-1/2">
                        <div className="bg-purple-600 text-white text-xs rounded-full w-4 h-4 flex items-center justify-center">
                          {entries.length}
                        </div>
                      </div>
                    )}
                  </button>
                );
              })}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
