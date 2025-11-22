import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/manajer_penyimpanan.dart';
import 'halaman_detail_pembelian.dart';

class HalamanEditTransaksi extends StatefulWidget {
  final Transaksi transaksi;

  const HalamanEditTransaksi({super.key, required this.transaksi});

  @override
  State<HalamanEditTransaksi> createState() => _HalamanEditTransaksiState();
}

class _HalamanEditTransaksiState extends State<HalamanEditTransaksi> {
  final _kunciForm = GlobalKey<FormState>();
  late TextEditingController _kontrolerJumlah;
  late TextEditingController _kontrolerCatatan;
  late TextEditingController _kontrolerNomorResep;
  late String _metodePembelian;
  bool _sedangMemuat = false;

  @override
  void initState() {
    super.initState();
    _kontrolerJumlah = TextEditingController(
      text: widget.transaksi.jumlah.toString(),
    );
    _kontrolerCatatan = TextEditingController(
      text: widget.transaksi.catatan ?? '',
    );
    _kontrolerNomorResep = TextEditingController(
      text: widget.transaksi.nomorResep ?? '',
    );
    _metodePembelian = widget.transaksi.metodePembelian;
  }

  @override
  void dispose() {
    _kontrolerJumlah.dispose();
    _kontrolerCatatan.dispose();
    _kontrolerNomorResep.dispose();
    super.dispose();
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

  Future<void> _simpanPerubahan() async {
    if (_kunciForm.currentState!.validate()) {
      setState(() {
        _sedangMemuat = true;
      });

      final jumlah = int.parse(_kontrolerJumlah.text);
      final totalHarga = widget.transaksi.hargaSatuan * jumlah;

      final transaksiDiperbarui = widget.transaksi.salin(
        jumlah: jumlah,
        totalHarga: totalHarga,
        catatan: _kontrolerCatatan.text.isEmpty ? null : _kontrolerCatatan.text,
        metodePembelian: _metodePembelian,
        nomorResep: _metodePembelian == 'resep'
            ? _kontrolerNomorResep.text
            : null,
      );

      final berhasil = await ManajerPenyimpanan.perbaruiTransaksi(
        transaksiDiperbarui,
      );

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
                      'Transaksi berhasil diperbarui!',
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
              builder: (context) =>
                  HalamanDetailPembelian(idTransaksi: widget.transaksi.id),
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
                      'Gagal memperbarui transaksi',
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
              const Color(0xFFFF0067)..withValues(alpha: 0.05),
              Colors.white,
              const Color(0xFFFF0067)..withValues(alpha: 0.1),
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
                      color: const Color(0xFFFF0067)..withValues(alpha: 0.3),
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
                        backgroundColor: Colors.white..withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Edit Transaksi',
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
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey..withValues(alpha: 0.2),
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
                                      const Color(0xFFFF0067)
                                        ..withValues(alpha: 0.2),
                                      const Color(0xFFFF0067)
                                        ..withValues(alpha: 0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.transaksi.gambarObat,
                                    style: const TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.transaksi.namaObat,
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
                                        color: const Color(0xFFFF0067)
                                          ..withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.transaksi.kategoriObat,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFFFF0067),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rp ${widget.transaksi.hargaSatuan.toStringAsFixed(0)}',
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
                                color: Colors.grey..withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Edit Detail Pembelian',
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
                                onChanged: (value) {
                                  setState(() {});
                                },
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
                                          color: _metodePembelian == 'langsung'
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
                                                  _metodePembelian == 'langsung'
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
                                              color: _metodePembelian == 'resep'
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
                                                    _metodePembelian == 'resep'
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
                                        const Color(0xFFFF0067)
                                          ..withValues(alpha: 0.1),
                                        const Color(0xFFFF0067)
                                          ..withValues(alpha: 0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFFF0067)
                                        ..withValues(alpha: 0.3),
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
                                            'Rp ${widget.transaksi.hargaSatuan.toStringAsFixed(0)}',
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
                                            'Rp ${(widget.transaksi.hargaSatuan * int.parse(_kontrolerJumlah.text)).toStringAsFixed(0)}',
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
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFFF0067),
                                    side: const BorderSide(
                                      color: Color(0xFFFF0067),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _sedangMemuat
                                      ? null
                                      : _simpanPerubahan,
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
                                          'Simpan',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
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
