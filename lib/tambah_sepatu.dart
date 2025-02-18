import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddShoePage extends StatefulWidget {
  final Function refreshData; // Callback function to refresh homepage data

  const AddShoePage({super.key, required this.refreshData});

  @override
  _AddShoePageState createState() => _AddShoePageState();
}

class _AddShoePageState extends State<AddShoePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _merkController = TextEditingController();
  final TextEditingController _mamaController = TextEditingController();
  final TextEditingController _ukuranController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  bool _isLoading = false;
  final Dio _dio = Dio();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('token');

        if (token != null) {
          final response = await _dio.post(
            'https://apis.narasaon.me/api/sepatu',
            options: Options(headers: {'Authorization': 'Bearer $token'}),
            data: {
              'merk': _merkController.text,
              'mama': _mamaController.text,
              'ukuran': _ukuranController.text,
              'harga': _hargaController.text,
              'deskripsi': _deskripsiController.text,
            },
          );

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sepatu berhasil ditambahkan!')),
            );

            // Refresh the homepage data by calling the passed callback function
            widget.refreshData();

            // Navigate back to the homepage
            Navigator.pop(context);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan sepatu.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Sepatu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _merkController,
                decoration: const InputDecoration(labelText: 'Merk'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Merk tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _mamaController,
                decoration: const InputDecoration(labelText: 'Nama Model'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama model tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ukuranController,
                decoration: const InputDecoration(labelText: 'Ukuran'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ukuran tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Tambah Sepatu'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
