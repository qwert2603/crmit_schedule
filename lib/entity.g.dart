// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScheduleGroup _$ScheduleGroupFromJson(Map<String, dynamic> json) {
  return ScheduleGroup(
      json['id'] as int,
      json['dayOfWeek'] as int,
      json['time'] as String,
      json['groupId'] as int,
      json['groupName'] as String,
      json['teacherId'] as int);
}

Map<String, dynamic> _$ScheduleGroupToJson(ScheduleGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'dayOfWeek': instance.dayOfWeek,
      'time': instance.time,
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'teacherId': instance.teacherId
    };
