import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'MyGamesService.dart';

class MyGame extends StatelessWidget {
  MyGame({super.key});
  final MyGamesService _gamesService = MyGamesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('My games', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            ),
            Divider(color: Colors.white.withOpacity(0.08), height: 1),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _gamesService.getOwnedGamesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 2));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("You haven't bought any games yet.", style: TextStyle(color: Colors.white38)));
                  }
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 12, 
                      mainAxisSpacing: 12, 
                      // Adjusted from 1.1 to 1.05 to give more vertical space for the larger title/button
                      childAspectRatio: 1.05 
                    ),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, i) {
                      final doc = snapshot.data!.docs[i];
                      return _GameCard(
                        docId: doc.id,
                        gameData: doc.data(),
                        onRemove: () => _showDeleteDialog(context, doc.id, doc.data()['title'] ?? 'this game'),
                      );
                    },
                  );
                },
              ),
            ),
            const _Footer(),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String docId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151515),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Remove $title?', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to completely remove this game from your inventory?', style: TextStyle(color: Colors.white60, fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () async {
              Navigator.pop(context);
              await _gamesService.removeGame(docId);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> gameData;
  final VoidCallback onRemove;

  const _GameCard({required this.docId, required this.gameData, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final title = gameData['title'] ?? 'Unknown Title';
    final imageUrl = gameData['image'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upper Layer: Image Artwork
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color((title.hashCode & 0xFFFFFF) | 0xFF000000).withBlue(45).withRed(20), const Color(0xFF0D1520)],
                      ),
                    ),
                  ),
                  if (imageUrl.isNotEmpty)
                    imageUrl.startsWith('http')
                        ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox())
                        : Image.asset(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox()),
                  CustomPaint(painter: _GridPainter(), size: Size.infinite),
                  Container(color: Colors.black.withOpacity(0.15)),
                ],
              ),
            ),
          ),
          
          // Bottom Layer: Title and Actions menu bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title, 
                    // Made the font size bigger (from 11 to 13) and bolder (from w600 to w700)
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700), 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  // Increased the delete icon size from 16 to 20, and bumped up opacity for visibility
                  icon: Icon(Icons.delete_outline, size: 20, color: Colors.white.withOpacity(0.65)),
                  onPressed: onRemove,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  splashRadius: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.02)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 20) { canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint); }
    for (double y = 0; y < size.height; y += 20) { canvas.drawLine(Offset(0, y), Offset(size.width, y), paint); }
  }
  @override
  bool shouldRepaint(_) => false;
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('©2026 Andhika Dwi Wiratmoko/Go-Games.', style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 9)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 10,
                  children: ['Privacy', 'Legal', 'Cookies']
                      .map((s) => Text(s, style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10, decoration: TextDecoration.underline)))
                      .toList(),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white.withOpacity(0.08))),
            child: const Center(child: Text('G', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
          ),
        ],
      ),
    );
  }
}