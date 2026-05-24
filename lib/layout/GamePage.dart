import 'package:flutter/material.dart';
import 'Pay.dart';
import 'Games.dart'; 
import 'WishlistService.dart'; // Ensure your service is imported

final _bodyStyle = TextStyle(
  color: Colors.white.withOpacity(0.7),
  fontSize: 13.5,
  height: 1.65,
);

class GamePage extends StatefulWidget {
  final GameModel game; 

  const GamePage({super.key, required this.game});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  final WishlistService _wishlistService = WishlistService();

  @override
  Widget build(BuildContext context) {
    final game = widget.game;

    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF2A2A2A),
            elevation: 0,
            title: Text(
              game.title, 
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            leading: const BackButton(color: Colors.white), 
          ),
          
          // FIXED: Enforced structured constraints for the Hero banner area
          SliverToBoxAdapter(
            child: _HeroBanner(title: game.title, imagePath: game.image),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: game.tags.map((t) => _Tag(label: t)).toList(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFCC00), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        game.rating,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${game.reviewCount})',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  // FIXED: Passed the current game instance straight into the Buy button
                  Expanded(child: _BuyButton(gameToBuy: game)),
                  const SizedBox(width: 10),
                  
                  // Integrated the Firestore Stream builder cleanly here
                  StreamBuilder<bool>(
                    stream: _wishlistService.isWishlistedStream(game.id.toString()),
                    initialData: false,
                    builder: (context, snapshot) {
                      final isBookmarked = snapshot.data ?? false;
                      return _WishlistButton(
                        active: isBookmarked,
                        onTap: () async {
                          try {
                            await _wishlistService.toggleWishlist(game, isBookmarked);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'About this game'),
                  const SizedBox(height: 10),
                  Text(
                    game.compDesc,
                    style: _bodyStyle,
                  ),
                  const SizedBox(height: 16),
                  
                  if (game.innerImageUrls.isNotEmpty) ...[
                    ...game.innerImageUrls.map((imageUrl) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl.startsWith('http')
                            ? Image.network(imageUrl)
                            : Image.asset(imageUrl),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionHeader(title: 'System Requirements'),
                  const SizedBox(height: 14),
                  _ReqCard(heading: 'Minimum', items: game.minimumRequirements),
                  const SizedBox(height: 12),
                  _ReqCard(heading: 'Recommended', items: game.recommendedRequirements),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
              child: Text(
                '© NEOWIZ All rights reserved.',
                style: TextStyle(color: Colors.white.withOpacity(0.28), fontSize: 11),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Wrap(
                spacing: 16,
                children: ['Privacy Policy', 'Legal', 'Accessibility', 'Cookies']
                    .map((s) => Text(s,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 11,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.25))))
                    .toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── REFACTORED Hero Banner (Handles Assets, URLs, and Aspect Ratio Constraints) ──

class _HeroBanner extends StatelessWidget {
  final String title;
  final String imagePath;

  const _HeroBanner({required this.title, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imagePath.startsWith('http://') || imagePath.startsWith('https://');

    return AspectRatio(
      aspectRatio: 16 / 9, 
      child: Container(
        width: double.infinity,
        color: const Color(0xFF1A1A1A), 
        child: Stack(
          fit: StackFit.expand,
          children: [
            isNetworkImage
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 40),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF3B30), strokeWidth: 2),
                      );
                    },
                  )
                : Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.image_not_supported_outlined, color: Colors.white24, size: 40),
                    ),
                  ),
            
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Color(0xFF2A2A2A), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tag ───────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

// ── Buy Button (FIXED Layout & Variable Routing) ──────────────────────────────

class _BuyButton extends StatefulWidget {
  final GameModel gameToBuy; // 1. Added variable to hold passed model info

  const _BuyButton({required this.gameToBuy});

  @override
  State<_BuyButton> createState() => _BuyButtonState();
}

class _BuyButtonState extends State<_BuyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 110),
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _pressed
                ? [const Color(0xFFCC2E25), const Color(0xFFCC2E25)]
                : [const Color(0xFFFF3B30), const Color(0xFFFF6B35)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: _pressed
              ? []
              : [BoxShadow(color: const Color(0xFFFF3B30).withOpacity(0.38), blurRadius: 16, offset: const Offset(0, 5))],
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            minimumSize: Size.infinite, 
          ),
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(
                // 2. Access via widget context and fixed missing parenthesis syntax error
                builder: (context) => Payment(gameToBuy: widget.gameToBuy),
              ),
            );
          }, 
          child: const Text(
            'Buy',
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Wishlist Button ───────────────────────────────────────────────────────────

class _WishlistButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _WishlistButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFFF3B30).withOpacity(0.18) : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? const Color(0xFFFF3B30).withOpacity(0.5) : Colors.white.withOpacity(0.12),
          ),
        ),
        child: Icon(
          active ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
          color: active ? const Color(0xFFFF3B30) : Colors.white54,
          size: 22,
        ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2)),
        const SizedBox(height: 6),
        Container(
          width: 32, height: 2.5,
          decoration: BoxDecoration(color: const Color(0xFFFF3B30), borderRadius: BorderRadius.circular(2)),
        ),
      ],
    );
  }
}

// ── Requirements Card ─────────────────────────────────────────────────────────

class _ReqCard extends StatelessWidget {
  final String heading;
  final List<String> items;
  const _ReqCard({required this.heading, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5, right: 8),
                      child: Container(
                        width: 4, height: 4,
                        decoration: const BoxDecoration(color: Color(0xFFFF3B30), shape: BoxShape.circle),
                      ),
                    ),
                    Expanded(
                      child: Text(item,
                          style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 12, height: 1.5)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}