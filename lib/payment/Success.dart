import 'package:flutter/material.dart';
import 'package:flutter_last_app/layout/Home.dart';
import 'package:flutter_last_app/layout/MyGame.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'SUCCESS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Thank you for purchasing the item',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 32),
              _btn('View in library', onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => MyGame()
                  ),
                );
              }),
              const SizedBox(height: 12),
              _btn('Back to store', onTap: () {
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const Home()
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _btn(String label, {required VoidCallback onTap}) => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
    );