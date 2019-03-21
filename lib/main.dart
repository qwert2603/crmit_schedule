import 'package:crmit_schedule/const.dart';
import 'package:crmit_schedule/entity.dart';
import 'package:crmit_schedule/repo.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'crmit_schedule',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final repo = Repo();

  List<ScheduleListItem> _scheduleItems;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  void _loadSchedule() async {
    final schedule = await repo.getScheduleGroups();
    setState(() => _scheduleItems = schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("crmit_schedule"),
      ),
      body: _scheduleItems == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Scrollbar(
              child: ListView.builder(
                itemCount: _scheduleItems.length,
                itemBuilder: (context, i) =>
                    _buildScheduleItem(_scheduleItems[i]),
              ),
            ),
    );
  }

  Widget _buildScheduleItem(ScheduleListItem scheduleListItem) {
    if (scheduleListItem is ScheduleGroup) {
      return InkWell(
        onTap: () => print("onTap $scheduleListItem"),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "${scheduleListItem.time ?? "без 🕑"} ${scheduleListItem.groupName}",
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }
    if (scheduleListItem is DayOfWeek) {
      return Card(
        margin: EdgeInsets.all(12),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            DAYS_OF_WEEK_NAMES[scheduleListItem.dayOfWeek],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      );
    }
    throw Exception("unknown ScheduleListItem $scheduleListItem");
  }
}
