import 'dart:async';

import 'package:crmit_schedule/state.dart';

class LoadItems {}

class LoadItemsStarted {}

class LoadItemsError {}

class ItemsLoaded {
  final ScheduleInitialModel model;

  ItemsLoaded(this.model);
}

class RefreshItems {
  final Completer<void> completer = Completer<void>();
}

class RefreshError {}
