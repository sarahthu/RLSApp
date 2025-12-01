import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { 
  LineChart, 
  Line, 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend, 
  ResponsiveContainer 
} from 'recharts';
import { 
  Moon, 
  Utensils, 
  Dumbbell, 
  Heart, 
  FileText, 
  Calendar,
  Lock,
  TrendingUp,
  TrendingDown
} from 'lucide-react';
import type { DiaryEntry } from '../lib/mockData';
import { Alert, AlertDescription } from './ui/alert';

interface DiaryAnalysisProps {
  diaryEntries: DiaryEntry[];
  patientName: string;
}

export function DiaryAnalysis({ diaryEntries, patientName }: DiaryAnalysisProps) {
  const [selectedCategory, setSelectedCategory] = useState<'sleep' | 'nutrition' | 'exercise' | 'wellbeing'>('sleep');

  if (diaryEntries.length === 0) {
    return (
      <Card>
        <CardContent className="pt-6">
          <p className="text-center text-gray-500">Keine Tagebucheinträge vorhanden</p>
        </CardContent>
      </Card>
    );
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit' });
  };

  // Prepare chart data
  const chartData = diaryEntries
    .sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime())
    .map(entry => ({
      date: formatDate(entry.date),
      fullDate: entry.date,
      sleepDuration: entry.sleep.duration,
      sleepQuality: entry.sleep.quality,
      nutritionRating: entry.nutrition.rating,
      exerciseDuration: entry.exercise.duration,
      mood: entry.wellbeing.mood,
      stress: entry.wellbeing.stress,
    }));

  // Calculate averages
  const avgSleepDuration = (diaryEntries.reduce((sum, e) => sum + e.sleep.duration, 0) / diaryEntries.length).toFixed(1);
  const avgSleepQuality = (diaryEntries.reduce((sum, e) => sum + e.sleep.quality, 0) / diaryEntries.length).toFixed(1);
  const avgNutrition = (diaryEntries.reduce((sum, e) => sum + e.nutrition.rating, 0) / diaryEntries.length).toFixed(1);
  const avgExercise = (diaryEntries.reduce((sum, e) => sum + e.exercise.duration, 0) / diaryEntries.length).toFixed(0);
  const avgMood = (diaryEntries.reduce((sum, e) => sum + e.wellbeing.mood, 0) / diaryEntries.length).toFixed(1);
  const avgStress = (diaryEntries.reduce((sum, e) => sum + e.wellbeing.stress, 0) / diaryEntries.length).toFixed(1);

  // Calculate trends (last 3 vs first 3 entries)
  const calculateTrend = (getValue: (entry: DiaryEntry) => number) => {
    if (diaryEntries.length < 6) return null;
    const recent = diaryEntries.slice(0, 3).reduce((sum, e) => sum + getValue(e), 0) / 3;
    const older = diaryEntries.slice(-3).reduce((sum, e) => sum + getValue(e), 0) / 3;
    return recent - older;
  };

  const sleepTrend = calculateTrend(e => e.sleep.quality);
  const moodTrend = calculateTrend(e => e.wellbeing.mood);

  // Get entries with free text
  const entriesWithFreeText = diaryEntries.filter(e => e.freeTextShared && e.freeText);

  return (
    <div className="space-y-6">
      {/* Overview Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm">Durchschn. Schlaf</CardTitle>
            <Moon className="w-4 h-4 text-indigo-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{avgSleepDuration}h</div>
            <p className="text-xs text-gray-500 mt-1">Qualität: {avgSleepQuality}/10</p>
            {sleepTrend !== null && (
              <div className={`flex items-center gap-1 mt-2 text-xs ${sleepTrend > 0 ? 'text-green-600' : 'text-red-600'}`}>
                {sleepTrend > 0 ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
                <span>{sleepTrend > 0 ? 'Verbesserung' : 'Verschlechterung'}</span>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm">Durchschn. Ernährung</CardTitle>
            <Utensils className="w-4 h-4 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{avgNutrition}/10</div>
            <p className="text-xs text-gray-500 mt-1">Bewertung</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm">Durchschn. Sport</CardTitle>
            <Dumbbell className="w-4 h-4 text-orange-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{avgExercise} min</div>
            <p className="text-xs text-gray-500 mt-1">Pro Tag</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm">Wohlbefinden</CardTitle>
            <Heart className="w-4 h-4 text-red-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{avgMood}/10</div>
            <p className="text-xs text-gray-500 mt-1">Stress: {avgStress}/10</p>
            {moodTrend !== null && (
              <div className={`flex items-center gap-1 mt-2 text-xs ${moodTrend > 0 ? 'text-green-600' : 'text-red-600'}`}>
                {moodTrend > 0 ? <TrendingUp className="w-3 h-3" /> : <TrendingDown className="w-3 h-3" />}
                <span>{moodTrend > 0 ? 'Verbesserung' : 'Verschlechterung'}</span>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Category Tabs */}
      <Card>
        <CardHeader>
          <CardTitle>Kategorien im Zeitverlauf</CardTitle>
          <CardDescription>Visualisierung der Tagebuchdaten</CardDescription>
        </CardHeader>
        <CardContent>
          <Tabs value={selectedCategory} onValueChange={(v) => setSelectedCategory(v as any)}>
            <TabsList className="grid w-full grid-cols-4">
              <TabsTrigger value="sleep" className="gap-2">
                <Moon className="w-4 h-4" />
                Schlaf
              </TabsTrigger>
              <TabsTrigger value="nutrition" className="gap-2">
                <Utensils className="w-4 h-4" />
                Ernährung
              </TabsTrigger>
              <TabsTrigger value="exercise" className="gap-2">
                <Dumbbell className="w-4 h-4" />
                Sport
              </TabsTrigger>
              <TabsTrigger value="wellbeing" className="gap-2">
                <Heart className="w-4 h-4" />
                Wohlbefinden
              </TabsTrigger>
            </TabsList>

            <TabsContent value="sleep" className="space-y-4 mt-6">
              <div className="h-[300px]">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={chartData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line 
                      type="monotone" 
                      dataKey="sleepDuration" 
                      stroke="#6366f1" 
                      name="Schlafdauer (h)" 
                      strokeWidth={2}
                    />
                    <Line 
                      type="monotone" 
                      dataKey="sleepQuality" 
                      stroke="#8b5cf6" 
                      name="Schlafqualität (1-10)" 
                      strokeWidth={2}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>
              <Alert>
                <AlertDescription>
                  <strong>Interpretation:</strong> Die durchschnittliche Schlafdauer liegt bei {avgSleepDuration} Stunden 
                  mit einer Qualitätsbewertung von {avgSleepQuality}/10. 
                  {parseFloat(avgSleepDuration) < 6 && ' ⚠️ Die Schlafdauer liegt unter dem empfohlenen Minimum.'}
                </AlertDescription>
              </Alert>
            </TabsContent>

            <TabsContent value="nutrition" className="space-y-4 mt-6">
              <div className="h-[300px]">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={chartData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis domain={[0, 10]} />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="nutritionRating" fill="#10b981" name="Ernährungsbewertung (1-10)" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              <Alert>
                <AlertDescription>
                  <strong>Interpretation:</strong> Die durchschnittliche Ernährungsbewertung liegt bei {avgNutrition}/10.
                  {parseFloat(avgNutrition) >= 7 && ' ✓ Gute Ernährungsgewohnheiten.'}
                  {parseFloat(avgNutrition) < 6 && ' ⚠️ Verbesserungspotenzial bei der Ernährung.'}
                </AlertDescription>
              </Alert>
            </TabsContent>

            <TabsContent value="exercise" className="space-y-4 mt-6">
              <div className="h-[300px]">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={chartData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Bar dataKey="exerciseDuration" fill="#f97316" name="Sportdauer (min)" />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              <Alert>
                <AlertDescription>
                  <strong>Interpretation:</strong> Die durchschnittliche tägliche Bewegungszeit beträgt {avgExercise} Minuten.
                  {parseInt(avgExercise) >= 30 && ' ✓ Erfüllt die empfohlene tägliche Bewegung.'}
                  {parseInt(avgExercise) < 30 && ' ⚠️ Mehr körperliche Aktivität könnte hilfreich sein.'}
                </AlertDescription>
              </Alert>
            </TabsContent>

            <TabsContent value="wellbeing" className="space-y-4 mt-6">
              <div className="h-[300px]">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={chartData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis domain={[0, 10]} />
                    <Tooltip />
                    <Legend />
                    <Line 
                      type="monotone" 
                      dataKey="mood" 
                      stroke="#ec4899" 
                      name="Stimmung (1-10)" 
                      strokeWidth={2}
                    />
                    <Line 
                      type="monotone" 
                      dataKey="stress" 
                      stroke="#ef4444" 
                      name="Stress (1-10)" 
                      strokeWidth={2}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>
              <Alert>
                <AlertDescription>
                  <strong>Interpretation:</strong> Durchschnittliche Stimmung: {avgMood}/10, Stress: {avgStress}/10.
                  {parseFloat(avgStress) >= 7 && ' ⚠️ Erhöhtes Stresslevel - möglicherweise Intervention erforderlich.'}
                  {parseFloat(avgMood) < 5 && ' ⚠️ Niedrige Stimmungswerte könnten auf Depression hinweisen.'}
                </AlertDescription>
              </Alert>
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>

      {/* Free Text Entries */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <FileText className="w-5 h-5" />
            Freitext-Einträge
          </CardTitle>
          <CardDescription>
            Persönliche Notizen des Patienten (sofern freigegeben)
          </CardDescription>
        </CardHeader>
        <CardContent>
          {entriesWithFreeText.length === 0 ? (
            <div className="flex items-center gap-2 text-gray-500">
              <Lock className="w-4 h-4" />
              <p>Keine freigegebenen Texteinträge vorhanden</p>
            </div>
          ) : (
            <div className="space-y-4">
              {entriesWithFreeText.map((entry) => (
                <Card key={entry.id} className="bg-gray-50">
                  <CardHeader className="pb-3">
                    <div className="flex items-center gap-2 text-sm text-gray-500">
                      <Calendar className="w-4 h-4" />
                      {new Date(entry.date).toLocaleDateString('de-DE', { 
                        day: '2-digit', 
                        month: 'long', 
                        year: 'numeric' 
                      })}
                    </div>
                  </CardHeader>
                  <CardContent>
                    <p className="text-sm italic">"{entry.freeText}"</p>
                    <div className="flex gap-2 mt-3 flex-wrap">
                      <Badge variant="outline" className="text-xs">
                        Schlaf: {entry.sleep.quality}/10
                      </Badge>
                      <Badge variant="outline" className="text-xs">
                        Stimmung: {entry.wellbeing.mood}/10
                      </Badge>
                      <Badge variant="outline" className="text-xs">
                        Stress: {entry.wellbeing.stress}/10
                      </Badge>
                    </div>
                  </CardContent>
                </Card>
              ))}
            </div>
          )}
        </CardContent>
      </Card>

      {/* Detailed Entry Table */}
      <Card>
        <CardHeader>
          <CardTitle>Alle Einträge im Detail</CardTitle>
          <CardDescription>Chronologische Übersicht aller Tagebuchdaten</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="border-b">
                <tr className="text-left">
                  <th className="pb-2">Datum</th>
                  <th className="pb-2">Schlaf (h)</th>
                  <th className="pb-2">Qualität</th>
                  <th className="pb-2">Ernährung</th>
                  <th className="pb-2">Sport (min)</th>
                  <th className="pb-2">Stimmung</th>
                  <th className="pb-2">Stress</th>
                </tr>
              </thead>
              <tbody>
                {diaryEntries.map((entry) => (
                  <tr key={entry.id} className="border-b last:border-b-0">
                    <td className="py-3">
                      {new Date(entry.date).toLocaleDateString('de-DE', { 
                        day: '2-digit', 
                        month: '2-digit',
                        year: 'numeric'
                      })}
                    </td>
                    <td className="py-3">{entry.sleep.duration}</td>
                    <td className="py-3">
                      <Badge 
                        variant="outline"
                        className={
                          entry.sleep.quality >= 7 ? 'bg-green-50' :
                          entry.sleep.quality >= 4 ? 'bg-yellow-50' :
                          'bg-red-50'
                        }
                      >
                        {entry.sleep.quality}/10
                      </Badge>
                    </td>
                    <td className="py-3">{entry.nutrition.rating}/10</td>
                    <td className="py-3">{entry.exercise.duration}</td>
                    <td className="py-3">
                      <Badge 
                        variant="outline"
                        className={
                          entry.wellbeing.mood >= 7 ? 'bg-green-50' :
                          entry.wellbeing.mood >= 4 ? 'bg-yellow-50' :
                          'bg-red-50'
                        }
                      >
                        {entry.wellbeing.mood}/10
                      </Badge>
                    </td>
                    <td className="py-3">
                      <Badge 
                        variant="outline"
                        className={
                          entry.wellbeing.stress >= 7 ? 'bg-red-50' :
                          entry.wellbeing.stress >= 4 ? 'bg-yellow-50' :
                          'bg-green-50'
                        }
                      >
                        {entry.wellbeing.stress}/10
                      </Badge>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
