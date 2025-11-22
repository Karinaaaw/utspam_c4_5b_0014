import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/transaksi.dart';
import '../services/manajer_penyimpanan.dart';
import 'riwayat_pembelian.dart';
import 'edit_transaksi.dart';

class HalamanDetailPembelian extends StatefulWidget {
  final String idTransaksi;

  const HalamanDetailPembelian({super.key, required this.idTransaksi});

  @override
  State<HalamanDetailPembelian> createState() => _HalamanDetailPembelianState();
}

class _HalamanDetailPembelianState extends State<HalamanDetailPembelian> {
  Transaksi? _transaksi;
  bool _sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _muatDataTransaksi();
  }

  Future<void> _muatDataTransaksi() async {
    setState(() {
      _sedangMemuat = true;
    });

    final transaksi = await ManajerPenyimpanan.dapatkanTransaksi(
      widget.idTransaksi,
    );
    setState(() {
      _transaksi = transaksi;
      _sedangMemuat = false;
    });
  }

  String _formatTanggal(DateTime tanggal) {
    return DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(tanggal);
  }

  Future<void> _batalkanTransaksi() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(child: Text('Konfirmasi Pembatalan')),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan transaksi ini? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Tidak',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Ya, Batalkan', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    if (konfirmasi == true && mounted) {
      if (_transaksi != null) {
        _transaksi!.status = 'dibatalkan';
        final berhasil = await ManajerPenyimpanan.perbaruiTransaksi(
          _transaksi!,
        );

        if (berhasil && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Transaksi berhasil dibatalkan',
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
        }
      }
    }
  }

  Future<void> _hapusTransaksi() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red),
            SizedBox(width: 12),
            Expanded(child: Text('Konfirmasi Hapus')),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus transaksi ini secara permanen? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Tidak',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Ya, Hapus', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );

    if (konfirmasi == true && mounted) {
      final berhasil = await ManajerPenyimpanan.hapusTransaksi(
        widget.idTransaksi,
      );

      if (berhasil && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Transaksi berhasil dihapus',
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sedangMemuat) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFFF0067)),
        ),
      );
    }

    if (_transaksi == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Color(0xFFFF0067),
              ),
              const SizedBox(height: 16),
              const Text(
                'Transaksi tidak ditemukan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF0067),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HalamanRiwayatPembelian(),
                    ),
                  );
                },
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
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    final isBatal = _transaksi!.status == 'dibatalkan';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFF0067).withValues(alpha: 0.05),
              Colors.white,
              const Color(0xFFFF0067).withValues(alpha: 0.1),
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
                      color: const Color(0xFFFF0067).withValues(alpha: 0.3),
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
                            builder: (context) =>
                                const HalamanRiwayatPembelian(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Detail Pembelian',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(
                                      0xFFFF0067,
                                    ).withValues(alpha: 0.2),
                                    const Color(
                                      0xFFFF0067,
                                    ).withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  _transaksi!.gambarObat,
                                  style: const TextStyle(fontSize: 64),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              _transaksi!.namaObat,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isBatal
                                    ? Colors.grey
                                    : const Color(0xFFFF0067),
                                decoration: isBatal
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isBatal
                                    ? Colors.grey.withValues(alpha: 0.2)
                                    : const Color(
                                        0xFFFF0067,
                                      ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _transaksi!.kategoriObat,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isBatal
                                      ? Colors.grey
                                      : const Color(0xFFFF0067),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isBatal
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isBatal
                                        ? Icons.cancel_rounded
                                        : Icons.check_circle_rounded,
                                    size: 20,
                                    color: isBatal ? Colors.red : Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isBatal ? 'Dibatalkan' : 'Selesai',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isBatal
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
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
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Pembelian',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF0067),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buatBariInfo(
                              'ID Transaksi',
                              _transaksi!.id,
                              Icons.tag_rounded,
                            ),
                            const Divider(height: 24),
                            _buatBariInfo(
                              'Nama Pembeli',
                              _transaksi!.namaPembeli,
                              Icons.person_rounded,
                            ),
                            const Divider(height: 24),
                            _buatBariInfo(
                              'Jumlah Pembelian',
                              '${_transaksi!.jumlah} item',
                              Icons.shopping_cart_rounded,
                            ),
                            const Divider(height: 24),
                            _buatBariInfo(
                              'Harga Satuan',
                              'Rp ${_transaksi!.hargaSatuan.toStringAsFixed(0)}',
                              Icons.payments_rounded,
                            ),
                            const Divider(height: 24),
                            _buatBariInfo(
                              'Total Harga',
                              'Rp ${_transaksi!.totalHarga.toStringAsFixed(0)}',
                              Icons.account_balance_wallet_rounded,
                              isHighlight: true,
                              isStrikethrough: isBatal,
                            ),
                            const Divider(height: 24),
                            _buatBariInfo(
                              'Tanggal Pembelian',
                              _formatTanggal(_transaksi!.tanggalPembelian),
                              Icons.calendar_today_rounded,
                            ),
                            const Divider(height: 24),
                            _buatBariInfo(
                              'Metode Pembelian',
                              _transaksi!.metodePembelian == 'resep'
                                  ? 'Resep Dokter'
                                  : 'Pembelian Langsung',
                              _transaksi!.metodePembelian == 'resep'
                                  ? Icons.receipt_long_rounded
                                  : Icons.shopping_bag_rounded,
                            ),
                            if (_transaksi!.metodePembelian == 'resep' &&
                                _transaksi!.nomorResep != null) ...[
                              const Divider(height: 24),
                              _buatBariInfo(
                                'Nomor Resep',
                                _transaksi!.nomorResep!,
                                Icons.medical_information_rounded,
                              ),
                            ],
                            if (_transaksi!.catatan != null &&
                                _transaksi!.catatan!.isNotEmpty) ...[
                              const Divider(height: 24),
                              _buatBariInfo(
                                'Catatan',
                                _transaksi!.catatan!,
                                Icons.note_rounded,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!isBatal) ...[
                        SizedBox(
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HalamanEditTransaksi(
                                    transaksi: _transaksi!,
                                  ),
                                ),
                              ).then((_) => _muatDataTransaksi());
                            },
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text(
                              'Edit Transaksi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0067),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: _batalkanTransaksi,
                            icon: const Icon(Icons.cancel_rounded),
                            label: const Text(
                              'Batalkan Transaksi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: _hapusTransaksi,
                          icon: const Icon(Icons.delete_forever_rounded),
                          label: const Text(
                            'Hapus Transaksi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buatBariInfo(
    String label,
    String nilai,
    IconData ikon, {
    bool isHighlight = false,
    bool isStrikethrough = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          ikon,
          color: isHighlight ? const Color(0xFFFF0067) : Colors.grey[600],
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nilai,
                style: TextStyle(
                  fontSize: isHighlight ? 18 : 16,
                  fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
                  color: isHighlight
                      ? (isStrikethrough
                            ? Colors.grey
                            : const Color(0xFFFF0067))
                      : Colors.black87,
                  decoration: isStrikethrough
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
