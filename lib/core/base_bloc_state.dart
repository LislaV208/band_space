import 'package:equatable/equatable.dart';

abstract class BaseBlocState extends Equatable {
  const BaseBlocState();

  @override
  List<Object?> get props => [];
}

class InitialState extends BaseBlocState {
  const InitialState();
}

class LoadingState extends BaseBlocState {
  const LoadingState();
}

class CompletedState<T> extends BaseBlocState {
  final T? data;

  const CompletedState({required this.data});

  @override
  List<Object?> get props => [data];
}

class FailureState extends BaseBlocState {
  final Exception error;

  const FailureState({required this.error});

  @override
  List<Object?> get props => [error];
}
