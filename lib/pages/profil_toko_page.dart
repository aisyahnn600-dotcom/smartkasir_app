import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'kelola_karyawan_page.dart';

// ==========================================
// PROFIL DAN PENGATURAN TOKO SMARTKASIR
// PRAKTIKUM MOBILE PROGRAMMING MINGGU 12
// ==========================================

class ProfilTokoPage extends StatefulWidget {
  const ProfilTokoPage({super.key});

  @override
  State<ProfilTokoPage> createState() => _ProfilTokoPageState();
}

class _ProfilTokoPageState extends State<ProfilTokoPage> {
  // ========================================
  // CONTROLLER DATA TOKO
  // ========================================

  final _namaTokoController = TextEditingController();

  final _alamatController = TextEditingController();

  final _noWaController = TextEditingController();

  final _footerController = TextEditingController();

  // Status proses penyimpanan
  bool _sedangMenyimpan = false;

  // Nama kasir aktif
  String _activeCashierName = 'Belum Ditentukan';

  // ========================================
  // INISIALISASI HALAMAN
  // ========================================

  @override
  void initState() {
    super.initState();

    _muatProfilToko();
  }

  // ========================================
  // MEMBERSIHKAN CONTROLLER
  // ========================================

  @override
  void dispose() {
    _namaTokoController.dispose();
    _alamatController.dispose();
    _noWaController.dispose();
    _footerController.dispose();

    super.dispose();
  }

  // ========================================
  // MEMBACA PROFIL DARI SHAREDPREFERENCES
  // ========================================

  Future<void> _muatProfilToko() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _namaTokoController.text =
          prefs.getString('nama_toko') ?? 'SmartKasir Poliban';

      _alamatController.text =
          prefs.getString('alamat_toko') ??
          'Jl. Brigjend H. Hasan Basry, Banjarmasin';

      _noWaController.text = prefs.getString('no_wa') ?? '081234567890';

      _footerController.text =
          prefs.getString('footer_struk') ??
          'Terima Kasih Atas Kunjungan Anda! '
              'Barang yang sudah dibeli tidak dapat ditukar.';

      _activeCashierName =
          prefs.getString('active_cashier_name') ?? 'Belum Ditentukan';
    });
  }

  // ========================================
  // MENYIMPAN PROFIL TOKO
  // ========================================

  Future<void> _simpanProfilToko() async {
    if (_sedangMenyimpan) return;

    setState(() {
      _sedangMenyimpan = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      // Menyimpan nama toko
      await prefs.setString('nama_toko', _namaTokoController.text.trim());

      // Menyimpan alamat usaha
      await prefs.setString('alamat_toko', _alamatController.text.trim());

      // Menyimpan kontak WhatsApp
      await prefs.setString('no_wa', _noWaController.text.trim());

      // Menyimpan catatan kaki struk
      await prefs.setString('footer_struk', _footerController.text.trim());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Identitas toko berhasil diperbarui!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil toko: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sedangMenyimpan = false;
        });
      }
    }
  }

  // ========================================
  // TAMPILAN PROFIL TOKO
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),

      // ======================================
      // APP BAR
      // ======================================
      appBar: AppBar(
        title: const Text(
          'Profil & Pengaturan Toko',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),

        backgroundColor: const Color(0xFF1E3A8A),

        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ======================================
      // KONTEN HALAMAN
      // ======================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            // ==================================
            // KARTU KASIR AKTIF
            // ==================================

            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(14),

                border: Border.all(color: const Color(0xFFE2E8F0)),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Row(
                children: [
                  // Icon toko
                  const CircleAvatar(
                    radius: 24,

                    backgroundColor: Color(0xFF1E3A8A),

                    child: Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Informasi kasir aktif
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'KASIR AKTIF SHIFT INI',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _activeCashierName,

                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol kelola karyawan
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KelolaKaryawanPage(),
                        ),
                      );

                      if (!mounted) return;

                      // Memuat kasir aktif terbaru
                      await _muatProfilToko();
                    },

                    icon: const Icon(Icons.people_outline, size: 16),

                    label: const Text('Kelola'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================================
            // BANNER IDENTITAS TOKO
            // ==================================
            Container(
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF60A5FA), Color(0xFF1E3A8A)],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius: BorderRadius.circular(14),
              ),

              child: const Row(
                children: [
                  Icon(Icons.store, color: Colors.white, size: 32),

                  SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'SmartKasir',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Pengaturan identitas usaha UMKM',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==================================
            // JUDUL FORM IDENTITAS TOKO
            // ==================================
            const Text(
              'IDENTITAS USAHA & STRUK KASIR',

              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF1E3A8A),
              ),
            ),

            const SizedBox(height: 14),

            // ==================================
            // INPUT NAMA TOKO
            // ==================================
            TextFormField(
              controller: _namaTokoController,

              decoration: InputDecoration(
                labelText: 'Nama Toko / Usaha',

                hintText: 'Contoh: Warung Berkah Digital',

                prefixIcon: const Icon(Icons.store),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            // ==================================
            // INPUT ALAMAT TOKO
            // ==================================
            TextFormField(
              controller: _alamatController,

              maxLines: 2,

              decoration: InputDecoration(
                labelText: 'Alamat Toko',

                hintText: 'Masukkan alamat lengkap usaha',

                prefixIcon: const Icon(Icons.location_on_outlined),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            // ==================================
            // INPUT NOMOR WHATSAPP
            // ==================================
            TextFormField(
              controller: _noWaController,

              keyboardType: TextInputType.phone,

              decoration: InputDecoration(
                labelText: 'Nomor WhatsApp / Kontak Toko',

                hintText: 'Contoh: 081234567890',

                prefixIcon: const Icon(Icons.phone_outlined),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            // ==================================
            // INPUT FOOTER STRUK
            // ==================================
            TextFormField(
              controller: _footerController,

              maxLines: 2,

              decoration: InputDecoration(
                labelText: 'Catatan Kaki Struk (Footer Nota)',

                hintText: 'Contoh: Terima kasih atas kunjungan Anda!',

                prefixIcon: const Icon(Icons.receipt_outlined),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 28),

            // ==================================
            // TOMBOL SIMPAN PROFIL TOKO
            // ==================================
            ElevatedButton.icon(
              onPressed: _sedangMenyimpan ? null : _simpanProfilToko,

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),

                foregroundColor: Colors.white,

                padding: const EdgeInsets.symmetric(vertical: 16),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              icon: _sedangMenyimpan
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),

              label: Text(
                _sedangMenyimpan
                    ? 'Menyimpan Pengaturan...'
                    : 'Simpan Profil Toko',

                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
