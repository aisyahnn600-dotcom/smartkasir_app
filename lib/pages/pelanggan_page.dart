import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/pelanggan.dart';
import '../helpers/database_helper.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({super.key});

  @override
  State<PelangganPage> createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  List<Pelanggan> daftarPelanggan = [];

  final namaController = TextEditingController();
  final waController = TextEditingController();
  final alamatController = TextEditingController();

  double? latitude;
  double? longitude;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    muatPelanggan();
  }

  @override
  void dispose() {
    namaController.dispose();
    waController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  // MEMUAT DATA PELANGGAN
  Future<void> muatPelanggan() async {
    final data = await DatabaseHelper.instance.getAllPelanggan();

    if (!mounted) return;

    setState(() {
      daftarPelanggan = data;
    });
  }

  // MENGAMBIL LOKASI GPS
  Future<void> ambilLokasi() async {
    try {
      setState(() => loading = true);

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi belum diberikan.');
      }

      final posisi = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        latitude = posisi.latitude;
        longitude = posisi.longitude;
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi berhasil diperoleh!')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal mengambil lokasi: $e')));
    }
  }

  // MENYIMPAN PELANGGAN
  Future<void> simpanPelanggan() async {
    if (namaController.text.trim().isEmpty ||
        waController.text.trim().isEmpty ||
        alamatController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua data pelanggan wajib diisi!')),
      );
      return;
    }

    final kode = 'CUST-${DateTime.now().millisecondsSinceEpoch}';

    final pelanggan = Pelanggan(
      kodePelanggan: kode,
      namaPelanggan: namaController.text.trim(),
      nomorWa: waController.text.trim(),
      alamat: alamatController.text.trim(),
      latitude: latitude,
      longitude: longitude,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await DatabaseHelper.instance.insertPelanggan(pelanggan);

      namaController.clear();
      waController.clear();
      alamatController.clear();

      setState(() {
        latitude = null;
        longitude = null;
      });

      await muatPelanggan();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pelanggan berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  // MEMBUKA GOOGLE MAPS
  Future<void> bukaMaps(Pelanggan pelanggan) async {
    if (!pelanggan.hasLocation) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${pelanggan.latitude},${pelanggan.longitude}',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // MENGHAPUS PELANGGAN
  Future<void> hapusPelanggan(int id) async {
    await DatabaseHelper.instance.deletePelanggan(id);
    await muatPelanggan();
  }

  // FORM INPUT PELANGGAN
  void tampilkanForm() {
    namaController.clear();
    waController.clear();
    alamatController.clear();

    latitude = null;
    longitude = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tambah Pelanggan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Pelanggan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: waController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor WhatsApp',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: alamatController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Alamat Pelanggan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: loading
                            ? null
                            : () async {
                                await ambilLokasi();
                                setModalState(() {});
                              },
                        icon: const Icon(Icons.my_location),
                        label: Text(
                          loading ? 'Mengambil Lokasi...' : 'Ambil Lokasi GPS',
                        ),
                      ),
                    ),

                    if (latitude != null && longitude != null)
                      Text(
                        'Koordinat: ${latitude!.toStringAsFixed(6)}, '
                        '${longitude!.toStringAsFixed(6)}',
                        style: const TextStyle(color: Colors.green),
                      ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await simpanPelanggan();

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Pelanggan'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Pelanggan'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),

      body: RefreshIndicator(
        onRefresh: muatPelanggan,
        child: daftarPelanggan.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 180),
                  Center(child: Text('Belum ada data pelanggan')),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: daftarPelanggan.length,
                itemBuilder: (context, index) {
                  final pelanggan = daftarPelanggan[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(
                        pelanggan.namaPelanggan,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${pelanggan.nomorWa}\n'
                        '${pelanggan.alamat}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'maps') {
                            bukaMaps(pelanggan);
                          } else if (value == 'hapus') {
                            hapusPelanggan(pelanggan.id!);
                          }
                        },
                        itemBuilder: (context) => [
                          if (pelanggan.hasLocation)
                            const PopupMenuItem(
                              value: 'maps',
                              child: Text('Lihat Google Maps'),
                            ),
                          const PopupMenuItem(
                            value: 'hapus',
                            child: Text('Hapus Pelanggan'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: tampilkanForm,
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Pelanggan'),
      ),
    );
  }
}
