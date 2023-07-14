import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late ValueNotifier<DateTime> _selectedDate;
  late DateTime _focusedDay;
  late DateTime _firstDay;
  late DateTime _lastDay;

  @override
  void initState() {
    super.initState();
    _selectedDate = ValueNotifier<DateTime>(DateTime.now());
    _focusedDay = DateTime.now();
    _firstDay = DateTime(DateTime.now().year - 1);
    _lastDay = DateTime(DateTime.now().year + 1);
  }

  @override
  void dispose() {
    _selectedDate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        backgroundColor: Colors.blue[600],
      ),
      body: SafeArea(
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: _firstDay,
              lastDay: _lastDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate.value, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate.value = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
