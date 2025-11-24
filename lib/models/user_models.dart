import 'package:equatable/equatable.dart';

enum Role { admin, moderator, client }

class UserModel extends Equatable {
  final String uid;
  final String email;
  final Role role;
  final String? clientId; // Only for client role

  const UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.clientId,
  });

  @override
  List<Object?> get props => [uid, email, role, clientId];
}
