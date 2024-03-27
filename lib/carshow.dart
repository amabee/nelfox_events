import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nelfox_events/link.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart' as file_picker;
import 'package:nelfox_events/participant_detail.dart';

class CarShow extends StatefulWidget {
  final String eventName;
  final String eventDate;
  final String eventVenue;
  final int event_id;
  CarShow(
      {Key? key,
      required this.eventName,
      required this.eventVenue,
      required this.eventDate,
      required this.event_id})
      : super(key: key);

  @override
  State<CarShow> createState() => _CarShowState();
}

class _CarShowState extends State<CarShow> {
  Future<List<dynamic>?>? eventsFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      eventsFuture = getPartipants(widget.event_id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.eventName} Details"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple[200],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddParticipantsDialog(context);
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            child: SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Event Name: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          widget.eventName,
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Event Date: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          widget.eventDate,
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Event Venue: ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          widget.eventVenue,
                          style: TextStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SizedBox(
              height: 400,
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
                              "CAR SHOW PARTICIPANTS:",
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
                                            builder: (context) =>
                                                ParticipantDetail(
                                              pname: events![index]
                                                  ['participant_name'],
                                              pcar: events![index]
                                                  ['participant_car'],
                                              cmodel: events![index]
                                                  ['car_model'],
                                              ctype: events![index]['car_type'],
                                              ryear: events![index]
                                                  ['release_year'],
                                              carimage: events![index]
                                                  ['car_image'],
                                            ),
                                          ),
                                        );
                                      },
                                      title: Text(
                                        "Participant Name: ${events![index]['participant_name']}",
                                      ),
                                      subtitle: Text(
                                        "Participant Car: ${events![index]['participant_car']}",
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Center(
                                child: Text('No participants found'),
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

  showAddParticipantsDialog(BuildContext context) {
    TextEditingController pname = TextEditingController();
    TextEditingController pcar = TextEditingController();
    TextEditingController ctype = TextEditingController();
    TextEditingController cmodel = TextEditingController();
    TextEditingController ryear = TextEditingController();

    File? imageFile;

    Future<void> pickImage() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowCompression: true,
      );

      if (result != null) {
        imageFile = File(result.files.single.path!);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Recipe'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: pname,
                  decoration: InputDecoration(labelText: 'Participant Name'),
                ),
                TextFormField(
                  controller: pcar,
                  decoration: InputDecoration(labelText: 'Participant Car'),
                ),
                TextFormField(
                  controller: ctype,
                  decoration: InputDecoration(labelText: 'Car Type'),
                ),
                TextFormField(
                  controller: cmodel,
                  decoration: InputDecoration(labelText: 'Car Model'),
                ),
                TextFormField(
                  controller: ryear,
                  decoration: InputDecoration(labelText: 'Release Year'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[400], elevation: 2),
                  onPressed: () async {
                    await pickImage();
                  },
                  child: Text(
                    'Car Image',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            SizedBox(
              height: 3,
            ),
            ElevatedButton(
              onPressed: () {
                if (imageFile != null) {
                  String imageName = imageFile!.path.split('/').last;
                  addParticipant(pname.text, pcar.text, ctype.text, cmodel.text,
                      ryear.text, widget.event_id, imageName, imageFile);
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void addParticipant(
    String pname,
    String pcar,
    String ctype,
    String cmodel,
    String ryear,
    int eid,
    String imageName,
    File? imageFile,
  ) async {
    final Map<String, dynamic> json = {
      "participant_name": pname,
      "participant_car": pcar,
      "car_type": ctype,
      "car_model": cmodel,
      "release_year": ryear,
      "event_id": eid,
      "image_name": imageName,
    };

    final Map<String, String> queryParams = {
      "operation": "addparticipants",
      "json": jsonEncode(json),
    };

    Links link = Links();

    var request = http.MultipartRequest('POST', Uri.parse(link.link));

    if (imageFile != null) {
      request.files.add(
        http.MultipartFile(
          'car_image', // Adjust the field name here
          imageFile.readAsBytes().asStream(),
          imageFile.lengthSync(),
          filename: imageName,
        ),
      );
    }

    request.fields.addAll(queryParams);

    var response = await request.send();

    try {
      if (response.statusCode == 200) {
        var res = await response.stream.bytesToString();

        var decodedResponse = jsonDecode(res);
        if (decodedResponse == "0") {
          print("Something went wrong");
        } else {
          setState(() {
            eventsFuture = getPartipants(eid);
          });
          print("Added Participant");
        }
      }
    } catch (error) {
      print(error);
    }
  }

  Future<List<dynamic>?> getPartipants(int event_id) async {
    Links link = Links();

    final Map<String, dynamic> json = {"event_id": event_id};
    final query = {
      "operation": "getparticipants",
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
}
