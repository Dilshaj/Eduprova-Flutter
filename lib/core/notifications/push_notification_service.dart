import 'dart:convert';
import 'dart:io';

import 'package:eduprova/core/navigation/app_routes.dart';
import 'package:eduprova/core/network/api_client.dart';
import 'package:eduprova/features/messages_old/activity/widgets/activity_screen.dart';
import 'package:eduprova/features/messages_old/messages/live_call_screen.dart';
import 'package:eduprova/features/messages_old/meet/meet.dart';
import 'package:eduprova/features/messages_old/models/call_room_model.dart';
import 'package:eduprova/features/messages_old/providers/chat_socket_provider.dart';
import 'package:eduprova/globals.dart';
import 'package:eduprova/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const AndroidNotificationChannel _messagesChannel = AndroidNotificationChannel(
  'eduprova_messages',
  'Eduprova Messages',
  description: 'Message, meeting, and activity notifications',
  importance: Importance.max,
);

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'eduprova_messages', // id (Matches AndroidManifest)
  'Eduprova Messages', // title
  description: 'Notifications for chat messages and updates',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

AndroidNotificationChannel _callsChannel = AndroidNotificationChannel(
  'eduprova_calls_v3', // increment version to force Android to create fresh channel with new settings
  'Eduprova Calls',
  description: 'Incoming call notifications',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('call_ringtone'),
  enableVibration: true,
  vibrationPattern: Int64List.fromList([0, 500, 200, 500, 200, 500]),
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint(
      '[PushNotifications] Background handler fired: ${message.messageId}',
    );

    final payload = AppNotificationPayload.fromMap({
      ...message.data,
      'title': message.notification?.title ?? message.data['title'] ?? '',
      'body': message.notification?.body ?? message.data['body'] ?? '',
    });

    debugPrint('[PushNotifications] Background type: ${payload.type}');

    // ALWAYS show a local notification for calls: the backend sends data-only
    // FCM for calls so Android never auto-shows anything, we must do it here.
    // For non-call messages with a notification block, the OS already showed
    // a plain notification — we add customization only if needed.
    final service = PushNotificationService.instance;
    if (!service._localNotificationsReady) {
      await service._initializeLocalNotifications();
    }

    await service.showLocalNotification(payload);
    debugPrint('[PushNotifications] Background notification shown');
  } catch (e, stack) {
    debugPrint('[PushNotifications] Background handler error: $e');
    debugPrintStack(stackTrace: stack);
  }
}

/// Called when user taps Answer/Decline in the notification while app is KILLED.
/// This runs in a separate background isolate — NO Flutter engine, NO Riverpod.
/// We store the pending action in SharedPreferences; main isolate reads it on startup.
@pragma('vm:entry-point')
void _onBackgroundNotificationAction(NotificationResponse response) {
  // The main isolate picks this up via flushPendingNavigation / _pendingPayload.
  // We cannot emit socket events here (no socket connection), but we can
  // store the intended action so when the app opens it handles it.
  debugPrint(
    '[Notifications] Background action: ${response.actionId} payload=${response.payload}',
  );
}

enum AppNotificationType { message, call, meeting, activity, mention, unknown }

class AppNotificationPayload {
  const AppNotificationPayload({
    required this.type,
    this.title,
    this.body,
    this.chatId,
    this.callId,
    this.meetingId,
    this.activityId,
    this.entityId,
    this.conversationType,
    this.callerName,
    this.callerId,
    this.callerAvatar,
  });

  final AppNotificationType type;
  final String? title;
  final String? body;
  final String? chatId;
  final String? callId;
  final String? meetingId;
  final String? activityId;
  final String? entityId;
  final String? conversationType;
  final String? callerName;
  final String? callerId;
  final String? callerAvatar;

  factory AppNotificationPayload.fromMap(Map<String, dynamic> map) {
    AppNotificationType parseType(String? raw) {
      switch (raw) {
        case 'message':
        case 'reply':
        case 'forward':
        case 'pin':
          return AppNotificationType.message;
        case 'call':
          return AppNotificationType.call;
        case 'meeting':
          return AppNotificationType.meeting;
        case 'activity':
          return AppNotificationType.activity;
        case 'mention':
          return AppNotificationType.mention;
        default:
          return AppNotificationType.unknown;
      }
    }

    return AppNotificationPayload(
      type: parseType(map['type']?.toString()),
      title: map['title']?.toString(),
      body: map['body']?.toString(),
      chatId: _clean(map['chatId']),
      callId: _clean(map['callId']),
      meetingId: _clean(map['meetingId']),
      activityId: _clean(map['activityId']),
      entityId: _clean(map['entityId']),
      conversationType: _clean(map['conversationType']),
      callerName: _clean(map['callerName']),
      callerId: _clean(map['callerId']),
      callerAvatar: _clean(map['callerAvatar']),
    );
  }

