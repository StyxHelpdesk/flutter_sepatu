import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditShoePage extends StatefulWidget {
  final String shoeId;
  final Function refreshData;
  final dynamic shoeData;

  const EditShoePage({
    super.key,
    required this.shoeId,
    required this.refreshData,
    required this.shoeData,
  });

  @override
  _EditShoePageState createState() => _EditShoePageState();
}

class _EditShoePageState extends State<EditShoePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _merkController = TextEditingController();
  final TextEditingController _mamaController = TextEditingController();
  final TextEditingController _ukuranController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _merkController.text = widget.shoeData['merk'] ?? '';
    _mamaController.text = widget.shoeData['mama'] ?? '';
    _ukuranController.text = widget.shoeData['ukuran'] ?? '';
    _hargaController.text = widget.shoeData['harga'] ?? '';
    _deskripsiController.text = widget.shoeData['deskripsi'] ?? '';
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final String? token = prefs.getString('token');

        if (token != null) {
          final response = await Dio().put(
            'https://apis.narasaon.me/api/sepatu/${widget.shoeId}',
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
              const SnackBar(content: Text('Sepatu berhasil diupdate!')),
            );

            widget.refreshData();
            Navigator.pop(context);
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengupdate sepatu.')),
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
      appBar: AppBar(title: const Text('Edit Sepatu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
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
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Simpan Perubahan'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
