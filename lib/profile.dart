import 'package:flutter/material.dart';
import 'home.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('img/profil.png'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Alfian Bernardo Rusli',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('714220048', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Mahasiswa D4 Teknik Informatika Universitas Logistik dan Bisnis Internasional',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
