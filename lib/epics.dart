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
    final Observable observable = Observable(actions);
    return Observable.merge([observable.ofType(TypeToken<LoadItems>())])
        .switchMap((_) {
      return Observable(repo.getScheduleGroups().asStream())
          .map<dynamic>((items) => ItemsLoaded(items))
          .onErrorReturnWith((e) {
        print("LoadEpic error $e");
        return LoadItemsError();
      }).startWith(LoadItemsStarted());
    });
  }
}
