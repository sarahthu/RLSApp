import { Button } from './ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { Badge } from './ui/badge';
import { ArrowLeft, Calendar, User } from 'lucide-react';
import { getPatient, getPatientQuestionnaires, getPatientDiaryEntries, getPatientSensorData } from '../lib/mockData';
import { RLSQuestionnaireView } from './RLSQuestionnaireView';
import { DiaryAnalysis } from './DiaryAnalysis';
import { SensorAnalysis } from './SensorAnalysis';

interface PatientDetailProps {
  patientId: string;
  onBack: () => void;
  doctorName: string;
}

export function PatientDetail({ patientId, onBack, doctorName }: PatientDetailProps) {
  const patient = getPatient(patientId);
  const questionnaires = getPatientQuestionnaires(patientId);
  const diaryEntries = getPatientDiaryEntries(patientId);
  const sensorData = getPatientSensorData(patientId);

  if (!patient) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p>Patient nicht gefunden</p>
      </div>
    );
  }

  const calculateAge = (birthDate: string) => {
    const today = new Date();
    const birth = new Date(birthDate);
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
      age--;
    }
    return age;
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' });
  };

  return (
    <div className="bg-gray-50">
      {/* Breadcrumb / Hero Section */}
      <div className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <Button variant="ghost" onClick={onBack} className="mb-4">
            <ArrowLeft className="w-4 h-4 mr-2" />
            Zurück zur Übersicht
          </Button>
          <div className="flex items-start justify-between">
            <div>
              <h1 className="text-3xl mb-2">{patient.name}</h1>
              <div className="flex items-center gap-4 text-sm text-gray-600">
                <span>{calculateAge(patient.dateOfBirth)} Jahre</span>
                <span>•</span>
                <span>Letzter Kontakt: {formatDate(patient.lastContact)}</span>
                <span>•</span>
                <span>RLS-Score: {patient.rlsScore}/40</span>
              </div>
            </div>
            <div>
              {patient.riskLevel === 'high' && (
                <Badge variant="destructive" className="text-base px-4 py-2">Hohe Priorität</Badge>
              )}
              {patient.riskLevel === 'medium' && (
                <Badge className="bg-orange-500 text-base px-4 py-2">Mittlere Priorität</Badge>
              )}
              {patient.riskLevel === 'low' && (
                <Badge variant="secondary" className="text-base px-4 py-2">Niedrige Priorität</Badge>
              )}
            </div>
          </div>
        </div>
      </div>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Patient Info Card */}
        <Card className="mb-8">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <User className="w-5 h-5" />
              Patienteninformationen
            </CardTitle>
          </CardHeader>
          <CardContent>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div>
                <p className="text-sm text-gray-500 mb-1">Name</p>
                <p>{patient.name}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Alter</p>
                <p>{calculateAge(patient.dateOfBirth)} Jahre</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Geburtsdatum</p>
                <div className="flex items-center gap-2">
                  <Calendar className="w-4 h-4 text-gray-400" />
                  <p>{formatDate(patient.dateOfBirth)}</p>
                </div>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Aktueller RLS-Score</p>
                <p>
                  <span className={
                    patient.rlsScore >= 21 ? 'text-red-600' :
                    patient.rlsScore >= 11 ? 'text-orange-600' :
                    'text-green-600'
                  }>
                    {patient.rlsScore}/40
                  </span>
                </p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Letzter Kontakt</p>
                <p>{formatDate(patient.lastContact)}</p>
              </div>
              <div>
                <p className="text-sm text-gray-500 mb-1">Status</p>
                {patient.riskLevel === 'high' && (
                  <Badge variant="destructive">Hohe Priorität</Badge>
                )}
                {patient.riskLevel === 'medium' && (
                  <Badge className="bg-orange-500">Mittlere Priorität</Badge>
                )}
                {patient.riskLevel === 'low' && (
                  <Badge variant="secondary">Niedrige Priorität</Badge>
                )}
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Tabs for Questionnaires and Diary */}
        <Tabs defaultValue="questionnaires" className="space-y-6">
          <TabsList className="grid w-full max-w-2xl grid-cols-3">
            <TabsTrigger value="questionnaires">RLS-Fragebögen</TabsTrigger>
            <TabsTrigger value="diary">Tagebuch</TabsTrigger>
            <TabsTrigger value="sensor">Sensor-Daten</TabsTrigger>
          </TabsList>

          <TabsContent value="questionnaires">
            <RLSQuestionnaireView questionnaires={questionnaires} />
          </TabsContent>

          <TabsContent value="diary">
            <DiaryAnalysis diaryEntries={diaryEntries} patientName={patient.name} />
          </TabsContent>

          <TabsContent value="sensor">
            <SensorAnalysis sensorData={sensorData} patientName={patient.name} />
          </TabsContent>
        </Tabs>
      </main>
    </div>
  );
}