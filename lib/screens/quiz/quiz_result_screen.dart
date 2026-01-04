import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizResultScreen extends StatefulWidget {
  final String tipSlug;
  final String tipTitle;
  final int score;
  final int totalQuestions;
  final int maxPossibleScore;

  const QuizResultScreen({
    super.key,
    required this.tipSlug,
    required this.tipTitle,
    required this.score,
    required this.totalQuestions,
    required this.maxPossibleScore,
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    setState(() {
      isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(kTokenStorageKey);

      // Calculate percentage
      final percentage = widget.maxPossibleScore > 0
          ? ((widget.score / widget.maxPossibleScore) * 100).round()
          : 0;

      if (token != null) {
        await http.post(
          Uri.parse('$kBaseUrl/quiz/result'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'category': widget.tipSlug,
            'score': widget.score,
            'totalQuestions': widget.totalQuestions,
            'percentage': percentage,
          }),
        );
      }
    } catch (e) {
      print('Error saving quiz result: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String _getBadge(int percentage) {
    if (percentage >= 90) return 'Safety Expert';
    if (percentage >= 70) return 'Well Prepared';
    if (percentage >= 50) return 'Getting There';
    return 'Needs Review';
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getFeedback(int percentage) {
    if (percentage >= 90)
      return 'Excellent work! You are well prepared for this emergency.';
    if (percentage >= 70)
      return 'Good job! Review a few more tips to be fully ready.';
    if (percentage >= 50)
      return 'Not bad, but you should review the safety tips again.';
    return 'Please read the safety tips carefully to ensure your safety.';
  }

  @override
  Widget build(BuildContext context) {
    final percentage = widget.maxPossibleScore > 0
        ? ((widget.score / widget.maxPossibleScore) * 100).round()
        : 0;

    final badge = _getBadge(percentage);
    final color = _getScoreColor(percentage);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Quiz Results'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            // Score Circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 10,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'Score',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Text(
              badge,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _getFeedback(percentage),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            SizedBox(height: 32),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Correct',
                  '${widget.score}/${widget.maxPossibleScore}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatItem(
                  'Questions',
                  '${widget.totalQuestions}',
                  Icons.list_alt,
                  Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 48),
            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to Intro
                  Navigator.pop(context); // Go back to Details
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back to Guide',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Go back to Intro
                // Intro will start new quiz
              },
              child: Text('Retake Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
