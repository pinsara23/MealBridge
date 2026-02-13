import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class WebSocketService {
  StompClient? stompClient;

  // IMPORTANT: 
  // - If using Android Emulator: Use '10.0.2.2'
  // - If using Real Device: Use your PC's IP address (e.g., '192.168.1.50')
  // - Protocol is 'ws://' (not 'http://')
  final String _socketUrl = 'ws://localhost:8080/ws/websocket'; 

  // Connect to the Backend
  void connect(String token, Function(StompFrame) onConnectCallback) {
    if (stompClient != null && stompClient!.connected) return;

    stompClient = StompClient(
      config: StompConfig(
        url: _socketUrl,
        onConnect: onConnectCallback,
        beforeConnect: () async {
          print('🔗 Connecting to WebSocket...');
        },
        onWebSocketError: (dynamic error) => print('❌ WebSocket Error: $error'),
        
        // Pass JWT Token in headers for security
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );

    stompClient!.activate();
  }

  // Listen to General Volunteer Updates
  void subscribeToVolunteerFeed(Function(String) onMessageReceived) {
    if (stompClient == null) return;

    stompClient!.subscribe(
      destination: '/topic/volunteers', // Must match backend!
      callback: (StompFrame frame) {
        if (frame.body != null) {
          onMessageReceived(frame.body!);
        }
      },
    );
  }

  // Listen to Updates for a Specific Donation (e.g., ID 123)
  void subscribeToDonation(int donationId, Function(String) onMessageReceived) {
    if (stompClient == null) return;

    stompClient!.subscribe(
      destination: '/topic/donation/$donationId', // Must match backend!
      callback: (StompFrame frame) {
        if (frame.body != null) {
          onMessageReceived(frame.body!);
        }
      },
    );
  }

  void subscribeToRestaurant(int restaurantId, Function(String) onMessageReceived) {
    if (stompClient == null) return;

    stompClient!.subscribe(
      destination: '/topic/restaurant/$restaurantId', // Must match backend!
      callback: (StompFrame frame) {
        if (frame.body != null) {
          onMessageReceived(frame.body!);
        }
      },
    );
  }

  void subscribeToVolunteerPrivate(int volunteerId, Function(String) onMessageReceived) {
    if (stompClient == null) return;

    stompClient!.subscribe(
      destination: '/topic/volunteer/$volunteerId', // Matches Backend
      callback: (StompFrame frame) {
        if (frame.body != null) {
          onMessageReceived(frame.body!);
        }
      },
    );
  }

  void subscribeToAdmin(Function(String) onMessageReceived) {
    if (stompClient == null) return;

    stompClient!.subscribe(
      destination: '/topic/admins',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          onMessageReceived(frame.body!);
        }
      },
    );
  }

  void disconnect() {
    stompClient?.deactivate();
    print("🔌 WebSocket Disconnected");
  }
}