import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../services/stats_service.dart';
import '../../utils/user_helpers.dart';

class MonthlyStatsPage extends StatefulWidget {
  final StatsService? service;
  const MonthlyStatsPage({super.key, this.service});

  @override
  State<MonthlyStatsPage> createState() => _MonthlyStatsPageState();
}

class _MonthlyStatsPageState extends State<MonthlyStatsPage> {
  late final StatsService _service;
  Map<String, List<int>> _stats = {};
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
    final data = await _service.fetchMonthlyStats();
    setState(() {
      _stats = data;
      _loaded = true;
    });
  }

  List<String> _monthLabels() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final dt = DateTime(now.year, now.month - 11 + i);
      return '${dt.month}/${dt.year % 100}';
    });
  }

  Widget _buildChart(String label, List<int> values, List<String> months) {
    final spots = List.generate(values.length,
        (i) => FlSpot(i.toDouble(), values[i].toDouble()));
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(spots: spots, isCurved: false),
                ],
                minY: 0,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < months.length) {
                          return SideTitleWidget(
                            meta: meta,
                            space: 4,
                            child: Text(
                              months[idx],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!currentUserIsAdmin()) return const SizedBox.shrink();
    final months = _monthLabels();
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Monthly Stats')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Stats')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: _stats.entries
              .map((e) => _buildChart(e.key, e.value, months))
              .toList(),
        ),
      ),
    );
  }
}

