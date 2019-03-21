import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'entity.g.dart';

abstract class ScheduleListItem {
  final int dayOfWeek;

  ScheduleListItem([this.dayOfWeek]);
}

@immutable
@JsonSerializable()
class ScheduleGroup implements ScheduleListItem {
  final int id;
  @override
  final int dayOfWeek;
  final String time;
  final int groupId;
  final String groupName;
  final int teacherId;

  const ScheduleGroup(this.id, this.dayOfWeek, this.time, this.groupId,
      this.groupName, this.teacherId);

  factory ScheduleGroup.fromJson(Map<String, dynamic> json) =>
      _$ScheduleGroupFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleGroupToJson(this);

  @override
  String toString() {
    return 'ScheduleGroup{id: $id, dayOfWeek: $dayOfWeek, time: $time, groupId: $groupId, groupName: $groupName, teacherId: $teacherId}';
  }
}

@immutable
class DayOfWeek implements ScheduleListItem {
  @override
  final int dayOfWeek;

  const DayOfWeek(this.dayOfWeek);

  @override
  String toString() {
    return 'DayOfWeek{dayOfWeek: $dayOfWeek}';
  }
}

// flutter packages pub run build_runner build
