import 'package:flutter/material.dart';

/// App theme color constant.
const kThemeColor = Color(0xFF1E88E5);

/// A single item in a timeline, showing step number, title, and subtitle.
class TimelineItem extends StatelessWidget {
  final int step;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isCurrent;
  final bool isRejected;

  const TimelineItem({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isCurrent,
    this.isRejected = false,
  });

  @override
  Widget build(BuildContext context) {
    Color circleColor;
    Widget circleChild;

    if (isRejected) {
      circleColor = Colors.red;
      circleChild = const Icon(Icons.close, color: Colors.white, size: 18);
    } else if (isCompleted && !isCurrent) {
      circleColor = Colors.green;
      circleChild = const Icon(Icons.check, color: Colors.white, size: 18);
    } else if (isCurrent) {
      circleColor = kThemeColor;
      circleChild = Text(
        '$step',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      circleColor = Colors.grey[300]!;
      circleChild = Text(
        '$step',
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
          ),
          child: Center(child: circleChild),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isCurrent
                      ? (isRejected ? Colors.red : kThemeColor)
                      : (isCompleted ? Colors.grey[700] : Colors.grey),
                ),
              ),
              if (isCurrent)
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A vertical connector line between timeline items.
class TimelineConnector extends StatelessWidget {
  final bool isCompleted;
  final double height;

  const TimelineConnector({
    super.key,
    required this.isCompleted,
    this.height = 35,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 13),
      child: Container(
        width: 3,
        height: height,
        color: isCompleted ? kThemeColor : Colors.grey[300],
      ),
    );
  }
}
