import 'dart:ui';

import 'package:crmit_schedule/actions.dart';
import 'package:crmit_schedule/epics.dart';
import 'package:crmit_schedule/reducer.dart';
import 'package:crmit_schedule/repo.dart';
import 'package:crmit_schedule/schedule.dart';
import 'package:crmit_schedule/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';
import 'package:redux_epics/redux_epics.dart';

void main() {
  final repo = Repo();

  final store = DevToolsStore<ScheduleViewState>(
    ScheduleReducer(),
    initialState: ScheduleViewState(Nth(), false, null),
    middleware: [
      EpicMiddleware<ScheduleViewState>(LoadEpic(repo)),
      EpicMiddleware<ScheduleViewState>(RefreshEpic(repo)),
      NavigationMiddleware(repo),
    ],
  );

  runApp(MyApp(
    store: store,
    isRootScreen: window.defaultRouteName == "root",
  ));
}

class MyApp extends StatelessWidget {
  final Store<ScheduleViewState> store;
  final bool isRootScreen;

  const MyApp({Key key, @required this.store, @required this.isRootScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<ScheduleViewState>(
      store: store,
      child: StoreBuilder<ScheduleViewState>(
        onInit: (store) => store.dispatch(LoadItems()),
        builder: (context, store) => MaterialApp(
              title: 'Расписание',
              theme: ThemeData(
                primarySwatch: Colors.red,
                scaffoldBackgroundColor: Colors.white,
                fontFamily: "google_sans",
              ),
              home: ScheduleScreen(
                appBarLeading:
                    isRootScreen ? Icons.menu : Icons.arrow_back,
              ),
            ),
      ),
    );
  }
}
