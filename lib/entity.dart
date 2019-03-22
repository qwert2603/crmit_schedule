import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'entity.g.dart';

@immutable
@JsonSerializable()
class ScheduleGroup {
  final int id;
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
class DayOfWeek {
  final int dayOfWeek;

  final List<ScheduleGroup> scheduleGroups;

  DayOfWeek(this.dayOfWeek, this.scheduleGroups);

  @override
  String toString() {
    return 'DayOfWeek{dayOfWeek: $dayOfWeek, scheduleGroups: $scheduleGroups}';
  }
}

@immutable
@JsonSerializable()
class Teacher {
  final int id;
  final String fio;

  const Teacher(this.id, this.fio);

  factory Teacher.fromJson(Map<String, dynamic> json) =>
      _$TeacherFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherToJson(this);

  @override
  String toString() {
    return 'Teacher{id: $id, fio: $fio}';
  }
}

// flutter packages pub run build_runner build
