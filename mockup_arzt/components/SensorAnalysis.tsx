import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { 
  LineChart, 
  Line, 
  AreaChart,
  Area,
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  Legend, 
  ResponsiveContainer 
} from 'recharts';
import { 
  Activity, 
  Calendar,
  Clock,
  TrendingUp,
  AlertTriangle,
  Heart,
  Info
} from 'lucide-react';
import type { SensorSession } from '../lib/mockData';
import { Alert, AlertDescription } from './ui/alert';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from './ui/select';

interface SensorAnalysisProps {
  sensorData: SensorSession[];
  patientName: string;
}

export function SensorAnalysis({ sensorData, patientName }: SensorAnalysisProps) {
  const [selectedSession, setSelectedSession] = useState<string>(
    sensorData[0]?.id || ''
  );

  if (sensorData.length === 0) {
    return (
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="w-5 h-5" />
            Sensor-Daten
          </CardTitle>
          <CardDescription>
            Objektive Messung von Bewegungsaktivität während der Nacht
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <Alert className="bg-blue-50 border-blue-200">
            <Info className="h-4 w-4 text-blue-600" />
            <AlertDescription className="text-blue-900">
              Sobald der Patient den RLS-Sensor verwendet, werden hier die aufgezeichneten 
              Bewegungsdaten und physiologischen Parameter angezeigt. Die Sensor-Auswertung 
              ermöglicht eine objektive Beurteilung der nächtlichen Bewegungsaktivität und 
              hilft bei der Verlaufskontrolle der RLS-Symptomatik.
            </AlertDescription>
          </Alert>
          
          <div className="bg-gray-50 rounded-lg p-6 space-y-3">
            <h3 className="text-sm">Was wird erfasst?</h3>
            <ul className="text-sm text-gray-600 space-y-2">
              <li className="flex gap-2">
                <span>•</span>
                <span><strong>Bewegungsintensität:</strong> Kontinuierliche Messung der Beinbewegungen</span>
              </li>
              <li className="flex gap-2">
                <span>•</span>
                <span><strong>Herzfrequenz:</strong> Monitoring der kardiovaskulären Parameter</span>
              </li>
              <li className="flex gap-2">
                <span>•</span>
                <span><strong>Bewegungsepisoden:</strong> Anzahl und Dauer von RLS-Episoden</span>
              </li>
              <li className="flex gap-2">
                <span>•</span>
                <span><strong>Zeitliche Verteilung:</strong> Wann treten die Symptome hauptsächlich auf</span>
              </li>
            </ul>
          </div>

          <p className="text-sm text-gray-500 text-center mt-6">
            Noch keine Sensor-Daten für diesen Patienten verfügbar.
          </p>
        </CardContent>
      </Card>
    );
  }

  const currentSession = sensorData.find(s => s.id === selectedSession);

  if (!currentSession) {
    return null;
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('de-DE', { 
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric'
    });
  };

  const formatTime = (time: string) => {
    return time;
  };

  const durationHours = (currentSession.duration / 60).toFixed(1);

  // Calculate additional metrics
  const highIntensityPeriods = currentSession.dataPoints.filter(
    dp => dp.movementIntensity >= 7
  ).length;
  
  const restfulPeriods = currentSession.dataPoints.filter(
    dp => dp.movementIntensity <= 2
  ).length;

  const movementTrend = currentSession.summary.avgMovementIntensity >= 5 ? 'Hoch' :
                        currentSession.summary.avgMovementIntensity >= 3 ? 'Mittel' : 'Niedrig';

  return (
    <div className="space-y-6">
      {/* Session Selector */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Activity className="w-5 h-5" />
            Sensor-Sitzung auswählen
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Select value={selectedSession} onValueChange={setSelectedSession}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {sensorData.map((session) => (
                <SelectItem key={session.id} value={session.id}>
                  {formatDate(session.date)} - {session.startTime} bis {session.endTime} 
                  ({session.type === 'night' ? 'Nacht' : 'Tag'})
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      {/* Summary Stats */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm">Aufzeichnungsdauer</CardTitle>
            <Clock className="w-4 h-4 text-indigo-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{durationHours}h</div>
            <p className="text-xs text-gray-500 mt-1">
              {formatTime(currentSession.startTime)} - {formatTime(currentSession.endTime)}
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm">Ø Bewegungsintensität</CardTitle>
            <Activity className="w-4 h-4 text-orange-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{currentSession.summary.avgMovementIntensity.toFixed(1)}/10</div>
            <Badge 
              className={
                currentSession.summary.avgMovementIntensity >= 5 ? 'bg-red-500' :
                currentSession.summary.avgMovementIntensity >= 3 ? 'bg-orange-500' :
                'bg-green-500'
              }
            >
              {movementTrend}
            </Badge>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm">Bewegungsepisoden</CardTitle>
            <AlertTriangle className="w-4 h-4 text-red-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">{currentSession.summary.movementEpisodes}</div>
            <p className="text-xs text-gray-500 mt-1">
              {highIntensityPeriods} Hochintensiv-Phasen
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm">Ø Herzfrequenz</CardTitle>
            <Heart className="w-4 h-4 text-red-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl">
              {currentSession.summary.avgHeartRate ? `${currentSession.summary.avgHeartRate} bpm` : 'N/A'}
            </div>
            <p className="text-xs text-gray-500 mt-1">
              {restfulPeriods} Ruhephasen
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Movement Intensity Chart */}
      <Card>
        <CardHeader>
          <CardTitle>Bewegungsintensität über die Nacht</CardTitle>
          <CardDescription className="flex items-center gap-2">
            <Calendar className="w-4 h-4" />
            {formatDate(currentSession.date)} - {currentSession.startTime} bis {currentSession.endTime}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="h-[350px]">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={currentSession.dataPoints}>
                <defs>
                  <linearGradient id="colorIntensity" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#ef4444" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#ef4444" stopOpacity={0.1}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis 
                  dataKey="timestamp" 
                  tick={{ fontSize: 12 }}
                  angle={-45}
                  textAnchor="end"
                  height={80}
                />
                <YAxis 
                  label={{ value: 'Bewegungsintensität', angle: -90, position: 'insideLeft' }}
                  domain={[0, 10]}
                />
                <Tooltip 
                  contentStyle={{ backgroundColor: 'white', border: '1px solid #ccc' }}
                  labelStyle={{ fontWeight: 'bold' }}
                />
                <Area 
                  type="monotone" 
                  dataKey="movementIntensity" 
                  stroke="#ef4444" 
                  fillOpacity={1}
                  fill="url(#colorIntensity)"
                  name="Bewegungsintensität"
                  strokeWidth={2}
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
          
          <div className="mt-4 p-4 bg-gray-50 rounded-lg">
            <p className="text-sm">
              <strong>Interpretation:</strong> Die roten Peaks zeigen Phasen erhöhter Bewegungsaktivität. 
              Eine durchschnittliche Intensität von {currentSession.summary.avgMovementIntensity.toFixed(1)}/10 
              {currentSession.summary.avgMovementIntensity >= 5 && ' deutet auf ausgeprägte RLS-Symptomatik hin.'}
              {currentSession.summary.avgMovementIntensity < 3 && ' zeigt eine relativ ruhige Nacht.'}
            </p>
          </div>
        </CardContent>
      </Card>

      {/* Heart Rate Chart */}
      {currentSession.summary.avgHeartRate && (
        <Card>
          <CardHeader>
            <CardTitle>Herzfrequenz im Verlauf</CardTitle>
            <CardDescription>
              Kardiovaskuläre Parameter während der Aufzeichnung
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="h-[300px]">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={currentSession.dataPoints}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis 
                    dataKey="timestamp"
                    tick={{ fontSize: 12 }}
                    angle={-45}
                    textAnchor="end"
                    height={80}
                  />
                  <YAxis 
                    label={{ value: 'Herzfrequenz (bpm)', angle: -90, position: 'insideLeft' }}
                    domain={[55, 90]}
                  />
                  <Tooltip />
                  <Legend />
                  <Line 
                    type="monotone" 
                    dataKey="heartRate" 
                    stroke="#ec4899" 
                    name="Herzfrequenz (bpm)"
                    strokeWidth={2}
                    dot={false}
                  />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Detailed Analysis */}
      <Card>
        <CardHeader>
          <CardTitle>Detaillierte Analyse</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-2">
              <h4 className="text-sm">Bewegungsmuster</h4>
              <div className="bg-gray-50 p-4 rounded-lg space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-600">Durchschnittliche Intensität:</span>
                  <span>{currentSession.summary.avgMovementIntensity.toFixed(1)}/10</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Maximale Intensität:</span>
                  <span className="text-red-600">{currentSession.summary.peakMovementIntensity}/10</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Bewegungsepisoden:</span>
                  <span>{currentSession.summary.movementEpisodes}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Hochintensiv-Phasen:</span>
                  <span>{highIntensityPeriods} Messungen</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Ruhephasen:</span>
                  <span className="text-green-600">{restfulPeriods} Messungen</span>
                </div>
              </div>
            </div>

            <div className="space-y-2">
              <h4 className="text-sm">Zeitliche Verteilung</h4>
              <div className="bg-gray-50 p-4 rounded-lg space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-600">Aufzeichnungsbeginn:</span>
                  <span>{formatTime(currentSession.startTime)} Uhr</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Aufzeichnungsende:</span>
                  <span>{formatTime(currentSession.endTime)} Uhr</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Gesamtdauer:</span>
                  <span>{durationHours} Stunden</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Datenpunkte:</span>
                  <span>{currentSession.dataPoints.length}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Typ:</span>
                  <Badge variant="outline">
                    {currentSession.type === 'night' ? 'Nächtliche Aufzeichnung' : 'Tagesaufzeichnung'}
                  </Badge>
                </div>
              </div>
            </div>
          </div>

          {/* Clinical Interpretation */}
          <Alert className={
            currentSession.summary.avgMovementIntensity >= 5 ? 'bg-red-50 border-red-200' :
            currentSession.summary.avgMovementIntensity >= 3 ? 'bg-orange-50 border-orange-200' :
            'bg-green-50 border-green-200'
          }>
            <TrendingUp className={`h-4 w-4 ${
              currentSession.summary.avgMovementIntensity >= 5 ? 'text-red-600' :
              currentSession.summary.avgMovementIntensity >= 3 ? 'text-orange-600' :
              'text-green-600'
            }`} />
            <AlertDescription>
              <strong>Klinische Einschätzung:</strong>
              {currentSession.summary.avgMovementIntensity >= 5 && (
                <span> Die Sensordaten zeigen eine ausgeprägte nächtliche Bewegungsaktivität mit 
                {currentSession.summary.movementEpisodes} deutlichen Episoden. Die durchschnittliche 
                Intensität von {currentSession.summary.avgMovementIntensity.toFixed(1)}/10 weist auf 
                eine schwere RLS-Symptomatik hin. Eine Therapieanpassung sollte erwogen werden.</span>
              )}
              {currentSession.summary.avgMovementIntensity >= 3 && currentSession.summary.avgMovementIntensity < 5 && (
                <span> Die Messungen zeigen eine moderate Bewegungsaktivität während der Nacht. 
                Die {currentSession.summary.movementEpisodes} Bewegungsepisoden und die durchschnittliche 
                Intensität von {currentSession.summary.avgMovementIntensity.toFixed(1)}/10 entsprechen einer 
                mittelschweren RLS-Symptomatik. Verlaufskontrolle empfohlen.</span>
              )}
              {currentSession.summary.avgMovementIntensity < 3 && (
                <span> Die Sensordaten zeigen eine relativ ruhige Nacht mit geringer Bewegungsaktivität. 
                Die durchschnittliche Intensität von {currentSession.summary.avgMovementIntensity.toFixed(1)}/10 
                deutet auf eine gute Symptomkontrolle hin. Aktuelle Therapie scheint wirksam.</span>
              )}
            </AlertDescription>
          </Alert>
        </CardContent>
      </Card>

      {/* Info Box */}
      <Card className="bg-blue-50 border-blue-200">
        <CardHeader>
          <CardTitle className="text-base flex items-center gap-2">
            <Info className="w-4 h-4" />
            Hinweise zur Sensor-Auswertung
          </CardTitle>
        </CardHeader>
        <CardContent className="text-sm space-y-2">
          <p>
            Die Sensor-Daten bieten eine objektive Messung der nächtlichen Bewegungsaktivität und 
            ergänzen die subjektiven Angaben aus Fragebögen und Tagebuch.
          </p>
          <ul className="list-disc list-inside space-y-1 text-gray-700">
            <li>Bewegungsintensität 7-10: Ausgeprägte RLS-Symptomatik</li>
            <li>Bewegungsintensität 4-6: Moderate Symptomatik</li>
            <li>Bewegungsintensität 0-3: Ruhige Phase / gute Kontrolle</li>
            <li>Mehrere Bewegungsepisoden pro Nacht können auf unzureichende Therapie hinweisen</li>
          </ul>
        </CardContent>
      </Card>
    </div>
  );
}
