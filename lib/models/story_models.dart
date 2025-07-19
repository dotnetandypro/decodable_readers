class Level {
  final int id;
  final String title;
  final String description;
  final List<String> phonicsSet;
  final String iconPath;
  final List<Storybook> storybooks;
  final bool isUnlocked;

  Level({
    required this.id,
    required this.title,
    required this.description,
    required this.phonicsSet,
    required this.iconPath,
    required this.storybooks,
    this.isUnlocked = true,
  });

  int get completedBooks {
    return storybooks.where((book) => book.isCompleted).length;
  }

  double get progress {
    if (storybooks.isEmpty) return 0.0;
    return completedBooks / storybooks.length;
  }
}

class Storybook {
  final String id;
  final String title;
  final String description;
  final String thumbnailPath;
  final List<StoryPage> pages;
  final int levelId;
  final QuizGame? quizGame;
  bool isCompleted;
  int currentPage;
  bool quizCompleted;

  Storybook({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailPath,
    required this.pages,
    required this.levelId,
    this.quizGame,
    this.isCompleted = false,
    this.currentPage = 0,
    this.quizCompleted = false,
  });

  double get progress {
    if (pages.isEmpty) return 0.0;
    return currentPage / pages.length;
  }

  void markAsCompleted() {
    isCompleted = true;
    currentPage = pages.length;
  }

  void updateProgress(int pageIndex) {
    currentPage = pageIndex + 1;
    if (currentPage >= pages.length) {
      markAsCompleted();
    }
  }
}

class StoryPage {
  final int pageNumber;
  final String imagePath;
  final String text;
  final List<String> words;
  final String audioPath;

  StoryPage({
    required this.pageNumber,
    required this.imagePath,
    required this.text,
    required this.words,
    required this.audioPath,
  });

  factory StoryPage.fromText({
    required int pageNumber,
    required String imagePath,
    required String text,
    required String audioPath,
  }) {
    // Split text into words for tappable functionality
    final words = text
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();

    return StoryPage(
      pageNumber: pageNumber,
      imagePath: imagePath,
      text: text,
      words: words,
      audioPath: audioPath,
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });
}

class QuizGame {
  final List<QuizQuestion> questions;
  int currentQuestionIndex;
  int correctAnswers;
  bool isCompleted;

  QuizGame({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.correctAnswers = 0,
    this.isCompleted = false,
  });

  QuizQuestion get currentQuestion => questions[currentQuestionIndex];

  bool get hasMoreQuestions => currentQuestionIndex < questions.length - 1;

  double get score =>
      questions.isEmpty ? 0.0 : correctAnswers / questions.length;

  void answerQuestion(String answer) {
    if (answer == currentQuestion.correctAnswer) {
      correctAnswers++;
    }

    if (hasMoreQuestions) {
      currentQuestionIndex++;
    } else {
      isCompleted = true;
    }
  }

  void reset() {
    currentQuestionIndex = 0;
    correctAnswers = 0;
    isCompleted = false;
  }
}

class ReadingProgress {
  final String storybookId;
  final int currentPage;
  final bool isCompleted;
  final bool quizCompleted;
  final DateTime lastRead;

  ReadingProgress({
    required this.storybookId,
    required this.currentPage,
    required this.isCompleted,
    required this.lastRead,
    this.quizCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'storybookId': storybookId,
      'currentPage': currentPage,
      'isCompleted': isCompleted,
      'quizCompleted': quizCompleted,
      'lastRead': lastRead.toIso8601String(),
    };
  }

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      storybookId: json['storybookId'],
      currentPage: json['currentPage'],
      isCompleted: json['isCompleted'],
      quizCompleted: json['quizCompleted'] ?? false,
      lastRead: DateTime.parse(json['lastRead']),
    );
  }
}
