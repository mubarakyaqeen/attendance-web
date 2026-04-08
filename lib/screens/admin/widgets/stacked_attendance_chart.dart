import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StackedAttendanceChart extends StatefulWidget {
  final List sessions;

  const StackedAttendanceChart({super.key, required this.sessions});

  @override
  State<StackedAttendanceChart> createState() =>
      _StackedAttendanceChartState();
}

class _StackedAttendanceChartState extends State<StackedAttendanceChart> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });
  }

  @override
  void didUpdateWidget(covariant StackedAttendanceChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.sessions.length != oldWidget.sessions.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToEnd();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionCount = widget.sessions.length;

    final double chartWidth = sessionCount < 6
        ? MediaQuery.of(context).size.width
        : sessionCount * 60;

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: chartWidth,
        height: 280, // 🔥 increased for rotated labels
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.start,

            /// ✅ BAR DATA (FIXED DOUBLE ISSUE)
            barGroups: List.generate(sessionCount, (index) {
              final session = widget.sessions[index];

              final present =
              (session["present"] ?? 0).toDouble();
              final late =
              (session["late"] ?? 0).toDouble();
              final absent =
              (session["absent"] ?? 0).toDouble();

              final total = present + late + absent;

              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: total.toDouble(), // ✅ FIXED
                    rodStackItems: [
                      BarChartRodStackItem(0, present, Colors.green),
                      BarChartRodStackItem(
                          present, present + late, Colors.orange),
                      BarChartRodStackItem(
                          present + late,
                          total,
                          Colors.red),
                    ],
                    width: 14,
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              );
            }),

            /// ✅ AXIS LABELS (ROTATED CLEANLY)
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 60, // 🔥 more space for rotation

                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();

                    if (index >= sessionCount) {
                      return const SizedBox();
                    }

                    final session = widget.sessions[index];

                    final label =
                        session["courseCode"] ??
                            session["course"] ??
                            "S${index + 1}";

                    return Transform.rotate(
                      angle: -0.7, // 🔥 clean angle
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          label.toString(),
                          style: const TextStyle(fontSize: 10),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  },
                ),
              ),

              leftTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: true),
              ),
            ),

            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: false),
          ),
        ),
      ),
    );
  }
}