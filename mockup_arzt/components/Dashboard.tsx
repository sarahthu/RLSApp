import { useState, useMemo } from 'react';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Card, CardContent, CardHeader, CardTitle } from './ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from './ui/table';
import { Badge } from './ui/badge';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from './ui/select';
import { Activity, LogOut, Search, AlertTriangle, TrendingUp, Users } from 'lucide-react';
import { mockPatients } from '../lib/mockData';
import type { Patient } from '../App';

interface DashboardProps {
  onSelectPatient: (patientId: string) => void;
  doctorName: string;
}

type SortOption = 'risk' | 'name' | 'lastContact' | 'score';

export function Dashboard({ onSelectPatient, doctorName }: DashboardProps) {
  const [searchTerm, setSearchTerm] = useState('');
  const [sortBy, setSortBy] = useState<SortOption>('risk');

  const filteredAndSortedPatients = useMemo(() => {
    let filtered = mockPatients.filter(patient =>
      patient.name.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const riskOrder = { high: 0, medium: 1, low: 2 };

    filtered.sort((a, b) => {
      switch (sortBy) {
        case 'risk':
          return riskOrder[a.riskLevel] - riskOrder[b.riskLevel];
        case 'name':
          return a.name.localeCompare(b.name);
        case 'lastContact':
          return new Date(b.lastContact).getTime() - new Date(a.lastContact).getTime();
        case 'score':
          return b.rlsScore - a.rlsScore;
        default:
          return 0;
      }
    });

    return filtered;
  }, [searchTerm, sortBy]);

  const getRiskBadge = (patient: Patient) => {
    if (patient.riskLevel === 'high') {
      return (
        <Badge variant="destructive" className="gap-1">
          <AlertTriangle className="w-3 h-3" />
          Hohe Priorität
        </Badge>
      );
    } else if (patient.riskLevel === 'medium') {
      return <Badge className="bg-orange-500">Mittlere Priorität</Badge>;
    }
    return <Badge variant="secondary">Niedrige Priorität</Badge>;
  };

  const getSeverity = (score: number) => {
    if (score >= 31) return 'Sehr schwer';
    if (score >= 21) return 'Schwer';
    if (score >= 11) return 'Mittelschwer';
    return 'Leicht';
  };

  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString('de-DE', { day: '2-digit', month: '2-digit', year: 'numeric' });
  };

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

  const highRiskCount = mockPatients.filter(p => p.riskLevel === 'high').length;
  const newDataCount = mockPatients.filter(p => p.hasNewData).length;

  return (
    <div className="bg-gray-50">
      {/* Hero Section */}
      <div className="bg-gradient-to-r from-indigo-600 to-indigo-800 text-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <h1 className="text-3xl mb-2">Willkommen, {doctorName}</h1>
          <p className="text-indigo-100">
            Ihre Patientenübersicht und aktuelles Monitoring
          </p>
        </div>
      </div>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm">Gesamt Patienten</CardTitle>
              <Users className="w-4 h-4 text-gray-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl">{mockPatients.length}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm">Hohe Priorität</CardTitle>
              <AlertTriangle className="w-4 h-4 text-red-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl">{highRiskCount}</div>
            </CardContent>
          </Card>
          <Card>
            <CardHeader className="flex flex-row items-center justify-between pb-2">
              <CardTitle className="text-sm">Neue Daten</CardTitle>
              <TrendingUp className="w-4 h-4 text-blue-500" />
            </CardHeader>
            <CardContent>
              <div className="text-2xl">{newDataCount}</div>
            </CardContent>
          </Card>
        </div>

        {/* Search and Filter */}
        <Card className="mb-6">
          <CardContent className="pt-6">
            <div className="flex flex-col sm:flex-row gap-4">
              <div className="relative flex-1">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
                <Input
                  placeholder="Patient suchen..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="pl-10"
                />
              </div>
              <Select value={sortBy} onValueChange={(value) => setSortBy(value as SortOption)}>
                <SelectTrigger className="w-full sm:w-[200px]">
                  <SelectValue placeholder="Sortieren nach" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="risk">Nach Priorität</SelectItem>
                  <SelectItem value="score">Nach RLS-Score</SelectItem>
                  <SelectItem value="lastContact">Nach letztem Kontakt</SelectItem>
                  <SelectItem value="name">Nach Name</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </CardContent>
        </Card>

        {/* Patients Table */}
        <Card>
          <CardHeader>
            <CardTitle>Patienten ({filteredAndSortedPatients.length})</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Priorität</TableHead>
                    <TableHead>Name</TableHead>
                    <TableHead>Alter</TableHead>
                    <TableHead>RLS-Score</TableHead>
                    <TableHead>Schweregrad</TableHead>
                    <TableHead>Letzter Kontakt</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Aktion</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredAndSortedPatients.map((patient) => (
                    <TableRow
                      key={patient.id}
                      className={`cursor-pointer hover:bg-gray-50 ${
                        patient.riskLevel === 'high' ? 'bg-red-50/50' : ''
                      }`}
                      onClick={() => onSelectPatient(patient.id)}
                    >
                      <TableCell>{getRiskBadge(patient)}</TableCell>
                      <TableCell>{patient.name}</TableCell>
                      <TableCell>{calculateAge(patient.dateOfBirth)} Jahre</TableCell>
                      <TableCell>
                        <span className={
                          patient.rlsScore >= 21 ? 'text-red-600' :
                          patient.rlsScore >= 11 ? 'text-orange-600' :
                          'text-green-600'
                        }>
                          {patient.rlsScore}/40
                        </span>
                      </TableCell>
                      <TableCell>{getSeverity(patient.rlsScore)}</TableCell>
                      <TableCell>{formatDate(patient.lastContact)}</TableCell>
                      <TableCell>
                        {patient.hasNewData && (
                          <Badge variant="outline" className="bg-blue-50">
                            Neue Daten
                          </Badge>
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          variant="ghost"
                          size="sm"
                          onClick={(e) => {
                            e.stopPropagation();
                            onSelectPatient(patient.id);
                          }}
                        >
                          Details
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      </main>
    </div>
  );
}