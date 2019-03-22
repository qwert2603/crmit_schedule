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
  final bool refreshError;

  ScheduleViewState(this.schedule, this.refreshError);

  ScheduleViewState copy({LrState schedule, bool refreshError}) =>
      ScheduleViewState(
        schedule ?? this.schedule,
        refreshError ?? this.refreshError,
      );
}
