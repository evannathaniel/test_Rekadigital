class Wilayah {
  String id;
  String kota;

  Wilayah({required this.id, required this.kota});

  factory Wilayah.fromJson(Map<String, dynamic> json) {
    return Wilayah(
      id: json['id'],
      kota: json['kota'],
    );
  }
}

var listWilayah = <Wilayah>[];
