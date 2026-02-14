import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'api_service.dart';

class WebSocketService {
  StompClient? stompClient;

  final String _socketUrl = _buildSocketUrl();

  static String _buildSocketUrl() {
    final apiUri = Uri.parse(ApiService().baseUrl);
    final socketScheme = apiUri.scheme == 'https' ? 'wss' : 'ws';

    final socketPath = apiUri.path.endsWith('/api')
        ? '${apiUri.path.substring(0, apiUri.path.length - 4)}/ws/websocket'
        : '/ws/websocket';

    return Uri(
      scheme: socketScheme,
      host: apiUri.host,
      port: apiUri.hasPort ? apiUri.port : null,
      path: socketPath,
    ).toString();
  }

  // Connect to the Backend
  void connect(String token, Function(StompFrame) onConnectCallback) {
    if (stompClient != null && stompClient!.connected) return;

    stompClient = StompClient(
      config: StompConfig(
        url: _socketUrl,
        onConnect: onConnectCallback,
        beforeConnect: () async {
          print('🔗 Connecting to WebSocket: $_socketUrl');
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