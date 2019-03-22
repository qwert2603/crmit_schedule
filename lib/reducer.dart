import 'package:crmit_schedule/actions.dart';
import 'package:crmit_schedule/state.dart';
import 'package:redux/redux.dart';

class ScheduleReducer implements ReducerClass<ScheduleViewState> {
  @override
  ScheduleViewState call(ScheduleViewState state, dynamic action) {
    print("ScheduleReducer $action");
    if (action is LoadItemsStarted) return state.copy(schedule: Loading());
    if (action is LoadItemsError) return state.copy(schedule: LoadingError());
    if (action is ItemsLoaded)
      return state.copy(schedule: Loaded(action.items));
    return state;
  }
}