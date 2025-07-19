import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/story_models.dart';
import '../services/orientation_service.dart';
import '../services/progress_service.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';

class QuizGameScreen extends StatefulWidget {
  final QuizGame quizGame;
  final String storybookTitle;
  final String storybookId;
  final int levelId;
  final VoidCallback onComplete;

  const QuizGameScreen({
    super.key,
    required this.quizGame,
    required this.storybookTitle,
    required this.storybookId,
    required this.levelId,
    required this.onComplete,
  });

  @override
  State<QuizGameScreen> createState() => _QuizGameScreenState();
}

class _QuizGameScreenState extends State<QuizGameScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;

  String? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;

  // TTS service for read aloud functionality
  final TTSService _ttsService = TTSService();
  bool _isReadingAloud = false;

  // Random background images for quiz boxes
  String? _questionBoxBackground;
  String? _optionsBoxBackground;

  @override
  void initState() {
    super.initState();

    // Force landscape orientation for quiz
    OrientationService.enterReadingMode();

    // Initialize TTS service
    _initializeTTS();

    // Initialize random background images
    _initializeBackgroundImages();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _slideController.forward();
    widget.quizGame.reset();
  }

  Future<void> _initializeTTS() async {
    try {
      await _ttsService.initialize();
      debugPrint('🎙️ TTS Service initialized for quiz game');
    } catch (e) {
      debugPrint('❌ Failed to initialize TTS for quiz: $e');
    }
  }

  void _initializeBackgroundImages() {
    // Use existing story images as backgrounds for quiz boxes
    final random = Random();
    final levelId = widget.levelId;

    // Generate random story and page numbers for the current level
    final maxStories = 7; // Most levels have up to 7 stories
    final maxPages = 10; // Most stories have up to 10 pages

    final questionStoryNum = random.nextInt(maxStories) + 1;
    final questionPageNum = random.nextInt(maxPages) + 1;

    final optionsStoryNum = random.nextInt(maxStories) + 1;
    final optionsPageNum = random.nextInt(maxPages) + 1;

    setState(() {
      _questionBoxBackground =
          'assets/stories/level$levelId/story$questionStoryNum/page$questionPageNum.png';
      _optionsBoxBackground =
          'assets/stories/level$levelId/story$optionsStoryNum/page$optionsPageNum.png';
    });

    debugPrint(
        '🎨 Quiz backgrounds: Question=${_questionBoxBackground}, Options=${_optionsBoxBackground}');
  }

  @override
  void dispose() {
    // Restore all orientations when exiting quiz
    OrientationService.exitReadingMode();

    // Stop any ongoing TTS
    _ttsService.stop();

    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPhysicallyLandscape = screenSize.width > screenSize.height;

    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: Text('Quiz: ${widget.storybookTitle}'),
        backgroundColor: Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Main content - landscape layout with question left, options right
                Expanded(
                  child: _buildLandscapeQuizLayout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallActionButton() {
    if (!_showResult) {
      return SizedBox(
        width: 140, // Small button width
        height: 36, // Small button height
        child: ElevatedButton(
          onPressed: _selectedAnswer != null ? _submitAnswer : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Submit',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      width: 140, // Small button width
      height: 36, // Small button height
      child: ElevatedButton(
        onPressed: _nextQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          widget.quizGame.hasMoreQuestions ? 'Next' : 'Finish',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLandscapeQuizLayout() {
    final screenSize = MediaQuery.of(context).size;
    final isPhysicallyLandscape = screenSize.width > screenSize.height;

    // If device is in portrait, rotate the entire quiz layout
    if (!isPhysicallyLandscape) {
      return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: Transform.rotate(
            angle: 1.5708, // 90 degrees in radians (π/2)
            child: SizedBox(
              width: screenSize.height * 0.85,
              height: screenSize.width * 0.75,
              child: _buildLandscapeContent(),
            ),
          ),
        ),
      );
    }

    // Device is in landscape - use normal layout
    return _buildLandscapeContent();
  }

  Widget _buildLandscapeContent() {
    return Row(
      children: [
        // Left side - Question
        Expanded(
          flex: 1,
          child: _buildQuestionSection(),
        ),

        const SizedBox(width: 20),

        // Right side - Options
        Expanded(
          flex: 1,
          child: _buildOptionsSection(),
        ),
      ],
    );
  }

  Widget _buildQuestionSection() {
    final question = widget.quizGame.currentQuestion;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: _questionBoxBackground != null
            ? DecorationImage(
                image: AssetImage(_questionBoxBackground!),
                fit: BoxFit.cover,
                opacity: 0.3,
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Question icon and read aloud button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.quiz_rounded,
                  size: 32,
                  color: Colors.purple[600],
                ),
              ),

              const SizedBox(width: 16),

              // Read aloud button for question
              GestureDetector(
                onTap: () => _readQuestionAloud(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        _isReadingAloud ? Colors.orange[100] : Colors.blue[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isReadingAloud
                        ? Icons.volume_up
                        : Icons.volume_up_outlined,
                    size: 28,
                    color:
                        _isReadingAloud ? Colors.orange[600] : Colors.blue[600],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Question text
          Flexible(
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsSection() {
    final question = widget.quizGame.currentQuestion;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        image: _optionsBoxBackground != null
            ? DecorationImage(
                image: AssetImage(_optionsBoxBackground!),
                fit: BoxFit.cover,
                opacity: 0.3,
              )
            : null,
      ),
      child: Column(
        children: [
          // Small submit button at top of options section
          _buildSmallActionButton(),

          const SizedBox(height: 16),

          // Answer options
          Expanded(
            child: ListView.builder(
              itemCount: question.options.length,
              itemBuilder: (context, index) {
                final option = question.options[index];
                final isSelected = _selectedAnswer == option;
                final isCorrect = option == question.correctAnswer;

                Color cardColor = Colors.grey[100]!;
                Color borderColor = Colors.grey[300]!;
                Color textColor = Colors.black87;

                if (_showResult) {
                  if (isCorrect) {
                    cardColor = Colors.green[100]!;
                    borderColor = Colors.green[400]!;
                    textColor = Colors.green[800]!;
                  } else if (isSelected && !isCorrect) {
                    cardColor = Colors.red[100]!;
                    borderColor = Colors.red[400]!;
                    textColor = Colors.red[800]!;
                  }
                } else if (isSelected) {
                  cardColor = Colors.purple[100]!;
                  borderColor = Colors.purple[400]!;
                  textColor = Colors.purple[800]!;
                }

                return AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: (_showResult && isCorrect)
                          ? _bounceAnimation.value
                          : 1.0,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap:
                              _showResult ? null : () => _selectAnswer(option),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor, width: 2),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: borderColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      String.fromCharCode(
                                          65 + index), // A, B, C, D
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                                if (_showResult && isCorrect)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green[600],
                                    size: 24,
                                  ),
                                if (_showResult && isSelected && !isCorrect)
                                  Icon(
                                    Icons.cancel,
                                    color: Colors.red[600],
                                    size: 24,
                                  ),

                                // Read aloud button for option
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _readOptionAloud(option),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Colors.blue[200]!, width: 1),
                                    ),
                                    child: Icon(
                                      Icons.volume_up_outlined,
                                      size: 16,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _selectAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
    HapticFeedback.lightImpact();
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    setState(() {
      _isCorrect =
          _selectedAnswer == widget.quizGame.currentQuestion.correctAnswer;
      _showResult = true;
    });

    if (_isCorrect) {
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _nextQuestion() {
    widget.quizGame.answerQuestion(_selectedAnswer!);

    if (widget.quizGame.isCompleted) {
      _showQuizResults();
    } else {
      setState(() {
        _selectedAnswer = null;
        _showResult = false;
      });

      // Slide animation for next question
      _slideController.reset();
      _slideController.forward();
    }
  }

  void _showQuizResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '🎉 Quiz Complete!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You got ${widget.quizGame.correctAnswers} out of ${widget.quizGame.questions.length} questions correct!',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Score: ${(widget.quizGame.score * 100).toInt()}%',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    widget.quizGame.score >= 0.7 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Save progress when quiz is completed
              await ProgressService.instance.completeBook(
                widget.storybookId,
                widget.levelId,
              );

              if (mounted) {
                Navigator.of(context).pop();
                widget.onComplete();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // Read aloud functionality
  Future<void> _readQuestionAloud() async {
    if (_isReadingAloud) {
      await _ttsService.stop();
      setState(() {
        _isReadingAloud = false;
      });
      return;
    }

    final currentQuestion = widget.quizGame.currentQuestion;
    setState(() {
      _isReadingAloud = true;
    });

    try {
      await _ttsService.speak(currentQuestion.question);
      debugPrint('🎙️ Reading question aloud: ${currentQuestion.question}');
    } catch (e) {
      debugPrint('❌ Failed to read question aloud: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isReadingAloud = false;
        });
      }
    }
  }

  Future<void> _readOptionAloud(String option) async {
    try {
      await _ttsService.speak(option);
      debugPrint('🎙️ Reading option aloud: $option');
    } catch (e) {
      debugPrint('❌ Failed to read option aloud: $e');
    }
  }
}
