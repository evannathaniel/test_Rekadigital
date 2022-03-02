import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
        primarySwatch: Colors.blue,
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
  var dropdownValue;
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
    print(wilayah);
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
    dropdownValue = listWilayah.asMap()[0];
    bacaDataCuaca();
  }

  Image gambar(String id) {
    if (id == '0') {
      return Image.asset("assets/images/cerah.jpg");
    } else if (id == '1' || id == '2') {
      return Image.asset("assets/images/cerah_berawan.jpg");
    } else if (id == '3' || id == '4') {
      return Image.asset("assets/images/berawan.jpg");
    } else if (id == '5') {
      return Image.asset("assets/images/udara_kabur.jpg");
    } else if (id == '10' || id == '45') {
      return Image.asset("assets/images/kabut.jpg");
    } else if (id == '60' || id == '65') {
      return Image.asset("assets/images/hujan_ringan.jpg");
    } else {
      return Image.asset("assets/images/hujan_deras.jpg");
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
                padding: EdgeInsets.all(10),
                child: Text(sekarang!.suhu, style: TextStyle(fontSize: 32))),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(sekarang.nama),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(sekarang.waktu.toString()),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                  constraints: BoxConstraints(maxHeight: 300, minHeight: 100),
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(sekarang.nama),
                  )),
            ),
          ],
        ),
      );
    } else {
      return Text("kosong");
    }
  }

  Widget showAll() {
    if (listWeather.length > 0) {
      return ListView.builder(
          itemCount: listWeather.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return new Card(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(listWeather[index].waktu.hour.toString()),
                    Container(
                      constraints:
                          BoxConstraints(maxHeight: 100, minHeight: 50),
                      child: gambar(listWeather[index].cuaca),
                    ),
                    Text(
                      listWeather[index].suhu,
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
                        });
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
                Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height / 1.7,
                      minHeight: 100),
                  child: showAll(),
                ),
              ],
            ),
          ]),
        ));
  }
}
