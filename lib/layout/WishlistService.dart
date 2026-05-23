import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Games.dart'; // Contains your GameModel definition

class WishlistService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Helper helper to get the current user's wishlist collection path
  CollectionReference<Map<String, dynamic>>? get _userWishlistRef {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection('users').doc(user.uid).collection('wishlist');
  }

  // Check if a single game is bookmarked
  Stream<bool> isWishlistedStream(String gameId) {
    final ref = _userWishlistRef;
    if (ref == null) return Stream.value(false);
    return ref.doc(gameId).snapshots().map((doc) => doc.exists);
  }

  // Toggle dynamic add/remove operations
  Future<void> toggleWishlist(GameModel game, bool currentlyWishlisted) async {
    final ref = _userWishlistRef;
    if (ref == null) throw 'You must be logged in to manage your wishlist';

    final docRef = ref.doc(game.id.toString()); // Ensure ID is a string

    if (currentlyWishlisted) {
      await docRef.delete();
    } else {
      await docRef.set({
        'id': game.id,
        'title': game.title,
        'image': game.image,
        'rating': game.rating,
        'reviewCount': game.reviewCount,
        'addedAt': FieldValue.serverTimestamp(),
        'note': null, // Space reserved for user notes
      });
    }
  }

  // Stream the entire wishlist for the Wishlist view
  Stream<QuerySnapshot<Map<String, dynamic>>> getWishlistStream() {
    final ref = _userWishlistRef;
    if (ref == null) return const Stream.empty();
    return ref.orderBy('addedAt', descending: true).snapshots();
  }

  // Update game notes inside the cloud storage repository
  Future<void> updateNote(String gameId, String? note) async {
    final ref = _userWishlistRef;
    if (ref == null) return;
    await ref.doc(gameId).update({'note': note});
  }

  // Direct removal method from the list view
  Future<void> removeFromWishlist(String gameId) async {
    final ref = _userWishlistRef;
    if (ref == null) return;
    await ref.doc(gameId).delete();
  }
}