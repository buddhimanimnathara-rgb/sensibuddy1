import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_interest_model.dart';

class ChildInterestFirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> saveOrUpdateInterest(
      ChildInterestModel interest,
      ) async {
    try {
      final documentRef = _firestore
          .collection('child_interests')
          .doc(interest.id);

      final snapshot = await documentRef.get();

      if (snapshot.exists) {
        final data = snapshot.data();

        final currentFrequency =
            data?['frequency'] ?? 0;

        await documentRef.update({
          'frequency': currentFrequency + 1,
          'updatedAt':
          DateTime.now().toIso8601String(),
        });
      } else {
        await documentRef.set(
          interest.toMap(),
        );
      }
    } catch (e) {
      throw Exception(
        'Failed to save child interest: $e',
      );
    }
  }

  Future<List<ChildInterestModel>>
  getChildInterests(
      String childId,
      ) async {
    try {
      final snapshot = await _firestore
          .collection('child_interests')
          .where(
        'childId',
        isEqualTo: childId,
      )
          .orderBy(
        'frequency',
        descending: true,
      )
          .get();

      return snapshot.docs
          .map(
            (doc) =>
            ChildInterestModel.fromMap(
              doc.data(),
            ),
      )
          .toList();
    } catch (e) {
      throw Exception(
        'Failed to get child interests: $e',
      );
    }
  }

  Future<void> setInterestAllowed({
    required String interestId,
    required bool isAllowed,
  }) async {
    try {
      await _firestore
          .collection('child_interests')
          .doc(interestId)
          .update({
        'isAllowed': isAllowed,
        'updatedAt':
        DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception(
        'Failed to update interest permission: $e',
      );
    }
  }
}