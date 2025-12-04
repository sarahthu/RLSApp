import { useState } from 'react';
import { Button } from '../ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { ArrowLeft, TrendingUp, Moon, Utensils, Heart, Dumbbell } from 'lucide-react';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '../ui/tabs';

interface AnalyticsModuleProps {
  onBack: () => void;
}

// Mock data for summary
const sleepData = [
  { date: 'Mo', quality: 3, hours: 6 },
  { date: 'Di', quality: 4, hours: 7 },
  { date: 'Mi', quality: 2, hours: 5 },
  { date: 'Do', quality: 3, hours: 6.5 },
  { date: 'Fr', quality: 4, hours: 7.5 },
  { date: 'Sa', quality: 5, hours: 8 },
  { date: 'So', quality: 4, hours: 7 },
];

const nutritionData = [
  { date: 'Mo', rating: 4 },
  { date: 'Di', rating: 3 },
  { date: 'Mi', rating: 4 },
  { date: 'Do', rating: 5 },
  { date: 'Fr', rating: 3 },
  { date: 'Sa', rating: 4 },
  { date: 'So', rating: 4 },
];

const wellbeingData = [
  { date: 'Mo', mood: 3, stress: 3 },
  { date: 'Di', mood: 4, stress: 2 },
  { date: 'Mi', mood: 3, stress: 4 },
  { date: 'Do', mood: 4, stress: 2 },
  { date: 'Fr', mood: 5, stress: 1 },
  { date: 'Sa', mood: 5, stress: 1 },
  { date: 'So', mood: 4, stress: 2 },
];

const exerciseData = [
  { date: 'Mo', activity: 3 },
  { date: 'Di', activity: 4 },
  { date: 'Mi', activity: 2 },
  { date: 'Do', activity: 4 },
  { date: 'Fr', activity: 3 },
  { date: 'Sa', activity: 5 },
  { date: 'So', activity: 4 },
];

