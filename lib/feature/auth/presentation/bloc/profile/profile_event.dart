import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {
  const ProfileLoadRequested();
}

class ProfileLogoutRequested extends ProfileEvent {
  const ProfileLogoutRequested();
}

class ProfileDeleteAccountRequested extends ProfileEvent {
  const ProfileDeleteAccountRequested();
}

class ProfileRefreshRequested extends ProfileEvent {
  const ProfileRefreshRequested();
}