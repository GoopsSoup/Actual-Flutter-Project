import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_last_app/layout/Friend.dart';
import 'package:flutter_last_app/layout/Home.dart';

const kBg         = Color(0xFF0A0A0A);
const kCard       = Color(0xFF141414);
const kRed        = Color(0xFFFF3B30);
const kGreen      = Color(0xFF34C759);
const kDarkCircle = Color(0xFF1C1C1E);

class Profile extends StatelessWidget {
  const Profile({super.key});

  void _goTo(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  void _onLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Home()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Live Firebase User info
    final user = FirebaseAuth.instance.currentUser;
    
    final String emailDisplay = user?.email ?? 'No email found';
    final String nameDisplay = (user?.displayName == null || user!.displayName!.isEmpty) 
        ? 'Gamer' 
        : user.displayName!;
        
    final String initialLetter = nameDisplay.isNotEmpty 
        ? nameDisplay[0].toUpperCase() 
        : 'G';

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: CustomScrollView(slivers: [

          // Top bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(children: [
                IconButton(
                  onPressed: () => _goTo(context, const Home()),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                ),
                const Text('Profile',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),

          // Avatar + stats (Great to keep as a visual dashboard!)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(children: [
                CircleAvatar(
                  radius: 52,
                  backgroundColor: kDarkCircle,
                  child: Text(initialLetter,
                      style: const TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 18),
                Text(nameDisplay,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const _StatChip(label: 'Games',   value: '38'),
                  _vDivider(),
                  const _StatChip(label: 'Friends',  value: '12'),
                  _vDivider(),
                  const _StatChip(label: 'Wishlist', value: '7'),
                ]),
              ]),
            ),
          ),

          // Social Section
          SliverToBoxAdapter(
            child: _Section(title: 'Social', children: [
              _MenuTile(
                icon: Icons.group_rounded, 
                label: 'Friends List',
                trailing: '12 online', 
                trailingColor: kGreen, 
                onTap: () => _goTo(context, const Friend()),
                showDivider: false,
              ),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Account Section 
          SliverToBoxAdapter(
            child: _Section(title: 'Account Info', children: [
              _MenuTile(icon: Icons.mail_outline_rounded, label: emailDisplay, showArrow: false, onTap: () {}),
              _MenuTile(
                icon: Icons.lock_outline_rounded, 
                label: '•••••••••••••', 
                showArrow: false,
                labelStyle: const TextStyle(color: Colors.white70, fontSize: 18, letterSpacing: 2),
                onTap: () {}, 
                showDivider: false
              ),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Settings & Preferences
          SliverToBoxAdapter(
            child: _Section(title: 'App Settings', children: [
              _MenuTile(icon: Icons.credit_card_rounded, label: 'Payment Methods', onTap: () {}),
              _MenuTile(icon: Icons.notifications_none_rounded, label: 'Push Notifications', onTap: () {}),
              _MenuTile(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}, showDivider: false),
            ]),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Logout Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: () => _onLogout(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                label: const Text('Log Out',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kRed,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ]),
      ),
    );
  }
}

Widget _vDivider() => Container(
  width: 1, height: 28,
  margin: const EdgeInsets.symmetric(horizontal: 20),
  color: Colors.white12,
);

class _StatChip extends StatelessWidget {
  final String label, value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
    const SizedBox(height: 2),
    Text(label, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
  ]);
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 4),
        child: Text(title.toUpperCase(),
            style: TextStyle(color: Colors.white.withOpacity(0.35),
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
      ),
      Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(children: children),
      ),
    ]),
  );
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextStyle? labelStyle;
  final String? trailing;
  final Color? trailingColor;
  final VoidCallback onTap;
  final bool showDivider;
  final bool showArrow;

  const _MenuTile({
    required this.icon, required this.label, required this.onTap,
    this.labelStyle, this.trailing, this.trailingColor, this.showDivider = true, this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) => Column(children: [
    ListTile(
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: kRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: kRed, size: 18),
      ),
      title: Text(label,
          style: labelStyle ??
              const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (trailing != null)
          Text(trailing!,
              style: TextStyle(
                  color: trailingColor ?? Colors.white.withOpacity(0.4),
                  fontSize: 13, fontWeight: FontWeight.w600)),
        if (showArrow)
          Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.25), size: 20),
      ]),
    ),
    if (showDivider)
      Divider(height: 1, thickness: 1, indent: 68, color: Colors.white.withOpacity(0.06)),
  ]);
}