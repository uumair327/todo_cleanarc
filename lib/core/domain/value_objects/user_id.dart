import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class UserId extends Equatable {
  final String value;

  const UserId._(this.value);

  factory UserId.generate() {
    return UserId._(const Uuid().v4());
  }

  factory UserId.fromString(String id) {
    if (id.isEmpty) {
      throw ArgumentError('UserId cannot be empty');
    }
    return UserId._(id);
  }

  @override
  List<Object> get props => [value];

  @override
  String toString() => value;
}