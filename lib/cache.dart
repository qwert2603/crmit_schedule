import 'dart:convert';
import 'dart:io';

import 'package:crmit_schedule/entity.dart';
import 'package:crmit_schedule/repo.dart';

class Cache {
  static const FILE_NAME_TEACHERS = "teachers.json";
  static const FILE_NAME_SCHEDULE = "schedule.json";

  Future<List<Teacher>> getTeachersList() async {
    final List list = json.decode((await _fileTeachers()).readAsStringSync());
    return list.map((q) => Teacher.fromJson(q)).toList();
  }

  Future<void> saveTeachersList(List<Teacher> teachers) async {
    final file = await _fileTeachers();
    _deleteIfExist(file);
    file.writeAsStringSync(json.encode(teachers));
  }

  Future<void> clearTeachers() async {
    _deleteIfExist(await _fileTeachers());
  }

  Future<List<ScheduleGroup>> getSchedule(int teacherId) async {
    final List list = json.decode((await _fileSchedule()).readAsStringSync());
    return list
        .map((q) => ScheduleGroup.fromJson(q))
        .where((g) => teacherId == 0 || g.teacherId == teacherId)
        .toList();
  }

  Future<void> saveSchedule(List<ScheduleGroup> schedule) async {
    final file = await _fileSchedule();
    _deleteIfExist(file);
    file.writeAsStringSync(json.encode(schedule));
  }

  Future<void> clearSchedule() async {
    _deleteIfExist(await _fileSchedule());
  }

  Future<File> _fileTeachers() async =>
      File("${(await _getCacheDir()).path}/$FILE_NAME_TEACHERS");

  Future<File> _fileSchedule() async =>
      File("${(await _getCacheDir()).path}/$FILE_NAME_SCHEDULE");

  // Directory("/home/alex/StudioProjects/crmit_schedule/crmit_schedule/lib");
  Future<Directory> _getCacheDir() async {
    final String path = await schedulePlatform.invokeMethod("getCacheDir");
    final directory = Directory(path);
    directory.createSync(recursive: true);
    return directory;
  }

  static void _deleteIfExist(File file) {
    if (file.existsSync()) file.deleteSync();
  }
}

void main() async {
  final repo = Repo();
  final cache = Cache();

  final schedule = await repo.getScheduleGroups();
  final teachers = await repo.getTeachersList();

  cache.saveSchedule(schedule);
  cache.saveTeachersList(teachers);

  print(await cache.getTeachersList());
  print(await cache.getSchedule(0));
  print(await cache.getSchedule(1));
  print(await cache.getSchedule(2));
  print(await cache.getSchedule(3));
}
