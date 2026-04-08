import 'package:flutter/material.dart';

class AttendanceHistogram extends StatelessWidget {
  final int present;
  final int late;
  final int absent;

  const AttendanceHistogram({
    super.key,
    required this.present,
    required this.late,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {

    final maxValue = [present, late, absent]
        .reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                _bar("Present", present, maxValue, Colors.green),
                _bar("Late", late, maxValue, Colors.orange),
                _bar("Absent", absent, maxValue, Colors.red),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, int value, int max, Color color) {

    final heightFactor = max == 0 ? 0.0 : value / max;

    return SizedBox(
      width: 50, // give more space

      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          /// VALUE TEXT (small to avoid overflow)
          FittedBox(
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ),

          const SizedBox(height: 4),

          /// FLEXIBLE BAR
          Flexible(
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              alignment: Alignment.bottomCenter,
              child: Container(
                width: 25,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// LABEL (prevent overflow)
          FittedBox(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}