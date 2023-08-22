import 'package:equatable/equatable.dart';

class UserData extends Equatable {
  const UserData({
    required this.email,
  });

  final String email;

  @override
  List<Object> get props => [email];
}
