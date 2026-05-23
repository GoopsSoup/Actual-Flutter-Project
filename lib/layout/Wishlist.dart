import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'WishlistService.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<Wishlist> {
  final _searchController = TextEditingController();
  final WishlistService _wishlistService = WishlistService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _removeGame(String id, Map<String, dynamic> backingData, String title) async {
    await _wishlistService.removeFromWishlist(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E1E),
        content: Text('$title removed from wishlist', style: const TextStyle(color: Colors.white70)),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFFE8C46A),
          onPressed: () async {
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser == null) return; 

            await FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid) 
                .collection('wishlist')
                .doc(id)
                .set(backingData);
          },
        ),
      ),
    );
  }

  void _addNoteGame(String id, String? currentNote) async {
    final ctrl = TextEditingController(text: currentNote ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Add note', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. Buy on sale, play co-op…',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF333333))),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE8C46A))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Colors.white38))),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('SAVE', style: TextStyle(color: Color(0xFFE8C46A), fontWeight: FontWeight.bold))),
        ],
      ),
    );
    
    if (result != null) {
      await _wishlistService.updateNote(id, result.trim().isEmpty ? null : result.trim());
    }
  }

  void _showOptions(String id, String title, String? note, Map<String, dynamic> rawMap) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const Divider(color: Colors.white12, height: 1),
            _BottomSheetTile(
              icon: Icons.sticky_note_2_outlined,
              label: note == null ? 'Add note' : 'Edit note',
              onTap: () {
                Navigator.pop(ctx);
                _addNoteGame(id, note);
              },
            ),
            _BottomSheetTile(
              icon: Icons.delete_outline,
              label: 'Remove from wishlist',
              color: const Color(0xFFE05C5C),
              onTap: () {
                Navigator.pop(ctx);
                _removeGame(id, rawMap, title);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text('Wishlist', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search here…',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _wishlistService.getWishlistStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFE8C46A)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No games found', style: TextStyle(color: Colors.white38, fontSize: 15)));
                }

                final searchQuery = _searchController.text.toLowerCase();
                final docs = snapshot.data!.docs.where((doc) {
                  return (doc.data()['title'] ?? '').toString().toLowerCase().contains(searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text('No matching items', style: TextStyle(color: Colors.white38, fontSize: 15)));
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data();
                    return _DynamicGameCard(
                      rawData: data,
                      onOptions: () => _showOptions(docs[i].id, data['title'] ?? 'Unknown Title', data['note'] as String?, data),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DynamicGameCard extends StatelessWidget {
  final Map<String, dynamic> rawData;
  final VoidCallback onOptions;

  const _DynamicGameCard({required this.rawData, required this.onOptions});

  @override
  Widget build(BuildContext context) {
    final title = rawData['title'] ?? 'Unknown Title';
    final note = rawData['note'] as String?;
    final imageUrl = rawData['image'] ?? rawData['imageUrl'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: const Color(0xFF1E1E1E),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2A2A2A), Color(0xFF121212)],
                      ),
                    ),
                  ),
                  if (imageUrl.isNotEmpty)
                    imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 24)),
                          )
                        : Image.asset(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 24)),
                          )
                  else
                    const Center(child: Icon(Icons.videogame_asset_outlined, color: Colors.white12, size: 32)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                  if (note != null) ...[
                    const SizedBox(height: 2),
                    Text(note, style: const TextStyle(color: Colors.white38, fontSize: 11, height: 1.3), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onOptions,
              child: const Padding(
                padding: EdgeInsets.only(left: 4, top: 2),
                child: Icon(Icons.more_vert, color: Colors.white54, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BottomSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _BottomSheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: color == Colors.white ? Colors.white70 : color, size: 22),
        title: Text(label, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w500)),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      ),
    );
  }
}