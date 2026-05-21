import 'package:flutter/material.dart';


void main() => runApp(const Wishlist());

// ── Data model ────────────────────────────────────────────────────────────────
class _Game {
  final String id;
  String title;
  String? note;

  _Game({required this.id, required this.title, this.note});
}

// ── WishlistPage ─────────────────────────────────────────────────────────────
class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<Wishlist> {
  final _searchController = TextEditingController();

  final List<_Game> _games = [
    _Game(id: '1', title: 'Dying Light', note: 'Good night, Good luck'),
    _Game(id: '2', title: 'Hogwarts Legacy'),
    _Game(id: '3', title: 'The Witcher 3: Wild Hunt'),
  ];

  List<_Game> get _filtered {
    final q = _searchController.text.toLowerCase();
    if (q.isEmpty) return _games;
    return _games.where((g) => g.title.toLowerCase().contains(q)).toList();
  }

  // ── helpers ─────────────────────────────────────────────────────────────────

  void _removeGame(_Game game) {
    setState(() => _games.removeWhere((g) => g.id == game.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E1E),
        content: Text(
          '${game.title} removed from wishlist',
          style: const TextStyle(color: Colors.white70),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFFE8C46A),
          onPressed: () => setState(() => _games.add(game)),
        ),
      ),
    );
  }

  void _renameGame(_Game game) async {
    final ctrl = TextEditingController(text: game.title);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Rename game', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE8C46A)),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE8C46A), width: 2),
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Save', style: TextStyle(color: Color(0xFFE8C46A))),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      setState(() => game.title = result.trim());
    }
  }

  void _addNoteGame(_Game game) async {
    final ctrl = TextEditingController(text: game.note ?? '');
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
          decoration: InputDecoration(
            hintText: 'e.g. Buy on sale, play co-op…',
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF333333)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFE8C46A)),
            ),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Save', style: TextStyle(color: Color(0xFFE8C46A))),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() => game.note = result.trim().isEmpty ? null : result.trim());
    }
  }

  void _showOptions(_Game game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                game.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            _BottomSheetTile(
              icon: Icons.edit_outlined,
              label: 'Rename',
              onTap: () {
                Navigator.pop(ctx);
                _renameGame(game);
              },
            ),
            _BottomSheetTile(
              icon: Icons.sticky_note_2_outlined,
              label: game.note == null ? 'Add note' : 'Edit note',
              onTap: () {
                Navigator.pop(ctx);
                _addNoteGame(game);
              },
            ),
            _BottomSheetTile(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share coming soon!')),
                );
              },
            ),
            _BottomSheetTile(
              icon: Icons.delete_outline,
              label: 'Remove from wishlist',
              color: const Color(0xFFE05C5C),
              onTap: () {
                Navigator.pop(ctx);
                _removeGame(game);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final games = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      // ── AppBar ──────────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Wishlist',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Add game',
            onPressed: () async {
              final ctrl = TextEditingController();
              final name = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF1A1A1A),
                  title: const Text('Add to wishlist',
                      style: TextStyle(color: Colors.white)),
                  content: TextField(
                    controller: ctrl,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Game title…',
                      hintStyle: TextStyle(color: Colors.white38),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFE8C46A)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Color(0xFFE8C46A), width: 2),
                      ),
                    ),
                    onSubmitted: (v) => Navigator.pop(ctx, v),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white54)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, ctrl.text),
                      child: const Text('Add',
                          style: TextStyle(color: Color(0xFFE8C46A))),
                    ),
                  ],
                ),
              );
              if (name != null && name.trim().isNotEmpty) {
                setState(() => _games.add(_Game(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: name.trim(),
                    )));
              }
            },
          ),
        ],
      ),

      // ── Body ────────────────────────────────────────────────────────────────
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search here…',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white38, size: 20),
                filled: true,
                fillColor: const Color(0xFF1C1C1C),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Grid
          Expanded(
            child: games.isEmpty
                ? const Center(
                    child: Text(
                      'No games found',
                      style: TextStyle(color: Colors.white38, fontSize: 15),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: games.length,
                    itemBuilder: (_, i) => _GameCard(
                      game: games[i],
                      onOptions: () => _showOptions(games[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── GameCard ──────────────────────────────────────────────────────────────────
class _GameCard extends StatelessWidget {
  final _Game game;
  final VoidCallback onOptions;

  const _GameCard({required this.game, required this.onOptions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail placeholder
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: const Color(0xFF1E1E1E),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient overlay for visual interest
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2A2A2A),
                          const Color(0xFF121212),
                        ],
                      ),
                    ),
                  ),
                  // Placeholder icon
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.videogame_asset_outlined,
                          color: Colors.white12,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                  // Subtle grid lines for texture
                  CustomPaint(painter: _GridPainter()),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Title row + three-dot menu
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (game.note != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      game.note!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onOptions,
              child: const Padding(
                padding: EdgeInsets.only(left: 4, top: 2),
                child: Icon(Icons.more_vert,
                    color: Colors.white54, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Grid texture painter ──────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;
    const step = 20.0;
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

// ── BottomSheet tile ──────────────────────────────────────────────────────────
class _BottomSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _BottomSheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: TextStyle(color: c, fontSize: 15)),
      onTap: onTap,
      dense: true,
    );
  }
}