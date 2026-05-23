import 'package:flutter/material.dart';

class MyGame extends StatelessWidget {
  const MyGame({super.key});

  static const List<Map<String, dynamic>> _games = [
    {
      'title': 'Lies of P',
      'gradient': [Color(0xFF1A2A3A), Color(0xFF0D1520)],
    },
    {
      'title': 'Uncharted 4',
      'gradient': [Color(0xFF1A3A2A), Color(0xFF0D2010)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Text(
                    'My games',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider ──────────────────────────────────────────────────
            Divider(color: Colors.white.withOpacity(0.1), height: 1),

            // ── Game Grid ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 16 / 10,
                  ),
                  itemCount: _games.length,
                  itemBuilder: (context, i) => _GameCard(game: _games[i]),
                ),
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────
            _Footer(),
          ],
        ),
      ),
    );
  }
}

// ── Game Card ─────────────────────────────────────────────────────────────────

class _GameCard extends StatelessWidget {
  final Map<String, dynamic> game;
  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: List<Color>.from(game['gradient'] as List),
          ),
        ),
        child: Stack(
          children: [
            // Grid texture
            CustomPaint(painter: _GridPainter(), size: Size.infinite),
            // Placeholder icon + label
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_outlined,
                      color: Colors.white.withOpacity(0.2), size: 28),
                  const SizedBox(height: 6),
                  Text(
                    game['title'] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 0.5;
    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '©2025 Andhika Dwi Wiratmoko/Go-Games. All rights served',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.28),
                      fontSize: 10,
                      height: 1.5),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 14,
                  children: ['Privacy Policy', 'Legal', 'Accessibility', 'Cookies']
                      .map((s) => Text(s,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.25),
                          )))
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // "G" logo badge
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}