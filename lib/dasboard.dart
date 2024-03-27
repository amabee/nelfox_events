import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nelfox_events/carshow.dart';
import 'package:nelfox_events/link.dart';

class Dashboard extends StatefulWidget {
  final String username;

  Dashboard({Key? key, required this.username}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<List<dynamic>?>? eventsFuture;
  bool isEmpty = true;
  @override
  void initState() {
    super.initState();
    eventsFuture = getEvents(widget.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NELFOX CAR SHOW EVENTS"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[100],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddEventsDialog(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 200,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: ListTile(
                          title: Center(
                            child: Text(
                              widget.username,
                              style: const TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              height: 380,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: ListTile(
                          title: Center(
                            child: Text(
                              "MY CAR SHOW EVENTS:",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: FutureBuilder<List<dynamic>?>(
                          future: eventsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error: ${snapshot.error}'),
                              );
                            } else if (snapshot.hasData) {
                              List<dynamic>? events = snapshot.data;
                              return ListView.builder(
                                itemCount: events?.length ?? 0,
                                itemBuilder: (context, index) {
                                  return Card(
                                    child: ListTile(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CarShow(
                                              eventName: events[index]
                                                  ['event_name'],
                                              eventVenue: events[index]
                                                  ['event_venue'],
                                              eventDate: events[index]
                                                  ['event_date'],
                                              event_id: events[index]['id'],
                                            ),
                                          ),
                                        );
                                      },
                                      title: Text(events![index]['event_name']),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child: Text('No events found'),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAddEventsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String eventName = '';
        String eventVenue = '';
        return AlertDialog(
          title: Text('Add New Event'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  eventName = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter Event Name',
                ),
              ),
              TextField(
                onChanged: (value) {
                  eventVenue = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Enter Event Venue',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _showEventDate(context, eventName, eventVenue);
              },
              child: Text('Next'),
            ),
          ],
        );
      },
    );
  }

  void _showEventDate(
      BuildContext context, String eventN, String eventV) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      await addEvent(eventN, eventV, pickedDate, widget.username);
      setState(() {
        eventsFuture = getEvents(widget.username);
      });
      Navigator.of(context).pop();
      print('Selected Date: $pickedDate');
    }
  }

  Future<List<dynamic>?> getEvents(String user) async {
    Links link = Links();

    final Map<String, dynamic> json = {"user": user};
    final query = {
      "operation": "getevents",
      "json": jsonEncode(json),
    };

    try {
      final response =
          await http.get(Uri.parse(link.link).replace(queryParameters: query));

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        print("DATA RESPONSE: $res");
        if (res is List && res.isNotEmpty && res[0] is Map<String, dynamic>) {
          return List<dynamic>.from(res);
        } else {
          print("Invalid data format received from API");
          return null;
        }
      }
    } catch (error) {
      print("Runtime Error: $error");
    }
    return null;
  }

  Future<void> addEvent(String event_name, String event_venue,
      DateTime event_date, String creator) async {
    Links link = Links();
    String formattedDate = event_date.toIso8601String();

    final Map<String, dynamic> json = {
      "event_name": event_name,
      "event_venue": event_venue,
      "event_date": formattedDate,
      "creator": creator
    };
    final Map<String, dynamic> query = {
      "operation": "addevent",
      "json": jsonEncode(json)
    };
    try {
      final response = await http.post(Uri.parse(link.link), body: query);
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);
        if (res == "1") {
          print('Added Event!');
        } else {
          print('Something went wrong!');
        }
      } else {
        print('Failed to add event: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error adding last event: $error');
    }
  }
}
