import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class TaskId extends Equatable {
  final String value;

  const TaskId._(this.value);

  // Public constructor for creating TaskId from string
  const TaskId(this.value);

  factory TaskId.generate() {
    return TaskId._(const Uuid().v4());
  }

  factory TaskId.fromString(String id) {
    if (id.isEmpty) {
      throw ArgumentError('TaskId cannot be empty');
    }
    return TaskId._(id);
  }

  @override
  List<Object> get props => [value];

  @override
  String toString() => value;
}