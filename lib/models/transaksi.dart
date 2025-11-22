class Transaksi {
  final String id;
  final String idObat;
  final String namaObat;
  final String kategoriObat;
  final String gambarObat;
  final String namaPembeli;
  final int jumlah;
  final double hargaSatuan;
  final double totalHarga;
  final DateTime tanggalPembelian;
  final String? catatan;
  final String metodePembelian;
  final String? nomorResep;
  String status;

  Transaksi({
    required this.id,
    required this.idObat,
    required this.namaObat,
    required this.kategoriObat,
    required this.gambarObat,
    required this.namaPembeli,
    required this.jumlah,
    required this.hargaSatuan,
    required this.totalHarga,
    required this.tanggalPembelian,
    this.catatan,
    required this.metodePembelian,
    this.nomorResep,
    this.status = 'selesai',
  });

  Map<String, dynamic> keJson() {
    return {
      'id': id,
      'idObat': idObat,
      'namaObat': namaObat,
      'kategoriObat': kategoriObat,
      'gambarObat': gambarObat,
      'namaPembeli': namaPembeli,
      'jumlah': jumlah,
      'hargaSatuan': hargaSatuan,
      'totalHarga': totalHarga,
      'tanggalPembelian': tanggalPembelian.toIso8601String(),
      'catatan': catatan,
      'metodePembelian': metodePembelian,
      'nomorResep': nomorResep,
      'status': status,
    };
  }

  factory Transaksi.dariJson(Map<String, dynamic> json) {
    return Transaksi(
      id: json['id'],
      idObat: json['idObat'],
      namaObat: json['namaObat'],
      kategoriObat: json['kategoriObat'],
      gambarObat: json['gambarObat'],
      namaPembeli: json['namaPembeli'],
      jumlah: json['jumlah'],
      hargaSatuan: json['hargaSatuan'].toDouble(),
      totalHarga: json['totalHarga'].toDouble(),
      tanggalPembelian: DateTime.parse(json['tanggalPembelian']),
      catatan: json['catatan'],
      metodePembelian: json['metodePembelian'],
      nomorResep: json['nomorResep'],
      status: json['status'] ?? 'selesai',
    );
  }

  Transaksi salin({
    String? id,
    String? idObat,
    String? namaObat,
    String? kategoriObat,
    String? gambarObat,
    String? namaPembeli,
    int? jumlah,
    double? hargaSatuan,
    double? totalHarga,
    DateTime? tanggalPembelian,
    String? catatan,
    String? metodePembelian,
    String? nomorResep,
    String? status,
  }) {
    return Transaksi(
      id: id ?? this.id,
      idObat: idObat ?? this.idObat,
      namaObat: namaObat ?? this.namaObat,
      kategoriObat: kategoriObat ?? this.kategoriObat,
      gambarObat: gambarObat ?? this.gambarObat,
      namaPembeli: namaPembeli ?? this.namaPembeli,
      jumlah: jumlah ?? this.jumlah,
      hargaSatuan: hargaSatuan ?? this.hargaSatuan,
      totalHarga: totalHarga ?? this.totalHarga,
      tanggalPembelian: tanggalPembelian ?? this.tanggalPembelian,
      catatan: catatan ?? this.catatan,
      metodePembelian: metodePembelian ?? this.metodePembelian,
      nomorResep: nomorResep ?? this.nomorResep,
      status: status ?? this.status,
    );
  }
}
