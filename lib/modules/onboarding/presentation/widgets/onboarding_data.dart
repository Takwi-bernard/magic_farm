class OnboardingData {
  final String image;
  final String title;
  final String description;

  /// Renders the language picker below this slide's text.
  final bool showLanguageSelector;

  /// Uses a clean rounded-rect "device frame" (no crop) instead of the
  /// organic blob frame. Needed for the chat slide since it's a phone
  /// screenshot — cropping it with the blob shape would cut off UI.
  final bool useDeviceFrame;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.description,
    this.showLanguageSelector = false,
    this.useDeviceFrame = false,
  });
}

// Language first, so the rest of onboarding renders in whichever
// language the user just picked.
const onboardingItems = [
  OnboardingData(
    image: "assets/images/onboarding/magic_language.jpeg",
    title: "language_title",
    description: "language_description",
    showLanguageSelector: true,
  ),
  OnboardingData(
    image: "assets/images/onboarding/magic_welcome.jpeg",
    title: "welcome_title",
    description: "welcome_description",
  ),
  OnboardingData(
    // Filename has a typo in the actual asset ("makert" not "market") —
    // referencing it exactly as it exists on disk.
    image: "assets/images/onboarding/magic_makert.jpeg",
    title: "market_title",
    description: "market_description",
  ),
  OnboardingData(
    image: "assets/images/onboarding/magic_chat.jpeg",
    title: "chat_title",
    description: "chat_description",
    useDeviceFrame: true,
  ),
];
