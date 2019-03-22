import 'package:crmit_schedule/actions.dart';
import 'package:crmit_schedule/repo.dart';
import 'package:crmit_schedule/state.dart';
import 'package:redux_epics/redux_epics.dart';
import 'package:rxdart/rxdart.dart';

class LoadEpic implements EpicClass<ScheduleViewState> {
  final Repo repo;

  LoadEpic(this.repo);

  @override
  Stream<dynamic> call(
      Stream<dynamic> actions, EpicStore<ScheduleViewState> store) {
    return Observable(actions).ofType(TypeToken<LoadItems>()).switchMap((_) {
      return Observable(repo.getScheduleInitialModel().asStream())
          .map<dynamic>((items) => ItemsLoaded(items))
          .onErrorReturnWith((e) {
        print("LoadEpic error $e");
        return LoadItemsError();
      }).startWith(LoadItemsStarted());
    });
  }
}

class RefreshEpic implements EpicClass<ScheduleViewState> {
  final Repo repo;

  RefreshEpic(this.repo);

  @override
  Stream<dynamic> call(
      Stream<dynamic> actions, EpicStore<ScheduleViewState> store) {
    final Observable observable = Observable(actions);
    return observable.ofType(TypeToken<RefreshItems>()).switchMap((action) {
      onFinish() {
        print("RefreshItems.completer.complete()");
        if (!action.completer.isCompleted) {
          action.completer.complete();
        }
      }

      return Observable(repo.getScheduleInitialModel().asStream())
          .map<dynamic>((items) => ItemsLoaded(items))
          .onErrorReturnWith((e) {
            print("RefreshEpic error $e");
            return RefreshError();
          })
          .doOnDone(onFinish)
          .doOnCancel(onFinish)
          .takeUntil(observable.where((a) => a is LoadItems));
    });
  }
}
