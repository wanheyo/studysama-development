class Quiz {
  final String title;
  final List<QuizItem> data;

  Quiz({
    required this.title,
    required this.data
  });

  // Factory method to create a Quiz object from JSON
  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      title: json['title'],
      data: (json['data'] as List)
          .map((item) => QuizItem.fromJson(item))
          .toList(),
    );
  }

  // Method to convert a Quiz object to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class QuizItem {
  final String question;
  final List<String> options;
  final int answerIndex;

  QuizItem({required this.question, required this.options, required this.answerIndex});

  // Factory method to create a QuizItem object from JSON
  factory QuizItem.fromJson(Map<String, dynamic> json) {
    return QuizItem(
      question: json['question'],
      options: List<String>.from(json['options']),
      answerIndex: json['answer'],
    );
  }

  // Method to convert a QuizItem object to JSON
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': options,
      'answer': answerIndex,
    };
  }

  String get correctAnswer => options[answerIndex];
  int get correctAnswerIndex => answerIndex;
}
