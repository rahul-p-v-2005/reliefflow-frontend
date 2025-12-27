class User {
  String? id;
  String? name;
  String? email;
  String? address;
  String? phoneNumber;
  String? role;
  String? skill;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? profileImage;

  User({
    this.id,
    this.name,
    this.email,
    this.address,
    this.phoneNumber,
    this.role,
    this.skill,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
  });

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, address: $address, phoneNumber: $phoneNumber, role: $role, skill: $skill, createdAt: $createdAt, updatedAt: $updatedAt, profileImage: $profileImage)';
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String?,
    name: json['name'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    role: json['role'] as String?,
    skill: json['skill'] as String?,
    createdAt: json['createdAt'] == null
        ? null
        : DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] == null
        ? null
        : DateTime.parse(json['updatedAt'] as String),
    profileImage: json['profileImage'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'address': address,
    'phoneNumber': phoneNumber,
    'role': role,
    'skill': skill,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'profileImage': profileImage,
  };
}
