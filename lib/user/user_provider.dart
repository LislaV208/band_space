import 'package:flutter/foundation.dart';

import 'package:band_space/user/model/personal_data.dart';
import 'package:band_space/user/model/user_model.dart';
import 'package:band_space/user/repository/user_repository.dart';

class UserProvider with ChangeNotifier {
  final UserRepository userRepository;
  late UserModel _user;

  UserProvider({
    required this.userRepository,
    required UserModel user,
  }) : _user = user;

  UserModel get user => _user;

  Future<void> updatePersonalData(PersonalData personalData) async {
    _user = await userRepository.updateUserPersonalData(_user.id, personalData);

    notifyListeners();
  }
}
