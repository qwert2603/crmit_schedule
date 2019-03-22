import 'package:crmit_schedule/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class RefreshErrorSnackbar extends StatelessWidget {
  final void Function() onRetryRefresh;

  RefreshErrorSnackbar(this.onRetryRefresh);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<ScheduleViewState, RefreshErrorSnackbarVM>(
      converter: (store) => RefreshErrorSnackbarVM.fromStore(store),
      builder: (BuildContext context, vm) => Container(),
      distinct: true,
      onWillChange: (vm) {
        if (vm.refreshError) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text("Ошибка обновления!"),
            duration: Duration(seconds: 2),
            action: SnackBarAction(
              label: "Повторить загрузку",
              onPressed: onRetryRefresh,
            ),
          ));
        }
      },
    );
  }
}

class RefreshErrorSnackbarVM {
  final bool refreshError;

  RefreshErrorSnackbarVM(this.refreshError);

  RefreshErrorSnackbarVM.fromStore(Store<ScheduleViewState> store)
      : this(store.state.refreshError);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefreshErrorSnackbarVM &&
          runtimeType == other.runtimeType &&
          refreshError == other.refreshError;

  @override
  int get hashCode => refreshError.hashCode;
}
