import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _bg = Color(0xFF0A0A0A);
const _surface = Color(0xFF161616);
const _card = Color(0xFF1E1E1E);
const _green = Color(0xFF39FF14);
const _textPrimary = Colors.white;
const _textSub = Color(0xFF888888);

class Friend extends StatefulWidget {
  const Friend({super.key});
  @override
  State<Friend> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<Friend> {
  final String _currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  void _openAddOverlay() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const _AddFriendSheet(),
      );

  @override
  Widget build(BuildContext context) {
    if (_currentUid.isEmpty) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(child: Text('Please log in first.', style: TextStyle(color: _textPrimary))),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Friends', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFF2A2A2A), height: 1),
        ),
      ),
      // Real-time friend synchronization with Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUid)
            .collection('friends')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _green));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No friends added yet', style: TextStyle(color: _textSub, fontSize: 14)),
            );
          }

          final friendDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: friendDocs.length,
            itemBuilder: (_, i) {
              final friendData = friendDocs[i].data() as Map<String, dynamic>;
              final String name = friendData['username'] ?? 'Unknown';
              return ListTile(
                leading: _Avatar(name),
                title: Text(name, style: const TextStyle(color: _textPrimary, fontSize: 15)),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _card,
                foregroundColor: _textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _openAddOverlay,
              child: const Text('Add friend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Add friend bottom-sheet ──
class _AddFriendSheet extends StatefulWidget {
  const _AddFriendSheet();
  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  // Realtime structural DB querying using target username prefixes
  void _search(String q) async {
    final cleanQuery = q.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Query documents where username starts with the typed query string
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username_lowercase', isGreaterThanOrEqualTo: cleanQuery)
          .where('username_lowercase', isLessThanOrEqualTo: '$cleanQuery\z')
          .limit(10)
          .get();

      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      setState(() {
        _results = querySnapshot.docs
            .map((doc) => doc.data())
            // Filter out yourself from search results
            .where((data) => data['uid'] != currentUid)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _addFriend(Map<String, dynamic> targetUser) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final currentName = FirebaseAuth.instance.currentUser?.displayName ?? 'Unknown';

    if (currentUid == null) return;

    // Save friend relationship into both user paths cleanly
    final batch = FirebaseFirestore.instance.batch();

    final myFriendRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('friends')
        .doc(targetUser['uid']);

    final theirFriendRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUser['uid'])
        .collection('friends')
        .doc(currentUid);

    batch.set(myFriendRef, {'uid': targetUser['uid'], 'username': targetUser['username']});
    batch.set(theirFriendRef, {'uid': currentUid, 'username': currentName});

    await batch.commit();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
              child: Row(children: [
                const Text('Add Friend', style: TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _textSub),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                onChanged: _search,
                style: const TextStyle(color: _textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search username…',
                  hintStyle: const TextStyle(color: _textSub, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: _textSub, size: 20),
                  filled: true,
                  fillColor: _card,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: _green))
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            _ctrl.text.isEmpty ? 'Type to search' : 'No users found',
                            style: const TextStyle(color: _textSub, fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                          controller: sc,
                          itemCount: _results.length,
                          itemBuilder: (_, i) {
                            final userData = _results[i];
                            return ListTile(
                              leading: _Avatar(userData['username'] ?? 'U'),
                              title: Text(userData['username'] ?? '', style: const TextStyle(color: _textPrimary, fontSize: 15)),
                              subtitle: Text(userData['email'] ?? '', style: const TextStyle(color: _textSub, fontSize: 12)),
                              trailing: InkWell(
                                onTap: () => _addFriend(userData),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _green.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: _green.withOpacity(0.5)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.add, color: _green, size: 14),
                                      const SizedBox(width: 4),
                                      const Text('add', style: TextStyle(color: _green, fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared avatar ──
class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar(this.name);
  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 20,
        backgroundColor: _green,
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16),
        ),
      );
}