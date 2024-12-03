import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SetupScreen(),
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Question {
  final String question;
  final String correctAnswer;
  final List<String> allAnswers;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.allAnswers,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> answers = [...json['incorrect_answers']];
    answers.add(json['correct_answer']);
    answers.shuffle();

    return Question(
      question: json['question'],
      correctAnswer: json['correct_answer'],
      allAnswers: answers,
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  SetupScreenState createState() => SetupScreenState();
}

class SetupScreenState extends State<SetupScreen> {
  List<Category> categories = [];
  Category? selectedCategory;
  String selectedDifficulty = 'easy';
  String selectedType = 'multiple';
  int numberOfQuestions = 5;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response =
        await http.get(Uri.parse('https://opentdb.com/api_category.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        categories = (data['trivia_categories'] as List)
            .map((cat) => Category.fromJson(cat))
            .toList();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Setup')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<Category>(
                    value: selectedCategory,
                    hint: const Text('Select Category'),
                    items: categories.map((Category category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (Category? value) {
                      setState(() => selectedCategory = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedDifficulty,
                    items: ['easy', 'medium', 'hard'].map((String difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty.capitalize()),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() => selectedDifficulty = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: [
                      const DropdownMenuItem(
                          value: 'multiple', child: Text('Multiple Choice')),
                      const DropdownMenuItem(
                          value: 'boolean', child: Text('True/False')),
                    ],
                    onChanged: (String? value) {
                      setState(() => selectedType = value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: numberOfQuestions.toDouble(),
                    min: 5,
                    max: 15,
                    divisions: 2,
                    label: numberOfQuestions.toString(),
                    onChanged: (double value) {
                      setState(() => numberOfQuestions = value.round());
                    },
                  ),
                  Text(
                    'Number of Questions: $numberOfQuestions',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedCategory == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select a category')),
                        );
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            categoryId: selectedCategory!.id,
                            difficulty: selectedDifficulty,
                            type: selectedType,
                            numberOfQuestions: numberOfQuestions,
                          ),
                        ),
                      );
                    },
                    child: const Text('Start Quiz'),
                  ),
                ],
              ),
            ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final int categoryId;
  final String difficulty;
  final String type;
  final int numberOfQuestions;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.difficulty,
    required this.type,
    required this.numberOfQuestions,
  });

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool isLoading = true;
  bool answered = false;
  String? selectedAnswer;
  Timer? timer;
  int timeLeft = 15;
  List<Map<String, dynamic>> questionResults = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final response = await http.get(Uri.parse(
        'https://opentdb.com/api.php?amount=${widget.numberOfQuestions}'
        '&category=${widget.categoryId}'
        '&difficulty=${widget.difficulty}'
        '&type=${widget.type}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        questions =
            (data['results'] as List).map((q) => Question.fromJson(q)).toList();
        isLoading = false;
      });
      startTimer();
    }
  }

  void startTimer() {
    timeLeft = 15;
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            handleTimeout();
          }
        });
      }
    });
  }

  void handleTimeout() {
    if (!answered) {
      setState(() {
        answered = true;
        questionResults.add({
          'question': questions[currentQuestionIndex].question,
          'correctAnswer': questions[currentQuestionIndex].correctAnswer,
          'userAnswer': 'Time Out',
          'isCorrect': false,
        });
      });
      timer?.cancel();
      Future.delayed(const Duration(seconds: 2), nextQuestion);
    }
  }

  void handleAnswer(String answer) {
    if (!answered) {
      setState(() {
        answered = true;
        selectedAnswer = answer;
        final isCorrect =
            answer == questions[currentQuestionIndex].correctAnswer;
        if (isCorrect) score++;

        questionResults.add({
          'question': questions[currentQuestionIndex].question,
          'correctAnswer': questions[currentQuestionIndex].correctAnswer,
          'userAnswer': answer,
          'isCorrect': isCorrect,
        });
      });
      timer?.cancel();
      Future.delayed(const Duration(seconds: 2), nextQuestion);
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        answered = false;
        selectedAnswer = null;
      });
      startTimer();
    } else {
      timer?.cancel();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SummaryScreen(
            score: score,
            totalQuestions: questions.length,
            questionResults: questionResults,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentQuestionIndex + 1}/${questions.length}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
            ),
            const SizedBox(height: 16),
            Text(
              'Time Left: $timeLeft seconds',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $score',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            Text(
              question.question,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ...question.allAnswers.map((answer) {
              final bool isSelected = selectedAnswer == answer;
              final bool showResult =
                  answered && answer == question.correctAnswer;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showResult
                        ? Colors.green
                        : (isSelected && answered)
                            ? Colors.red
                            : null,
                  ),
                  onPressed: answered ? null : () => handleAnswer(answer),
                  child: Text(answer),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class SummaryScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final List<Map<String, dynamic>> questionResults;

  const SummaryScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.questionResults,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Final Score: $score/$totalQuestions',
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: questionResults.length,
                itemBuilder: (context, index) {
                  final result = questionResults[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question ${index + 1}: ${result['question']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Your Answer: ${result['userAnswer']}'),
                          Text('Correct Answer: ${result['correctAnswer']}'),
                          Text(
                            result['isCorrect'] ? 'Correct!' : 'Incorrect',
                            style: TextStyle(
                              color: result['isCorrect']
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SetupScreen()),
                  (route) => false,
                );
              },
              child: const Text('Start New Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
