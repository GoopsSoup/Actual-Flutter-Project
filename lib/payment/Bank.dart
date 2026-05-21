import 'package:flutter/material.dart';
import 'package:flutter_last_app/payment/Success.dart';

class BankPage extends StatefulWidget {
  const BankPage({super.key});

  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  String _country = 'Indonesia';

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
        title: const Text('Bank', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Card number'),
            _field('1231029312301932109323', keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('First name'), _field('')])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_label('Last name'), _field('')])),
            ]),
            const SizedBox(height: 16),
            _label('Country'),
            _dropdown(),
            const SizedBox(height: 16),
            _label('Phone number'),
            _field('+1 222 222 22 2', keyboardType: TextInputType.phone),
            const SizedBox(height: 32),
            _continueBtn(),
          ],
        ),
      ),
    );
  }

  Widget _dropdown() => Container(
        decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButton<String>(
          value: _country,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A1A),
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          style: const TextStyle(color: Colors.white),
          onChanged: (v) => setState(() => _country = v!),
          items: ['Indonesia', 'United States', 'Malaysia', 'Singapore']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
        ),
      );
}

Widget _label(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    );

Widget _field(String hint, {TextInputType? keyboardType}) => TextField(
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
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