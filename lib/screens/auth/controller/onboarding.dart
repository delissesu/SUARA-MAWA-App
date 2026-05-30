class OnboardingStep {
  final String key;
  final bool completed;
  final bool editable;

  OnboardingStep({
    required this.key,
    required this.completed,
    required this.editable,
  });

  factory OnboardingStep.fromJson(Map<String, dynamic> json) {
    return OnboardingStep(
      key: json["key"],
      completed: json["completed"],
      editable: json["editable"],
    );
  }
}

final class Onboarding {
  Onboarding._();

  static const stepNames = [
    "Verifikasi\nEmail",
    "Pengisian\nNIM",
    "Pengisian\nNomor\nTelepon",
    "Verifikasi\nNomor\nTelepon"
  ];

  static const stepOrder = [
    "VERIFY_EMAIL",
    "FILL_PHONE",
    "VERIFY_PHONE"
  ];
  static int getCurrentIndex(String nextStep){
    return stepOrder.indexOf(nextStep);
  }

  static bool canGoBack(
      int currentIndex,
      List<OnboardingStep> steps
  ){
      if(currentIndex <= 0){
        return false;
      }
      return steps[currentIndex-1]
        .completed;
  }
}
