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

// -------------------- Holt Diagrammdaten von Django --------------------------------------------------------------
Future<List<DiagrammPunkt>> lade_diagrammdaten(String fragebogenId) async {
  List diagramm_items = [];  //leere Liste diagrammitems
  final response = await dio.get("/rls/diagramm/$fragebogenId"); //get request an Django
    if (response.statusCode == 200) {  //Wenn Request erfolgreich....
      diagramm_items = response.data;  //speichert Daten von Django in Liste
    } else {
      print('Fehler beim Laden der Diagrammdaten');
  }
  // Nutzt Diagrammpunkt factory um aus den Daten in der Liste Diagrammpunkte zu machen
  final points = diagramm_items.map((e) => DiagrammPunkt.fromJson(e as Map<String,dynamic>)).toList();
  // gibt die Diagrammpunkte zurück
  return points;
}


//gibt den Score des aktuellsten ausgefüllten Fragebogens zurück
double neuesterScore(List<DiagrammPunkt> points) {
  if (points.isEmpty) return 0;
  return points.first.score;
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
                title: const Text('Fragebogendaten im Überblick'),
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
              EvaluationTab(title: 'International RLS Scale', fragebogenId: 'f1'),
              EvaluationTab(title: 'RLS Quality of Life', fragebogenId: 'f2'),
            ],
          ),
        ),
      ),
    );
  }
}

//KPI-ROW: lädt Daten und zeigt neuesten Score für jeden Fragebogen
class KpiRow extends StatelessWidget {
  const KpiRow({super.key});

  /// Lädt die Daten und berechnet KPI-Strings
  Future<Map<String, String>> _loadKpis() async {
    // Daten aus Backend holen (über lade_diagrammdaten)
    final irlsdaten = await lade_diagrammdaten('f1');
    final rlsqoldaten = await lade_diagrammdaten('f2'); 

    // Neuesten Score für jeden Fragebogen holen
    final irlsdatenNeuester = neuesterScore(irlsdaten);
    final rlsqoldatenNeuester = neuesterScore(rlsqoldaten);

    // MaxScore (für Anzeige "x / max")
    final irlsdatenMax = irlsdaten.isNotEmpty ? irlsdaten.first.maxScore : 5.0;
    final rlsqoldatenMax = rlsqoldaten.isNotEmpty ? rlsqoldaten.first.maxScore : 5.0;

    return {
      'irlsdaten': '${irlsdatenNeuester.toStringAsFixed(1)} / ${irlsdatenMax.toStringAsFixed(0)}',
      'rlsqoldaten': '${rlsqoldatenNeuester.toStringAsFixed(1)} / ${rlsqoldatenMax.toStringAsFixed(0)}',
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
        final irlsdatenText = data['irlsdaten'] ?? '—';
        final rlsqoldatenText = data['rlsqoldaten'] ?? '—';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Container(
                child: GridView.count(
                  shrinkWrap: true, //Reihe mit den Karten darf nur so hoch werden wie ihr Inhalt
                  crossAxisCount: 2, 
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  children: [
                    KpiCard(title: 'IRLS', value: irlsdatenText),
                    KpiCard(title: 'RLSQoL', value: rlsqoldatenText),
                  ],
                ),
              ),
              Text("(Score des letzten ausgefüllten Fragebogens)",)
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

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
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
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

            // --------------------- Diagramm Erstellung ----------------------------------------------------
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
                        interval: 10,  //zeigt auf y-Achse für Fragebögen nur jeden 10ten Score Wert (damit y-Achse nicht so voll wird)
                        reservedSize: 35,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 2, // zeigt nur von jedem 2ten Tag das Datum auf der x-Achse
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
                  lineTouchData: LineTouchData(    // Einstellungen wenn der Nutzer einen Punkt auf dem Diagramm anklickt....
                    touchTooltipData: LineTouchTooltipData(
                      maxContentWidth: 100,
                      tooltipBgColor: Theme.of(context).colorScheme.inversePrimary,   //Zeigt ein Feld mit hellgrünem Hintergrund
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          return LineTooltipItem(
                            'Score: ${touchedSpot.y.toStringAsFixed(2)}',    // Test des Felds ist "Score: [Scorewert]"
                            TextStyle(fontSize: 14,),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                    getTouchLineStart: (data, index) => 0,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      gradient: LinearGradient(  //Farbe der Linie (Farbverlauf)
                        colors: [
                          Theme.of(context).colorScheme.inversePrimary,
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary,
                        ],
                      ),
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

            // Liste unter dem Diagramm:
            ...points.reversed.map((p) {   // geht Diagrammpunkte so herum durch dass der neueste Eintrag in der Liste oben steht
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
