import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../models/ai_interaction_analysis.dart';
import '../models/child_model.dart';
import '../models/guardian_model.dart';
import '../models/assessment_model.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save child & return ID
  Future<String> saveChild(Map<String, dynamic> data) async {
    final doc = await _db.collection("children").add(data);
    return doc.id;
  }

  // Get child
  Future<ChildModel?> getChild(String childId) async {
    final doc = await _db.collection("children").doc(childId).get();

    if (!doc.exists) return null;

    return ChildModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateChild(
      String childId,
      Map<String, dynamic> data,
      ) async {

    await _db
        .collection("children")
        .doc(childId)
        .update(data);
  }


  // Save assessment
  Future<void> saveAssessment(String childId, Map<String, dynamic> data)
  async {
    await _db.collection("children").doc(childId).collection("assessment").add(data);}

// SAVE GUARDIAN
  Future<String> saveGuardian(Map<String, dynamic> data,)
  async {
    final doc =await _db.collection("guardians").add(data);

    return doc.id;

  }


  Future<bool> checkEmailExists(
      String email,
      ) async {

    final result = await _db
        .collection("guardians")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;

  }

Future<GuardianModel?> getGuardian(String guardianId,) async {

  final doc = await _db
      .collection("guardians")
      .doc(guardianId)
      .get();

  if (!doc.exists) {
    return null;
  }

  return GuardianModel.fromMap(
    doc.id,
    doc.data()!,
  );

}

  Future<GuardianModel?> getGuardianById(
      String guardianId,
      ) async {

    final doc = await _db
        .collection("guardians")
        .doc(guardianId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return GuardianModel.fromMap(
      doc.id,
      doc.data()!,
    );
  }

  Future<GuardianModel?> getGuardianByEmail(
      String email,
      ) async {

    final snapshot = await _db
        .collection("guardians")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return GuardianModel.fromMap(
      snapshot.docs.first.id,
      snapshot.docs.first.data(),
    );

  }

  Future<void> updateParentPin({
    required String guardianId,
    required String newPin,
  }) async {

    await _db
        .collection('parent_pins')
        .doc(guardianId)
        .update({
      'pin': newPin,
    });

  }




  Future<void> deleteGuardianAccount(
      String guardianId,
      ) async {

    await _db
        .collection("parent_pins")
        .doc(guardianId)
        .delete();

    await _db
        .collection("guardian_faces")
        .doc(guardianId)
        .delete();

    await _db
        .collection("guardians")
        .doc(guardianId)
        .delete();

  }



Future<void> updateGuardian(String guardianId,Map<String, dynamic> data,) async {

  await _db
      .collection("guardians")
      .doc(guardianId)
      .update(data);

}



Future<void> saveGuardianFaceRegistration(String guardianId,String childId,) async {

  await _db
      .collection("guardian_faces")
      .doc(guardianId)
      .set({
    "guardianId": guardianId,
    "childId": childId,
    "registered": true,
    "faceCount": 3,
    "createdAt":
    DateTime.now()
        .toIso8601String(),
  });

}

Future<void> saveGuardianFace(String guardianId,Map<String, dynamic> data,) async {await _db.collection("guardian_faces").doc(guardianId).set(data);}

Future<Map<String, dynamic>?> getGuardianFace(String guardianId,) async {

  final doc = await _db
      .collection("guardian_faces")
      .doc(guardianId)
      .get();

  if (!doc.exists) {
    return null;
  }

  return doc.data();

}

Future<void> saveChildFaceRegistration(String childId,) async {

  await _db
      .collection("child_faces")
      .doc(childId)
      .set({
    "registered": true,
    "faceCount": 3,
    "createdAt":
    FieldValue.serverTimestamp(),
  });

}Future<void> saveChildFace(String childId,Map<String, dynamic> data,) async {

  await _db
      .collection("child_faces")
      .doc(childId)
      .set(data);

}

Future<Map<String, dynamic>?> getChildFace(String childId,) async {

  final doc = await _db
      .collection("child_faces")
      .doc(childId)
      .get();

  if (!doc.exists) {
    return null;
  }

  return doc.data();

}



Future<void> saveParentPin(String guardianId,Map<String, dynamic> data,) async {await _db.collection("parent_pins").doc(guardianId).set(data);}

Future<Map<String, dynamic>?> getParentPin(String guardianId,) async {

  final doc = await _db
      .collection("parent_pins")
      .doc(guardianId)
      .get();

  if (!doc.exists) {
    return null;
  }

  return doc.data();

}

// GET ALL CHILD FACES

  Future<List<Map<String, dynamic>>> getAllChildFaces() async {
    final snapshot =
    await _db
        .collection("child_faces")
        .where("registered", isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        ...doc.data(),
      };
    }).toList();
  }


