class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  // بنحول البيانات لـ Map عشان يفهمها الفايربيز ويخزنها
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
