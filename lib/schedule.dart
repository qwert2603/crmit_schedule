import 'package:crmit_schedule/actions.dart';
import 'package:crmit_schedule/const.dart';
import 'package:crmit_schedule/custom_app_bar.dart';
import 'package:crmit_schedule/entity.dart';
import 'package:crmit_schedule/refresh_error_snackbar.dart';
import 'package:crmit_schedule/repo.dart';
import 'package:crmit_schedule/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class _ScheduleViewModel {
  final LrState lrState;
  final int selectedTeacherId;
  final void Function() onRetry;
  final Future<void> Function() onRefresh;
  final void Function(int) onTeacherSelected;
  final void Function(ScheduleGroup) onGroupClicked;

  _ScheduleViewModel.fromStore(Store<ScheduleViewState> store)
      : this(
          store.state.lrState,
          store.state.selectedTeacherId,
          () => store.dispatch(LoadItems()),
          () {
            final refreshItems = RefreshItems();
            store.dispatch(refreshItems);
            return refreshItems.completer.future;
          },
          (teacherId) => store.dispatch(SelectedTeacherChanged(teacherId)),
          (scheduleGroup) => store.dispatch(NavigateToGroup(scheduleGroup)),
        );

  _ScheduleViewModel(this.lrState, this.selectedTeacherId, this.onRetry,
      this.onRefresh, this.onTeacherSelected, this.onGroupClicked);

  @override
  String toString() {
    return '_ScheduleViewModel{lrState: $lrState, selectedTeacherId: $selectedTeacherId, onRetry: $onRetry, onRefresh: $onRefresh, onTeacherSelected: $onTeacherSelected, onGroupClicked: $onGroupClicked}';
  }
}

final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
final _scrollController = ScrollController();

class ScheduleScreen extends StatelessWidget {
  final IconData appBarLeading;

  const ScheduleScreen({Key key, @required this.appBarLeading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        appBar: AppBar(
          title: Text("Расписание"),
          leading: IconButton(
            icon: Icon(appBarLeading),
            onPressed: () =>
                schedulePlatform.invokeMethod("onNavigationIconClicked"),
          ),
        ),
        onTap: () => _scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ),
      ),
      body: StoreConnector<ScheduleViewState, _ScheduleViewModel>(
        converter: (store) => _ScheduleViewModel.fromStore(store),
        builder: (BuildContext context, _ScheduleViewModel vm) {
          print("ScheduleScreen builder $vm");
          final lrState = vm.lrState;
          if (lrState is Nth) return Container();
          if (lrState is Loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (lrState is LoadingError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    "Ошибка",
                    style: TextStyle(color: Colors.red, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  OutlineButton(
                    onPressed: vm.onRetry,
                    child: const Text(
                      "Повторить загрузку",
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  )
                ],
              ),
            );
          }
          if (lrState is Loaded<ScheduleInitialModel>) {
            return Stack(
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    lrState.data.isCached
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 12,
                            ).copyWith(top: 8),
                            child: Text(
                              "Показаны кешированные данные",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ))
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: "Преподаватель",
                          border: const OutlineInputBorder(),
                        ),
                        value: vm.selectedTeacherId ?? 0,
                        items: lrState.data.teachers
                            .map(
                              (teacher) => DropdownMenuItem(
                                    child: Text(teacher.fio),
                                    value: teacher.id,
                                  ),
                            )
                            .toList()
                              ..insert(
                                  0,
                                  DropdownMenuItem(
                                    child: Text("все"),
                                    value: 0,
                                  )),
                        onChanged: vm.onTeacherSelected,
                      ),
                    ),
                    SizedBox(
                      height: 1,
                      child: Container(color: Colors.black26),
                    ),
                    Flexible(
                      child: RefreshIndicator(
                        key: _refreshIndicatorKey,
                        onRefresh: vm.onRefresh,
                        child: lrState.data.schedule.isNotEmpty
                            ? Scrollbar(
                                child: ListView.builder(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  itemCount: lrState.data.schedule.length,
                                  itemBuilder: (BuildContext context, int i) =>
                                      _buildDayOfWeek(
                                        lrState.data.schedule[i],
                                        lrState.data.authedTeacherId,
                                        vm.onGroupClicked,
                                      ),
                                  controller: _scrollController,
                                ),
                              )
                            : ListView(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(24),
                                    child: Center(
                                      child: Text(
                                        "Нет расписания",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
                RefreshErrorSnackbar(
                  () => _refreshIndicatorKey.currentState.show(),
                ),
              ],
            );
          }
          throw Exception("unknown lrState $vm.schedule");
        },
      ),
    );
  }

  Widget _buildDayOfWeek(
    DayOfWeek dayOfWeek,
    int authedTeacherId,
    void Function(ScheduleGroup) onGroupClicked,
  ) {
    const textStyle = TextStyle(
      fontFamily: "google_sans",
      fontSize: 16,
      color: Colors.black,
    );

    final scheduleGroups = dayOfWeek.scheduleGroups
        .where((s) => s is ScheduleGroup && s.dayOfWeek == dayOfWeek.dayOfWeek)
        .map((s) => InkWell(
              onTap: () => onGroupClicked(s),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RichText(
                        text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: s.time ?? "без 🕑",
                          style: textStyle.copyWith(
                            color: Color(0xFF707070),
                          ),
                        ),
                        TextSpan(text: " "),
                        TextSpan(
                          text: s.groupName,
                          style: s.teacherId == authedTeacherId
                              ? textStyle.copyWith(color: Colors.red)
                              : textStyle,
                        ),
                      ],
                    )),
                    const Icon(Icons.keyboard_arrow_right),
                  ],
                ),
              ),
            ));

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.black54),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              DAYS_OF_WEEK_NAMES[dayOfWeek.dayOfWeek],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ]..addAll(scheduleGroups),
      ),
    );
  }
}
