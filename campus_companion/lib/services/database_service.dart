import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/timetable_model.dart';
import '../models/attendance_model.dart';

class DatabaseService extends ChangeNotifier {
  final SupabaseClient _client = supabase;

  // Timetables
  Stream<List<TimetableModel>> getTimetables() {
    return _client
        .from('timetables')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((e) => TimetableModel.fromJson(e)).toList());
  }

  Future<void> addTimetable(String subject, String time) async {
    await _client.from('timetables').insert({'subject': subject, 'time': time});
  }

  Future<void> deleteTimetable(String id) async {
    await _client.from('timetables').delete().eq('id', id);
  }

  // Notices
  Stream<List<Map<String, dynamic>>> getNotices() {
    return _client
        .from('notices')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> addNotice(String title, String content) async {
    await _client.from('notices').insert({'title': title, 'content': content});
  }

  Future<void> deleteNotice(String id) async {
    await _client.from('notices').delete().eq('id', id);
  }

  // Attendance
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    final response = await supabase
        .from('profiles')
        .select('id, email, role')
        .eq('role', 'student');

    print("Students fetched: $response"); // 🔍 Add this for debugging

    if (response == null) {
      throw Exception('No response from Supabase');
    }

    if (response is List && response.isNotEmpty) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      return [];
    }
  }

  // Get attendance for a specific date (for admin/teacher)
  Future<List<Map<String, dynamic>>> getAttendanceByDate(DateTime date) async {
    final d = date.toIso8601String().split('T')[0];
    final res = await _client
        .from('attendance')
        .select('id, user_id, present, marked_by, created_at')
        .eq('date', d);
    return List<Map<String, dynamic>>.from(res ?? []);
  }

  Future<void> markAttendance(
    String userId,
    DateTime date,
    bool present,
  ) async {
    final dateStr = date.toIso8601String().split('T')[0];
    await _client.from('attendance').upsert({
      'user_id': userId,
      'date': dateStr,
      'present': present,
      'marked_by': _client.auth.currentUser?.id,
    }, onConflict: 'user_id,date');
  }

  // Get monthly attendance for a user using RPC
  Future<List<Map<String, dynamic>>> getUserMonthlyAttendance(
    String userId,
    int year,
    int month,
  ) async {
    final res = await _client.rpc(
      'get_user_monthly_attendance',
      params: {'_user': userId, '_year': year, '_month': month},
    );
    return List<Map<String, dynamic>>.from(res ?? []);
  }

  Stream<List<Map<String, dynamic>>> getAllAttendance() {
    return _client
        .from('attendance')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<List<Map<String, dynamic>>> getUserAttendance(String userId) async {
    final res = await _client
        .from('attendance')
        .select('id, user_id, present, date, marked_by, created_at')
        .eq('user_id', userId)
        .order('date', ascending: false);
    return List<Map<String, dynamic>>.from(res ?? []);
  }

  Future<void> deleteAttendance(String id) async {
    await _client.from('attendance').delete().eq('id', id);
  }

  // Materials
  Stream<List<Map<String, dynamic>>> getMaterials() {
    return _client
        .from('materials')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> addMaterial(
    String title,
    String description,
    String? subject,
    String? link,
  ) async {
    await _client.from('materials').insert({
      'title': title,
      'description': description,
      'subject': subject,
      'link': link,
    });
  }

  Future<void> deleteMaterial(String id) async {
    await _client.from('materials').delete().eq('id', id);
  }
}
