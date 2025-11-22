import 'package:flutter/material.dart';
import '../models/obat.dart';
import '../models/transaksi.dart';
import '../models/pengguna.dart';
import '../data/data_obat.dart';
import '../services/manajer_penyimpanan.dart';
import 'halaman_riwayat_pembelian.dart';

class HalamanFormulirPembelian extends StatefulWidget {
  final Obat? obat;

  const HalamanFormulirPembelian({super.key, this.obat});

  @override
  State<HalamanFormulirPembelian> createState() =>
      _HalamanFormulirPembelianState();
}

class _HalamanFormulirPembelianState extends State<HalamanFormulirPembelian> {
  final _kunciForm = GlobalKey<FormState>();
  final _kontrolerJumlah = TextEditingController();
  final _kontrolerCatatan = TextEditingController();
  final _kontrolerNomorResep = TextEditingController();

  Obat? _obatTerpilih;
  String _metodePembelian = 'langsung';
  bool _sedangMemuat = false;
  Pengguna? _penggunaAktif;

  @override
  void initState() {
    super.initState();
    _obatTerpilih = widget.obat;
    _muatDataPengguna();
  }

  @override
  void dispose() {
    _kontrolerJumlah.dispose();
    _kontrolerCatatan.dispose();
    _kontrolerNomorResep.dispose();
    super.dispose();
  }

  Future<void> _muatDataPengguna() async {
    final pengguna = await ManajerPenyimpanan.dapatkanPenggunaAktif();
    setState(() {
      _penggunaAktif = pengguna;
    });
  }

