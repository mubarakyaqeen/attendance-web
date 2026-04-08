import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AttendanceLineChart extends StatelessWidget {
  final List trend;

  const AttendanceLineChart({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      height: 220,

      child: LineChart(
        LineChartData(

          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),

          lineTouchData: LineTouchData(enabled: true),

          lineBarsData: [
            LineChartBarData(
              spots: List.generate(trend.length, (index) {

                final item = trend[index];
                final value = (item["present"] ?? 0).toDouble();

                return FlSpot(index.toDouble(), value);
              }),

              isCurved: true,
              barWidth: 3,
              color: Colors.green,
              dotData: FlDotData(show: true),
            ),
          ],

          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,

                getTitlesWidget: (value, meta) {

                  final index = value.toInt();

                  if (index >= trend.length) {
                    return const SizedBox();
                  }

                  final date = trend[index]["date"];

                  return Text(
                    date.toString().substring(5),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
        ),
      )
    );
  }
}