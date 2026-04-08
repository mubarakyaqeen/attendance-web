import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AttendancePieChart extends StatelessWidget {
  final int present;
  final int late;
  final int absent;

  const AttendancePieChart({
    super.key,
    required this.present,
    required this.late,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {

    final total = present + late + absent;

    return SizedBox(
      height: 220,
      child: PieChart(

        PieChartData(

          sections: [

            PieChartSectionData(
              value: present.toDouble(),
              color: Colors.green,
              title: "${_percent(present, total)}%",
            ),

            PieChartSectionData(
              value: late.toDouble(),
              color: Colors.orange,
              title: "${_percent(late, total)}%",
            ),

            PieChartSectionData(
              value: absent.toDouble(),
              color: Colors.red,
              title: "${_percent(absent, total)}%",
            ),

          ],
        ),
      ),
    );
  }

  String _percent(int value, int total) {
    if (total == 0) return "0";
    return ((value / total) * 100).toStringAsFixed(0);
  }
}