class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; 
  final String phoneNumber;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber = '-',
    this.isActive = true,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'] ?? 'Tanpa Nama',
     
      role: data['role'] ?? 'user', 
      phoneNumber: data['phone_number'] ?? '-',
      isActive: data['is_active'] ?? true,
      createdAt: data['created_at'] != null 
          ? (data['created_at'] as dynamic).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'created_at': createdAt,
    };
  }
}