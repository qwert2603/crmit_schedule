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

  List<DayOfWeek> _schedule;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final schedule = await repo.getScheduleGroups();
    setState(() => _schedule = schedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("crmit_schedule"),
      ),
      body: _schedule == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: _schedule.length,
                  itemBuilder: (context, i) => _buildDayOfWeek(_schedule[i]),
                ),
              ),
              onRefresh: _loadSchedule),
    );
  }

  Widget _buildDayOfWeek(DayOfWeek dayOfWeek) {
    var scheduleGroups = dayOfWeek.scheduleGroups
        .where((s) => s is ScheduleGroup && s.dayOfWeek == dayOfWeek.dayOfWeek)
        .map((s) => InkWell(
              onTap: () => print("onTap $s"),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "${s.time ?? "без 🕑"} ${s.groupName}",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.keyboard_arrow_right),
                  ],
                ),
              ),
            ));

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              DAYS_OF_WEEK_NAMES[dayOfWeek.dayOfWeek],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ]..addAll(scheduleGroups),
      ),
    );
  }
}
