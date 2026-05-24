import 'package:flutter/material.dart';
import 'package:flutter_last_app/payment/Success.dart';
import 'package:flutter_last_app/layout/Games.dart'; // Make sure path points to your GameModel file
import 'package:flutter_last_app/layout/MyGamesService.dart';

class BankPage extends StatefulWidget {
  final GameModel gameToBuy;

  const BankPage({super.key, required this.gameToBuy});

  @override
  State<BankPage> createState() => _BankPageState();
}

class _BankPageState extends State<BankPage> {
  String _country = 'Indonesia';
  bool _isProcessing = false;
  final MyGamesService _gamesService = MyGamesService();

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
            _isProcessing 
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _continueBtn(),
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

  Widget _continueBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing 
            ? null // Prevents accidental double-tapping while writing data
            : () async {
                setState(() => _isProcessing = true);
                try {
                  // 1. Write purchase record passing the entire object cleanly
                  await _gamesService.purchaseGame(widget.gameToBuy);

                  if (!mounted) return;

                  // 2. Head to success screen
                  Navigator.pushReplacement( // Use pushReplacement so they can't hit 'back' to pay again
                    context,
                    MaterialPageRoute(builder: (context) => const SuccessPage()),
                  );
                } catch (e) {
                  if (!mounted) return;
                  setState(() => _isProcessing = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Payment failure: ${e.toString()}')),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white30,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
              )
            : const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
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