import '../../../core/network/livekit_config.dart';

class CallRoomModel {
  final String roomName;
  final String token;
  final String joinUrl;
  final String serverUrl;

  const CallRoomModel({
    required this.roomName,
    required this.token,
    required this.joinUrl,
    required this.serverUrl,
  });

  factory CallRoomModel.fromJson(Map<String, dynamic> json) {
    return CallRoomModel(
      roomName: json['roomName']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
      joinUrl: json['joinUrl']?.toString() ?? '',
      serverUrl: LiveKitConfig.resolve(json['serverUrl']?.toString()),
    );
  }
}

class IncomingCallModel {
  final String callerId;
  final String callerName;
  final String? callerAvatar;
  final String roomName;
  final String conversationType;

  const IncomingCallModel({
    required this.callerId,
    required this.callerName,
    this.callerAvatar,
    required this.roomName,
    required this.conversationType,
  });

  factory IncomingCallModel.fromJson(Map<String, dynamic> json) {
    return IncomingCallModel(
      callerId: json['callerId']?.toString() ?? '',
      callerName: json['callerName']?.toString() ?? 'Unknown',
      callerAvatar: json['callerAvatar']?.toString(),
      roomName: json['roomName']?.toString() ?? '',
      conversationType: json['conversationType']?.toString() ?? 'meet',
    );
  }
}
