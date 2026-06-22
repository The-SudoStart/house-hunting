import 'package:flutter/material.dart';

class HouseDetailsScreen extends StatelessWidget {
  const HouseDetailsScreen({
    super.key,
    required this.houseId,
  });

  final String houseId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('House Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'House #$houseId',
              style: textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Details about this house will be displayed here.',
              style: textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
