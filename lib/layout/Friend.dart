import 'package:flutter/material.dart';

// ── Colours ───────────────────────────────────────────────────────────────────
const _bg = Color(0xFF0A0A0A);
const _surface = Color(0xFF161616);
const _card = Color(0xFF1E1E1E);
const _green = Color(0xFF39FF14);
const _textPrimary = Colors.white;
const _textSub = Color(0xFF888888);

// ── FriendsPage ───────────────────────────────────────────────────────────────
class Friend extends StatefulWidget {
  const Friend({super.key});
  @override
  State<Friend> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<Friend> {
  final List<String> _friends = ['My friend 1', 'My frend 2', 'My fren 3'];

  void _openAddOverlay() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AddFriendSheet(onAdd: (name) {
          setState(() => _friends.add(name));
        }),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Friends',
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w700)),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: Color(0xFF2A2A2A), height: 1),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _friends.length,
        itemBuilder: (_, i) => ListTile(
          leading: _Avatar(_friends[i]),
          title: Text(_friends[i],
              style: const TextStyle(color: _textPrimary, fontSize: 15)),
        ),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: _openAddOverlay,
              child: const Text('Add friend',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Add friend bottom-sheet ────────────────────────────────────────────────────
class _AddFriendSheet extends StatefulWidget {
  final ValueChanged<String> onAdd;
  const _AddFriendSheet({required this.onAdd});
  @override
  State<_AddFriendSheet> createState() => _AddFriendSheetState();
}

class _AddFriendSheetState extends State<_AddFriendSheet> {
  final _ctrl = TextEditingController();
  // Simulated user pool
  final _all = ['Alice', 'Bob', 'Charlie', 'Diana', 'Eve', 'Frank'];
  List<String> _results = [];

  void _search(String q) => setState(() {
        _results = q.trim().isEmpty
            ? []
            : _all
                .where((u) => u.toLowerCase().contains(q.toLowerCase()))
                .toList();
      });

  void _add(String name) {
    widget.onAdd(name);
    Navigator.pop(context);
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
            // handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 12),
              child: Row(children: [
                const Text('Add Friend',
                    style: TextStyle(
                        color: _textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _textSub),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
            ),
            // search field
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
                  prefixIcon:
                      const Icon(Icons.search, color: _textSub, size: 20),
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
            // results
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        _ctrl.text.isEmpty
                            ? 'Type to search'
                            : 'No users found',
                        style: const TextStyle(color: _textSub, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      controller: sc,
                      itemCount: _results.length,
                      itemBuilder: (_, i) => ListTile(
                        leading: _Avatar(_results[i]),
                        title: Text(_results[i],
                            style: const TextStyle(
                                color: _textPrimary, fontSize: 15)),
                        subtitle: const Text('Unknown friend',
                            style:
                                TextStyle(color: _textSub, fontSize: 12)),
                        trailing: GestureDetector(
                          onTap: () => _add(_results[i]),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _green.withOpacity(0.5)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: _green, size: 14),
                                SizedBox(width: 4),
                                Text('add',
                                    style: TextStyle(
                                        color: _green,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared avatar ─────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar(this.name);
  @override
  Widget build(BuildContext context) => CircleAvatar(
        radius: 20,
        backgroundColor: _green,
        child: Text(
          name[0].toUpperCase(),
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w800, fontSize: 16),
        ),
      );
}