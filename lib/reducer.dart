import 'package:crmit_schedule/actions.dart';
import 'package:crmit_schedule/state.dart';
import 'package:redux/redux.dart';

class ScheduleReducer implements ReducerClass<ScheduleViewState> {
  @override
  ScheduleViewState call(ScheduleViewState state, dynamic action) {
    print("ScheduleReducer $action");
    if (action is LoadItemsStarted)
      return state.copy(lrState: Loading(), refreshError: false);
    if (action is LoadItemsError) return state.copy(lrState: LoadingError());
    if (action is ItemsLoaded)
      return state.copy(
        lrState: Loaded(action.model),
        selectedTeacherId:
            state.selectedTeacherId ?? action.model.authedTeacherId,
      );
    if (action is RefreshItems) return state.copy(refreshError: false);
    if (action is RefreshError) return state.copy(refreshError: true);
    if (action is SelectedTeacherChanged)
      return state.copy(selectedTeacherId: action.selectedTeacherId);
    return state;
  }
}