  String? _validasiJumlah(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Jumlah pembelian harus diisi';
    }
    final angka = int.tryParse(nilai);
    if (angka == null || angka <= 0) {
      return 'Jumlah harus berupa angka positif';
    }
    return null;
  }

  String? _validasiNomorResep(String? nilai) {
    if (_metodePembelian == 'resep') {
      if (nilai == null || nilai.isEmpty) {
        return 'Nomor resep harus diisi';
      }
      if (nilai.length < 6) {
        return 'Nomor resep minimal 6 karakter';
      }
      final polaHuruf = RegExp(r'[a-zA-Z]');
      final polaAngka = RegExp(r'[0-9]');
      if (!polaHuruf.hasMatch(nilai) || !polaAngka.hasMatch(nilai)) {
        return 'Nomor resep harus kombinasi huruf & angka';
      }
    }
    return null;
  }

  Future<void> _simpanPembelian() async {
    if (_obatTerpilih == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Silakan pilih obat terlebih dahulu',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_kunciForm.currentState!.validate()) {
      setState(() {
        _sedangMemuat = true;
      });

      final jumlah = int.parse(_kontrolerJumlah.text);
      final totalHarga = _obatTerpilih!.harga * jumlah;

      final transaksi = Transaksi(
        id: 'TRX${DateTime.now().millisecondsSinceEpoch}',
        idObat: _obatTerpilih!.id,
        namaObat: _obatTerpilih!.nama,
        kategoriObat: _obatTerpilih!.kategori,
        gambarObat: _obatTerpilih!.gambar,
        namaPembeli: _penggunaAktif?.namaAkun ?? '',
        jumlah: jumlah,
        hargaSatuan: _obatTerpilih!.harga,
        totalHarga: totalHarga,
        tanggalPembelian: DateTime.now(),
        catatan: _kontrolerCatatan.text.isEmpty ? null : _kontrolerCatatan.text,
        metodePembelian: _metodePembelian,
        nomorResep: _metodePembelian == 'resep'
            ? _kontrolerNomorResep.text
            : null,
        status: 'selesai',
      );

      final berhasil = await ManajerPenyimpanan.simpanTransaksi(transaksi);

      setState(() {
        _sedangMemuat = false;
      });

      if (mounted) {
        if (berhasil) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pembelian berhasil disimpan!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HalamanRiwayatPembelian(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Gagal menyimpan pembelian',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF0067).withOpacity(0.05),
              Colors.white,
              const Color(0xFFFF0067).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF0067), Color(0xFFFF3385)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF0067).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Formulir Pembelian Obat',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _kunciForm,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_obatTerpilih == null)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pilih Obat',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF0067),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<Obat>(
                                  value: _obatTerpilih,
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.medication_rounded,
                                      color: Color(0xFFFF0067),
                                    ),
                                    labelText: 'Pilih Obat',
                                    labelStyle: const TextStyle(
                                      color: Color(0xFFFF0067),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFFF0067),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  items: DataObat.daftarObat.map((obat) {
                                    return DropdownMenuItem<Obat>(
                                      value: obat,
                                      child: Text(
                                        '${obat.gambar} ${obat.nama}',
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (obat) {
                                    setState(() {
                                      _obatTerpilih = obat;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Silakan pilih obat';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        if (_obatTerpilih != null) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(
                                          0xFFFF0067,
                                        ).withOpacity(0.2),
                                        const Color(
                                          0xFFFF0067,
                                        ).withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _obatTerpilih!.gambar,
                                      style: const TextStyle(fontSize: 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _obatTerpilih!.nama,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF0067),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFF0067,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          _obatTerpilih!.kategori,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFFF0067),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Rp ${_obatTerpilih!.harga.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF0067),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Detail Pembelian',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF0067),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _kontrolerJumlah,
                                  keyboardType: TextInputType.number,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Jumlah Pembelian',
                                    prefixIcon: const Icon(
                                      Icons.shopping_cart_rounded,
                                      color: Color(0xFFFF0067),
                                    ),
                                    labelStyle: const TextStyle(
                                      color: Color(0xFFFF0067),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFFF0067),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 1,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  validator: _validasiJumlah,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _kontrolerCatatan,
                                  maxLines: 3,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Catatan (Opsional)',
                                    prefixIcon: const Icon(
                                      Icons.note_rounded,
                                      color: Color(0xFFFF0067),
                                    ),
                                    labelStyle: const TextStyle(
                                      color: Color(0xFFFF0067),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFFF0067),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Metode Pembelian',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF0067),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _metodePembelian = 'langsung';
                                            _kontrolerNomorResep.clear();
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color:
                                                _metodePembelian == 'langsung'
                                                ? const Color(0xFFFF0067)
                                                : Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  _metodePembelian == 'langsung'
                                                  ? const Color(0xFFFF0067)
                                                  : Colors.grey[300]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.shopping_bag_rounded,
                                                color:
                                                    _metodePembelian ==
                                                        'langsung'
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                                size: 32,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Langsung',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      _metodePembelian ==
                                                          'langsung'
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _metodePembelian = 'resep';
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: _metodePembelian == 'resep'
                                                ? const Color(0xFFFF0067)
                                                : Colors.grey[200],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: _metodePembelian == 'resep'
                                                  ? const Color(0xFFFF0067)
                                                  : Colors.grey[300]!,
                                              width: 2,
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.receipt_long_rounded,
                                                color:
                                                    _metodePembelian == 'resep'
                                                    ? Colors.white
                                                    : Colors.grey[600],
                                                size: 32,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Resep Dokter',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      _metodePembelian ==
                                                          'resep'
                                                      ? Colors.white
                                                      : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_metodePembelian == 'resep') ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _kontrolerNomorResep,
                                    style: const TextStyle(fontSize: 16),
                                    decoration: InputDecoration(
                                      labelText: 'Nomor Resep Dokter',
                                      prefixIcon: const Icon(
                                        Icons.medical_information_rounded,
                                        color: Color(0xFFFF0067),
                                      ),
                                      labelStyle: const TextStyle(
                                        color: Color(0xFFFF0067),
                                        fontWeight: FontWeight.w600,
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Color(0xFFFF0067),
                                          width: 2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 1,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    validator: _validasiNomorResep,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.orange[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.orange[700],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Nomor resep minimal 6 karakter dan harus kombinasi huruf & angka',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange[900],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                if (_kontrolerJumlah.text.isNotEmpty &&
                                    int.tryParse(_kontrolerJumlah.text) !=
                                        null) ...[
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(
                                            0xFFFF0067,
                                          ).withOpacity(0.1),
                                          const Color(
                                            0xFFFF0067,
                                          ).withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(
                                          0xFFFF0067,
                                        ).withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Harga Satuan:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              'Rp ${_obatTerpilih!.harga.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Jumlah:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              '${_kontrolerJumlah.text} item',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Total Harga:',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF0067),
                                              ),
                                            ),
                                            Text(
                                              'Rp ${(_obatTerpilih!.harga * int.parse(_kontrolerJumlah.text)).toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFF0067),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _sedangMemuat ? null : _simpanPembelian,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0067),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: _sedangMemuat
                                ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    'Simpan Pembelian',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
