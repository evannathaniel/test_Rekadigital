import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:test_weather/weather.dart';
import 'package:test_weather/wilayah.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch:  Colors.lightBlue,
        scaffoldBackgroundColor: Colors.lightBlue[50],
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var dropdownValue = listWilayah.asMap()[5];
  final today =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  final tomorrow = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);

  String wilayah = "501290";
  Future<String> fetchDataWilayah() async {
    final response = await http.get(
        Uri.parse("https://ibnux.github.io/BMKG-importer/cuaca/wilayah.json"));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaDataWilayah() {
    listWilayah.clear();
    Future<String> data = fetchDataWilayah();
    data.then((value) async {
      List json = jsonDecode(value);
      for (var g in json) {
        Wilayah m = Wilayah.fromJson(g);
        listWilayah.add(m);
      }
      setState(() {});
    });
  }

  Future<String> fetchDataCuaca(String id) async {
    final response = await http.get(Uri.parse(
        "https://ibnux.github.io/BMKG-importer/cuaca/" + id + ".json"));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to read API');
    }
  }

  bacaDataCuaca() {
    listWeather.clear();
    Future<String> data = fetchDataCuaca(wilayah);
    data.then((value) async {
      List json = jsonDecode(value);
      for (var g in json) {
        Weather m = Weather.fromJson(g);
        listWeather.add(m);
      }
      setState(() {});
    });
  }

  void initState() {
    super.initState();
    bacaDataWilayah();

    bacaDataCuaca();
  }

  Image gambar(String id) {
    if (id == '0') {
      return Image.asset("assets/images/cerah.png");
    } else if (id == '1' || id == '2') {
      return Image.asset("assets/images/cerah_berawan.png");
    } else if (id == '3' || id == '4') {
      return Image.asset("assets/images/berawan.jpg");
    } else if (id == '5') {
      return Image.asset("assets/images/udara_kabur.png");
    } else if (id == '10' || id == '45') {
      return Image.asset("assets/images/kabut.png");
    } else if (id == '60' || id == '65') {
      return Image.asset("assets/images/hujan_ringan.png");
    } else {
      return Image.asset("assets/images/hujan_deras.png");
    }
  }

  Widget showSekarang() {
    int selisih = 10;
    Weather? sekarang;
    if (listWeather.length > 0) {
      for (Weather w in listWeather) {
        if ((w.waktu.hour - DateTime.now().hour).abs() < selisih) {
          selisih = (w.waktu.hour - DateTime.now().hour).abs();
          sekarang = w;
        }
      }
      return Center(
        child: ListView(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.all(5),
                child: Text(sekarang!.suhu + "°C",
                    style: TextStyle(fontSize: 32),
                    textAlign: TextAlign.center)),
            Padding(
              padding: EdgeInsets.all(1),
              child: Container(
                child: gambar(sekarang.cuaca),
                constraints: BoxConstraints(maxHeight: 100, minHeight: 50),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5),
              child: Text(
                DateFormat("yyyy-MM-dd kk:mm").format(sekarang.waktu),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(1),
              child: Container(
                  constraints: BoxConstraints(maxHeight: 100, minHeight: 50),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(sekarang.nama, textAlign: TextAlign.center),
                  )),
            ),
          ],
        ),
      );
    } else {
      return Text("kosong");
    }
  }

  Widget showHariIni() {
    listWeatherHariIni.clear();
    if (listWeather.length > 0) {
      for (Weather w in listWeather) {
        if (DateTime(w.waktu.year, w.waktu.month, w.waktu.day) == today) {
          listWeatherHariIni.add(w);
        }
      }
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listWeatherHariIni.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return new Card(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(DateFormat("kk:mm")
                        .format(listWeatherHariIni[index].waktu)),
                    Container(
                      constraints: BoxConstraints(maxHeight: 50, minHeight: 25),
                      child: gambar(listWeatherHariIni[index].cuaca),
                    ),
                    Text(
                      listWeatherHariIni[index].suhu + "°C",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ));
          });
    } else {
      return Text("Empty");
    }
  }

  Widget showBesok() {
    listWeatherBesok.clear();
    if (listWeather.length > 0) {
      for (Weather w in listWeather) {
        if (DateTime(w.waktu.year, w.waktu.month, w.waktu.day) == tomorrow) {
          listWeatherBesok.add(w);
        }
      }
      return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: listWeatherBesok.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return new Card(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(DateFormat("kk:mm")
                        .format(listWeatherBesok[index].waktu)),
                    Container(
                      constraints: BoxConstraints(maxHeight: 50, minHeight: 25),
                      child: gambar(listWeatherBesok[index].cuaca),
                    ),
                    Text(
                      listWeatherBesok[index].suhu + "°C",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ));
          });
    } else {
      return Text("Empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Weather App"),
        ),
        body: Center(
          child: ListView(children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text("Pilih Daerah", textAlign: TextAlign.center)),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: DropdownButton<Wilayah>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.deepPurpleAccent,
                      ),
                      onChanged: (Wilayah? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                          wilayah = dropdownValue!.id;
                        });

                        bacaDataCuaca();
                      },
                      items: listWilayah.map((Wilayah value) {
                        return DropdownMenuItem<Wilayah>(
                          value: value,
                          child: Text(value.kota.toString()),
                        );
                      }).toList(),
                    )),
                Container(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2,
                        minHeight: 100),
                    child: showSekarang()),
                DefaultTabController(
                    length: 2,
                    initialIndex: 0,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            child: TabBar(
                              labelColor: Colors.green,
                              unselectedLabelColor: Colors.black,
                              tabs: [
                                Tab(text: 'Hari Ini'),
                                Tab(text: 'Besok'),
                              ],
                            ),
                          ),
                          Container(
                              height: MediaQuery.of(context).size.height / 3.6,
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          color: Colors.grey, width: 0.5))),
                              child: TabBarView(children: <Widget>[
                                Container(
                                    constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height /
                                                3.7,
                                        minHeight: 100),
                                    child: showHariIni()),
                                Container(
                                    constraints: BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height /
                                                3.7,
                                        minHeight: 100),
                                    child: showBesok()),
                              ]))
                        ])),
              ],
            ),
          ]),
        ));
  }
}
