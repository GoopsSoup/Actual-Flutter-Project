import 'package:flutter/material.dart';
import 'package:flutter_last_app/payment/Venmo.dart';
import 'package:flutter_last_app/payment/Dana.dart';
import 'package:flutter_last_app/payment/Paypal.dart';
import 'package:flutter_last_app/payment/Bank.dart';
import 'package:flutter_last_app/layout/Games.dart'; // Imports GameModel

const _bg = Color(0xFF0A0A0A);
const _card = Color(0xFF1E1E1E);
const _border = Color(0xFF2A2A2A);
const _green = Color(0xFF39FF14);

class Payment extends StatefulWidget {
  // 1. Pass the full GameModel object here instead of a plain string
  final GameModel gameToBuy;

  const Payment({super.key, required this.gameToBuy});

  @override
  State<Payment> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<Payment> {
  String? _selected;
  bool _agreeEmail = true;
  bool _agreeTerms = true;

  final _methods = const [
    ('paypal', 'Paypal', Icons.paypal),
    ('dana', 'Dana', Icons.account_balance_wallet),
    ('venmo', 'Venmo', Icons.attach_money),
    ('bank', 'Bank accounts', Icons.account_balance),
  ];

  void _onPurchase() {
    if (_selected == null) return;
    
    // 2. We remove 'const' from BankPage because widget.gameToBuy is a runtime value
    final page = switch (_selected) {
      'paypal' => PaypalPage(gameToBuy: widget.gameToBuy),
      'dana'   => DanaPage(gameToBuy: widget.gameToBuy),
      'venmo'  => VenmoPage(gameToBuy: widget.gameToBuy),
      'bank'   => BankPage(gameToBuy: widget.gameToBuy), // Passes the game model object directly
      _        => null,
    };
    if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: _border, height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uses widget.gameToBuy details to populate text fields seamlessly
            Text('You are purchasing ${widget.gameToBuy.title}',
                style: const TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 16),
            const Text('Verify your information and click Purchase',
                style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 16),

            ..._methods.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selected = m.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selected == m.$1 ? _green : _border,
                          width: _selected == m.$1 ? 1.5 : 1,
                        ),
                      ),
                      child: Row(children: [
                        Icon(m.$3, color: Colors.white70, size: 22),
                        const SizedBox(width: 12),
                        Text(m.$2, style: const TextStyle(color: Colors.white, fontSize: 15)),
                      ]),
                    ),
                  ),
                )),

            const Spacer(),

            _Check(
              value: _agreeEmail,
              onChanged: (v) => setState(() => _agreeEmail = v!),
              label:
                  'Click here to agree to share your email with Company name. will use your email address for marketing and otherwise in accordance with its Privacy policy, so we encourage you to read it.',
            ),
            const SizedBox(height: 8),
            _Check(
              value: _agreeTerms,
              onChanged: (v) => setState(() => _agreeTerms = v!),
              label: 'Agree to go-games for buying games',
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selected != null ? _green : const Color(0xFF2A2A2A),
                  foregroundColor: _selected != null ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: _selected != null ? _onPurchase : null,
                child: const Text('Purchase',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white70,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(fontSize: 15)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Check extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;
  const _Check({required this.value, required this.onChanged, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: _green,
            checkColor: Colors.black,
            side: const BorderSide(color: Colors.white38),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
            ),
          ),
        ],
      );
}