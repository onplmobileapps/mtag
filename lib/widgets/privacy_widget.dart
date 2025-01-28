import 'package:flutter/material.dart';

class PrivacyPolicySection extends StatelessWidget {
  final String title;
  final String content;
  const PrivacyPolicySection({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              fontSize: 11,
              height: 1.4,
              fontFamily: 'Poppins',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
