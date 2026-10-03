import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String get _usersCollection => 'users';

  // Get all users stream
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection(_usersCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = Map<String, dynamic>.from(doc.data());
        user['uid'] = doc.id;
        return user;
      }).toList();
    });
  }

  // Send message
  Future<void> sendMessage(String receiverId, String message) async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) {
      throw StateError('No signed-in user found for sending a message.');
    }

    final String currentUserId = currentUser.uid;
    final String? currentUserEmail = currentUser.email;
    final Timestamp timestamp = Timestamp.now();

    MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail ?? "",
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // Sort the IDs (ensures the chatroomID is the same for any 2 people)
    String chatRoomID = ids.join("_");

    // Add new message to database
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // Get messages
  Stream<QuerySnapshot> getMessage(String userID, String otherUserID) {
    // Construct chat room ID for the two users (sorted to ensure uniqueness)
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get UID by Email
  Future<String?> getUidByEmail(String email) async {
    final q = await _firestore
        .collection(_usersCollection)
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (q.docs.isEmpty) return null;
    return q.docs.first.id;
  }
}