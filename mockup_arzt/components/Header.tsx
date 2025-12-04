import { Button } from './ui/button';
import { Activity, LogOut, User } from 'lucide-react';

interface HeaderProps {
  onLogout?: () => void;
  showLogout?: boolean;
  currentPage?: string;
}

export function Header({ onLogout, showLogout = false, currentPage }: HeaderProps) {
  return (
    <header className="bg-white border-b sticky top-0 z-50 shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo and Brand */}
          <div className="flex items-center gap-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-indigo-600 to-indigo-700 rounded-lg flex items-center justify-center shadow-md">
                <Activity className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-xl">DiGA Arzt-Portal</h1>
                <p className="text-xs text-gray-500">Restless-Legs-Syndrom Management</p>
              </div>
            </div>
          </div>

          {/* Navigation */}
          {showLogout && (
            <nav className="flex items-center gap-6">
              <div className="hidden md:flex items-center gap-6 text-sm">
                <a href="#" className={currentPage === 'dashboard' ? 'text-indigo-600' : 'text-gray-600 hover:text-gray-900'}>
                  Übersicht
                </a>
                <a href="#" className="text-gray-600 hover:text-gray-900">
                  Dokumentation
                </a>
                <a href="#" className="text-gray-600 hover:text-gray-900">
                  Einstellungen
                </a>
              </div>
              
              <div className="flex items-center gap-3 border-l pl-6">
                <div className="flex items-center gap-2 text-sm">
                  <div className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center">
                    <User className="w-4 h-4 text-gray-600" />
                  </div>
                  <span className="hidden sm:inline text-gray-700">Dr. Schmidt</span>
                </div>
                <Button variant="ghost" size="sm" onClick={onLogout}>
                  <LogOut className="w-4 h-4 mr-2" />
                  <span className="hidden sm:inline">Abmelden</span>
                </Button>
              </div>
            </nav>
          )}
        </div>
      </div>
    </header>
  );
}
