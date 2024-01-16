import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../models/task.dart';

class FirestoreRepository {
  // Create tasks
  static Future<void> create({Task? task}) async {
    debugPrint('email is: ${GetStorage().read('email')}');
    try {
      await FirebaseFirestore.instance
          .collection(GetStorage().read('email'))
          .doc(task!.id)
          .set(task.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  } //create

  // Get tasks
  static Future<List<Task>> get() async {
    List<Task> taskList = [];
    try {
      final data = await FirebaseFirestore.instance.collection(GetStorage().read('email')).get();
      for (var task in data.docs) {
        taskList.add(Task.fromMap(task.data()));
      }
      return taskList;
    } catch (e) {
      throw Exception(e.toString());
    }
  } //get

  // Update Tasks
  static Future<void> update({Task? task}) async {
    try {
      final data = FirebaseFirestore.instance.collection(GetStorage().read('email'));
      data.doc(task!.id).update(task.toMap());
    } catch (e) {
      throw Exception(e.toString());
    }
  } //update
} //class FirststoreRepository
