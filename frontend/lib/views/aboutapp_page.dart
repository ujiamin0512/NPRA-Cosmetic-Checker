import 'package:flutter/material.dart';

import '../models/aboutapp.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<AboutSection> sections = AboutAppContent.sections();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (final AboutSection section in sections) ...<Widget>[
            Text(
              section.title,
              style: const TextStyle(
                color: Color(0xFF1D0CC2),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (section.bulleted)
              ...section.paragraphs.map(
                (String item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '\u2022',
                        style: TextStyle(
                          color: Color(0xFF333752),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Color(0xFF333752),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...section.paragraphs.map(
                (String paragraph) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    paragraph,
                    style: const TextStyle(
                      color: Color(0xFF333752),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}
