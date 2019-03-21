import 'dart:convert';

import 'package:crmit_schedule/const.dart';
import 'package:crmit_schedule/entity.dart';
import 'package:http/http.dart' as http;

class Repo {
  Future<List<DayOfWeek>> getScheduleGroups() async {
    final url = _addAccessToken("$BASE_URL$API_PREFIX/schedule");
    final http.Response response = await http.get(url);
    _checkStatusCode(response);
    final List list = json.decode(response.body);
    final scheduleGroups = list.map((q) => ScheduleGroup.fromJson(q)).toList();
    return _makeSchedule(scheduleGroups);
  }

  void _checkStatusCode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("response.statusCode == ${response.statusCode}");
    }
  }

  String _addAccessToken(String url) =>
      "$url?access_token=${_getAccessToken()}";

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
  final schedule = await repo.getScheduleGroups();
  for (final s in schedule) {
    print(s);
  }
}
