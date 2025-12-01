import { useState } from 'react';
import { Button } from '../ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { ArrowLeft, ChevronRight, ClipboardList } from 'lucide-react';
import { RadioGroup, RadioGroupItem } from '../ui/radio-group';
import { Label } from '../ui/label';

interface QuestionnaireModuleProps {
  onBack: () => void;
}

type View = 'list' | 'irlss' | 'qol';

const irlssQuestions = [
  'Wie würden Sie die Beschwerden in Ihren Beinen oder Armen insgesamt bewerten?',
  'Wie stark ist Ihr Bewegungsdrang aufgrund der RLS-Beschwerden?',
  'Wie stark werden Ihre RLS-Beschwerden durch Bewegung gelindert?',
  'Wie stark beeinträchtigen die RLS-Beschwerden Ihren Schlaf?',
  'Wie müde oder schläfrig sind Sie tagsüber aufgrund der RLS-Beschwerden?',
  'Wie stark ausgeprägt sind Ihre RLS-Beschwerden insgesamt?',
  'Wie oft treten Ihre RLS-Beschwerden auf?',
  'Wenn Sie RLS-Beschwerden haben, wie stark sind diese im Durchschnitt?',
  'Wie stark beeinträchtigen die RLS-Beschwerden Ihre Fähigkeit, tägliche Aufgaben zu erledigen?',
  'Wie stark beeinträchtigen die RLS-Beschwerden Ihre Stimmung?',
];

const qolQuestions = [
  'Wie würden Sie Ihre allgemeine Lebensqualität bewerten?',
  'Wie zufrieden sind Sie mit Ihrer Schlafqualität?',
  'Wie stark beeinträchtigt RLS Ihre täglichen Aktivitäten?',
  'Wie zufrieden sind Sie mit Ihrer aktuellen Behandlung?',
  'Wie würden Sie Ihr allgemeines Wohlbefinden bewerten?',
];

const options = [
  { value: '0', label: 'Keine' },
  { value: '1', label: 'Leicht' },
  { value: '2', label: 'Mittel' },
  { value: '3', label: 'Stark' },
  { value: '4', label: 'Sehr stark' },
];

