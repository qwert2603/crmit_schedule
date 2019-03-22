import 'dart:async';

import 'package:crmit_schedule/entity.dart';

class LoadItems {}

class LoadItemsStarted {}

class LoadItemsError {}

class ItemsLoaded {
  final List<DayOfWeek> items;

  ItemsLoaded(this.items);
}

class RefreshItems {
  final Completer<void> completer = Completer<void>();
}

class RefreshError {}
