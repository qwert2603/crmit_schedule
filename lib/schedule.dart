import 'package:crmit_schedule/actions.dart';
import 'package:crmit_schedule/const.dart';
import 'package:crmit_schedule/entity.dart';
import 'package:crmit_schedule/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class _ScheduleViewModel {
  final LrState schedule;
  final void Function() onRetry;

  _ScheduleViewModel.fromStore(Store<ScheduleViewState> store)
      : this(store.state.schedule, () => store.dispatch(LoadItems()));

  _ScheduleViewModel(this.schedule, this.onRetry);

  @override
  String toString() {
    return '_ScheduleViewModel{schedule: $schedule, onRetry: $onRetry}';
  }
}

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("crmit_schedule"),
      ),
      body: StoreConnector<ScheduleViewState, _ScheduleViewModel>(
        converter: (store) => _ScheduleViewModel.fromStore(store),
        builder: (BuildContext context, _ScheduleViewModel vm) {
          print("ScheduleScreen builder $vm");
          final schedule = vm.schedule;
          if (schedule is Nth) return Container();
          if (schedule is Loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (schedule is LoadingError) {
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
          if (schedule is Loaded<List<DayOfWeek>>) {
            return Scrollbar(
              child: ListView.builder(
                itemCount: schedule.data.length,
                itemBuilder: (BuildContext context, int i) =>
                    _buildDayOfWeek(schedule.data[i]),
              ),
            );
          }
          throw Exception("unknown lrState $vm.schedule");
        },
      ),
    );
  }

  Widget _buildDayOfWeek(DayOfWeek dayOfWeek) {
    const textStyle = TextStyle(
      fontFamily: "google_sans",
      fontSize: 16,
      color: Colors.black,
    );

    final scheduleGroups = dayOfWeek.scheduleGroups
        .where((s) => s is ScheduleGroup && s.dayOfWeek == dayOfWeek.dayOfWeek)
        .map((s) => InkWell(
              onTap: () => print("onTap $s"),
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
                            color: Colors.black.withOpacity(0.65),
                          ),
                        ),
                        TextSpan(text: " "),
                        TextSpan(text: s.groupName, style: textStyle),
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
        side: BorderSide(),
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
