import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/stats_service.dart';
import '../../utils/user_helpers.dart';

class AnalyticsPage extends StatefulWidget {
  final StatsService? service;
  const AnalyticsPage({super.key, this.service});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late final StatsService _service;
  Map<String, int> _stats = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (!currentUserIsAdmin()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Admin access required')));
      });
    } else {
      _service = widget.service ?? StatsService();
      _load();
    }
  }

  Future<void> _load() async {
    final data = await _service.fetchStats();
    setState(() {
      _stats = data.map((k, v) => MapEntry(k, v as int));
      _loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final entries = _stats.entries.toList();
    final groups = List.generate(entries.length, (i) {
      return BarChartGroupData(
        x: i,
        barRods: [BarChartRodData(toY: entries[i].value.toDouble(), width: 16)],
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            barGroups: groups,
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final label = entries[value.toInt()].key;
                    return SideTitleWidget(
                      meta: meta,
                      space: 4,
                      child: Text(label, style: const TextStyle(fontSize: 10)),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}
