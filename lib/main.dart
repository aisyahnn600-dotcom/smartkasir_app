import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/produk.dart';
import 'helpers/database_helper.dart';
import 'pages/dashboard_page.dart';

// ==========================================
// WARNA SMARTKASIR
// ==========================================

const Color biruMuda = Color(0xFF60A5FA);
const Color biruNavy = Color(0xFF1E3A8A);
const Color latarBiru = Color(0xFFF0F5FF);

// ==========================================
// FORMAT RUPIAH
// ==========================================

String rupiah(num value) {
  final number = value.toInt().toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );

  return 'Rp $number';
}

// ==========================================
// MODEL TRANSAKSI
// ==========================================

class Sale {
  final String id;
  final String date;
  final List<Map<String, dynamic>> items;
  final int total;

  Sale({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'date': date, 'items': items, 'total': total};
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'].toString(),
      date: json['date'].toString(),
      items: (json['items'] as List)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      total: (json['total'] as num).toInt(),
    );
  }
}

// ==========================================
// MAIN
// ==========================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartKasirApp());
}

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
          seedColor: biruNavy,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: latarBiru,

        appBarTheme: const AppBarTheme(
          backgroundColor: biruNavy,
          foregroundColor: Colors.white,
          centerTitle: false,
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFE8EEFF),
          indicatorColor: biruMuda.withValues(alpha: 0.25),
          labelTextStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 12)),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}

// ==========================================
// SPLASH SCREEN
// ==========================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? timer;
  int countdown = 10;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (countdown > 1) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [biruMuda, biruNavy],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.point_of_sale,
                  color: Colors.white,
                  size: 75,
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'SmartKasir',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Solusi Kasir Digital UMKM',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 30),

              Text(
                'Memulai dalam $countdown...',
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 20),

              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// DASHBOARD UTAMA