// GET ALL GUARDIAN FACES

  Future<List<Map<String, dynamic>>> getAllGuardianFaces() async {
    final snapshot =
    await _db
        .collection("guardian_faces")
        .where("registered", isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) {
      return {
        "id": doc.id,
        ...doc.data(),
      };
    }).toList();
  }




Future<Map<String, dynamic>?> getLatestAssessment(String childId,) async {

  final snapshot = await _db
      .collection("children")
      .doc(childId)
      .collection("assessment")
      .orderBy(
    "createdAt",
    descending: true,
  )
      .limit(1)
      .get();

  if (snapshot.docs.isEmpty) {
    return null;
  }

  return snapshot.docs.first.data();

}

  Future<void> saveAIInteractionAnalysis({
    required AIInteractionAnalysisModel analysis,
  }) async {
    try {
      await _db
          .collection('ai_interaction_analysis')
          .add(
        analysis.toMap(),
      );

      debugPrint(
        'AI interaction analysis saved successfully',
      );
    } catch (e) {
      debugPrint(
        'Error saving AI interaction analysis: $e',
      );

      rethrow;
    }
  }


  Future<List<Map<String, dynamic>>> getAIInteractionAnalysis(
      String childId,
      ) async {
    try {
      final snapshot = await _db
          .collection('ai_interaction_analysis')
          .where(
        'childId',
        isEqualTo: childId,
      )
          .get();

      return snapshot.docs
          .map(
            (doc) => doc.data(),
      )
          .toList();
    } catch (e) {
      debugPrint(
        'Error getting AI interaction analysis: $e',
      );

      return [];
    }
  }

  // EMOTION RECOGNITION
  // SAVE EMOTION RECOGNITION RESULT
  Future<void> saveEmotion({
    required String childId,
    required String emotion,
    required double confidence,
    required String language,
  }) async {
    try {
      await _db
          .collection("children")
          .doc(childId)
          .collection("emotion_logs")
          .add({
        "emotion": emotion.toLowerCase().trim(),
        "confidence": confidence,
        "language": language,
        "createdAt": FieldValue.serverTimestamp(),
      });

      debugPrint(
        " Emotion saved: $emotion "
            "(${(confidence * 100).toStringAsFixed(1)}%)",
      );
    } catch (e) {
      debugPrint(
        " Error saving emotion: $e",
      );

      rethrow;
    }
  }

  // GET EMOTION HISTORY
  Future<List<Map<String, dynamic>>> getEmotionLogs(
      String childId,
      ) async {
    try {
      final snapshot = await _db
          .collection("children")
          .doc(childId)
          .collection("emotion_logs")
          .orderBy(
        "createdAt",
        descending: true,
      )
          .get();

      return snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      debugPrint(
        " Error getting emotion logs: $e",
      );

      return [];
    }
  }

  // GET EMOTION HISTORY
  Future<List<Map<String, dynamic>>> getEmotionHistory(
      String childId,
      ) async {
    try {
      final snapshot = await _db
          .collection("children")
          .doc(childId)
          .collection("emotion_logs")
          .orderBy(
        "createdAt",
        descending: true,
      )
          .get();

      return snapshot.docs.map((doc) {
        return {
          "id": doc.id,
          ...doc.data(),
        };
      }).toList();
    } catch (e) {
      debugPrint(
        " Error getting emotion history: $e",
      );

      return [];
    }
  }

  Future<void> saveGameResult(
      String childId,
      Map<String, dynamic> data,
      ) async {
    await _db
        .collection("children")
        .doc(childId)
        .collection("games")
        .add(data);
  }

  Future<List<Map<String, dynamic>>> getGames(
      String childId,
      ) async {

    final snapshot = await _db
        .collection("children")
        .doc(childId)
        .collection("games")
        .get();

    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }



}


final firestoreService = FirestoreService();