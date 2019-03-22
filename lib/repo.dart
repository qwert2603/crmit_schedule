import 'dart:convert';

import 'package:crmit_schedule/cache.dart';
import 'package:crmit_schedule/const.dart';
import 'package:crmit_schedule/entity.dart';
import 'package:crmit_schedule/state.dart';
import 'package:http/http.dart' as http;

class Repo {
  final Cache _cache = Cache();

  Future<ScheduleInitialModel> getScheduleInitialModel(
      int teacherId, bool allowCache) {
    return getAuthedTeacherIdOrZero().then((authedTeacherId) {
      teacherId = teacherId ?? authedTeacherId;
      return Future.wait([
        getTeachersList(),
        getScheduleGroups(teacherId),
      ]).then((list) async {
        List<Teacher> teachers = list[0];
        List<DayOfWeek> schedule = list[1];
        await _cache.saveSchedule(schedule
            .map((dow) => dow.scheduleGroups)
            .fold([], (l1, l2) => l1 + l2));
        await _cache.saveTeachersList(teachers);
        return ScheduleInitialModel(
          false,
          teachers,
          schedule,
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

  Future<List<DayOfWeek>> getScheduleGroups(int teacherId) async {
    final url = _addAccessToken(
        "$BASE_URL$API_PREFIX/schedule${teacherId != null ? "?teacherId=$teacherId" : ""}");
    final http.Response response = await http.get(url);
    _checkStatusCode(response);
    final List list = json.decode(response.body);
    final scheduleGroups = list.map((q) => ScheduleGroup.fromJson(q)).toList();
    return _makeSchedule(scheduleGroups);
  }

  Future<List<Teacher>> getTeachersList() async {
    final url = _addAccessToken("$BASE_URL$API_PREFIX/teachers_list");
    final http.Response response = await http.get(url);
    _checkStatusCode(response);
    final List list = json.decode(response.body);
    return list.map((q) => Teacher.fromJson(q)).toList();
  }

  Future<int> getAuthedTeacherIdOrZero() async {
    return 1;
  }

  void _checkStatusCode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("response.statusCode == ${response.statusCode}");
    }
  }

  String _addAccessToken(String url) =>
      "$url${url.contains('?') ? "&" : "?"}access_token=${_getAccessToken()}";

  String _getAccessToken() => "ac28bd98-afc4-4310-90ee-017515a636ba";

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
  final repo = Repo();

  final schedule = await repo.getScheduleGroups(1);
  for (final s in schedule) {
    print(s);
  }

  final teachers = await repo.getTeachersList();
  for (final t in teachers) {
    print(t);
  }

//  await repo.getScheduleInitialModel(1, true);
}