// ==========================================

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  bool loading = true;
  int catalogKey = 0;

  final List<Produk> products = [];
  final List<Sale> sales = [];
  final Map<int, int> cart = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ========================================
  // MEMUAT DATA
  // ========================================

  Future<void> loadData() async {
    try {
      final databaseProducts = await DatabaseHelper.instance.getAllProduk();

      final prefs = await SharedPreferences.getInstance();
      final salesData = prefs.getString('sales');

      products
        ..clear()
        ..addAll(databaseProducts);

      sales.clear();

      if (salesData != null) {
        final decoded = jsonDecode(salesData) as List;

        sales.addAll(
          decoded.map(
            (item) => Sale.fromJson(Map<String, dynamic>.from(item as Map)),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        showMessage('Gagal membaca data: $error');
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  // ========================================
  // MENYIMPAN TRANSAKSI
  // ========================================

  Future<void> saveSales() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'sales',
      jsonEncode(sales.map((item) => item.toJson()).toList()),
    );
  }

  // ========================================
  // NOTIFIKASI
  // ========================================

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ========================================
  // MENCARI PRODUK
  // ========================================

  Produk? findProduct(int id) {
    for (final product in products) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

  // ========================================
  // MENAMBAHKAN KE KERANJANG
  // ========================================

  void addToCart(Produk product) {
    final id = product.id;

    if (id == null) return;

    final currentQuantity = cart[id] ?? 0;

    if (currentQuantity >= product.stok) {
      showMessage('Stok produk tidak mencukupi.');
      return;
    }

    setState(() {
      cart[id] = currentQuantity + 1;
    });

    showMessage('${product.nama} masuk keranjang.');
  }

  // ========================================
  // MENGURANGI KERANJANG
  // ========================================

  void removeFromCart(int id) {
    setState(() {
      final quantity = cart[id] ?? 0;

      if (quantity <= 1) {
        cart.remove(id);
      } else {
        cart[id] = quantity - 1;
      }
    });
  }

  // ========================================
  // TOTAL KERANJANG
  // ========================================

  int get cartTotal {
    int total = 0;

    for (final entry in cart.entries) {
      final product = findProduct(entry.key);

      if (product != null) {
        final price = (product.hargaJual * (1 - product.diskonPersen / 100))
            .round();

        total += price * entry.value;
      }
    }

    return total;
  }

  // ========================================
  // TOTAL PENDAPATAN
  // ========================================

  int get totalRevenue {
    return sales.fold<int>(0, (total, sale) => total + sale.total);
  }

  // ========================================
  // CHECKOUT
  // ========================================

  Future<void> checkout() async {
    if (cart.isEmpty) {
      showMessage('Keranjang masih kosong.');
      return;
    }

    final items = <Map<String, dynamic>>[];

    for (final entry in cart.entries) {
      final product = findProduct(entry.key);

      if (product == null || product.stok < entry.value) {
        showMessage('Stok produk tidak mencukupi.');
        return;
      }

      final harga = (product.hargaJual * (1 - product.diskonPersen / 100))
          .round();

      items.add({
        'name': product.nama,
        'price': harga,
        'quantity': entry.value,
        'subtotal': harga * entry.value,
      });
    }

    final total = cartTotal;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Pembayaran'),
          content: Text('Total pembayaran:\n${rupiah(total)}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Bayar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      // Perbarui stok SQLite.
      for (final entry in cart.entries) {
        final product = findProduct(entry.key);

        if (product == null) continue;

        final produkBaru = Produk(
          id: product.id,
          kodeProduk: product.kodeProduk,
          nama: product.nama,
          kategori: product.kategori,
          hargaBeli: product.hargaBeli,
          hargaJual: product.hargaJual,
          stok: product.stok - entry.value,
          gambarUrl: product.gambarUrl,
          diskonPersen: product.diskonPersen,
        );

        await DatabaseHelper.instance.updateProduk(produkBaru);
      }

      final transaksiBaru = Sale(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: DateTime.now().toString().split('.').first,
        items: items,
        total: total,
      );

      sales.insert(0, transaksiBaru);

      await saveSales();

      cart.clear();

      final dataTerbaru = await DatabaseHelper.instance.getAllProduk();

      if (!mounted) return;

      setState(() {
        products
          ..clear()
          ..addAll(dataTerbaru);

        catalogKey++;
      });

      showMessage('Transaksi berhasil disimpan!');
    } catch (error) {
      showMessage('Gagal menyimpan transaksi: $error');
    }
  }

  // ========================================
  // TAMPILAN UTAMA
  // ========================================

  @override
  Widget build(BuildContext context) {
    final titles = ['SmartKasir', 'Katalog Produk', 'Transaksi', 'Profil'];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: selectedIndex,
              children: [
                buildHome(),

                ProductCatalogPage(key: ValueKey(catalogKey), embedded: true),

                buildTransactions(),

                buildProfile(),
              ],
            ),

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
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  // ========================================
  // KARTU RINGKASAN
  // ========================================

  Widget summaryCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: biruNavy, size: 28),

            const SizedBox(height: 12),

            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: biruNavy,
                ),
              ),
            ),

            const SizedBox(height: 5),

            Text(title),
          ],
        ),
      ),
    );
  }

  // ========================================
  // HALAMAN BERANDA
  // ========================================

  Widget buildHome() {
    final totalStok = products.fold<int>(
      0,
      (total, product) => total + product.stok,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [biruMuda, biruNavy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),

          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.storefront, color: Colors.white, size: 38),

              SizedBox(height: 12),

              Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 8),

              Text(
                'Kelola penjualan UMKM dengan mudah bersama SmartKasir.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Ringkasan Bisnis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: biruNavy,
          ),
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: summaryCard(
                'Total Produk',
                '${products.length}',
                Icons.inventory_2,
              ),
            ),

            Expanded(
              child: summaryCard('Total Stok', '$totalStok', Icons.warehouse),
            ),
          ],
        ),

        Row(
          children: [
            Expanded(
              child: summaryCard(
                'Transaksi',
                '${sales.length}',
                Icons.receipt_long,
              ),
            ),

            Expanded(
              child: summaryCard(
                'Pendapatan',
                rupiah(totalRevenue),
                Icons.payments,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        const Text(
          'Produk Tersedia',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: biruNavy,
          ),
        ),

        const SizedBox(height: 12),

        ...products.map(
          (product) => Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: biruMuda.withValues(alpha: 0.2),
                child: const Icon(Icons.shopping_bag, color: biruNavy),
              ),

              title: Text(product.nama),

              subtitle: Text('${product.kategori} | Stok: ${product.stok}'),

              trailing: Text(
                rupiah(product.hargaJual),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: biruNavy,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ========================================
  // HALAMAN TRANSAKSI
  // ========================================

  Widget buildTransactions() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Keranjang Belanja',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: biruNavy,
          ),
        ),

        const SizedBox(height: 12),

        if (cart.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Keranjang kosong. Tambahkan produk melalui menu Produk.',
              ),
            ),
          ),

        ...cart.entries.map((entry) {
          final product = findProduct(entry.key);

          if (product == null) {
            return const SizedBox.shrink();
          }

          final harga = (product.hargaJual * (1 - product.diskonPersen / 100))
              .round();

          return Card(
            child: ListTile(
              title: Text(product.nama),

              subtitle: Text('${entry.value} x ${rupiah(harga)}'),

              trailing: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                children: [
                  IconButton(
                    onPressed: () {
                      removeFromCart(product.id!);
                    },
                    icon: const Icon(Icons.remove_circle_outline),
                  ),

                  Text('${entry.value}'),

                  IconButton(
                    onPressed: () {
                      addToCart(product);
                    },
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Total Pembayaran'),

                const SizedBox(height: 8),

                Text(
                  rupiah(cartTotal),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: biruNavy,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: cart.isEmpty ? null : checkout,
                    icon: const Icon(Icons.payment),
                    label: const Text('Bayar Sekarang'),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Riwayat Transaksi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: biruNavy,
          ),
        ),

        const SizedBox(height: 12),

        if (sales.isEmpty) const Text('Belum ada transaksi.'),

        ...sales.map(
          (sale) => Card(
            child: ExpansionTile(
              title: Text('Transaksi ${sale.id}'),

              subtitle: Text(sale.date),

              trailing: Text(
                rupiah(sale.total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: biruNavy,
                ),
              ),

              children: [
                ...sale.items.map(
                  (item) => ListTile(
                    title: Text(item['name'].toString()),

                    subtitle: Text(
                      '${item['quantity']} x '
                      '${rupiah((item['price'] as num).toInt())}',
                    ),

                    trailing: Text(rupiah((item['subtotal'] as num).toInt())),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ========================================
  // HALAMAN PROFIL
  // ========================================

  Widget buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 24),

        Center(
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [biruMuda, biruNavy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.store, size: 55, color: Colors.white),
          ),
        ),

        const SizedBox(height: 16),

        const Center(
          child: Text(
            'SmartKasir',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: biruNavy,
            ),
          ),
        ),

        const SizedBox(height: 8),

        const Center(child: Text('Aplikasi Kasir Digital UMKM')),

        const SizedBox(height: 24),

        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.info_outline, color: biruNavy),
                title: Text('Nama Aplikasi'),
                subtitle: Text('SmartKasir'),
              ),

              Divider(height: 1),

              ListTile(
                leading: Icon(Icons.business, color: biruNavy),
                title: Text('Kategori'),
                subtitle: Text('Manajemen Penjualan UMKM'),
              ),

              Divider(height: 1),

              ListTile(
                leading: Icon(Icons.storage, color: biruNavy),
                title: Text('Penyimpanan'),
                subtitle: Text('SQLite Database'),
              ),

              Divider(height: 1),

              ListTile(
                leading: Icon(Icons.code, color: biruNavy),
                title: Text('Framework'),
                subtitle: Text('Flutter'),
              ),

              Divider(height: 1),

              ListTile(
                leading: Icon(Icons.verified_outlined, color: biruNavy),
                title: Text('Versi'),
                subtitle: Text('1.0.0'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
