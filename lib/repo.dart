import 'dart:convert';

import 'package:crmit_schedule/cache.dart';
import 'package:crmit_schedule/entity.dart';
import 'package:crmit_schedule/state.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

const schedulePlatform = const MethodChannel('app.channel.schedule');

class Repo {
  final Cache _cache;

  final String _baseUrl;

  Repo(this._cache, this._baseUrl);

  void navigateToGroup(ScheduleGroup scheduleGroup) {
    schedulePlatform.invokeMethod("navigateToGroup", {
      "groupId": scheduleGroup.groupId,
      "groupName": scheduleGroup.groupName,
    });
  }

  Future<ScheduleInitialModel> getScheduleInitialModel(
      int teacherId, bool allowCache) {
    return getAuthedTeacherIdOrZero().then((authedTeacherId) {
      teacherId = teacherId ?? authedTeacherId;
      return Future.wait([
        getTeachersList(),
        getScheduleGroups(),
      ]).then((list) async {
        List<Teacher> teachers = list[0];
        List<ScheduleGroup> scheduleGroups = list[1];
        await _cache.saveSchedule(scheduleGroups);
        await _cache.saveTeachersList(teachers);
        final List<DayOfWeek> makeSchedule = _makeSchedule(scheduleGroups
            .where((g) => teacherId == 0 || g.teacherId == teacherId)
            .toList());
        return ScheduleInitialModel(
          false,
          teachers,
          makeSchedule,
          authedTeacherId,
        );
      }).catchError((e) {
        if (allowCache) {
          print("getScheduleInitialModel $e");
          return Future.wait([
            _cache.getTeachersList(),
            _cache.getSchedule(teacherId),
          ]).then((list) {
            return ScheduleInitialModel(
              true,
              list[0],
              _makeSchedule(list[1]),
              authedTeacherId,
            );
          });
        } else {
          throw e;
        }
      });
    });
  }

  Future<List<ScheduleGroup>> getScheduleGroups() async {
    final String url = await _addAccessToken("${_baseUrl}schedule");
    final http.Response response = await http.get(url);
    _checkStatusCode(response);
    final List list = json.decode(response.body);
    return list.map((q) => ScheduleGroup.fromJson(q)).toList();
  }

  Future<List<Teacher>> getTeachersList() async {
    final String url = await _addAccessToken("${_baseUrl}teachers_list");
    final http.Response response = await http.get(url);
    _checkStatusCode(response);
    final List list = json.decode(response.body);
    return list.map((q) => Teacher.fromJson(q)).toList();
  }

  Future<int> getAuthedTeacherIdOrZero() async =>
      schedulePlatform.invokeMethod("getAuthedTeacherIdOrZero");

  void _checkStatusCode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) {
        schedulePlatform.invokeMethod("on401");
      }
      throw Exception("response.statusCode == ${response.statusCode}");
    }
  }

  Future<String> _addAccessToken(String url) async =>
      "$url${url.contains('?') ? "&" : "?"}access_token=${await _getAccessToken()}";

  Future<String> _getAccessToken() =>
      schedulePlatform.invokeMethod("getAccessToken");

  List<DayOfWeek> _makeSchedule(List<ScheduleGroup> scheduleGroups) {
    final List<DayOfWeek> result = [];
    for (final scheduleGroup in scheduleGroups) {
      if (result.isEmpty || scheduleGroup.dayOfWeek != result.last.dayOfWeek) {
        result.add(DayOfWeek(scheduleGroup.dayOfWeek, []));
      }
      result.last.scheduleGroups.add(scheduleGroup);
    }
    return result;
  }
}

void main() async {
  final repo = Repo(Cache(), "http://192.168.1.26:1918/api/v1.1.0");

  final schedule = await repo.getScheduleGroups();
  for (final s in schedule) {
    print(s);
  }

  final teachers = await repo.getTeachersList();
  for (final t in teachers) {
    print(t);
  }

//  await repo.getScheduleInitialModel(1, true);
}
