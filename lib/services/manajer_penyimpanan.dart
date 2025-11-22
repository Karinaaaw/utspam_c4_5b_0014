import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pengguna.dart';
import '../models/transaksi.dart';

class ManajerPenyimpanan {
  static const String kunciPengguna = 'daftar_pengguna';
  static const String kunciPenggunaAktif = 'pengguna_aktif';
  static const String kunciTransaksi = 'daftar_transaksi';

  static Future<bool> simpanPengguna(Pengguna pengguna) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> daftarPengguna = prefs.getStringList(kunciPengguna) ?? [];

      for (String dataPengguna in daftarPengguna) {
        Map<String, dynamic> json = jsonDecode(dataPengguna);
        if (json['namaAkun'] == pengguna.namaAkun) {
          return false;
        }
      }

      daftarPengguna.add(jsonEncode(pengguna.keJson()));
      await prefs.setStringList(kunciPengguna, daftarPengguna);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<Pengguna?> login(String namaAkun, String kataSandi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> daftarPengguna = prefs.getStringList(kunciPengguna) ?? [];

      for (String dataPengguna in daftarPengguna) {
        Map<String, dynamic> json = jsonDecode(dataPengguna);
        if (json['namaAkun'] == namaAkun && json['kataSandi'] == kataSandi) {
          Pengguna pengguna = Pengguna.dariJson(json);
          await prefs.setString(
            kunciPenggunaAktif,
            jsonEncode(pengguna.keJson()),
          );
          return pengguna;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Pengguna?> dapatkanPenggunaAktif() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? dataPengguna = prefs.getString(kunciPenggunaAktif);
      if (dataPengguna != null) {
        return Pengguna.dariJson(jsonDecode(dataPengguna));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kunciPenggunaAktif);
  }

  static Future<bool> simpanTransaksi(Transaksi transaksi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> daftarTransaksi = prefs.getStringList(kunciTransaksi) ?? [];
      daftarTransaksi.add(jsonEncode(transaksi.keJson()));
      await prefs.setStringList(kunciTransaksi, daftarTransaksi);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<List<Transaksi>> dapatkanDaftarTransaksi(
    String namaAkun,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> daftarTransaksi = prefs.getStringList(kunciTransaksi) ?? [];

      List<Transaksi> transaksiPengguna = [];
      for (String dataTransaksi in daftarTransaksi) {
        Map<String, dynamic> json = jsonDecode(dataTransaksi);
        if (json['namaPembeli'] == namaAkun) {
          transaksiPengguna.add(Transaksi.dariJson(json));
        }
      }

      transaksiPengguna.sort(
        (a, b) => b.tanggalPembelian.compareTo(a.tanggalPembelian),
      );
      return transaksiPengguna;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> hapusTransaksi(String idTransaksi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> daftarTransaksi = prefs.getStringList(kunciTransaksi) ?? [];

      daftarTransaksi.removeWhere((dataTransaksi) {
        Map<String, dynamic> json = jsonDecode(dataTransaksi);
        return json['id'] == idTransaksi;
      });

      await prefs.setStringList(kunciTransaksi, daftarTransaksi);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> perbaruiTransaksi(Transaksi transaksi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> daftarTransaksi = prefs.getStringList(kunciTransaksi) ?? [];

      for (int i = 0; i < daftarTransaksi.length; i++) {
        Map<String, dynamic> json = jsonDecode(daftarTransaksi[i]);
        if (json['id'] == transaksi.id) {
          daftarTransaksi[i] = jsonEncode(transaksi.keJson());
          await prefs.setStringList(kunciTransaksi, daftarTransaksi);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<Transaksi?> dapatkanTransaksi(String idTransaksi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> daftarTransaksi = prefs.getStringList(kunciTransaksi) ?? [];

      for (String dataTransaksi in daftarTransaksi) {
        Map<String, dynamic> json = jsonDecode(dataTransaksi);
        if (json['id'] == idTransaksi) {
          return Transaksi.dariJson(json);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
