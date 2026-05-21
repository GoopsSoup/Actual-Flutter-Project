import 'package:flutter/material.dart';
import 'package:flutter_last_app/payment/Success.dart';

class PaypalPage extends StatelessWidget {
  const PaypalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Paypal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Account name'),
            _field('Account name....'),
            const SizedBox(height: 16),
            _label('Account number'),
            _field('Account number....'),
            const Spacer(),
            _continueBtn(),
          ],
        ),
      ),
    );
  }
}

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    );

Widget _field(String hint) => TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );

Widget _continueBtn() => Builder(
  builder: (context) => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const SuccessPage()
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    ),
  );