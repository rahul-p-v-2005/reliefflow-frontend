import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:reliefflow_frontend_public_app/env.dart';
import 'package:reliefflow_frontend_public_app/models/disaster_tip.dart';
import 'package:reliefflow_frontend_public_app/screens/quiz/quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String tipSlug;
  final String tipTitle;

  const QuizScreen({
    super.key,
    required this.tipSlug,
    required this.tipTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> questions = [];
  bool isLoading = true;
  int currentQuestionIndex = 0;
  int totalScore = 0;
  int maxPossibleScore = 0;
  bool hasAnswered = false;
  QuizOption? selectedOption;
  bool isCorrect = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      // The backend endpoint might be /quiz/:category
      final response = await http.get(
        Uri.parse('$kBaseUrl/quiz/${widget.tipSlug}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> questionsData = data['data'] ?? [];

        setState(() {
          questions = questionsData
              .map((e) => QuizQuestion.fromJson(e))
              .toList();

          // Calculate max possible score
          for (var q in questions) {
            // Assuming max points is 10 per question or max of options
            int maxQ = 0;
            for (var opt in q.options) {
              if (opt.points > maxQ) maxQ = opt.points;
            }
            maxPossibleScore += maxQ;
          }

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching quiz questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handleOptionSelect(QuizOption option) {
    if (hasAnswered) return;

    setState(() {
      selectedOption = option;
      hasAnswered = true;
      totalScore += option.points;

      // Determine if it was the "best" answer (max points)
      // We'll consider it "correct" if it has > 0 points, but strictly correct if it's the max points option.
      // For visual feedback, let's say:
      // Green if points == max points for this question
      // Orange if points > 0 but < max points
      // Red if points == 0

      int maxPointsForQ = 0;
      for (var opt in questions[currentQuestionIndex].options) {
        if (opt.points > maxPointsForQ) maxPointsForQ = opt.points;
      }

      isCorrect = option.points == maxPointsForQ;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        hasAnswered = false;
        selectedOption = null;
      });
    } else {
      // Finish Quiz
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            tipSlug: widget.tipSlug,
            tipTitle: widget.tipTitle,
            score: totalScore,
            totalQuestions: questions.length,
            maxPossibleScore: maxPossibleScore,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.tipTitle} Quiz')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assignment_late_outlined,
                size: 60,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text('No questions available for this topic yet.'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentQuestionIndex];
    double progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${widget.tipTitle} Quiz'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(6.0),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            minHeight: 6,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Counter
                  Text(
                    'Question ${currentQuestionIndex + 1} of ${questions.length}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Question Text
                  Text(
                    question.question,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 24),
                  // Options
                  ...question.options.map((option) => _buildOptionCard(option)),
                ],
              ),
            ),
          ),
          // Explanation Panel (Visible after answering)
          if (hasAnswered)
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCorrect ? Icons.check_circle : Icons.info,
                        color: isCorrect ? Colors.green : Colors.orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        isCorrect ? 'Correct Answer!' : 'Explanation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green : Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    question.explanation,
                    style: TextStyle(color: Colors.grey[800], height: 1.4),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        currentQuestionIndex < questions.length - 1
                            ? 'Next Question'
                            : 'See Results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(QuizOption option) {
    bool isSelected = selectedOption?.id == option.id;
    bool showCorrect = hasAnswered && option.correct;
    // Ideally we'd use option.points == max, but option.correct boolean is available.
    // Let's use option.correct for green logic if available, else comparison.

    Color borderColor = Colors.grey[300]!;
    Color bgColor = Colors.white;
    IconData? icon;
    Color iconColor = Colors.transparent;

    if (hasAnswered) {
      if (isSelected) {
        borderColor = option.points > 0 ? Colors.green : Colors.red;
        bgColor = option.points > 0
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1);
        icon = option.points > 0 ? Icons.check_circle : Icons.cancel;
        iconColor = option.points > 0 ? Colors.green : Colors.red;
      } else if (option.correct) {
        // Show the correct answer if user picked wrong
        borderColor = Colors.green;
        bgColor = Colors.green.withOpacity(0.05);
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
      }
    }

    return GestureDetector(
      onTap: () => _handleOptionSelect(option),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? borderColor : borderColor,
            width: isSelected || (hasAnswered && option.correct) ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (hasAnswered && (isSelected || option.correct))
              Icon(icon, color: iconColor),
          ],
        ),
      ),
    );
  }
}
