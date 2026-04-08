import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AttendanceChart extends StatelessWidget {

  final List trendData;

  const AttendanceChart({
    super.key,
    required this.trendData,
  });

  @override
  Widget build(BuildContext context) {

    List<FlSpot> spots = [];

    for (int i = 0; i < trendData.length; i++) {

      final value = trendData[i]["present"];

      spots.add(
        FlSpot(
          i.toDouble(),
          (value ?? 0).toDouble(),
        ),
      );
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),

      child: LineChart(
        LineChartData(

          gridData: FlGridData(show: true),

          titlesData: FlTitlesData(

            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(

                showTitles: true,

                getTitlesWidget: (value, meta) {

                  int index = value.toInt();

                  if (index >= trendData.length) {
                    return const Text("");
                  }

                  String date = trendData[index]["date"];

                  return Text(
                    date.substring(5),
                    style: const TextStyle(fontSize: 10),
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
              color: const Color(0xFF034D08),

              spots: spots,

              dotData: FlDotData(show: true),
            )

          ],
        ),
      ),
    );
  }
}