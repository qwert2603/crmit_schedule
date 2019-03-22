abstract class LrState {}

class Nth implements LrState {}

class Loading implements LrState {}

class LoadingError implements LrState {}

class Loaded<T> implements LrState {
  final T data;

  Loaded(this.data);
}

class ScheduleViewState {
  final LrState schedule;

  ScheduleViewState(this.schedule);

  ScheduleViewState copy({LrState schedule}) =>
      ScheduleViewState(schedule ?? this.schedule);
}
