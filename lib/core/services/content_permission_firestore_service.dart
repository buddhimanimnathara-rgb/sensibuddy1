import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/content_permission_model.dart';

class ContentPermissionFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // SAVE OR UPDATE CONTENT PERMISSION

  Future<void> saveOrUpdatePermission(
      ContentPermissionModel permission,
      ) async {
    try {
      final normalizedTopic =
      permission.topic.toLowerCase().trim();

      final docId =
          '${permission.childId}_$normalizedTopic';

      await _db
          .collection('content_permissions')
          .doc(docId)
          .set(
        {
          'id': docId,
          'childId': permission.childId,
          'topic': normalizedTopic,
          'isAllowed': permission.isAllowed,
          'createdAt': permission.createdAt
              .toIso8601String(),
          'updatedAt': DateTime.now()
              .toIso8601String(),
        },
        SetOptions(
          merge: true,
        ),
      );

      debugPrint(
        ' CONTENT PERMISSION SAVED: '
            '$normalizedTopic',
      );
    } catch (e) {
      debugPrint(
        ' CONTENT PERMISSION SAVE ERROR: $e',
      );

      rethrow;
    }
  }

  // CHECK CONTENT PERMISSION

  Future<bool?> checkPermission({
    required String childId,
    required String topic,
  }) async {
    try {
      final normalizedTopic =
      topic.toLowerCase().trim();

      final docId =
          '${childId}_$normalizedTopic';

      final snapshot = await _db
          .collection('content_permissions')
          .doc(docId)
          .get();

      // No parent decision yet
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data();

      if (data == null) {
        return null;
      }

      return data['isAllowed'] as bool?;
    } catch (e) {
      debugPrint(
        ' CONTENT PERMISSION CHECK ERROR: $e',
      );

      return null;
    }
  }

  // GET ALL CHILD CONTENT PERMISSIONS

  Future<List<ContentPermissionModel>>
  getChildPermissions(
      String childId,
      ) async {
    try {
      final snapshot = await _db
          .collection('content_permissions')
          .where(
        'childId',
        isEqualTo: childId,
      )
          .get();

      return snapshot.docs
          .map(
            (doc) =>
            ContentPermissionModel.fromMap(
              doc.data(),
            ),
      )
          .toList();
    } catch (e) {
      debugPrint(
        ' GET CONTENT PERMISSIONS ERROR: $e',
      );

      return [];
    }
  }
}