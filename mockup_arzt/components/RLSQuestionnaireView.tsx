import { useState } from 'react';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from './ui/card';
import { Badge } from './ui/badge';
import { Progress } from './ui/progress';
import { Calendar, ClipboardList } from 'lucide-react';
import type { RLSQuestionnaire } from '../lib/mockData';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from './ui/select';

interface RLSQuestionnaireViewProps {
  questionnaires: RLSQuestionnaire[];
}

export function RLSQuestionnaireView({ questionnaires }: RLSQuestionnaireViewProps) {
  const [selectedQuestionnaire, setSelectedQuestionnaire] = useState<string>(
    questionnaires[0]?.id || ''
  );

  if (questionnaires.length === 0) {
    return (
      <Card>
        <CardContent className="pt-6">
          <p className="text-center text-gray-500">Keine Fragebögen vorhanden</p>
        </CardContent>
      </Card>
    );
  }

  const currentQuestionnaire = questionnaires.find(q => q.id === selectedQuestionnaire);

  if (!currentQuestionnaire) {
    return null;
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('de-DE', { 
      day: '2-digit', 
      month: '2-digit', 
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  const getSeverityColor = (severity: string) => {
    switch (severity.toLowerCase()) {
      case 'sehr schwer':
      case 'schwer':
        return 'bg-red-500';
      case 'mittelschwer':
        return 'bg-orange-500';
      case 'leicht':
        return 'bg-yellow-500';
      default:
        return 'bg-gray-500';
    }
  };

  const scorePercentage = (currentQuestionnaire.score / currentQuestionnaire.maxScore) * 100;

  return (
    <div className="space-y-6">
      {/* Questionnaire Selector */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <ClipboardList className="w-5 h-5" />
            Fragebogen auswählen
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Select value={selectedQuestionnaire} onValueChange={setSelectedQuestionnaire}>
            <SelectTrigger>
              <SelectValue />
            </SelectTrigger>
            <SelectContent>
              {questionnaires.map((q) => (
                <SelectItem key={q.id} value={q.id}>
                  {q.type} - {formatDate(q.date)} (Score: {q.score}/{q.maxScore})
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </CardContent>
      </Card>

      {/* Summary Card */}
      <Card>
        <CardHeader>
          <CardTitle>Zusammenfassung</CardTitle>
          <CardDescription className="flex items-center gap-2">
            <Calendar className="w-4 h-4" />
            {formatDate(currentQuestionnaire.date)}
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="space-y-2">
              <p className="text-sm text-gray-500">Fragebogen-Typ</p>
              <Badge variant="outline" className="text-base">
                {currentQuestionnaire.type}
              </Badge>
            </div>
            <div className="space-y-2">
              <p className="text-sm text-gray-500">Gesamtscore</p>
              <p className="text-2xl">
                {currentQuestionnaire.score}/{currentQuestionnaire.maxScore}
              </p>
            </div>
            <div className="space-y-2">
              <p className="text-sm text-gray-500">Schweregrad</p>
              <Badge className={getSeverityColor(currentQuestionnaire.severity)}>
                {currentQuestionnaire.severity}
              </Badge>
            </div>
          </div>
          
          <div className="space-y-2">
            <div className="flex justify-between text-sm">
              <span>Score-Prozentsatz</span>
              <span>{Math.round(scorePercentage)}%</span>
            </div>
            <Progress value={scorePercentage} className="h-2" />
          </div>
        </CardContent>
      </Card>

      {/* Detailed Questions */}
      <Card>
        <CardHeader>
          <CardTitle>Detaillierte Antworten</CardTitle>
          <CardDescription>
            Einzelne Fragen und deren Bewertung
          </CardDescription>
        </CardHeader>
        <CardContent>
          <div className="space-y-4">
            {currentQuestionnaire.questions.map((question, index) => {
              const percentage = (question.answer / question.maxPoints) * 100;
              return (
                <div key={index} className="space-y-2 pb-4 border-b last:border-b-0 last:pb-0">
                  <div className="flex justify-between items-start gap-4">
                    <p className="text-sm flex-1">
                      <span className="text-gray-500 mr-2">{index + 1}.</span>
                      {question.question}
                    </p>
                    <Badge variant="secondary" className="shrink-0">
                      {question.answer}/{question.maxPoints}
                    </Badge>
                  </div>
                  <Progress 
                    value={percentage} 
                    className={`h-2 ${
                      percentage >= 75 ? '[&>div]:bg-red-500' :
                      percentage >= 50 ? '[&>div]:bg-orange-500' :
                      percentage >= 25 ? '[&>div]:bg-yellow-500' :
                      '[&>div]:bg-green-500'
                    }`}
                  />
                </div>
              );
            })}
          </div>
        </CardContent>
      </Card>

      {/* Interpretation Guide */}
      <Card className="bg-blue-50 border-blue-200">
        <CardHeader>
          <CardTitle className="text-base">Bewertungsskala {currentQuestionnaire.type}</CardTitle>
        </CardHeader>
        <CardContent>
          {currentQuestionnaire.type === 'IRLS' ? (
            <div className="space-y-2 text-sm">
              <p><span>0-10:</span> Leicht</p>
              <p><span>11-20:</span> Mittelschwer</p>
              <p><span>21-30:</span> Schwer</p>
              <p><span>31-40:</span> Sehr schwer</p>
            </div>
          ) : (
            <div className="space-y-2 text-sm">
              <p><span>0-10:</span> Leicht</p>
              <p><span>11-20:</span> Mittelschwer</p>
              <p><span>21-30:</span> Schwer</p>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
