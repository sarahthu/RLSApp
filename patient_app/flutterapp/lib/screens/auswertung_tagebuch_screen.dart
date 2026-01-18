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


//KPI-Berechnung: Durchschnitt der letzten 7 Kalendertage
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
//Fasst mehrere Einträge eines Tages zu einem Tagesdurchschnitt zusammen
List<DiagrammPunkt> aggregateDailyAverage(List<DiagrammPunkt> points) {
  final Map<DateTime, List<DiagrammPunkt>> grouped = {};
  // Einträge nach Kalendertag gruppieren 
  for (final p in points) {
    final day = DateTime(p.datetime.year, p.datetime.month, p.datetime.day);
    grouped.putIfAbsent(day, () => []).add(p);
  }
  // Für jeden Tag einen Durchschnittspunkt erzeugen
  final dailyPoints = grouped.entries.map((entry) {
    final day = entry.key;
    final list = entry.value;

    final avg =
        list.fold<double>(0, (sum, p) => sum + p.score) / list.length;

    return DiagrammPunkt(
      datetime: day,
      score: avg,
      interpretation: 'Ø Tageswert (${list.length} Einträge)',
      maxScore: list.first.maxScore,
    );
  }).toList();
//sortieren
  dailyPoints.sort((a, b) => a.datetime.compareTo(b.datetime));
  return dailyPoints;
}
//SCREEN: Tabs + KPI-Zeile oben

class AuswertungTagebuchScreen extends StatelessWidget {
  const AuswertungTagebuchScreen({super.key});

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
                    Tab(text: 'Schlaf'),
                    Tab(text: 'Ernährung'),
                    Tab(text: 'Wohlbefinden'),
                    Tab(text: 'Sport'),
                  ],
                ),
              ),

              // KPI-Übersicht oben (zeigt Wochendurchschnitt)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: SizedBox(
                    height: 220, 
                    child: KpiRow(),
                  ),
                ),
              ),
            ];
          },

          // Inhalte der Tabs: pro Kategorie wird lade_diagrammdaten(id) aufgerufen
          body: const TabBarView(
            children: [
              EvaluationTab(title: 'Schlaf', fragebogenId: 'tschlaf'),
              EvaluationTab(title: 'Ernährung', fragebogenId: 'ternaehrung'),
              EvaluationTab(title: 'Wohlbefinden', fragebogenId: 'twohlbefinden'),
              EvaluationTab(title: 'Sport', fragebogenId: 'tsport'),
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
    final sleep = await lade_diagrammdaten('tschlaf');
    final nutrition = await lade_diagrammdaten('ternaehrung'); 
    final wellbeing = await lade_diagrammdaten('twohlbefinden');
    final sport = await lade_diagrammdaten('tsport');

    // Durchschnitt der letzten 7 Tage berechnen
    final sleepAvg = avgLast7Days(sleep);
    final nutritionAvg = avgLast7Days(nutrition);
    final wellbeingAvg = avgLast7Days(wellbeing);
    final sportAvg = avgLast7Days(sport);

    // MaxScore (für Anzeige "x / max")
    final sleepMax = sleep.isNotEmpty ? sleep.first.maxScore : 5.0;
    final nutritionMax = nutrition.isNotEmpty ? nutrition.first.maxScore : 5.0;
    final wellbeingMax = wellbeing.isNotEmpty ? wellbeing.first.maxScore : 5.0;
    final sportMax = sport.isNotEmpty ? sport.first.maxScore : 5.0;

    return {
      'sleep': '${sleepAvg.toStringAsFixed(1)} / ${sleepMax.toStringAsFixed(0)}',
      'nutrition': '${nutritionAvg.toStringAsFixed(1)} / ${nutritionMax.toStringAsFixed(0)}',
      'wellbeing': '${wellbeingAvg.toStringAsFixed(1)} / ${wellbeingMax.toStringAsFixed(0)}',
      'sport': '${sportAvg.toStringAsFixed(1)} / ${sportMax.toStringAsFixed(0)}',
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
        final sleepText = data['sleep'] ?? '—';
        final nutritionText = data['nutrition'] ?? '—';
        final wellbeingText = data['wellbeing'] ?? '—';
        final sportText = data['sport'] ?? '—';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.count(
            crossAxisCount: 4, 
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            childAspectRatio: 1.8,
            children: [
              KpiCard(title: 'Schlaf', value: sleepText, icon: Icons.bed),
              KpiCard(title: 'Ernährung', value: nutritionText, icon: Icons.restaurant),
              KpiCard(title: 'Wohlbefinden', value: wellbeingText, icon: Icons.mood),
              KpiCard(title: 'Aktivität', value: sportText, icon: Icons.directions_run),
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

        final dailyPoints = aggregateDailyAverage(points);
        // Startdatum fürs Diagramm (erstes Tagesdatum)
        final start = DateTime(
          dailyPoints.first.datetime.year,
          dailyPoints.first.datetime.month,
          dailyPoints.first.datetime.day,
        );
        // Spots: X = Tage seit Start, Y = Tagesdurchschnitt
        final spots = dailyPoints.map((p) {
          final d = DateTime(p.datetime.year, p.datetime.month, p.datetime.day);
          final x = d.difference(start).inDays.toDouble();
          return FlSpot(x, p.score);
          }).toList();

        // Für Achse: minX/maxX setzen
          final minX = spots.first.x;
          final maxX = spots.last.x;

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
                  minX: minX,          
                  maxX: maxX,
                  minY: 0,
                  maxY: maxScore,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 32,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1, // 1 Tag Abstand
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final startDate = DateTime(
                            dailyPoints.first.datetime.year,
                            dailyPoints.first.datetime.month,
                            dailyPoints.first.datetime.day,
                          );

                          final date = startDate.add(Duration(days: value.toInt()));
                          final label =
                              '${date.day.toString().padLeft(2, '0')}.'
                              '${date.month.toString().padLeft(2, '0')}';

                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
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
