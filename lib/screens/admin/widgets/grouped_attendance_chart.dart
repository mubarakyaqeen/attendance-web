import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GroupedAttendanceChart extends StatelessWidget {
  final List sessions;

  const GroupedAttendanceChart({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          barGroups: _buildGroups(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  return Text("S${index + 1}");
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildGroups() {

    return List.generate(sessions.length, (index) {

      final session = sessions[index];

      final present = (session["present"] ?? 0).toDouble();
      final late = (session["late"] ?? 0).toDouble();
      final absent = (session["absent"] ?? 0).toDouble();

      return BarChartGroupData(
        x: index,
        barRods: [

          /// PRESENT (GREEN)
          BarChartRodData(
            toY: present,
            color: Colors.green,
            width: 8,
          ),

          /// LATE (ORANGE)
          BarChartRodData(
            toY: late,
            color: Colors.orange,
            width: 8,
          ),

          /// ABSENT (RED)
          BarChartRodData(
            toY: absent,
            color: Colors.red,
            width: 8,
          ),

        ],
      );
    });
  }
}