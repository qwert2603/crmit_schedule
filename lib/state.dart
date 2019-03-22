import 'package:crmit_schedule/entity.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LrState {}

class Nth implements LrState {}

class Loading implements LrState {}

class LoadingError implements LrState {}

class Loaded<T> implements LrState {
  final T data;

  Loaded(this.data);

  @override
  String toString() {
    return 'Loaded{data: $data}';
  }
}

@immutable
class ScheduleInitialModel {
  final List<Teacher> teachers;
  final List<DayOfWeek> schedule;
  final int authedTeacherId;

  ScheduleInitialModel(this.teachers, this.schedule, this.authedTeacherId);

  @override
  String toString() {
    return 'ScheduleInitialModel{teachers: $teachers, schedule: $schedule, authedTeacherId: $authedTeacherId}';
  }
}

@immutable
class ScheduleViewState {
  final LrState lrState;
  final bool refreshError;
  final int selectedTeacherId;

  ScheduleViewState(this.lrState, this.refreshError, this.selectedTeacherId);

  ScheduleViewState copy({
    LrState lrState,
    bool refreshError,
    int selectedTeacherId,
  }) =>
      ScheduleViewState(
        lrState ?? this.lrState,
        refreshError ?? this.refreshError,
        selectedTeacherId ?? this.selectedTeacherId,
      );
}
