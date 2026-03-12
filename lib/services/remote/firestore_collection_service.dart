import 'package:cloud_firestore/cloud_firestore.dart';

typedef FirestoreDecoder<T> = T Function(Map<String, dynamic> data);

class FirestoreCollectionService<T> {
  FirestoreCollectionService({
    required String collectionName,
    required FirestoreDecoder<T> fromMap,
    required String Function(T value) getId,
    required Map<String, dynamic> Function(T value) toMap,
    required String orderByField,
    bool descending = false,
  })  : _collectionName = collectionName,
        _fromMap = fromMap,
        _getId = getId,
        _toMap = toMap,
        _orderByField = orderByField,
        _descending = descending;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName;
  final FirestoreDecoder<T> _fromMap;
  final String Function(T value) _getId;
  final Map<String, dynamic> Function(T value) _toMap;
  final String _orderByField;
  final bool _descending;

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection(_collectionName);
  }

  Stream<List<T>> watchAll(String userId) {
    return _collection(userId)
        .orderBy(_orderByField, descending: _descending)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => _fromMap(doc.data()))
              .toList(growable: false),
        );
  }

  Future<void> upsert(String userId, T value) async {
    final id = _getId(value);
    await _collection(userId).doc(id).set(_toMap(value));
  }

  Future<void> delete(String userId, String id) async {
    await _collection(userId).doc(id).delete();
  }
}

