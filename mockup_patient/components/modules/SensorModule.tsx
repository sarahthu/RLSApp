import { Button } from '../ui/button';
import { Card, CardContent } from '../ui/card';
import { ArrowLeft, Activity, Construction } from 'lucide-react';

interface SensorModuleProps {
  onBack: () => void;
}

export function SensorModule({ onBack }: SensorModuleProps) {
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
          <h2 className="text-2xl mb-2">Sensor Messung</h2>
          <p className="text-gray-600">
            Kommende Funktion zur Überwachung Ihrer RLS-Symptome
          </p>
        </div>

        <Card className="border-2 border-dashed">
          <CardContent className="pt-12 pb-12 text-center">
            <div className="w-20 h-20 mx-auto bg-gradient-to-br from-pink-100 to-pink-200 rounded-full flex items-center justify-center mb-6">
              <Construction className="w-10 h-10 text-pink-600" />
            </div>
            <h3 className="text-xl mb-3">In Entwicklung</h3>
            <p className="text-gray-600 mb-6 max-w-md mx-auto">
              Diese Funktion wird in einer zukünftigen Version verfügbar sein. Sie ermöglicht die Integration von Sensoren zur objektiven Messung Ihrer Bewegungen während der Nacht.
            </p>
            <div className="bg-pink-50 rounded-lg p-6 max-w-md mx-auto text-left">
              <div className="flex items-start gap-3">
                <Activity className="w-5 h-5 text-pink-600 flex-shrink-0 mt-0.5" />
                <div>
                  <p className="mb-3">
                    Geplante Features:
                  </p>
                  <ul className="text-sm text-gray-700 space-y-2">
                    <li>• Automatische Erfassung nächtlicher Bewegungen</li>
                    <li>• Verbindung mit tragbaren Sensoren</li>
                    <li>• Objektive Messung der RLS-Symptome</li>
                    <li>• Langzeit-Analyse und Verlaufskontrolle</li>
                    <li>• Integration in die Auswertung</li>
                  </ul>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="mt-6 bg-blue-50 border-blue-100">
          <CardContent className="pt-6">
            <h3 className="mb-2">Interesse an dieser Funktion?</h3>
            <p className="text-sm text-gray-600 mb-4">
              Lassen Sie sich benachrichtigen, sobald die Sensor-Messung verfügbar ist.
            </p>
            <Button variant="outline">
              Benachrichtigung aktivieren
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