export function QuestionnaireModule({ onBack }: QuestionnaireModuleProps) {
  const [view, setView] = useState<View>('list');
  const [irlssAnswers, setIrlssAnswers] = useState<Record<number, string>>({});
  const [qolAnswers, setQolAnswers] = useState<Record<number, string>>({});

  const handleIrlssAnswer = (questionIndex: number, value: string) => {
    setIrlssAnswers({ ...irlssAnswers, [questionIndex]: value });
  };

  const handleQolAnswer = (questionIndex: number, value: string) => {
    setQolAnswers({ ...qolAnswers, [questionIndex]: value });
  };

  const handleSubmitIrlss = () => {
    alert('IRLSS Fragebogen wurde gespeichert!');
    setView('list');
    setIrlssAnswers({});
  };

  const handleSubmitQol = () => {
    alert('Lebensqualität Fragebogen wurde gespeichert!');
    setView('list');
    setQolAnswers({});
  };

  if (view === 'irlss') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
        <div className="bg-white shadow-sm sticky top-0 z-10">
          <div className="max-w-3xl mx-auto px-4 py-4">
            <Button variant="ghost" onClick={() => setView('list')}>
              <ArrowLeft className="w-4 h-4 mr-2" />
              Zurück
            </Button>
          </div>
        </div>

        <div className="max-w-3xl mx-auto px-4 py-6">
          <Card>
            <CardHeader>
              <CardTitle>IRLSS - Internationaler RLS Schweregrad Score</CardTitle>
              <CardDescription>
                Bitte bewerten Sie jede Frage auf einer Skala von 0-4
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {irlssQuestions.map((question, index) => (
                <div key={index} className="space-y-3 pb-6 border-b last:border-b-0">
                  <p className="mb-3">
                    <span className="text-sm text-gray-500 mr-2">Frage {index + 1}:</span>
                    {question}
                  </p>
                  <RadioGroup
                    value={irlssAnswers[index]}
                    onValueChange={(value) => handleIrlssAnswer(index, value)}
                  >
                    <div className="space-y-2">
                      {options.map((option) => (
                        <div key={option.value} className="flex items-center space-x-2">
                          <RadioGroupItem value={option.value} id={`irlss-${index}-${option.value}`} />
                          <Label htmlFor={`irlss-${index}-${option.value}`} className="cursor-pointer">
                            {option.label}
                          </Label>
                        </div>
                      ))}
                    </div>
                  </RadioGroup>
                </div>
              ))}
              <Button
                onClick={handleSubmitIrlss}
                disabled={Object.keys(irlssAnswers).length !== irlssQuestions.length}
                className="w-full"
              >
                Fragebogen absenden
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

  if (view === 'qol') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
        <div className="bg-white shadow-sm sticky top-0 z-10">
          <div className="max-w-3xl mx-auto px-4 py-4">
            <Button variant="ghost" onClick={() => setView('list')}>
              <ArrowLeft className="w-4 h-4 mr-2" />
              Zurück
            </Button>
          </div>
        </div>

        <div className="max-w-3xl mx-auto px-4 py-6">
          <Card>
            <CardHeader>
              <CardTitle>Lebensqualität Fragebogen</CardTitle>
              <CardDescription>
                Bitte bewerten Sie jede Frage auf einer Skala von 0-4
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {qolQuestions.map((question, index) => (
                <div key={index} className="space-y-3 pb-6 border-b last:border-b-0">
                  <p className="mb-3">
                    <span className="text-sm text-gray-500 mr-2">Frage {index + 1}:</span>
                    {question}
                  </p>
                  <RadioGroup
                    value={qolAnswers[index]}
                    onValueChange={(value) => handleQolAnswer(index, value)}
                  >
                    <div className="space-y-2">
                      {options.map((option) => (
                        <div key={option.value} className="flex items-center space-x-2">
                          <RadioGroupItem value={option.value} id={`qol-${index}-${option.value}`} />
                          <Label htmlFor={`qol-${index}-${option.value}`} className="cursor-pointer">
                            {option.label}
                          </Label>
                        </div>
                      ))}
                    </div>
                  </RadioGroup>
                </div>
              ))}
              <Button
                onClick={handleSubmitQol}
                disabled={Object.keys(qolAnswers).length !== qolQuestions.length}
                className="w-full"
              >
                Fragebogen absenden
              </Button>
            </CardContent>
          </Card>
        </div>
      </div>
    );
  }

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
        <div className="mb-6">
          <h2 className="text-2xl mb-2">Fragebögen</h2>
          <p className="text-gray-600">
            Füllen Sie regelmäßig Fragebögen aus, um Ihren Behandlungsverlauf zu dokumentieren
          </p>
        </div>

        <div className="grid gap-4">
          <button
            onClick={() => setView('irlss')}
            className="bg-white rounded-xl shadow-sm hover:shadow-md transition-all p-5 flex items-center gap-4 text-left group"
          >
            <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center flex-shrink-0">
              <ClipboardList className="w-7 h-7 text-white" />
            </div>
            <div className="flex-1">
              <h3 className="text-lg mb-1">IRLSS Fragebogen</h3>
              <p className="text-sm text-gray-500">
                Internationaler RLS Schweregrad Score - 10 Fragen
              </p>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400 group-hover:text-gray-600 transition-colors flex-shrink-0" />
          </button>

          <button
            onClick={() => setView('qol')}
            className="bg-white rounded-xl shadow-sm hover:shadow-md transition-all p-5 flex items-center gap-4 text-left group"
          >
            <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center flex-shrink-0">
              <ClipboardList className="w-7 h-7 text-white" />
            </div>
            <div className="flex-1">
              <h3 className="text-lg mb-1">Lebensqualität Fragebogen</h3>
              <p className="text-sm text-gray-500">
                Bewertung der Lebensqualität - 5 Fragen
              </p>
            </div>
            <ChevronRight className="w-5 h-5 text-gray-400 group-hover:text-gray-600 transition-colors flex-shrink-0" />
          </button>
        </div>
      </div>
    </div>
  );
}
