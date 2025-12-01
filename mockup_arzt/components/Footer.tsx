import { Activity, Mail, Phone, MapPin } from 'lucide-react';

export function Footer() {
  return (
    <footer className="bg-gray-900 text-gray-300 mt-auto">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* Brand */}
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-gradient-to-br from-indigo-600 to-indigo-700 rounded-lg flex items-center justify-center">
                <Activity className="w-6 h-6 text-white" />
              </div>
              <div>
                <h3 className="text-white">DiGA Portal</h3>
                <p className="text-xs text-gray-400">RLS Management</p>
              </div>
            </div>
            <p className="text-sm text-gray-400">
              Digitale Gesundheitsanwendung für die professionelle Betreuung von Patienten mit Restless-Legs-Syndrom.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="text-white mb-4">Navigation</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="#" className="hover:text-white transition-colors">Patientenübersicht</a></li>
              <li><a href="#" className="hover:text-white transition-colors">Dokumentation</a></li>
              <li><a href="#" className="hover:text-white transition-colors">Einstellungen</a></li>
              <li><a href="#" className="hover:text-white transition-colors">Hilfe & Support</a></li>
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h3 className="text-white mb-4">Ressourcen</h3>
            <ul className="space-y-2 text-sm">
              <li><a href="#" className="hover:text-white transition-colors">Datenschutz</a></li>
              <li><a href="#" className="hover:text-white transition-colors">Nutzungsbedingungen</a></li>
              <li><a href="#" className="hover:text-white transition-colors">Impressum</a></li>
              <li><a href="#" className="hover:text-white transition-colors">Technischer Support</a></li>
            </ul>
          </div>

          {/* Contact */}
          <div>
            <h3 className="text-white mb-4">Kontakt</h3>
            <ul className="space-y-3 text-sm">
              <li className="flex items-start gap-2">
                <Mail className="w-4 h-4 mt-0.5 text-indigo-400" />
                <span>support@diga-portal.de</span>
              </li>
              <li className="flex items-start gap-2">
                <Phone className="w-4 h-4 mt-0.5 text-indigo-400" />
                <span>+49 (0) 123 456789</span>
              </li>
              <li className="flex items-start gap-2">
                <MapPin className="w-4 h-4 mt-0.5 text-indigo-400" />
                <span>Musterstraße 123<br />12345 Berlin</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="border-t border-gray-800 mt-8 pt-8 text-sm text-center text-gray-400">
          <p>&copy; 2025 DiGA Arzt-Portal. Alle Rechte vorbehalten.</p>
          <p className="mt-2 text-xs">
            Diese Anwendung dient ausschließlich medizinischen Fachkräften zur Patientenbetreuung.
          </p>
        </div>
      </div>
    </footer>
  );
}
