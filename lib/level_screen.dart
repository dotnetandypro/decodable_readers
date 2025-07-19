import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LevelScreen extends StatelessWidget {
  final int level;
  const LevelScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Level $level'),
        backgroundColor: AppTheme.getLevelColor(level - 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.2,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            final book = index + 1;
            return GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/reader',
                  arguments: {'level': level, 'book': book},
                );
              },
              child: Card(
                color: AppTheme.cardColor,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'book_${level}_$book',
                        child: Icon(Icons.menu_book_rounded,
                            size: 48, color: AppTheme.getLevelColor(level - 1)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Storybook $book',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Placeholder for completion status
                      Icon(Icons.check_circle,
                          color: Colors.greenAccent, size: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
