


class Weather{
  DateTime waktu;
  String cuaca;
  String suhu;
  String nama;
  
  
  Weather({required this.waktu,required this.cuaca,
  required this.suhu,required this.nama});
  
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
        waktu: DateTime.parse(json['jamCuaca']),
        cuaca: json['kodeCuaca'],
        suhu:json['tempC'],
        nama: json['cuaca']
       ); 
  }
}


var listWeather = <Weather>[];
var listWeatherHariIni = <Weather>[];
var listWeatherBesok = <Weather>[];