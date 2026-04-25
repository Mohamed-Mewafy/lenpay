import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  String? get currentUserUid => _auth.currentUser?.uid;

  // --- Retry helper ---

  static const List<String> _retryableCodes = [
    'unavailable',
    'network-request-failed',
    'deadline-exceeded',
    'resource-exhausted',
  ];

  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 1);

  Future<T> _withRetry<T>(Future<T> Function() operation) async {
    int attempt = 0;
    while (true) {
      try {
        return await operation();
      } on FirebaseException catch (e) {
        if (_retryableCodes.contains(e.code) && attempt < _maxRetries) {
          attempt++;
          final delay = _baseDelay * (1 << attempt); // exponential backoff
          debugPrint(
            'Firestore retryable error (${e.code}), attempt $attempt/${_maxRetries + 1}, retrying in ${delay.inSeconds}s...',
          );
          await Future.delayed(delay);
          continue;
        }
        rethrow;
      } catch (_) {
        rethrow;
      }
    }
  }

  // --- User Data ---

  Stream<DocumentSnapshot> getUserStream() {
    if (currentUserUid == null) return const Stream.empty();
    return _firestore.collection('users').doc(currentUserUid).snapshots();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUserUid == null) return null;
    final snap = await _firestore.collection('users').doc(currentUserUid).get();
    return snap.data();
  }

  Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String location,
  }) async {
    if (currentUserUid == null) return;
    await _withRetry(() async {
      await _firestore.collection('users').doc(currentUserUid).update({
        'name': name,
        'phone': phone,
        'location': location,
      });
    });
  }

  // --- Transactions ---

  Stream<QuerySnapshot> getTransactionsStream() {
    if (currentUserUid == null) return const Stream.empty();
    return _firestore
        .collection('users')
        .doc(currentUserUid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> addTransaction({
    required String title,
    required String type,
    required double amount,
    required String category,
  }) async {
    if (currentUserUid == null) return;
    final userDoc = _firestore.collection('users').doc(currentUserUid);

    await _withRetry(() async {
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);
        if (!snapshot.exists) return;

        double currentBalance = (snapshot.data()?['balance'] ?? 0.0).toDouble();
        double newBalance = currentBalance + amount;

        transaction.update(userDoc, {'balance': newBalance});

        final newTxRef = userDoc.collection('transactions').doc();
        transaction.set(newTxRef, {
          'id': newTxRef.id,
          'title': title,
          'type': type,
          'amount': amount,
          'category': category,
          'timestamp': FieldValue.serverTimestamp(),
        });
      });
    });
  }

  Future<void> initializeUserData({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    if (uid.isEmpty) return;
    await _withRetry(() async {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'location': '',
        'balance': 1500.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
