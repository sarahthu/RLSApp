import { Button } from '../ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '../ui/card';
import { ArrowLeft, ExternalLink, FileText } from 'lucide-react';

interface InfoModuleProps {
  onBack: () => void;
}

const infoTopics = [
  {
    title: 'Was ist RLS?',
    content: 'Das Restless-Legs-Syndrom (RLS) ist eine neurologische Erkrankung, die durch einen starken Bewegungsdrang in den Beinen gekennzeichnet ist. Dieser tritt typischerweise in Ruhe auf und wird von unangenehmen Missempfindungen wie Kribbeln, Ziehen oder Stechen begleitet. Die Beschwerden bessern sich meist durch Bewegung.',
  },
  {
    title: 'Ursachen und Formen',
    content: 'Man unterscheidet zwischen primärem (idiopathischem) und sekundärem RLS. Das primäre RLS hat oft eine genetische Komponente. Das sekundäre RLS kann durch Eisenmangel, Schwangerschaft, Nierenerkrankungen oder bestimmte Medikamente ausgelöst werden.',
  },
  {
    title: 'Symptome erkennen',
    content: 'Typische Symptome sind: Bewegungsdrang in den Beinen, unangenehme Missempfindungen, Verschlechterung in Ruhe und am Abend, Besserung durch Bewegung. Viele Betroffene leiden unter Schlafstörungen und sind tagsüber müde.',
  },
  {
    title: 'Diagnose',
    content: 'Die Diagnose wird hauptsächlich anhand der Symptome gestellt. Ihr Arzt wird Sie ausführlich befragen und eine körperliche Untersuchung durchführen. Blutuntersuchungen (vor allem Eisenwerte) und manchmal auch eine Schlaflabor-Untersuchung können hilfreich sein.',
  },
  {
    title: 'Behandlungsmöglichkeiten',
    content: 'Die Behandlung umfasst nicht-medikamentöse Maßnahmen (Bewegung, Schlafhygiene, Vermeidung von Triggern) und bei Bedarf Medikamente. Häufig eingesetzte Medikamente sind Dopamin-Agonisten, Alpha-2-Delta-Liganden oder Opioide. Die Wahl hängt von der Schwere Ihrer Beschwerden ab.',
  },
  {
    title: 'Lebensstil und Selbsthilfe',
    content: 'Regelmäßige, moderate Bewegung kann helfen. Vermeiden Sie Koffein, Alkohol und Nikotin, besonders am Abend. Etablieren Sie feste Schlafzeiten. Wechselduschen, Massagen oder das Hochlagern der Beine können Linderung verschaffen. Führen Sie ein Symptom-Tagebuch.',
  },
  {
    title: 'Ernährung bei RLS',
    content: 'Achten Sie auf eine ausgewogene, eisenreiche Ernährung (rotes Fleisch, Hülsenfrüchte, grünes Blattgemüse). Vitamin C verbessert die Eisenaufnahme. Bei nachgewiesenem Eisenmangel kann eine Supplementierung sinnvoll sein - sprechen Sie mit Ihrem Arzt.',
  },
  {
    title: 'Umgang mit der Erkrankung',
    content: 'RLS ist eine chronische Erkrankung, die aber gut behandelbar ist. Informieren Sie Ihr Umfeld über Ihre Erkrankung. Suchen Sie sich gegebenenfalls Unterstützung in Selbsthilfegruppen. Mit der richtigen Behandlung können die meisten Betroffenen eine gute Lebensqualität erreichen.',
  },
];

export function InfoModule({ onBack }: InfoModuleProps) {
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
          <h2 className="text-2xl mb-2">Informationen</h2>
          <p className="text-gray-600">
            Wissenswertes über das Restless-Legs-Syndrom
          </p>
        </div>

        {/* Official Website Link */}
        <Card className="mb-6 bg-gradient-to-br from-blue-500 to-purple-600 text-white border-0">
          <CardContent className="p-6">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 bg-white/20 rounded-xl flex items-center justify-center flex-shrink-0">
                <ExternalLink className="w-6 h-6" />
              </div>
              <div className="flex-1">
                <h3 className="mb-2">Offizielle RLS Website</h3>
                <p className="text-sm text-white/90 mb-4">
                  Besuchen Sie die offizielle Website der Deutschen Restless Legs Vereinigung für weitere Informationen, aktuelle Forschung und Patientennetzwerke.
                </p>
                <Button 
                  variant="secondary"
                  onClick={() => window.open('https://www.restless-legs.org/', '_blank')}
                >
                  Website besuchen
                  <ExternalLink className="w-4 h-4 ml-2" />
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Info Topics */}
        <div className="space-y-4">
          {infoTopics.map((topic, index) => (
            <Card key={index} className="hover:shadow-md transition-shadow">
              <CardHeader>
                <div className="flex items-start gap-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-indigo-100 to-indigo-200 rounded-lg flex items-center justify-center flex-shrink-0">
                    <FileText className="w-5 h-5 text-indigo-600" />
                  </div>
                  <CardTitle className="text-lg">{topic.title}</CardTitle>
                </div>
              </CardHeader>
              <CardContent>
                <p className="text-gray-600 leading-relaxed">{topic.content}</p>
              </CardContent>
            </Card>
          ))}
        </div>

        {/* Additional Resources */}
        <Card className="mt-6 border-2 border-dashed">
          <CardContent className="pt-6">
            <h3 className="mb-3">Weitere Ressourcen</h3>
            <div className="space-y-2 text-sm text-gray-600">
              <p>• Patientenbroschüren können Sie bei Ihrem Arzt erhalten</p>
              <p>• Lokale Selbsthilfegruppen bieten Austausch mit anderen Betroffenen</p>
              <p>• Online-Foren und Communities für RLS-Patienten</p>
              <p>• Aktuelle Studien und Forschungsergebnisse</p>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
