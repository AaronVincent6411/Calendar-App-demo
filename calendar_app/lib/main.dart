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
  final ValueNotifier<DateTime> _selectedDate = ValueNotifier<DateTime>(DateTime.now());
  final DateTime _focusedDay = DateTime.now();
  final DateTime _firstDay = DateTime(DateTime.now().year - 1);
  final DateTime _lastDay = DateTime(DateTime.now().year + 1);

  Map<DateTime, List<Event>> _events = {};

  Future<void> _addEvent() async {
    Event? newEvent = await showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime selectedDate = _selectedDate.value;
        String eventName = '';
        TimeOfDay eventTime = TimeOfDay.now();

        return AlertDialog(
          title: Text('Add Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Event Name'),
                onChanged: (value) {
                  eventName = value;
                },
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: eventTime,
                    builder: (BuildContext context, Widget? child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                        child: child!,
                      );
                    },
                  );
                  if (pickedTime != null) {
                    setState(() {
                      eventTime = pickedTime;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Event Time',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${eventTime.format(context)}'),
                      Icon(Icons.access_time),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(Event(
                  date: selectedDate,
                  title: eventName,
                  description: '',
                  eventTime: eventTime,
                ));
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );

    if (newEvent != null) {
      _addEventToCalendar(newEvent);
      // Update the selected date to the date of the newly added event.
      setState(() {
        _selectedDate.value = newEvent.date;
      });
    }
  }

  void _addEventToCalendar(Event event) {
    setState(() {
      if (_events[event.date] == null) {
        _events[event.date] = [event];
      } else {
        _events[event.date]!.add(event);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Calendar'),
      backgroundColor: Colors.blue[600],
    ),
    body: SafeArea(
      child: Stack( // Wrap everything in a Stack
        children: [
          Column(
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
                });
              },
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, focused) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
              Expanded(
                child: ListView(
                children: _events[_selectedDate.value] != null
                    ? _events[_selectedDate.value]!
                        .map((event) => ListTile(
                              title: Text(event.title),
                              subtitle: Text(event.eventTime.format(context)),
                            ))
                        .toList()
                    : [],
              ),
              ),
            ],
          ),
          Positioned( // Position the GestureDetector
            bottom: 16, // Adjust the position as needed
            right: 16, // Adjust the position as needed
            child: GestureDetector(
              onTap: _addEvent, 
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent, 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(16), 
                child: Icon(
                  Icons.calendar_today,
                  size: 30, 
                  color: Colors.white, 
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
 }
}


class Event {
  final DateTime date;
  final String title;
  final String description;
  final TimeOfDay eventTime;

  Event({
    required this.date,
    required this.title,
    required this.description,
    required this.eventTime,
  });
}

extension TimeOfDayExtension on TimeOfDay {
  String format(BuildContext context) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, hour, minute);
    // final format = MediaQuery.of(context).alwaysUse24HourFormat ? 'HH:mm' : 'hh:mm a';
    return TimeOfDay.fromDateTime(dateTime).format(context);
  }
}
