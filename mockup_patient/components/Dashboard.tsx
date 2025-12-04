import { useState } from 'react';
import { Home, Calendar, Settings } from 'lucide-react';
import { CalendarView } from './CalendarView';
import { SettingsView } from './SettingsView';
import { QuestionnaireModule } from './modules/QuestionnaireModule';
import { DiaryModule } from './modules/DiaryModule';
import { RemindersModule } from './modules/RemindersModule';
import { AnalyticsModule } from './modules/AnalyticsModule';
import { FAQModule } from './modules/FAQModule';
import { InfoModule } from './modules/InfoModule';
import { SensorModule } from './modules/SensorModule';
import {
  ClipboardList,
  BookOpen,
  Bell,
  BarChart3,
  HelpCircle,
  Info,
  Activity,
} from 'lucide-react';

interface DashboardProps {
  username: string;
  onLogout: () => void;
}

type MainView = 'home' | 'calendar' | 'settings';
type Module =
  | 'questionnaire'
  | 'diary'
  | 'reminders'
  | 'analytics'
  | 'faq'
  | 'info'
  | 'sensor'
  | null;

export function Dashboard({ username, onLogout }: DashboardProps) {
  const [mainView, setMainView] = useState<MainView>('home');
  const [activeModule, setActiveModule] = useState<Module>(null);

  const modules = [
    {
      id: 'questionnaire' as Module,
      title: 'Fragebögen',
      description: 'IRLSS & Lebensqualität',
      icon: ClipboardList,
      gradient: 'from-blue-500 to-blue-600',
    },
    {
      id: 'diary' as Module,
      title: 'Tagebuch',
      description: 'Symptome dokumentieren',
      icon: BookOpen,
      gradient: 'from-purple-500 to-purple-600',
    },
    {
      id: 'reminders' as Module,
      title: 'Erinnerungen',
      description: 'Medikamente & Termine',
      icon: Bell,
      gradient: 'from-green-500 to-green-600',
    },
    {
      id: 'analytics' as Module,
      title: 'Auswertungen',
      description: 'Diagramme & Statistiken',
      icon: BarChart3,
      gradient: 'from-orange-500 to-orange-600',
    },
    {
      id: 'faq' as Module,
      title: 'FAQ',
      description: 'Häufige Fragen',
      icon: HelpCircle,
      gradient: 'from-teal-500 to-teal-600',
    },
    {
      id: 'info' as Module,
      title: 'Informationen',
      description: 'Wissenswertes zu RLS',
      icon: Info,
      gradient: 'from-indigo-500 to-indigo-600',
    },
    {
      id: 'sensor' as Module,
      title: 'Sensor-Daten',
      description: 'Messungen erfassen',
      icon: Activity,
      gradient: 'from-pink-500 to-pink-600',
    },
  ];

  const handleModuleOpen = (moduleId: Module) => {
    setActiveModule(moduleId);
  };

  const handleModuleClose = () => {
    setActiveModule(null);
  };

  // Render active module
  if (activeModule === 'questionnaire') {
    return <QuestionnaireModule onBack={handleModuleClose} />;
  }
  if (activeModule === 'diary') {
    return <DiaryModule onBack={handleModuleClose} />;
  }
  if (activeModule === 'reminders') {
    return <RemindersModule onBack={handleModuleClose} />;
  }
  if (activeModule === 'analytics') {
    return <AnalyticsModule onBack={handleModuleClose} />;
  }
  if (activeModule === 'faq') {
    return <FAQModule onBack={handleModuleClose} />;
  }
  if (activeModule === 'info') {
    return <InfoModule onBack={handleModuleClose} />;
  }
  if (activeModule === 'sensor') {
    return <SensorModule onBack={handleModuleClose} />;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-purple-50">
      {/* Main Content */}
      <div className="pb-20">
        {mainView === 'home' && (
          <>
            {/* Header */}
            <div className="bg-gradient-to-r from-blue-500 to-purple-600 text-white px-4 py-6 rounded-b-3xl shadow-lg">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h1 className="text-2xl mb-1">Willkommen zurück!</h1>
                  <p className="text-blue-100">{username}</p>
                </div>
                <div className="w-12 h-12 rounded-full bg-white/20 flex items-center justify-center text-2xl">
                  {username.charAt(0).toUpperCase()}
                </div>
              </div>
            </div>

            {/* Modules Grid */}
            <div className="px-4 pt-6">
              <h2 className="text-lg mb-4">Ihre Tools</h2>
              <div className="grid grid-cols-2 gap-4">
                {modules.map((module) => {
                  const Icon = module.icon;
                  return (
                    <button
                      key={module.id}
                      onClick={() => handleModuleOpen(module.id)}
                      className="bg-white rounded-2xl shadow-sm hover:shadow-md transition-all p-4 text-left active:scale-95"
                    >
                      <div
                        className={`w-12 h-12 rounded-xl bg-gradient-to-br ${module.gradient} flex items-center justify-center mb-3`}
                      >
                        <Icon className="w-6 h-6 text-white" />
                      </div>
                      <h3 className="mb-1">{module.title}</h3>
                      <p className="text-xs text-gray-500">{module.description}</p>
                    </button>
                  );
                })}
              </div>
            </div>
          </>
        )}

        {mainView === 'calendar' && <CalendarView username={username} />}
        {mainView === 'settings' && <SettingsView username={username} onLogout={onLogout} />}
      </div>

      {/* Bottom Navigation */}
      <div className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 shadow-lg">
        <div className="grid grid-cols-3 max-w-md mx-auto">
          <button
            onClick={() => setMainView('home')}
            className={`flex flex-col items-center justify-center py-3 transition-colors ${
              mainView === 'home' ? 'text-blue-600' : 'text-gray-400'
            }`}
          >
            <Home className="w-6 h-6 mb-1" />
            <span className="text-xs">Start</span>
          </button>

          <button
            onClick={() => setMainView('calendar')}
            className={`flex flex-col items-center justify-center py-3 transition-colors ${
              mainView === 'calendar' ? 'text-blue-600' : 'text-gray-400'
            }`}
          >
            <Calendar className="w-6 h-6 mb-1" />
            <span className="text-xs">Kalender</span>
          </button>

          <button
            onClick={() => setMainView('settings')}
            className={`flex flex-col items-center justify-center py-3 transition-colors ${
              mainView === 'settings' ? 'text-blue-600' : 'text-gray-400'
            }`}
          >
            <Settings className="w-6 h-6 mb-1" />
            <span className="text-xs">Einstellungen</span>
          </button>
        </div>
      </div>
    </div>
  );
}