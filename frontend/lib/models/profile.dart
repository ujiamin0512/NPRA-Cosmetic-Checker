class ProfileOption {
  ProfileOption({
    required this.name,
    required this.description,
    this.pageIndex,
  });

  final String name;
  final String description;
  final int? pageIndex;

  bool? get requiresConfirmation => null;

  static List<ProfileOption> getAllOption() {
    return <ProfileOption>[
      ProfileOption(
        name: 'Edit Profile',
        description: 'Update your personal details here.',
        pageIndex: 0,
      ),
      ProfileOption(
        name: 'Change PIN',
        description: 'Secure your account with a new 6-digit PIN.',
        pageIndex: 1,
      ),
      ProfileOption(
        name: 'About App',
        description: 'Learn more about the NPRA Cosmetic Checker.',
        pageIndex: 2,
      ),
      ProfileOption(
        name: 'Skin Profile',
        description: 'Personalize your skin types and concerns.',
        pageIndex: 3,
      ),
      ProfileOption(
        name: 'Log out',
        description: 'Confirm to sign out of your account.'
      ),
      ProfileOption(
        name: 'Clear Cache & History',
        description: 'Delete all locally cached analysis reports and chat history.'
      ),
    ];
  }
}
