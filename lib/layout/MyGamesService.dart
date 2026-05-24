import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Games.dart';

class MyGamesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>? get _userOwnedGamesRef {
    final user = _auth.currentUser;
    return user == null ? null : _db.collection('users').doc(user.uid).collection('owned_games');
  }

  Stream<bool> isOwnedStream(dynamic gameId) =>
      _userOwnedGamesRef?.doc(gameId.toString()).snapshots().map((d) => d.exists) ?? Stream.value(false);

  Future<void> purchaseGame(GameModel game) async {
    final ref = _userOwnedGamesRef;
    if (ref == null) throw "No authenticated user found! Please log in.";
    await ref.doc(game.id.toString()).set({
      'id': game.id,
      'title': game.title,
      'image': game.image,
      'purchasedAt': FieldValue.serverTimestamp(),
    });
  }

  // New deletion method using your exact instance parameters safely
  Future<void> removeGame(String docId) async {
    final ref = _userOwnedGamesRef;
    if (ref != null) await ref.doc(docId).delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getOwnedGamesStream() =>
      _userOwnedGamesRef?.orderBy('purchasedAt', descending: true).snapshots() ?? const Stream.empty();
}