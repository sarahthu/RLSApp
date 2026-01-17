import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutterapp/dio_setup.dart';


/// DATENMODELL
class DiagrammPunkt {
  final DateTime datetime;        // Zeitpunkt der Antwort
  final double score;             // berechneter Score (y-Wert im Diagramm)
  final String interpretation;    // Text für die Liste (optional)
  final double maxScore;          // Maximaler Score (für Diagramm-Skalierung + Anzeige)

  DiagrammPunkt({
    required this.datetime,
    required this.score,
    required this.interpretation,
    required this.maxScore,
  });

  /// Wandelt JSON vom Backend in ein DiagrammPunkt-Objekt um
  factory DiagrammPunkt.fromJson(Map<String, dynamic> json) {
    return DiagrammPunkt(
      datetime: DateTime.parse(json['date'] as String),            
      score: double.parse(json['score'].toString()),                   
      interpretation: (json['interpretation'] ?? '').toString(),       
      maxScore: double.parse(json['maxscore'].toString()),            
    );
  }
}

// Holt Diagrammdaten von Django
Future<List<DiagrammPunkt>> lade_diagrammdaten(String fragebogenId) async {
  List diagramm_items = [];  
  final response = await dio.get("/rls/diagramm/$fragebogenId");
    if (response.statusCode == 200) {
      diagramm_items = response.data;
    } else {
      print('Fehler beim Laden der Diagrammdaten');
  }
  print("HALLO");
  print(diagramm_items);
  final points = diagramm_items.map((e) => DiagrammPunkt.fromJson(e as Map<String,dynamic>)).toList();
  return points;
}


//KPI-BERECHNUNG: Durchschnitt der letzten 7 Kalendertage
double avgLast7Days(List<DiagrammPunkt> points) {
  if (points.isEmpty) return 0;

  final now = DateTime.now();

  // Start: heute minus 6 Tage (inkl. heute = 7 Tage insgesamt)
  final startOfWeek = DateTime(now.year, now.month, now.day)
      .subtract(const Duration(days: 6));

  // Filter: nur Einträge innerhalb der letzten 7 Tage
  final weekPoints = points
      .where((p) => !p.datetime.isBefore(startOfWeek) && !p.datetime.isAfter(now))
      .toList();

  if (weekPoints.isEmpty) return 0;

  final sum = weekPoints.fold<double>(0, (acc, p) => acc + p.score);
  return sum / weekPoints.length;
}

//SCREEN: Tabs + KPI-Zeile oben

class AuswertungFragebogenScreen extends StatelessWidget {
  const AuswertungFragebogenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Obere Leiste + Tabs
              SliverAppBar(
                title: const Text('Ihre Daten im Überblick'),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'IRLS'),
                    Tab(text: 'RLSQoL'),
                  ],
                ),
              ),

              // KPI-Übersicht oben (zeigt Wochendurchschnitt)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: KpiRow(),
                ),
              ),
            ];
          },

          // Inhalte der Tabs: pro Kategorie wird lade_diagrammdaten(id) aufgerufen
          body: const TabBarView(
            children: [
              EvaluationTab(title: 'IRLS', fragebogenId: 'f1'),
              EvaluationTab(title: 'RLSQoL', fragebogenId: 'f2'),
            ],
          ),
        ),
      ),
    );
  }
}

//KPI-ROW: lädt Daten und zeigt Durchschnitt
class KpiRow extends StatelessWidget {
  const KpiRow({super.key});

  /// Lädt die Daten und berechnet KPI-Strings
  Future<Map<String, String>> _loadKpis() async {
    // Daten aus Backend holen (über lade_diagrammdaten)
    final irls = await lade_diagrammdaten('f1');
    final rlsqol = await lade_diagrammdaten('f2');

    // Durchschnitt der letzten 7 Tage berechnen
    final irlsAvg = avgLast7Days(irls);
    final rlsqolAvg = avgLast7Days(rlsqol);

    // MaxScore (für Anzeige "x / max")
    final irlsMax = irls.isNotEmpty ? irls.first.maxScore : 5.0;
    final rlsqolMax = rlsqol.isNotEmpty ? rlsqol.first.maxScore : 5.0;

    return {
      'irls': '${irlsAvg.toStringAsFixed(1)} / ${irlsMax.toStringAsFixed(0)}',
      'rlsqol': '${rlsqolAvg.toStringAsFixed(1)} / ${rlsqolMax.toStringAsFixed(0)}',
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _loadKpis(),
      builder: (context, snapshot) {
        // Laden
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // Fehler
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('KPI Fehler: ${snapshot.error}'),
          );
        }

        // Werte anzeigen
        final data = snapshot.data ?? {};
        final irlsText = data['irls'] ?? '—';
        final rlsqolText = data['rlsqol'] ?? '—';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.3,
            children: [
              KpiCard(title: 'IRLS', value: irlsText, icon: Icons.edit_note),
              KpiCard(title: 'RLSQoL', value: rlsqolText, icon: Icons.edit_note),
            ],
          ),
        );
      },
    );
  }
}

/// Kleine Karte für KPI-Anzeige
class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

//TAB: lädt Daten für bestimmte Kategorie und zeigt Liniendiagramm und Liste (Datum + Interpretation + Score)
class EvaluationTab extends StatelessWidget {
  final String title;
  final String fragebogenId;

  const EvaluationTab({
    super.key,
    required this.title,
    required this.fragebogenId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DiagrammPunkt>>(
      future: lade_diagrammdaten(fragebogenId),
      builder: (context, snapshot) {
        // Laden
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        // Fehler
        if (snapshot.hasError) {
          return Center(child: Text('Fehler: ${snapshot.error}'));
        }

        // Keine Daten
        final points = snapshot.data ?? [];
        if (points.isEmpty) {
          return const Center(child: Text('Keine Daten vorhanden.'));
        }

        // Y-Achse im Diagramm: 0..maxScore
        final maxScore = points.first.maxScore;

        // Sortierung nach Datum
        points.sort((a, b) => a.datetime.compareTo(b.datetime));

        // Datenpunkte fürs Diagramm:
        // x = Index (0,1,2,...), y = Score
        final spots = List.generate(
          points.length,
          (i) => FlSpot(i.toDouble(), points[i].score),
        );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Diagramm
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxScore,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      spots: spots,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text('Antwortverlauf',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // Liste unter dem Diagramm
            ...points.map((p) {
              final d = p.datetime;
              final dateText =
                  '${d.day.toString().padLeft(2, '0')}.'
                  '${d.month.toString().padLeft(2, '0')}.'
                  '${d.year}';

              return ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(dateText),
                subtitle: Text(p.interpretation),
                trailing: Text('${p.score} / ${p.maxScore}'),
              );
            }),
          ],
        );
      },
    );
  }

}
