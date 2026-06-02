import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

class StoryList extends StatelessWidget {
  const StoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          final isAddStory = index == 0;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isAddStory 
                        ? null 
                        : Border.all(color: AppColors.primaryOrange, width: 2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: CircleAvatar(
                      backgroundColor: AppColors.surface,
                      child: isAddStory
                          ? const Icon(Icons.add, color: AppColors.primaryOrange)
                          : const Icon(Icons.person, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAddStory ? 'Your Story' : 'User $index',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