  Map<String, dynamic> toMap() => {
    'type': switch (type) {
      AppNotificationType.message => 'message',
      AppNotificationType.call => 'call',
      AppNotificationType.meeting => 'meeting',
      AppNotificationType.activity => 'activity',
      AppNotificationType.mention => 'mention',
      AppNotificationType.unknown => 'unknown',
    },
    'title': title,
    'body': body,
    'chatId': chatId,
    'callId': callId,
    'meetingId': meetingId,
    'activityId': activityId,
    'entityId': entityId,
    'conversationType': conversationType,
    'callerName': callerName,
    'callerId': callerId,
    'callerAvatar': callerAvatar,
  };

  String toJson() => jsonEncode(toMap());

  static AppNotificationPayload? fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AppNotificationPayload.fromMap(decoded);
      }
    } catch (_) {}
    return null;
  }

  static String? _clean(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  late final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _firebaseReady = false;
  bool _localNotificationsReady = false;
  String? _lastRegisteredToken;
  AppNotificationPayload? _pendingPayload;
  WidgetRef? _ref;

  void setRef(WidgetRef ref) => _ref = ref;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      debugPrint('[Main] Initializing Firebase...');
      await Firebase.initializeApp();
      debugPrint('[Main] Firebase initialized');
      _messaging = FirebaseMessaging.instance;
      _firebaseReady = true;
      debugPrint('[PushNotifications] Firebase initialized successfully');
    } catch (error, stackTrace) {
      debugPrint('[PushNotifications] Firebase init unavailable: $error');
      debugPrintStack(stackTrace: stackTrace);
      return;
    }

    if (_firebaseReady) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      await _initializeLocalNotifications();
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false, // Don't show native FCM notification in foreground
        badge: false,
        sound: false,
      );

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint(
          '[PushNotifications] Raw Foreground Message: ${message.messageId}',
        );
        debugPrint('[PushNotifications] Raw Data: ${message.data}');
        debugPrint(
          '[PushNotifications] Raw Notification: ${message.notification?.title}',
        );
        _handleForegroundMessage(message);
      });
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleNotificationTap(AppNotificationPayload.fromMap(message.data));
      });

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _pendingPayload = AppNotificationPayload.fromMap(initialMessage.data);
      }
    } else {
      await _initializeLocalNotifications();
    }

    _messaging.onTokenRefresh.listen((token) async {
      if (!_firebaseReady) return;
      if (prefs.getString('access_token') == null) return;
      await _registerToken(token);
    });
  }

  Future<void> syncAuthState({required bool isAuthenticated}) async {
    debugPrint(
      '[PushNotifications] syncAuthState: isAuthenticated=$isAuthenticated, firebaseReady=$_firebaseReady',
    );
    if (!_firebaseReady) return;

    if (!isAuthenticated) {
      return;
    }

    await _requestPermissionIfNeeded();

    // On iOS/macOS, we must wait for APNS token before getting FCM token
    if (!await _ensureApnsToken()) {
      return;
    }

    String? token;
    try {
      token = await _messaging.getToken();
      debugPrint('[PushNotifications] FCM Token: $token');
    } catch (e) {
      debugPrint('[PushNotifications] Failed to get FCM token: $e');
      if (e.toString().contains('SERVICE_NOT_AVAILABLE')) {
        debugPrint(
          '[PushNotifications] TIP: Check if your emulator has Google Play Services and internet.',
        );
      }
    }

    if (token != null && token.isNotEmpty) {
      await _registerToken(token);
    }

    await flushPendingNavigation();
  }

  Future<bool> _ensureApnsToken() async {
    return true;
    // if (kIsWeb) return true;
    // if (defaultTargetPlatform != .iOS && defaultTargetPlatform != .macOS) {
    //   return true;
    // }

    // debugPrint('[PushNotifications] Checking APNS token...');
    // String? apnsToken = await _messaging.getAPNSToken();
    // int retryCount = 0;
    // const maxRetries = 10;

    // while (apnsToken == null && retryCount < maxRetries) {
    //   retryCount++;
    //   debugPrint(
    //     '[PushNotifications] APNS token not ready, retrying ($retryCount/$maxRetries)...',
    //   );
    //   await Future.delayed(.new(seconds: 1));
    //   apnsToken = await _messaging.getAPNSToken();
    // }

    // if (apnsToken == null) {
    //   debugPrint('[PushNotifications] APNS token still not available.');
    //   return false;
    // }

    // debugPrint('[PushNotifications] APNS token is ready.');
    // return true;
  }

  Future<void> unregisterCurrentToken() async {
    try {
      if (!_firebaseReady) return;

      if (!await _ensureApnsToken()) {
        debugPrint(
          '[PushNotifications] APNS token not available for unregistration',
        );
        return;
      }

      final token = _lastRegisteredToken ?? await _messaging.getToken();
      if (token == null || token.isEmpty) return;

      await ApiClient.instance.delete(
        '/notifications/token',
        data: {'token': token},
      );
      if (_lastRegisteredToken == token) {
        _lastRegisteredToken = null;
      }
    } catch (error) {
      debugPrint('[PushNotifications] Token unregister failed: $error');
    }
  }

  Future<void> flushPendingNavigation() async {
    final payload = _pendingPayload;
    if (payload == null) return;
    if (prefs.getString('access_token') == null) return;

    _pendingPayload = null;
    await _navigate(payload);
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/notification_icon',
    );
    const iosSettings = DarwinInitializationSettings();

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = AppNotificationPayload.fromJson(response.payload);
        if (payload != null) {
          if (response.actionId != null) {
            _handleCallAction(response.actionId!, payload);
          } else {
            _handleNotificationTap(payload);
          }
        }
      },
      // Called when buttons tapped from notification shade while app is background/killed
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationAction,
    );
    // 77:fa:9e:cd:84:75:e2:f9:81:b2:ad:47:e5:e6:b2:fb:25:dd:da:5a

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // ── CRITICAL: Delete old channels before recreating ──────────────────────
    // Android permanently locks sound/vibration when a channel is first created.
    // Deleting and recreating with a new ID forces Android to apply the ringtone.
    await androidPlugin?.deleteNotificationChannel('eduprova_calls');
    await androidPlugin?.deleteNotificationChannel('eduprova_calls_v2');

    await androidPlugin?.createNotificationChannel(_messagesChannel);
    await androidPlugin?.createNotificationChannel(_callsChannel);
    _localNotificationsReady = true;
  }

  Future<void> _requestPermissionIfNeeded() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint(
      '[PushNotifications] Permission status: ${settings.authorizationStatus}',
    );
  }

  Future<void> _registerToken(String token) async {
    if (_lastRegisteredToken == token) return;

    final device = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      _ => 'android',
    };

    debugPrint('[PushNotifications] Registering token for platform: $device');
    try {
      final response = await ApiClient.instance.post(
        '/notifications/register-token',
        data: {
          'token': token,
          'device': Platform.isAndroid ? 'android' : 'ios',
          'browser': 'flutter',
        },
      );
      _lastRegisteredToken = token;
      debugPrint(
        '[PushNotifications] Token registered successfully: ${response.statusCode}',
      );
    } catch (error) {
      debugPrint('[PushNotifications] Token register failed: $error');
    }
  }

  Future<void> showLocalNotification(AppNotificationPayload payload) async {
    final title = payload.title ?? 'Eduprova';
    final body = payload.body ?? '';
    final isCall = payload.type == AppNotificationType.call;

    final androidDetails = AndroidNotificationDetails(
      isCall ? _callsChannel.id : channel.id,
      isCall ? _callsChannel.name : channel.name,
      channelDescription: isCall
          ? _callsChannel.description
          : channel.description,
      importance: Importance.max,
      priority: isCall ? Priority.max : Priority.high,
      icon: '@drawable/notification_icon',
      category: isCall ? AndroidNotificationCategory.call : null,
      fullScreenIntent: isCall,
      sound: isCall
          ? const RawResourceAndroidNotificationSound('call_ringtone')
          : null,
      playSound: isCall,
      enableVibration: isCall,
      vibrationPattern: isCall
          ? Int64List.fromList([0, 500, 200, 500, 200, 500])
          : null,
      actions: isCall
          ? <AndroidNotificationAction>[
              const AndroidNotificationAction(
                'answer_call',
                'Answer',
                showsUserInterface: true,
                cancelNotification: true,
              ),
              const AndroidNotificationAction(
                'decline_call',
                'Decline',
                cancelNotification: true,
              ),
            ]
          : null,
      ticker: title,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      (DateTime.now().millisecondsSinceEpoch % 1000000) ^ title.hashCode,
      title,
      body,
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        macOS: iosDetails,
      ),
      payload: payload.toJson(),
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('[PushNotifications] Foreground data: ${message.data}');
    debugPrint(
      '[PushNotifications] Foreground notification: ${message.notification?.title} / ${message.notification?.body}',
    );

    final payload = AppNotificationPayload.fromMap({
      ...message.data,
      'title': message.notification?.title ?? message.data['title'],
      'body': message.notification?.body ?? message.data['body'],
    });

    if (payload.type == AppNotificationType.call) {
      _setIncomingCallState(payload);
    }
    await showLocalNotification(payload);
  }

  void _handleNotificationTap(AppNotificationPayload payload) {
    if (prefs.getString('access_token') == null) {
      _pendingPayload = payload;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (payload.type == AppNotificationType.call) {
        _setIncomingCallState(payload);
      }
      _navigate(payload);
    });
  }

  Future<void> _navigate(AppNotificationPayload payload) async {
    final context = rootNavigatorKey.currentContext;
    final navigator = rootNavigatorKey.currentState;

    if (context == null || navigator == null) {
      _pendingPayload = payload;
      return;
    }

    switch (payload.type) {
      case AppNotificationType.message:
      case AppNotificationType.mention:
        final chatId = payload.chatId;
        if (chatId == null || chatId.isEmpty) {
          context.go(AppRoutes.messages);
          return;
        }
        context.go(AppRoutes.chat(chatId));
        return;
      case AppNotificationType.call:
        final roomName = payload.callId;
        if (roomName == null || roomName.isEmpty) {
          context.go(AppRoutes.messages);
          return;
        }
        await navigator.push(
          MaterialPageRoute(
            builder: (_) => LiveCallScreen(
              roomName: roomName,
              initialVideo: !_isDirectCall(payload, roomName),
              initialAudio: true,
            ),
          ),
        );
        return;
      case AppNotificationType.meeting:
        await navigator.push(
          MaterialPageRoute(builder: (_) => const MeetScreen()),
        );
        return;
      case AppNotificationType.activity:
      case AppNotificationType.unknown:
        await navigator.push(
          MaterialPageRoute(builder: (_) => const ActivityScreen()),
        );
        return;
    }
  }

  bool _isDirectCall(AppNotificationPayload payload, String roomName) {
    return payload.conversationType == 'dm' || roomName.startsWith('dm:');
  }

  void _handleCallAction(String actionId, AppNotificationPayload payload) {
    if (_ref == null) return;

    final call = IncomingCallModel(
      callerId: payload.callerId ?? '',
      callerName: payload.callerName ?? 'Unknown',
      callerAvatar: payload.callerAvatar,
      roomName: payload.callId ?? '',
      conversationType: payload.conversationType ?? 'meet',
    );

    final notifier = _ref!.read(chatSocketProvider.notifier);

    if (actionId == 'answer_call') {
      _setIncomingCallState(payload); // Ensure state is set before navigating
      notifier.emitCallAccepted(call);
      _navigate(payload);
    } else if (actionId == 'decline_call') {
      notifier.emitCallRejected(call);
      _localNotifications.cancelAll(); // Or cancel specific ID if we tracked it
    }
  }

  void _setIncomingCallState(AppNotificationPayload payload) {
    if (_ref == null) return;

    final call = IncomingCallModel(
      callerId: payload.callerId ?? '',
      callerName: payload.callerName ?? 'Unknown',
      callerAvatar: payload.callerAvatar,
      roomName: payload.callId ?? '',
      conversationType: payload.conversationType ?? 'meet',
    );

    _ref!.read(chatSocketProvider.notifier).setIncomingCall(call);
  }
}
