class UserProfileModel {
  final String firstName;
  final String lastName;
  final String gender;
  final String email;

  const UserProfileModel({
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.email,
  });

  String get displayName {
    final String fullName = '${firstName.trim()} ${lastName.trim()}'.trim();
    return fullName.isEmpty ? 'User' : fullName;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'email': email,
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      firstName: (map['firstName'] ?? '').toString(),
      lastName: (map['lastName'] ?? '').toString(),
      gender: (map['gender'] ?? 'male').toString(),
      email: (map['email'] ?? '').toString(),
    );
  }
}
