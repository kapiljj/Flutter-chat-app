class User {
  static User? currentUser;
  final String id, firstName, lastName, authToken;
  final bool onboardingPending;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.authToken,
    required this.onboardingPending,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      authToken: json['authToken'] ?? '',
      onboardingPending: json['onboardingPending'] ?? false,
    );
  }
}
