class AboutSection {
  const AboutSection({
    required this.title,
    required this.paragraphs,
    this.bulleted = false,
  });

  final String title;
  final List<String> paragraphs;
  final bool bulleted;
}

class AboutAppContent {
  static List<AboutSection> sections() {
    return const <AboutSection>[
      AboutSection(
        title: 'Our History',
        paragraphs: <String>[
          'The National Pharmaceutical Regulatory Agency (NPRA) is the authority under the Ministry of Health Malaysia (MOH) responsible for regulating pharmaceutical and cosmetic products in Malaysia.',
          'The Cosmetic Product Division of NPRA specifically ensures that all cosmetic products marketed in Malaysia are safe, of good quality, and compliant with national regulations.',
          'Since the implementation of the Control of Drugs and Cosmetics Regulations 1984, all cosmetics must be notified to NPRA before being sold or distributed. This notification system requires the product owner to declare product information, including ingredients, manufacturer, and function, through the Quest3+ online system.',
          'Unlike pharmaceutical products, cosmetics are not registered, but notified — meaning the company is responsible for ensuring product safety and compliance with NPRA’s Guidelines for Control of Cosmetic Products in Malaysia. NPRA conducts post-market surveillance and laboratory testing to verify the safety of notified products and takes enforcement action against any products found containing prohibited or harmful ingredients.',
          'Through continuous monitoring, regulatory improvement, and collaboration with international agencies, NPRA protects Malaysian consumers from unsafe or falsely labelled cosmetics and promotes best practices within the cosmetic industry.',
        ],
      ),
      AboutSection(
        title: 'Our Objective',
        paragraphs: <String>[
          'To ensure that all cosmetic products notified and marketed in Malaysia are safe, effective, and of high quality for consumer use.',
        ],
      ),
      AboutSection(
        title: 'Our Mission',
        bulleted: true,
        paragraphs: <String>[
          'Evaluate and process cosmetic product notifications.',
          'Maintain the Notified Cosmetic Product List for public reference.',
          'Conduct post-market surveillance and testing of cosmetics.',
          'Revoke notifications of products containing prohibited or unsafe substances.',
          'Provide information and guidance to the public and industry stakeholders.',
        ],
      ),
      AboutSection(
        title: 'Legal Reference',
        paragraphs: <String>[
          'All cosmetic product control activities are governed under the Control of Drugs and Cosmetics Regulations 1984 and aligned with the ASEAN Cosmetic Directive (ACD).',
        ],
      ),
    ];
  }
}
