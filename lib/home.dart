import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tambah_sepatu.dart';
import 'edit_sepatu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Dio _dio = Dio();
  bool _isLoading = false;
  List<dynamic> _data = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token != null) {
        final response = await _dio.get(
          'https://apis.narasaon.me/api/sepatu',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (response.statusCode == 200) {
          setState(() {
            _data = response.data['data'];
          });
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Token tidak ditemukan.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal mengambil data.')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token != null) {
      try {
        final response = await _dio.delete(
          'https://apis.narasaon.me/api/sepatu/$itemId',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sepatu berhasil dihapus!')),
          );
          _fetchData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghapus sepatu.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _data.isEmpty
              ? const Center(child: Text('Tidak ada data'))
              : ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  final item = _data[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(item['merk']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['deskripsi']),
                          const SizedBox(height: 8),
                          Text(
                            'Ukuran: ${item['ukuran']}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Harga: ${item['harga'] ?? 'Harga tidak tersedia'}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () async {
                                  final itemId = item['id'];
                                  if (itemId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EditShoePage(
                                              shoeId: itemId,
                                              refreshData: _fetchData,
                                              shoeData: item,
                                            ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'ID Sepatu tidak ditemukan.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                              ),
                              TextButton.icon(
                                onPressed: () async {
                                  bool? confirmDelete = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Konfirmasi Hapus'),
                                        content: const Text(
                                          'Apakah Anda yakin ingin menghapus sepatu ini?',
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmDelete == true) {
                                    _deleteItem(item['id']);
                                  }
                                },
                                icon: const Icon(Icons.delete),
                                label: const Text('Hapus'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddShoePage(refreshData: _fetchData),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
