import 'package:band_space/auth/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:band_space/core/base_bloc_state.dart';

class AuthCubit extends Cubit<BaseBlocState> {
  AuthCubit(this._authService) : super(const InitialState());

  final AuthService _authService;

  void logIn(String email, String password) async {
    emit(const LoadingState());

    try {
      await _authService.logIn(email, password);

      emit(const CompletedState(data: null));
    } on Exception catch (e) {
      emit(FailureState(error: e));
    }

    emit(const InitialState());
  }

  void signUp(String email, String password) async {
    emit(const LoadingState());

    try {
      await _authService.signUp(email, password);

      emit(const CompletedState(data: null));
    } on Exception catch (e) {
      emit(FailureState(error: e));
    }
    emit(const InitialState());
  }

  void signOut() async {
    emit(const LoadingState());

    try {
      await _authService.signOut();

      emit(const CompletedState(data: null));
    } on Exception catch (e) {
      emit(FailureState(error: e));
    }
    emit(const InitialState());
  }
}
