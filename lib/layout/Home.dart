import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_last_app/layout/GamePage.dart';
import 'MyGame.dart';
import 'Games.dart'; 
import 'Profile.dart';
import 'Auth.dart';
import 'Wishlist.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFFFFF),
          surface: Color(0xFF2A2A2A),
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomePage(), 
    );
  }
}

void _executeProtectedAction(BuildContext context, VoidCallback action) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    _showSignInPopup(context);
  } else {
    action();
  }
}

// ─── Main Shell with Bottom Navigation Bar ───────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // The pages for our bottom navigation destinations
  final List<Widget> _pages = [
    const _HomeCatalog(),
    const Wishlist(),
    const MyGame(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: const Color(0xFF151515),
        selectedItemColor: const Color(0xFFE53935), // Red accent to match your titles
        unselectedItemColor: const Color(0xFF888888),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports_outlined), activeIcon: Icon(Icons.sports_esports), label: 'My Games'),
        ],
      ),
    );
  }
}

// ─── Extracted Home Catalog Layout ──────────────────────────────────────────

class _HomeCatalog extends StatefulWidget {
  const _HomeCatalog();

  @override
  State<_HomeCatalog> createState() => _HomeCatalogState();
}

class _HomeCatalogState extends State<_HomeCatalog> {
  late Future<List<GameModel>> _gamesFuture;

  @override
  void initState() {
    super.initState();
    _gamesFuture = _loadGamesJson();
  }

  Future<List<GameModel>> _loadGamesJson() async {
    final String response = await rootBundle.loadString('assets/data/games.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((json) => GameModel.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GameModel>>(
      future: _gamesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Error loading catalog data"));
        }

        final allGames = snapshot.data!;

        final featuredGame = allGames.firstWhere(
          (g) => g.section == 'featured',
          orElse: () => allGames.first,
        );
        final bestSellingGames = allGames.where((g) => g.section == 'best_selling').toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SearchBar(),
              const SizedBox(height: 24),

              const _SectionTitle(title: 'Today Recommendation'),
              const SizedBox(height: 12),
              _FeaturedGameCard(game: featuredGame),

              const SizedBox(height: 32),

              const _SectionTitle(title: 'Popular'),
              const SizedBox(height: 12),
              const _PopularGamesRow(),

              const SizedBox(height: 32),

              const _SectionTitle(title: 'Best Selling'),
              const SizedBox(height: 12),
              _BestSellingList(games: bestSellingGames),

              const SizedBox(height: 32),
              const _Footer(),
            ],
          ),
        );
      },
    );
  }
}

// ─── Pop-up Dialog ───────────────────────────────────────────────────────────

void _showSignInPopup(BuildContext parentContext) {
  showDialog(
    context: parentContext,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      title: const Text('Sign In Required'),
      content: const Text('You need to be signed in to access this feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            Navigator.push(
              parentContext,
              MaterialPageRoute(builder: (_) => const SignInPage())
            );
          },
          child: const Text('Sign In', style: TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

// ─── Search Bar (Reactive to Auth Changes) ────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  SizedBox(width: 12),
                  Icon(Icons.search, color: Color(0xFF888888), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final isAuthenticated = snapshot.hasData && snapshot.data != null;

              if (isAuthenticated) {
                return OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Profile()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    side: const BorderSide(color: Colors.white, width: 0.5),
                    fixedSize: const Size(44, 44),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.person_outline, color: Color(0xFFCCCCCC), size: 22),
                );
              } else {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 232, 232, 232),
                    foregroundColor: const Color.fromARGB(255, 33, 33, 33),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Sign In', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            width: 40,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Featured Game Card ───────────────────────────────────────────────────────

class _FeaturedGameCard extends StatelessWidget {
  final GameModel game;
  const _FeaturedGameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Image.asset(game.image)),
          const SizedBox(height: 10),
          Row(
            children: [
              ...game.tags.map((t) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _Tag(label: t),
              )),
              const Spacer(),
              Text(game.rating, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text(game.desc, style: const TextStyle(color: Color(0xFFCCCCCC), fontSize: 13, height: 1.4)),
          const SizedBox(height: 14),
          _BuyButton(game: game),
        ],
      ),
    );
  }
}

// ─── Tag Chip ─────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 10)),
    );
  }
}

// ─── Buy Button ───────────────────────────────────────────────────────────────

class _BuyButton extends StatelessWidget {
  final GameModel game;
  const _BuyButton({required this.game});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        _executeProtectedAction(context, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GamePage(game: game),
            ),
          );
        });
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.white, width: 1.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      ),
      child: const Text("BUY"),
    );
  }
}

// ─── Popular Games Row ────────────────────────────────────────────────────────

class _PopularGamesRow extends StatelessWidget {
  const _PopularGamesRow();

  static const List<Map<String, dynamic>> _games = [
    {'label': 'Game 1', 'image': 'lib/images/tlou.jpg'},
    {'label': 'Game 2', 'image': 'lib/images/fire.jpg'},
    {'label': 'Game 3', 'image': 'lib/images/sekiro.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _games.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final g = _games[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Image.asset(g['image'] as String, width: 280, height: 140, fit: BoxFit.fill),
          );
        },
      ),
    );
  }
}

// ─── Best Selling List ────────────────────────────────────────────────────────

class _BestSellingList extends StatelessWidget {
  final List<GameModel> games;
  const _BestSellingList({required this.games});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: games.map((g) => Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _BestSellingItem(game: g),
      )).toList(),
    );
  }
}

class _BestSellingItem extends StatelessWidget {
  final GameModel game;
  const _BestSellingItem({required this.game});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90,
            height: 120,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(game.image, width: 90, height: 120, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(game.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(game.desc, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 12, height: 1.45)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _BuyButton(game: game),
                    const Spacer(),
                    Text(game.rating, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: const Wrap(
        spacing: 20,
        children: [
          Text('Privacy Policy', style: TextStyle(color: Color(0xFF666666), fontSize: 11)),
          Text('Legal', style: TextStyle(color: Color(0xFF666666), fontSize: 11)),
          Text('Accessibility', style: TextStyle(color: Color(0xFF666666), fontSize: 11)),
          Text('Cookies', style: TextStyle(color: Color(0xFF666666), fontSize: 11)),
        ],
      ),
    );
  }
}