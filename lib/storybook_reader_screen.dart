import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:page_flip/page_flip.dart';
import '../theme/app_theme.dart';

class StorybookReaderScreen extends StatefulWidget {
  final int level;
  final int book;
  const StorybookReaderScreen(
      {super.key, required this.level, required this.book});

  @override
  State<StorybookReaderScreen> createState() => _StorybookReaderScreenState();
}

class _StorybookReaderScreenState extends State<StorybookReaderScreen> {
  final _controller = GlobalKey<PageFlipWidgetState>();
  List<dynamic> pages = [];
  int currentPage = 0;
  bool isLoading = true;
  bool showGame = false;
  Map<String, dynamic>? gameData;

  @override
  void initState() {
    super.initState();
    _loadStoryData();
  }

  Future<void> _loadStoryData() async {
    final String data = await rootBundle.loadString('assets/settings.json');
    final json = jsonDecode(data);
    final levelData = json['levels'][widget.level - 1];
    final story = levelData['storybooks'][widget.book - 1];
    setState(() {
      pages = story['pages'];
      gameData = story['game'];
      isLoading = false;
    });
  }

  void playPhonicsSound(String word) {
    debugPrint('playPhonicsSound: $word');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (showGame && gameData != null) {
      return _GameScreen(gameData: gameData!);
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        debugPrint('Orientation: $orientation, isLandscape: $isLandscape');

        return Scaffold(
          appBar: AppBar(
            title: Text('Storybook ${widget.book}'),
            backgroundColor: AppTheme.getLevelColor(widget.level - 1),
          ),
          body: Container(
            color: AppTheme.backgroundColor,
            child: PageFlipWidget(
              key: _controller,
              backgroundColor: AppTheme.backgroundColor,
              lastPage: Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration,
                        size: 80, color: AppTheme.accentColor),
                    const SizedBox(height: 24),
                    Text('The End!',
                        style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: 16),
                    Text('Great job reading!',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showGame = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Play Quiz Game!',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              children: List.generate(
                isLandscape ? (pages.length / 2).ceil() : pages.length,
                (i) => isLandscape
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StoryPage(
                                pageData: pages[i * 2],
                                page: i * 2,
                                onWordTap: playPhonicsSound,
                                isLandscape: isLandscape,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (i * 2 + 1 < pages.length)
                              Expanded(
                                child: _StoryPage(
                                  pageData: pages[i * 2 + 1],
                                  page: i * 2 + 1,
                                  onWordTap: playPhonicsSound,
                                  isLandscape: isLandscape,
                                ),
                              )
                            else
                              const Expanded(child: SizedBox()),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(16),
                        child: _StoryPage(
                          pageData: pages[i],
                          page: i,
                          onWordTap: playPhonicsSound,
                          isLandscape: isLandscape,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StoryPage extends StatelessWidget {
  final Map<String, dynamic> pageData;
  final int page;
  final void Function(String word) onWordTap;
  final bool isLandscape;

  const _StoryPage({
    required this.pageData,
    required this.page,
    required this.onWordTap,
    required this.isLandscape,
  });

  @override
  Widget build(BuildContext context) {
    final text = pageData['text'] as String;
    final words = text.split(' ');

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image section - maintains aspect ratio
          Expanded(
            flex: 3,
            child: Hero(
              tag: 'page_image_$page',
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    pageData['image'],
                    fit: BoxFit.contain, // Maintain aspect ratio
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 48, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Text section - scrollable for long text
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 600),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: words
                            .map((word) => GestureDetector(
                                  onTap: () => onWordTap(
                                      word.replaceAll(RegExp(r'[^\w]'), '')),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.accentColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppTheme.accentColor
                                            .withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      word,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.primaryColor,
                                            fontSize: isLandscape ? 14 : 16,
                                          ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Read Out Loud button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Play full page audio
                    },
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    label: Text(
                      'Read Out Loud',
                      style: TextStyle(fontSize: isLandscape ? 12 : 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      elevation: 3,
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
}

class _GameScreen extends StatefulWidget {
  final Map<String, dynamic> gameData;
  const _GameScreen({required this.gameData});

  @override
  State<_GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<_GameScreen> {
  Map<int, String> selectedAnswers = {};
  bool showResults = false;
  int score = 0;

  void _submitAnswers() {
    final questions = widget.gameData['questions'] as List<dynamic>;
    int correctCount = 0;

    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final correctAnswer = question['correctAnswer'] as String;
      if (selectedAnswers[i] == correctAnswer) {
        correctCount++;
      }
    }

    setState(() {
      score = correctCount;
      showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.gameData['questions'] as List<dynamic>?;
    if (questions == null || questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No game available.')),
      );
    }

    if (showResults) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz Results'),
          backgroundColor: AppTheme.successColor,
        ),
        body: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                score == questions.length ? Icons.star : Icons.thumb_up,
                size: 100,
                color: AppTheme.accentColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Great Job!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'You got $score out of ${questions.length} correct!',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Time!'),
        backgroundColor: AppTheme.accentColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: questions.length,
              itemBuilder: (context, i) {
                final q = questions[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${i + 1}',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppTheme.accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          q['question'],
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        ...List.generate((q['options'] as List).length, (j) {
                          final opt = q['options'][j];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedAnswers[i] == opt
                                    ? AppTheme.accentColor
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              color: selectedAnswers[i] == opt
                                  ? AppTheme.accentColor.withOpacity(0.1)
                                  : Colors.transparent,
                            ),
                            child: ListTile(
                              title: Text(
                                opt,
                                style: TextStyle(
                                  fontWeight: selectedAnswers[i] == opt
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              leading: Radio<String>(
                                value: opt,
                                groupValue: selectedAnswers[i],
                                onChanged: (value) {
                                  setState(() {
                                    selectedAnswers[i] = value!;
                                  });
                                },
                                activeColor: AppTheme.accentColor,
                              ),
                              onTap: () {
                                setState(() {
                                  selectedAnswers[i] = opt;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAnswers.length == questions.length
                    ? _submitAnswers
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  selectedAnswers.length == questions.length
                      ? 'Submit Answers'
                      : 'Answer all questions (${selectedAnswers.length}/${questions.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
