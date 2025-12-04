import { useState } from 'react';
import { Button } from '../ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { ArrowLeft, Moon, Utensils, Heart, Dumbbell, Plus, ChevronRight, Lock, Eye } from 'lucide-react';
import { RadioGroup, RadioGroupItem } from '../ui/radio-group';
import { Label } from '../ui/label';
import { Textarea } from '../ui/textarea';
import { Switch } from '../ui/switch';

interface DiaryModuleProps {
  onBack: () => void;
}

type Category = 'list' | 'sleep' | 'nutrition' | 'wellbeing' | 'exercise';

const categories = [
  {
    id: 'sleep' as Category,
    title: 'Schlaf',
    icon: Moon,
    color: 'from-indigo-500 to-indigo-600',
    questions: [
      'Wie würden Sie Ihre Schlafqualität heute bewerten?',
      'Wie viele Stunden haben Sie geschlafen?',
      'Hatten Sie Schwierigkeiten beim Einschlafen?',
    ],
  },
  {
    id: 'nutrition' as Category,
    title: 'Ernährung',
    icon: Utensils,
    color: 'from-green-500 to-green-600',
    questions: [
      'Wie ausgewogen war Ihre Ernährung heute?',
      'Haben Sie ausreichend Wasser getrunken?',
      'Haben Sie koffeinhaltige Getränke konsumiert?',
    ],
  },
  {
    id: 'wellbeing' as Category,
    title: 'Seelisches Wohlbefinden',
    icon: Heart,
    color: 'from-pink-500 to-pink-600',
    questions: [
      'Wie würden Sie Ihre Stimmung heute bewerten?',
      'Fühlten Sie sich gestresst?',
      'Hatten Sie Zeit für Entspannung?',
    ],
  },
  {
    id: 'exercise' as Category,
    title: 'Sport & Bewegung',
    icon: Dumbbell,
    color: 'from-orange-500 to-orange-600',
    questions: [
      'Wie aktiv waren Sie heute?',
      'Haben Sie Sport getrieben?',
      'Wie fühlen Sie sich körperlich?',
    ],
  },
];

const ratingOptions = [
  { value: '1', label: 'Sehr schlecht' },
  { value: '2', label: 'Schlecht' },
  { value: '3', label: 'Mittel' },
  { value: '4', label: 'Gut' },
  { value: '5', label: 'Sehr gut' },
];