export function AnalyticsModule({ onBack }: AnalyticsModuleProps) {
  const [timeframe, setTimeframe] = useState<'week' | 'month'>('week');

  const avgSleepQuality = (sleepData.reduce((acc, curr) => acc + curr.quality, 0) / sleepData.length).toFixed(1);
  const avgSleepHours = (sleepData.reduce((acc, curr) => acc + curr.hours, 0) / sleepData.length).toFixed(1);
  const avgMood = (wellbeingData.reduce((acc, curr) => acc + curr.mood, 0) / wellbeingData.length).toFixed(1);
  const avgActivity = (exerciseData.reduce((acc, curr) => acc + curr.activity, 0) / exerciseData.length).toFixed(1);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      <div className="bg-white shadow-sm sticky top-0 z-10">
        <div className="max-w-5xl mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <Button variant="ghost" onClick={onBack}>
              <ArrowLeft className="w-4 h-4 mr-2" />
              Zurück zur Übersicht
            </Button>
            <div className="flex gap-2">
              <Button 
                variant={timeframe === 'week' ? 'default' : 'outline'} 
                size="sm"
                onClick={() => setTimeframe('week')}
              >
                Woche
              </Button>
              <Button 
                variant={timeframe === 'month' ? 'default' : 'outline'} 
                size="sm"
                onClick={() => setTimeframe('month')}
              >
                Monat
              </Button>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-5xl mx-auto px-4 py-6">
        <div className="mb-6">
          <h2 className="text-2xl mb-2">Auswertung</h2>
          <p className="text-gray-600">
            Ihre Daten im Überblick - {timeframe === 'week' ? 'Letzte 7 Tage' : 'Letzter Monat'}
          </p>
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-indigo-100 rounded-lg flex items-center justify-center">
                  <Moon className="w-5 h-5 text-indigo-600" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Ø Schlafqualität</p>
                  <p className="text-2xl">{avgSleepQuality}/5</p>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
                  <Utensils className="w-5 h-5 text-green-600" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Ø Schlafstunden</p>
                  <p className="text-2xl">{avgSleepHours}h</p>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-pink-100 rounded-lg flex items-center justify-center">
                  <Heart className="w-5 h-5 text-pink-600" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Ø Stimmung</p>
                  <p className="text-2xl">{avgMood}/5</p>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="pt-6">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                  <Dumbbell className="w-5 h-5 text-orange-600" />
                </div>
                <div>
                  <p className="text-sm text-gray-500">Ø Aktivität</p>
                  <p className="text-2xl">{avgActivity}/5</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Data Visualization */}
        <Tabs defaultValue="sleep" className="space-y-6">
          <TabsList className="grid grid-cols-2 lg:grid-cols-4 w-full">
            <TabsTrigger value="sleep">Schlaf</TabsTrigger>
            <TabsTrigger value="nutrition">Ernährung</TabsTrigger>
            <TabsTrigger value="wellbeing">Wohlbefinden</TabsTrigger>
            <TabsTrigger value="exercise">Sport</TabsTrigger>
          </TabsList>

          <TabsContent value="sleep">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Moon className="w-5 h-5" />
                  Schlafanalyse
                </CardTitle>
                <CardDescription>
                  Entwicklung Ihrer Schlafqualität und Schlafdauer
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {sleepData.map((day) => (
                    <div key={day.date} className="flex items-center gap-4">
                      <div className="w-8 text-sm text-gray-500">{day.date}</div>
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <div className="text-sm text-gray-600 w-24">Qualität:</div>
                          <div className="flex-1 bg-gray-200 rounded-full h-2">
                            <div 
                              className="bg-indigo-500 h-2 rounded-full transition-all"
                              style={{ width: `${(day.quality / 5) * 100}%` }}
                            />
                          </div>
                          <div className="text-sm w-12 text-right">{day.quality}/5</div>
                        </div>
                        <div className="flex items-center gap-2">
                          <div className="text-sm text-gray-600 w-24">Stunden:</div>
                          <div className="flex-1 bg-gray-200 rounded-full h-2">
                            <div 
                              className="bg-purple-500 h-2 rounded-full transition-all"
                              style={{ width: `${(day.hours / 10) * 100}%` }}
                            />
                          </div>
                          <div className="text-sm w-12 text-right">{day.hours}h</div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="mt-6 flex items-start gap-2 p-4 bg-blue-50 rounded-lg">
                  <TrendingUp className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                  <div className="text-sm text-gray-700">
                    <p>
                      Ihre Schlafqualität zeigt einen positiven Trend. Am Wochenende schlafen Sie durchschnittlich besser.
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="nutrition">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Utensils className="w-5 h-5" />
                  Ernährungsverhalten
                </CardTitle>
                <CardDescription>
                  Bewertung Ihrer täglichen Ernährung
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {nutritionData.map((day) => (
                    <div key={day.date} className="flex items-center gap-4">
                      <div className="w-8 text-sm text-gray-500">{day.date}</div>
                      <div className="flex-1 bg-gray-200 rounded-full h-8">
                        <div 
                          className="bg-green-500 h-8 rounded-full flex items-center justify-end pr-3 transition-all"
                          style={{ width: `${(day.rating / 5) * 100}%` }}
                        >
                          <span className="text-xs text-white">{day.rating}/5</span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="mt-6 flex items-start gap-2 p-4 bg-green-50 rounded-lg">
                  <TrendingUp className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
                  <div className="text-sm text-gray-700">
                    <p>
                      Sie ernähren sich überwiegend ausgewogen. Achten Sie weiterhin auf eisenreiche Lebensmittel.
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="wellbeing">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Heart className="w-5 h-5" />
                  Seelisches Wohlbefinden
                </CardTitle>
                <CardDescription>
                  Entwicklung Ihrer Stimmung und Stresslevel
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {wellbeingData.map((day) => (
                    <div key={day.date} className="flex items-center gap-4">
                      <div className="w-8 text-sm text-gray-500">{day.date}</div>
                      <div className="flex-1">
                        <div className="flex items-center gap-2 mb-1">
                          <div className="text-sm text-gray-600 w-24">Stimmung:</div>
                          <div className="flex-1 bg-gray-200 rounded-full h-2">
                            <div 
                              className="bg-pink-500 h-2 rounded-full transition-all"
                              style={{ width: `${(day.mood / 5) * 100}%` }}
                            />
                          </div>
                          <div className="text-sm w-12 text-right">{day.mood}/5</div>
                        </div>
                        <div className="flex items-center gap-2">
                          <div className="text-sm text-gray-600 w-24">Stress:</div>
                          <div className="flex-1 bg-gray-200 rounded-full h-2">
                            <div 
                              className="bg-orange-500 h-2 rounded-full transition-all"
                              style={{ width: `${(day.stress / 5) * 100}%` }}
                            />
                          </div>
                          <div className="text-sm w-12 text-right">{day.stress}/5</div>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="mt-6 flex items-start gap-2 p-4 bg-pink-50 rounded-lg">
                  <TrendingUp className="w-5 h-5 text-pink-600 flex-shrink-0 mt-0.5" />
                  <div className="text-sm text-gray-700">
                    <p>
                      Ihre Stimmung hat sich im Wochenverlauf verbessert. Der Stresslevel ist am Wochenende deutlich niedriger.
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>

          <TabsContent value="exercise">
            <Card>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Dumbbell className="w-5 h-5" />
                  Sport & Bewegung
                </CardTitle>
                <CardDescription>
                  Ihre tägliche körperliche Aktivität
                </CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  {exerciseData.map((day) => (
                    <div key={day.date} className="flex items-center gap-4">
                      <div className="w-8 text-sm text-gray-500">{day.date}</div>
                      <div className="flex-1 bg-gray-200 rounded-full h-8">
                        <div 
                          className="bg-orange-500 h-8 rounded-full flex items-center justify-end pr-3 transition-all"
                          style={{ width: `${(day.activity / 5) * 100}%` }}
                        >
                          <span className="text-xs text-white">{day.activity}/5</span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="mt-6 flex items-start gap-2 p-4 bg-orange-50 rounded-lg">
                  <TrendingUp className="w-5 h-5 text-orange-600 flex-shrink-0 mt-0.5" />
                  <div className="text-sm text-gray-700">
                    <p>
                      Sie sind regelmäßig aktiv. Moderate Bewegung kann RLS-Symptome lindern - weiter so!
                    </p>
                  </div>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

        {/* Export Section */}
        <Card className="mt-6">
          <CardContent className="pt-6">
            <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
              <div>
                <h3 className="mb-1">Daten exportieren</h3>
                <p className="text-sm text-gray-600">
                  Exportieren Sie Ihre Auswertungen für Ihren Arzt
                </p>
              </div>
              <Button variant="outline">
                Als PDF exportieren
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
