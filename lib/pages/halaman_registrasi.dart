import 'package:flutter/material.dart';
import '../models/pengguna.dart';
import '../services/manajer_penyimpanan.dart';
import 'halaman_login.dart';

class HalamanRegistrasi extends StatefulWidget {
  const HalamanRegistrasi({super.key});

  @override
  State<HalamanRegistrasi> createState() => _HalamanRegistrasiState();
}

class _HalamanRegistrasiState extends State<HalamanRegistrasi> {
  final _kunciForm = GlobalKey<FormState>();
  final _kontrolerNamaLengkap = TextEditingController();
  final _kontrolerEmail = TextEditingController();
  final _kontrolerNomorTelepon = TextEditingController();
  final _kontrolerAlamat = TextEditingController();
  final _kontrolerNamaAkun = TextEditingController();
  final _kontrolerKataSandi = TextEditingController();
  final _kontrolerKonfirmasiKataSandi = TextEditingController();

  bool _sembunyikanKataSandi = true;
  bool _sembunyikanKonfirmasi = true;
  bool _sedangMemuat = false;

  @override
  void dispose() {
    _kontrolerNamaLengkap.dispose();
    _kontrolerEmail.dispose();
    _kontrolerNomorTelepon.dispose();
    _kontrolerAlamat.dispose();
    _kontrolerNamaAkun.dispose();
    _kontrolerKataSandi.dispose();
    _kontrolerKonfirmasiKataSandi.dispose();
    super.dispose();
  }

