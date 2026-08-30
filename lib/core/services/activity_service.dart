import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/activity_session_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // SAVE ACTIVITY SESSION
  Future<void> saveActivitySession(
      ActivitySessionModel session,
      ) async {
    await _firestore
        .collection('children')
        .doc(session.childId)
        .collection('activities')
        .add(session.toMap());
  }


  // GET ALL ACTIVITIES
  Future<List<Map<String, dynamic>>> getActivities(
      String childId,
      ) async {
    final snapshot = await _firestore
        .collection('children')
        .doc(childId)
        .collection('activities')
        .orderBy(
      'completedAt',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }


  // GET TODAY'S ACTIVITIES
  Future<List<Map<String, dynamic>>> getTodayActivities(
      String childId,
      ) async {
    final now = DateTime.now();

    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );

    final snapshot = await _firestore
        .collection('children')
        .doc(childId)
        .collection('activities')
        .where(
      'completedAt',
      isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
    )
        .where(
      'completedAt',
      isLessThan: Timestamp.fromDate(endOfDay),
    )
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  // GET ACTIVITIES BY EMOTION
  Future<List<Map<String, dynamic>>> getActivitiesByEmotion(
      String childId,
      String emotion,
      ) async {
    final snapshot = await _firestore
        .collection('children')
        .doc(childId)
        .collection('activities')
        .where(
      'emotion',
      isEqualTo: emotion,
    )
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  // GET ACTIVITY SESSION MODELS
  Future<List<ActivitySessionModel>> getActivitySessions(
      String childId,
      ) async {
    final snapshot = await _firestore
        .collection('children')
        .doc(childId)
        .collection('activities')
        .orderBy(
      'completedAt',
      descending: true,
    )
        .get();

    return snapshot.docs
        .map(
          (doc) => ActivitySessionModel.fromMap(doc.data()),
    )
        .toList();
  }
}