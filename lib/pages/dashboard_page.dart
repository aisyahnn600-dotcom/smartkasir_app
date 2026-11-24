import 'package:flutter/material.dart';

import '../helpers/database_helper.dart';
import '../models/produk.dart';

// ==========================================
// DASHBOARD SMARTKASIR
// PRAKTIKUM MOBILE PROGRAMMING
// ==========================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Produk>> _produkFuture;

  @override
  void initState() {
    super.initState();
    _muatProduk();
  }

  void _muatProduk() {
    _produkFuture = DatabaseHelper.instance.getAllProduk();
  }

  Future<void> _refresh() async {
    setState(() {
      _muatProduk();
    });

    await _produkFuture;
  }

  String _rupiah(double harga) {
    return 'Rp ${harga.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),

      appBar: AppBar(
        title: const Text(
          'SmartKasir',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Muat ulang',
          ),
        ],
      ),

      body: FutureBuilder<List<Produk>>(
        future: _produkFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Gagal memuat produk: ${snapshot.error}'),
            );
          }

          final produkList = snapshot.data ?? <Produk>[];

          final totalStok = produkList.fold<int>(
            0,
            (total, produk) => total + produk.stok,
          );

          final stokMenipis = produkList
              .where((produk) => produk.stok > 0 && produk.stok <= 5)
              .length;

          return RefreshIndicator(
            onRefresh: _refresh,

            child: ListView(
              padding: const EdgeInsets.all(16),

              children: [
                // HEADER DASHBOARD
                Container(
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF60A5FA), Color(0xFF1E3A8A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Kelola penjualan UMKM dengan mudah.',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // RINGKASAN PRODUK
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.inventory_2,
                        title: 'Total Produk',
                        value: '${produkList.length}',
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.warehouse,
                        title: 'Total Stok',
                        value: '$totalStok',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.warning_amber,
                        title: 'Stok Menipis',
                        value: '$stokMenipis',
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Produk Habis',
                        value: '${produkList.where((p) => p.stok == 0).length}',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // JUDUL DAFTAR PRODUK
                const Text(
                  'Produk Tersedia',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),

                const SizedBox(height: 14),

                // DAFTAR PRODUK
                if (produkList.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Text('Belum ada produk tersedia.'),
                    ),
                  )
                else
                  ...produkList.map((produk) => _buildProdukCard(produk)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========================================
  // KARTU STATISTIK
  // ========================================

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1E3A8A), size: 26),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ========================================
  // KARTU PRODUK
  // ========================================

  Widget _buildProdukCard(Produk produk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(
        contentPadding: const EdgeInsets.all(10),

        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),

          child: SizedBox(
            width: 65,
            height: 65,

            child: produk.gambarUrl.isNotEmpty
                ? Image.network(
                    produk.gambarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return Container(
                        color: Colors.blue.shade50,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Color(0xFF1E3A8A),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.blue.shade50,
                    child: const Icon(
                      Icons.inventory_2,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
          ),
        ),

        title: Text(
          produk.nama,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(produk.kategori),

              const SizedBox(height: 4),

              Text(
                _rupiah(produk.hargaJual),
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Stok: ${produk.stok}',
                style: TextStyle(
                  color: produk.stok == 0
                      ? Colors.red
                      : produk.stok <= 5
                      ? Colors.orange
                      : Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

        isThreeLine: true,
      ),
    );
  }
}