  String? _validasiNamaLengkap(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Nama lengkap harus diisi';
    }
    if (nilai.length < 3) {
      return 'Nama lengkap minimal 3 karakter';
    }
    return null;
  }

  String? _validasiEmail(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Email harus diisi';
    }
    final pola = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!pola.hasMatch(nilai)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? _validasiNomorTelepon(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    final pola = RegExp(r'^[0-9]+$');
    if (!pola.hasMatch(nilai)) {
      return 'Nomor telepon hanya boleh angka';
    }
    if (nilai.length < 10 || nilai.length > 13) {
      return 'Nomor telepon harus 10-13 digit';
    }
    return null;
  }

  String? _validasiAlamat(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Alamat harus diisi';
    }
    if (nilai.length < 10) {
      return 'Alamat minimal 10 karakter';
    }
    return null;
  }

  String? _validasiNamaAkun(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Username harus diisi';
    }
    if (nilai.length < 4) {
      return 'Username minimal 4 karakter';
    }
    final pola = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!pola.hasMatch(nilai)) {
      return 'Username hanya boleh huruf, angka, dan underscore';
    }
    return null;
  }

  String? _validasiKataSandi(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Password harus diisi';
    }
    if (nilai.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  String? _validasiKonfirmasiKataSandi(String? nilai) {
    if (nilai == null || nilai.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    if (nilai != _kontrolerKataSandi.text) {
      return 'Password tidak sama';
    }
    return null;
  }

  Future<void> _daftarAkun() async {
    if (_kunciForm.currentState!.validate()) {
      setState(() {
        _sedangMemuat = true;
      });

      final pengguna = Pengguna(
        namaLengkap: _kontrolerNamaLengkap.text.trim(),
        email: _kontrolerEmail.text.trim(),
        nomorTelepon: _kontrolerNomorTelepon.text.trim(),
        alamat: _kontrolerAlamat.text.trim(),
        namaAkun: _kontrolerNamaAkun.text.trim(),
        kataSandi: _kontrolerKataSandi.text,
      );

      final berhasil = await ManajerPenyimpanan.simpanPengguna(pengguna);

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
                      'Pendaftaran berhasil! Silakan masuk',
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
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HalamanLogin()),
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
                      'Username sudah digunakan. Silakan pilih username lain',
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
              const Color(0xFFFF0067),
              const Color(0xFFFF0067)..withValues(alpha: 0.8),
              const Color(0xFFFF0067)..withValues(alpha: 0.6),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white..withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Daftar Akun Baru',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat akun untuk mulai berbelanja obat',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white..withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black..withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Form(
                      key: _kunciForm,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buatInputTeks(
                            kontroler: _kontrolerNamaLengkap,
                            label: 'Nama Lengkap',
                            ikon: Icons.person_rounded,
                            validator: _validasiNamaLengkap,
                            kapitalisasi: TextCapitalization.words,
                          ),
                          const SizedBox(height: 20),
                          _buatInputTeks(
                            kontroler: _kontrolerEmail,
                            label: 'Email',
                            ikon: Icons.email_rounded,
                            jenisKeyboard: TextInputType.emailAddress,
                            validator: _validasiEmail,
                          ),
                          const SizedBox(height: 20),
                          _buatInputTeks(
                            kontroler: _kontrolerNomorTelepon,
                            label: 'Nomor Telepon',
                            ikon: Icons.phone_rounded,
                            jenisKeyboard: TextInputType.phone,
                            validator: _validasiNomorTelepon,
                          ),
                          const SizedBox(height: 20),
                          _buatInputTeks(
                            kontroler: _kontrolerAlamat,
                            label: 'Alamat',
                            ikon: Icons.location_on_rounded,
                            validator: _validasiAlamat,
                            kapitalisasi: TextCapitalization.sentences,
                            maksBaris: 3,
                          ),
                          const SizedBox(height: 20),
                          _buatInputTeks(
                            kontroler: _kontrolerNamaAkun,
                            label: 'Username',
                            ikon: Icons.account_circle_rounded,
                            validator: _validasiNamaAkun,
                          ),
                          const SizedBox(height: 20),
                          _buatInputKataSandi(
                            kontroler: _kontrolerKataSandi,
                            label: 'Password',
                            sembunyikan: _sembunyikanKataSandi,
                            onToggle: () {
                              setState(() {
                                _sembunyikanKataSandi = !_sembunyikanKataSandi;
                              });
                            },
                            validator: _validasiKataSandi,
                          ),
                          const SizedBox(height: 20),
                          _buatInputKataSandi(
                            kontroler: _kontrolerKonfirmasiKataSandi,
                            label: 'Konfirmasi Password',
                            sembunyikan: _sembunyikanKonfirmasi,
                            onToggle: () {
                              setState(() {
                                _sembunyikanKonfirmasi =
                                    !_sembunyikanKonfirmasi;
                              });
                            },
                            validator: _validasiKonfirmasiKataSandi,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _sedangMemuat ? null : _daftarAkun,
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
                                      'Daftar Sekarang',
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
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sudah punya akun? ',
                        style: TextStyle(
                          color: Colors.white..withValues(alpha: 0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HalamanLogin(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationThickness: 2,
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
      ),
    );
  }

  Widget _buatInputTeks({
    required TextEditingController kontroler,
    required String label,
    required IconData ikon,
    required String? Function(String?) validator,
    TextInputType jenisKeyboard = TextInputType.text,
    TextCapitalization kapitalisasi = TextCapitalization.none,
    int maksBaris = 1,
  }) {
    return TextFormField(
      controller: kontroler,
      keyboardType: jenisKeyboard,
      textCapitalization: kapitalisasi,
      maxLines: maksBaris,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(ikon, color: const Color(0xFFFF0067)),
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
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF0067), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buatInputKataSandi({
    required TextEditingController kontroler,
    required String label,
    required bool sembunyikan,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: kontroler,
      obscureText: sembunyikan,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFFFF0067)),
        suffixIcon: IconButton(
          icon: Icon(
            sembunyikan
                ? Icons.visibility_rounded
                : Icons.visibility_off_rounded,
            color: const Color(0xFFFF0067),
          ),
          onPressed: onToggle,
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
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF0067), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: validator,
    );
  }
}
