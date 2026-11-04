
import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const SmartKasirApp());
}

// ==========================================
// APLIKASI UTAMA
// ==========================================

class SmartKasirApp extends StatelessWidget {
  const SmartKasirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartKasir',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==========================================
// SPLASH SCREEN + COUNTDOWN TIMER
// ==========================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int countdown = 3;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (countdown > 1) {
          setState(() {
            countdown--;
          });
        } else {
          timer.cancel();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardPage(),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.point_of_sale,
              color: Colors.white,
              size: 90,
            ),
            const SizedBox(height: 20),
            const Text(
              'SmartKasir',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Solusi Kasir Digital UMKM',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 35),
            Text(
              'Memulai dalam $countdown...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// MODEL DATA PRODUK
// ==========================================

class Product {
  final String name;
  final String category;
  final int price;
  final int stock;
  final IconData icon;

  const Product({
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.icon,
  });
}

// ==========================================
// DASHBOARD SMARTKASIR
// ==========================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  String searchText = '';

  final List<Product> products = const [
    Product(
      name: 'Kopi Arabika',
      category: 'Minuman',
      price: 25000,
      stock: 20,
      icon: Icons.coffee,
    ),
    Product(
      name: 'Teh Original',
      category: 'Minuman',
      price: 10000,
      stock: 35,
      icon: Icons.local_cafe,
    ),
    Product(
      name: 'Roti Cokelat',
      category: 'Makanan',
      price: 12000,
      stock: 15,
      icon: Icons.bakery_dining,
    ),
    Product(
      name: 'Keripik Pisang',
      category: 'Camilan',
      price: 15000,
      stock: 25,
      icon: Icons.fastfood,
    ),
  ];

  String rupiah(int value) {
    return 'Rp ${value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  List<Product> get filteredProducts {
    return products.where((product) {
      return product.name.toLowerCase().contains(
        searchText.toLowerCase(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'SmartKasir',
      'Katalog Produk',
      'Transaksi',
      'Profil',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      // HEADER
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),

      // KONTEN HALAMAN
      body: IndexedStack(
        index: selectedIndex,
        children: [
          _buildHome(),
          _buildProducts(),
          _buildPlaceholder(
            'Halaman Transaksi',
            Icons.receipt_long,
            'Fitur transaksi akan dikembangkan selanjutnya.',
          ),
          _buildPlaceholder(
            'Halaman Profil',
            Icons.person,
            'Informasi profil pengguna SmartKasir.',
          ),
        ],
      ),

      // NAVIGASI BAWAH
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ========================================
  // HALAMAN BERANDA
  // ========================================

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Datang!',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Kelola penjualan UMKM dengan mudah.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'Total Produk',
                  '${products.length}',
                  Icons.inventory_2,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryCard(
                  'Total Stok',
                  '${products.fold<int>(
                    0,
                    (total, product) => total + product.stock,
                  )}',
                  Icons.warehouse,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          const Text(
            'Katalog Produk',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          _buildSearchField(),

          const SizedBox(height: 15),

          _buildProductList(),
        ],
      ),
    );
  }

  // ========================================
  // HALAMAN PRODUK
  // ========================================

  Widget _buildProducts() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daftar Produk UMKM',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${products.length} produk tersedia',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _buildSearchField(),
          const SizedBox(height: 15),
          _buildProductList(),
        ],
      ),
    );
  }

  // ========================================
  // PENCARIAN PRODUK
  // ========================================

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchText = value;
        });
      },
      decoration: InputDecoration(
        hintText: 'Cari nama produk...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ========================================
  // DAFTAR KATALOG
  // ========================================

  Widget _buildProductList() {
    if (filteredProducts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Text('Produk tidak ditemukan.'),
        ),
      );
    }

    return Column(
      children: filteredProducts.map((product) {
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFE0E7FF),
              child: Icon(
                product.icon,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${product.category} • Stok: ${product.stock}',
            ),
            trailing: Text(
              rupiah(product.price),
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ========================================
  // KARTU RINGKASAN
  // ========================================

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: Colors.white,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // HALAMAN TRANSAKSI DAN PROFIL
  // ========================================

  Widget _buildPlaceholder(
    String title,
    IconData icon,
    String description,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 75,
              color: const Color(0xFF1E3A8A),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
