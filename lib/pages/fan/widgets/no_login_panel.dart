import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pilipala/utils/utils.dart';

class NoLoginPanel extends StatelessWidget {
  const NoLoginPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '请先登录',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Get.toNamed('/loginPage'),
              child: const Text('立即登录'),
            ),
          ],
        ),
      ),
    );
  }
} 