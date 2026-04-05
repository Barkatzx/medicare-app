import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medicare_app/data/repositories/notification_repository.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/entities/notification_entity.dart';
import '../datasources/local/shared_prefs_helper.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final http.Client client;
  final SharedPrefsHelper prefsHelper;

  NotificationRepositoryImpl({required this.client, required this.prefsHelper});

  @override
  Future<List<NotificationEntity>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .get(
            Uri.parse('${ApiConstants.notifications}?page=$page&limit=$limit'),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      print('Get notifications response: ${response.statusCode}');
      print('Get notifications body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          final notificationsData =
              responseData['data']['notifications'] as List? ?? [];
          return notificationsData
              .map((json) => NotificationEntity.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      print('Get notifications error: $e');
      throw Exception('Error loading notifications: $e');
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        return 0;
      }

      final response = await client
          .get(
            Uri.parse(ApiConstants.notifications),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          final notifications =
              responseData['data']['notifications'] as List? ?? [];
          return notifications.where((n) => n['isRead'] == false).length;
        }
        return 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Get unread count error: $e');
      return 0;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .patch(
            Uri.parse(ApiConstants.markNotificationRead(notificationId)),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      print('Mark as read response: ${response.statusCode}');
      print('Mark as read body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['message'] ?? 'Failed to mark notification as read',
        );
      }
    } catch (e) {
      print('Mark as read error: $e');
      throw Exception('Error marking notification as read: $e');
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      final token = await prefsHelper.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await client
          .post(
            Uri.parse(ApiConstants.markAllRead),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            ApiConstants.connectionTimeout,
            onTimeout: () {
              throw Exception('Connection timeout');
            },
          );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('Success: ${responseData['message']}');
        return;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to mark all as read');
      }
    } catch (e) {
      print('Mark all as read error: $e');
      throw Exception('Error marking all notifications as read: $e');
    }
  }
}
