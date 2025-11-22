import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaksi.dart';
import '../models/pengguna.dart';
import '../services/manajer_penyimpanan.dart';
import 'halaman_utama.dart';
import 'halaman_detail_pembelian.dart';

class HalamanRiwayatPembelian extends StatefulWidget {
  const HalamanRiwayatPembelian({super.key});

  @override
  State<HalamanRiwayatPembelian> createState() =>
      _HalamanRiwayatPembelianState();
}

class _HalamanRiwayatPembelianState extends State<HalamanRiwayatPembelian> {
  List<Transaksi> _daftarTransaksi = [];
  bool _sedangMemuat = true;
  Pengguna? _penggunaAktif;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() {
      _sedangMemuat = true;
    });

    final pengguna = await ManajerPenyimpanan.dapatkanPenggunaAktif();
    if (pengguna != null) {
      final transaksi = await ManajerPenyimpanan.dapatkanDaftarTransaksi(
        pengguna.namaAkun,
      );
      setState(() {
        _penggunaAktif = pengguna;
        _daftarTransaksi = transaksi;
        _sedangMemuat = false;
      });
    } else {
      setState(() {
        _sedangMemuat = false;
      });
    }
  }

  String _formatTanggal(DateTime tanggal) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(tanggal);
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
              const Color(0xFFFF0067).withValues(alpha: .05),
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
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HalamanUtama(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white..withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Riwayat Pembelian',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _muatData,
                      icon: const Icon(Icons.refresh_rounded),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white..withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _sedangMemuat
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF0067),
                        ),
                      )
                    : _daftarTransaksi.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF0067)..withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.shopping_bag_outlined,
                                size: 80,
                                color: Color(0xFFFF0067),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Belum Ada Riwayat',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF0067),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Anda belum melakukan pembelian',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HalamanUtama(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.shopping_cart_rounded),
                              label: const Text('Mulai Belanja'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF0067),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _muatData,
                        color: const Color(0xFFFF0067),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _daftarTransaksi.length,
                          itemBuilder: (context, index) {
                            final transaksi = _daftarTransaksi[index];
                            return _buatKartuTransaksi(transaksi);
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buatKartuTransaksi(Transaksi transaksi) {
    final isBatal = transaksi.status == 'dibatalkan';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                HalamanDetailPembelian(idTransaksi: transaksi.id),
          ),
        ).then((_) => _muatData());
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isBatal
                ? Colors.red..withValues(alpha: 0.3)
                : const Color(0xFFFF0067)..withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey..withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFF0067)..withValues(alpha: 0.2),
                          const Color(0xFFFF0067)..withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        transaksi.gambarObat,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaksi.namaObat,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isBatal
                                ? Colors.grey
                                : const Color(0xFFFF0067),
                            decoration: isBatal
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isBatal
                                    ? Colors.grey..withValues(alpha: 0.2)
                                    : const Color(0xFFFF0067)..withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                transaksi.kategoriObat,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isBatal
                                      ? Colors.grey
                                      : const Color(0xFFFF0067),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: isBatal
                                    ? Colors.red..withValues(alpha: 0.1)
                                    : Colors.green..withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isBatal ? 'Dibatalkan' : 'Selesai',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isBatal ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaksi.jumlah} item',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF0067),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Total Harga',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${transaksi.totalHarga.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isBatal
                              ? Colors.grey
                              : const Color(0xFFFF0067),
                          decoration: isBatal
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTanggal(transaksi.tanggalPembelian),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  Icon(
                    transaksi.metodePembelian == 'resep'
                        ? Icons.receipt_long_rounded
                        : Icons.shopping_bag_rounded,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    transaksi.metodePembelian == 'resep'
                        ? 'Resep Dokter'
                        : 'Langsung',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
