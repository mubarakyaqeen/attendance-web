import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AdminAttendancePieChart extends StatelessWidget {
  final int present;
  final int late;
  final int absent;

  const AdminAttendancePieChart({
    super.key,
    required this.present,
    required this.late,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    final total = present + late + absent;

    if (total == 0) {
      return const Center(child: Text("No Data"));
    }

    return Column(
      children: [

        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,

              sections: [

                /// 🟢 PRESENT
                PieChartSectionData(
                  value: present.toDouble(),
                  color: Colors.green,
                  title:
                  "${((present / total) * 100).toStringAsFixed(1)}%",
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// 🟠 LATE
                PieChartSectionData(
                  value: late.toDouble(),
                  color: Colors.orange,
                  title:
                  "${((late / total) * 100).toStringAsFixed(1)}%",
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                /// 🔴 ABSENT
                PieChartSectionData(
                  value: absent.toDouble(),
                  color: Colors.red,
                  title:
                  "${((absent / total) * 100).toStringAsFixed(1)}%",
                  radius: 50,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 15),

        /// 🔥 LEGEND
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [

            Icon(Icons.circle, color: Colors.green, size: 12),
            SizedBox(width: 5),
            Text("Present"),

            SizedBox(width: 15),

            Icon(Icons.circle, color: Colors.orange, size: 12),
            SizedBox(width: 5),
            Text("Late"),

            SizedBox(width: 15),

            Icon(Icons.circle, color: Colors.red, size: 12),
            SizedBox(width: 5),
            Text("Absent"),
          ],
        ),
      ],
    );
  }
}