import 'package:flutter/material.dart';
import 'package:flutter_last_app/payment/Success.dart';
import 'package:flutter_last_app/layout/Games.dart'; 
import 'package:flutter_last_app/layout/MyGamesService.dart';

class DanaPage extends StatefulWidget {
  final GameModel gameToBuy;

  const DanaPage({super.key, required this.gameToBuy});

  @override
  State<DanaPage> createState() => _DanaPageState();
}

class _DanaPageState extends State<DanaPage> {
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
        title: const Text('Dana', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
            _isProcessing 
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : _continueBtn(),
          ],
        ),
      ),
    );
  }

  Widget _continueBtn() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing 
            ? null 
            : () async {
                setState(() => _isProcessing = true);
                try {
                  await _gamesService.purchaseGame(widget.gameToBuy);

                  if (!mounted) return;

                  Navigator.pushReplacement(
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