export function DiaryModule({ onBack }: DiaryModuleProps) {
  const [view, setView] = useState<Category>('list');
  const [answers, setAnswers] = useState<Record<string, string>>({});
  const [freeText, setFreeText] = useState('');
  const [isPrivate, setIsPrivate] = useState(false);

  const handleAnswer = (questionId: string, value: string) => {
    setAnswers({ ...answers, [questionId]: value });
  };

  const handleSubmit = () => {
    const privacyStatus = isPrivate ? 'privat' : 'mit Arzt geteilt';
    alert(`Tagebucheintrag wurde ${privacyStatus} gespeichert!`);
    setView('list');
    setAnswers({});
    setFreeText('');
    setIsPrivate(false);
  };

  const activeCategory = categories.find((cat) => cat.id === view);

  if (view !== 'list' && activeCategory) {
    const Icon = activeCategory.icon;

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
              <div className="flex items-center gap-3 mb-2">
                <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${activeCategory.color} flex items-center justify-center`}>
                  <Icon className="w-6 h-6 text-white" />
                </div>
                <CardTitle>{activeCategory.title}</CardTitle>
              </div>
              <CardDescription>
                Datum: {new Date().toLocaleDateString('de-DE', { 
                  weekday: 'long', 
                  year: 'numeric', 
                  month: 'long', 
                  day: 'numeric' 
                })}
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {activeCategory.questions.map((question, index) => (
                <div key={index} className="space-y-3 pb-6 border-b">
                  <p className="mb-3">
                    <span className="text-sm text-gray-500 mr-2">Frage {index + 1}:</span>
                    {question}
                  </p>
                  <RadioGroup
                    value={answers[`${view}-${index}`]}
                    onValueChange={(value) => handleAnswer(`${view}-${index}`, value)}
                  >
                    <div className="space-y-2">
                      {ratingOptions.map((option) => (
                        <div key={option.value} className="flex items-center space-x-2">
                          <RadioGroupItem 
                            value={option.value} 
                            id={`${view}-${index}-${option.value}`} 
                          />
                          <Label 
                            htmlFor={`${view}-${index}-${option.value}`} 
                            className="cursor-pointer"
                          >
                            {option.label}
                          </Label>
                        </div>
                      ))}
                    </div>
                  </RadioGroup>
                </div>
              ))}

              <div className="space-y-3 pt-2">
                <Label htmlFor="freetext">Zusätzliche Notizen (optional)</Label>
                <Textarea
                  id="freetext"
                  placeholder="Hier können Sie weitere Gedanken, Beobachtungen oder Details notieren..."
                  value={freeText}
                  onChange={(e) => setFreeText(e.target.value)}
                  rows={5}
                />
              </div>

              {/* Privacy Toggle */}
              <Card className={`border-2 transition-colors ${
                isPrivate ? 'border-orange-300 bg-orange-50' : 'border-blue-300 bg-blue-50'
              }`}>
                <CardContent className="p-4">
                  <div className="flex items-start gap-4">
                    <div className={`w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0 ${
                      isPrivate ? 'bg-orange-100' : 'bg-blue-100'
                    }`}>
                      {isPrivate ? (
                        <Lock className="w-6 h-6 text-orange-600" />
                      ) : (
                        <Eye className="w-6 h-6 text-blue-600" />
                      )}
                    </div>
                    <div className="flex-1">
                      <div className="flex items-center justify-between mb-2">
                        <div>
                          <h4 className="mb-1">
                            {isPrivate ? '🔒 Privater Eintrag' : '👁️ Mit Arzt teilen'}
                          </h4>
                          <p className="text-sm text-gray-600">
                            {isPrivate 
                              ? 'Nur Sie können diesen Eintrag sehen' 
                              : 'Ihr Arzt kann diesen Eintrag einsehen'}
                          </p>
                        </div>
                        <Switch
                          id="privacy"
                          checked={isPrivate}
                          onCheckedChange={(checked) => setIsPrivate(checked)}
                        />
                      </div>
                      <p className="text-xs text-gray-500">
                        {isPrivate 
                          ? 'Dieser Eintrag wird nicht mit Ihrem Arzt geteilt und dient nur Ihrer persönlichen Dokumentation.' 
                          : 'Dieser Eintrag wird für Ihren Arzt sichtbar sein und kann bei der Behandlung helfen.'}
                      </p>
                    </div>
                  </div>
                </CardContent>
              </Card>

              <Button
                onClick={handleSubmit}
                disabled={Object.keys(answers).length !== activeCategory.questions.length}
                className="w-full"
              >
                {isPrivate ? '🔒 Privat speichern' : '✓ Speichern & mit Arzt teilen'}
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
          <h2 className="text-2xl mb-2">Tagebuch / Symptomabfrage</h2>
          <p className="text-gray-600">
            Dokumentieren Sie täglich Ihr Wohlbefinden in verschiedenen Kategorien
          </p>
        </div>

        <div className="grid gap-4">
          {categories.map((category) => {
            const Icon = category.icon;
            return (
              <button
                key={category.id}
                onClick={() => setView(category.id)}
                className="bg-white rounded-xl shadow-sm hover:shadow-md transition-all p-5 flex items-center gap-4 text-left group"
              >
                <div className={`w-14 h-14 rounded-xl bg-gradient-to-br ${category.color} flex items-center justify-center flex-shrink-0`}>
                  <Icon className="w-7 h-7 text-white" />
                </div>
                <div className="flex-1">
                  <h3 className="text-lg mb-1">{category.title}</h3>
                  <p className="text-sm text-gray-500">
                    {category.questions.length} Fragen + Freitextfeld
                  </p>
                </div>
                <ChevronRight className="w-5 h-5 text-gray-400 group-hover:text-gray-600 transition-colors flex-shrink-0" />
              </button>
            );
          })}
        </div>

        <Card className="mt-6 border-2 border-dashed">
          <CardContent className="pt-6">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center">
                <Plus className="w-5 h-5 text-gray-600" />
              </div>
              <div>
                <p className="text-sm">
                  Tipp: Füllen Sie das Tagebuch täglich aus für beste Ergebnisse
                </p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
