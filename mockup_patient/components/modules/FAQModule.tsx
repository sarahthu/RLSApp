import { Button } from '../ui/button';
import { ArrowLeft } from 'lucide-react';
import { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from '../ui/accordion';

interface FAQModuleProps {
  onBack: () => void;
}

const faqs = [
  {
    question: 'Was ist RLS (Restless-Legs-Syndrom)?',
    answer: 'Das Restless-Legs-Syndrom ist eine neurologische Erkrankung, die durch einen unangenehmen Bewegungsdrang in den Beinen gekennzeichnet ist, meist begleitet von unangenehmen Missempfindungen. Die Beschwerden treten typischerweise in Ruhe auf und bessern sich durch Bewegung.',
  },
  {
    question: 'Wann treten die Beschwerden am häufigsten auf?',
    answer: 'Die Symptome treten meistens abends und nachts auf, besonders in Ruhe oder beim Liegen. Viele Betroffene haben daher Schlafstörungen. Die Beschwerden können aber auch tagsüber auftreten, zum Beispiel bei längerem Sitzen.',
  },
  {
    question: 'Was kann ich selbst gegen RLS tun?',
    answer: 'Regelmäßige Bewegung, Verzicht auf Koffein und Alkohol am Abend, feste Schlafzeiten und Entspannungstechniken können helfen. Auch Wechselduschen oder Massagen der Beine werden von vielen Betroffenen als hilfreich empfunden.',
  },
  {
    question: 'Wie werden die Medikamente richtig eingenommen?',
    answer: 'Nehmen Sie Ihre Medikamente genau nach ärztlicher Verordnung ein. Die meisten RLS-Medikamente werden abends eingenommen, etwa 1-2 Stunden vor dem Schlafengehen. Ändern Sie nie selbstständig die Dosis. Nutzen Sie die Erinnerungsfunktion dieser App.',
  },
  {
    question: 'Wie oft sollte ich das Tagebuch ausfüllen?',
    answer: 'Am besten füllen Sie das Tagebuch täglich aus, möglichst zur gleichen Tageszeit. So können Sie und Ihr Arzt den Verlauf Ihrer Erkrankung besser nachvollziehen und die Behandlung optimal anpassen.',
  },
  {
    question: 'Was sind die IRLSS-Fragebögen?',
    answer: 'Der International RLS Severity Scale (IRLSS) ist ein standardisierter Fragebogen zur Bewertung des Schweregrads von RLS. Er hilft Ihrem Arzt, die Wirksamkeit der Behandlung zu beurteilen. Füllen Sie ihn am besten wöchentlich oder nach ärztlicher Empfehlung aus.',
  },
  {
    question: 'Wann sollte ich meinen Arzt kontaktieren?',
    answer: 'Kontaktieren Sie Ihren Arzt, wenn sich Ihre Symptome deutlich verschlechtern, die Medikamente nicht mehr wirken, starke Nebenwirkungen auftreten oder Sie neue Beschwerden bemerken. Nutzen Sie die Erinnerungsfunktion für Ihre Kontrolltermine.',
  },
  {
    question: 'Ist RLS heilbar?',
    answer: 'Das primäre RLS ist nicht heilbar, aber sehr gut behandelbar. Mit der richtigen Therapie können die meisten Betroffenen eine deutliche Verbesserung ihrer Lebensqualität erreichen. Das sekundäre RLS kann manchmal durch Behandlung der Grunderkrankung verbessert werden.',
  },
  {
    question: 'Kann ich trotz RLS Sport treiben?',
    answer: 'Ja, regelmäßige moderate Bewegung wird sogar empfohlen. Sport kann die Symptome lindern. Vermeiden Sie jedoch intensive Trainingseinheiten kurz vor dem Schlafengehen, da dies die Beschwerden verstärken kann.',
  },
  {
    question: 'Wie funktioniert die Auswertung in der App?',
    answer: 'Die App analysiert Ihre Tagebucheinträge und stellt sie grafisch dar. So können Sie Muster und Zusammenhänge erkennen, zum Beispiel zwischen Schlafqualität, Ernährung und Ihren RLS-Symptomen. Diese Informationen sind auch für Ihren Arzt wertvoll.',
  },
];

export function FAQModule({ onBack }: FAQModuleProps) {
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
          <h2 className="text-2xl mb-2">Häufig gestellte Fragen</h2>
          <p className="text-gray-600">
            Antworten auf die wichtigsten Fragen rund um RLS und die App
          </p>
        </div>

        <div className="bg-white rounded-xl shadow-sm p-6">
          <Accordion type="single" collapsible className="w-full">
            {faqs.map((faq, index) => (
              <AccordionItem key={index} value={`item-${index}`}>
                <AccordionTrigger className="text-left">
                  {faq.question}
                </AccordionTrigger>
                <AccordionContent className="text-gray-600 leading-relaxed">
                  {faq.answer}
                </AccordionContent>
              </AccordionItem>
            ))}
          </Accordion>
        </div>

        <div className="mt-6 bg-blue-50 rounded-xl p-6 border border-blue-100">
          <h3 className="mb-2">Weitere Fragen?</h3>
          <p className="text-sm text-gray-600 mb-4">
            Wenn Sie weitere Fragen haben, wenden Sie sich bitte an Ihren behandelnden Arzt oder kontaktieren Sie unsere Support-Hotline.
          </p>
          <div className="flex flex-col sm:flex-row gap-3">
            <Button variant="outline" className="flex-1">
              Support kontaktieren
            </Button>
            <Button variant="outline" className="flex-1">
              Arzt anrufen
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
