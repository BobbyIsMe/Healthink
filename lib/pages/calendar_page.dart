import 'package:flutter/material.dart';
import 'package:healthink/database/database_helper.dart';
import 'package:healthink/pages/about_page.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:healthink/pages/meal_planner_page.dart';

const List months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December'
];

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int index = 0;
  List<Widget> pages = const [CalendarTablePage(), AboutPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Healthink"),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 30,
        ),
        backgroundColor: Colors.green,
      ),
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      backgroundColor: const Color.fromARGB(255, 240, 236, 236),
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.green,
          onTap: (value) {
            setState(() {
              index = value;
            });
          },
          currentIndex: index,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_calendar),
              label: "Calendar",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: "About",
            ),
          ]),
    );
  }
}

class CalendarTablePage extends StatefulWidget {
  const CalendarTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarTableState();
}

class _CalendarTableState extends State<CalendarTablePage> {
  late Future<Map<String, MarkerPlanner>?> progressList;

  @override
  void initState() {
    progressList = updateProgress();
    super.initState();
  }

  Future<Map<String, MarkerPlanner>?> updateProgress() async {
    return await DatabaseHelper.instance.getAllProgress();
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Center(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                        height: 570,
                        width: double.infinity,
                        color: Colors.white,
                        child: FutureBuilder<Map<String, MarkerPlanner>?>(
                            future: progressList,
                            builder: (context,
                                AsyncSnapshot<Map<String, MarkerPlanner>?>
                                    snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator(
                                  color: Colors.green,
                                ));
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text(snapshot.error.toString()));
                              }
                              Map<String, MarkerPlanner> progress;
                              if (snapshot.data == null) {
                                progress = {};
                              } else {
                                progress = snapshot.data!;
                              }

                              return TableCalendar(
                                rowHeight: 80,
                                sixWeekMonthsEnforced: true,
                                calendarStyle: const CalendarStyle(
                                  selectedDecoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle),
                                  markersAlignment: Alignment.bottomRight,
                                ),
                                calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, day, events) {
                                    MarkerPlanner? m = progress[
                                        '_${DateFormat("MMddyy").format(day)}'];
                                    if (m == null) {
                                      return null;
                                    } else {
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Center(
                                              child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                if (m.complete > 0)
                                                  Container(
                                                    width: 20,
                                                    height: 20,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: Colors.lightGreen,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Text(
                                                      '${m.complete}',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                if (m.incomplete == 0 ||
                                                    m.complete == 0)
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                      bottom: 20,
                                                    ),
                                                    width: 15,
                                                    height: 15,
                                                  ),
                                                if (m.incomplete > 0)
                                                  Container(
                                                    width: 20,
                                                    height: 20,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Text(
                                                      '${m.incomplete}',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13),
                                                    ),
                                                  )
                                              ])));
                                    }
                                  },
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: const TextStyle(fontSize: 20),
                                  titleTextFormatter: (date, locale) {
                                    return '${DateFormat.MMMM(locale).format(date)} ${DateFormat.y(locale).format(date)}\nSelect Date';
                                  },
                                ),
                                availableGestures: AvailableGestures.all,
                                selectedDayPredicate: (day) =>
                                    isSameDay(day, today),
                                focusedDay: today,
                                firstDay: DateTime.utc(2020, 10, 16),
                                lastDay: DateTime.utc(2030, 3, 14),
                                onDaySelected: (day, focusedDay) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => UserMP(
                                                month: months[day.month - 1],
                                                day: day.day.toString(),
                                                year: day.year.toString(),
                                                date:
                                                    '_${DateFormat("MMddyy").format(day)}',
                                              ))).then((value) => setState(() {
                                        progressList = updateProgress();
                                      }));
                                },
                              );
                            }))))
          ],
        ));
  }
}
