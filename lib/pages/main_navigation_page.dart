import 'package:flutter/material.dart';

import 'dashboard_page.dart';
import 'pelanggan_page.dart';
import 'profil_toko_page.dart';

// ==========================================
// NAVIGASI UTAMA SMARTKASIR
// PRAKTIKUM MOBILE PROGRAMMING MINGGU 13
// ==========================================

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  // ==========================================
  // DAFTAR HALAMAN UTAMA
  // ==========================================

  final List<Widget> _pages = [
    // Menu 1: Beranda
    const DashboardPage(),

    // Menu 2: Pelanggan
    const PelangganPage(),

    // Menu 3: Kasir
    const Center(
      child: Text(
        'Menu Kasir POS (Modul M14)',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    ),

    // Menu 4: Riwayat
    const Center(
      child: Text(
        'Riwayat Penjualan & Laporan (Modul M14)',
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      ),
    ),

    // Menu 5: Profil Toko
    const ProfilTokoPage(),
  ];

  // ==========================================
  // MEMBANGUN ANTARMUKA NAVIGASI
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F5FF),

      body: IndexedStack(index: _currentIndex, children: _pages),

      // ========================================
      // BOTTOM NAVIGATION BAR
      // ========================================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),

        child: BottomNavigationBar(
          currentIndex: _currentIndex,

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.white,

          selectedItemColor: const Color(0xFF1E3A8A),

          unselectedItemColor: Colors.grey.shade500,

          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),

          unselectedLabelStyle: const TextStyle(fontSize: 10),

          // ======================================
          // LIMA MENU UTAMA
          // ======================================
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Beranda',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Pelanggan',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Kasir',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Riwayat',
            ),

            BottomNavigationBarItem(
              icon: Icon(Icons.store_outlined),
              activeIcon: Icon(Icons.store),
              label: 'Toko',
            ),
          ],
        ),
      ),
    );
  }
}
