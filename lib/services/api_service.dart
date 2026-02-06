import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_stats.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
  final String baseUrl = "https://mbtorailway-production.up.railway.app:8080/api";
      // ? "http://localhost:8080/api"  // Web (Chrome)
      // : "http://10.0.2.2:8080/api";  // Android Emulator

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email, 
        'password': password
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // --- FETCH STATS (3 Endpoints at once) ---
  Future<DashboardStats> getDonorStats(String token, int restaurantId) async {
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      // We run all 3 requests in parallel for speed
      final results = await Future.wait([
        http.get(Uri.parse('$baseUrl/analytic/donations/count/total/restaurant/$restaurantId'), headers: headers),
        http.get(Uri.parse('$baseUrl/analytic/donations/count/month/restaurant/$restaurantId'), headers: headers),
        http.get(Uri.parse('$baseUrl/analytic/donations/count/aval/restaurant/$restaurantId'), headers: headers),
      ]);

      // Check if any request failed
      if (results.any((res) => res.statusCode != 200)) {
        throw Exception('Failed to load analytics data');
      }

      // Parse the simple integer responses
      final total = int.parse(results[0].body);
      final month = int.parse(results[1].body);
      final active = int.parse(results[2].body);

      return DashboardStats.fromJson(total, month, active);

    } catch (e) {
      print("Error fetching stats: $e");
      rethrow;
    }
  }

  // --- ADD THIS NEW FUNCTION ---
  Future<void> addDonation(String token, Map<String, dynamic> donationData) async {
    // 1. Point to the donations endpoint
    final url = Uri.parse('$baseUrl/donations'); 
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token', // The token from login
          'Content-Type': 'application/json',
        },
        body: jsonEncode(donationData), // Sends your JSON data
      );

      // 2. Check for success (200 OK or 201 Created)
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to post donation: ${response.body}');
      }
    } catch (e) {
      print("Error posting donation: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getRestaurantDonations(String token, int restaurantId) async {
    // Endpoint: /api/donations/feed/restaurent/{id}
    // Note: You wrote "restaurent" in your prompt, double check if it is "restaurant" or "restaurent" in your Java code.
    // I will use "restaurant" (standard spelling) but change it if your backend uses "restaurent".
    final url = Uri.parse('$baseUrl/donations/feed/restaurent/$restaurantId'); 
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Returns a List of Maps
      } else {
        throw Exception('Failed to load donations: ${response.body}');
      }
    } catch (e) {
      print("Error fetching donations: $e");
      rethrow;
    }
  }

  // --- GET DONATION HISTORY ---
  Future<List<dynamic>> getDonationHistory(String token, int restaurantId) async {
    // Endpoint: /api/donations/feed/history/restaurant/{id}
    final url = Uri.parse('$baseUrl/donations/feed/history/restaurant/$restaurantId');
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Returns list of history items
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print("Error fetching history: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRestaurantDetails(String token, int restaurantId) async {
    final url = Uri.parse('$baseUrl/restaurants/details/$restaurantId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load restaurant details');
      }
    } catch (e) {
      print("Error fetching details: $e");
      rethrow;
    }
  }

  // --- GET MONTHLY COUNT (Specific Endpoint) ---
  Future<int> getMonthlyDonations(String token, int restaurantId) async {
    final url = Uri.parse('$baseUrl/analytic/donations/count/month/restaurant/$restaurantId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return int.parse(response.body); // Assuming it returns a raw number like "12"
      } else {
        return 0; // Default on error
      }
    } catch (e) {
      return 0;
    }
  }

  // --- GET VOLUNTEER DETAILS ---
  Future<Map<String, dynamic>> getVolunteerDetails(String token, int volunteerId) async {
    // CORRECTED ENDPOINT: /api/volunteer/details/{id}
    final url = Uri.parse('$baseUrl/volunteer/details/$volunteerId');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to load profile');
    } catch (e) {
      print("Error: $e");
      rethrow;
    }
  }
  
  // --- 2. Get All Available Donations (Feed) ---
  Future<List<dynamic>> getAllDonationsFeed(String token) async {
    final url = Uri.parse('$baseUrl/donations/feed');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load feed');
    }
  }

  // --- 3. Get Assigned Tasks (My Claims) ---
  Future<List<dynamic>> getVolunteerTasks(String token, int volunteerId) async {
    final url = Uri.parse('$baseUrl/donations/feed/volunteer/$volunteerId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  // --- CLAIM DONATION ---
  Future<void> claimDonation(String token, int donationId, int volunteerId) async {
    final url = Uri.parse('$baseUrl/donations/$donationId/claim?vId=$volunteerId');
    
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    print("DEBUG: Status: ${response.statusCode}"); // Check your console
    print("DEBUG: Body: ${response.body}");         // Check your console

    // 1. Check for specific error strings explicitly (even if status is 200)
    if (response.body.contains("error1")) {
      throw Exception("error1"); 
    }
    if (response.body.contains("error2")) {
      throw Exception("error2");
    }

    // 2. Check for standard HTTP errors
    if (response.statusCode != 200) {
      // Pass the body so the UI can read it
      throw Exception(response.body); 
    }
  }

  // --- UPDATE VOLUNTEER PROFILE ---
  Future<void> updateVolunteerProfile(String token, int volunteerId, Map<String, dynamic> updateData) async {
    // Endpoint: /api/volunteer/update/{id}
    final url = Uri.parse('$baseUrl/volunteer/update/$volunteerId');
    
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(updateData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update: ${response.body}');
    }
  }

  // --- ANALYTICS: VOLUNTEER ---

  Future<int> getVolunteerCreditScore(String token, int id) async {
    final url = Uri.parse('$baseUrl/analytic/creditor/volunteer/$id');
    return _getIntHelper(token, url);
  }

  Future<int> getVolunteerMonthCount(String token, int id) async {
    final url = Uri.parse('$baseUrl/analytic/donations/count/month/volunteer/$id');
    return _getIntHelper(token, url);
  }

  Future<int> getVolunteerTotalCount(String token, int id) async {
    final url = Uri.parse('$baseUrl/analytic/donations/count/total/volunteer/$id');
    return _getIntHelper(token, url);
  }

  Future<int> getVolunteerActiveCount(String token, int id) async {
    final url = Uri.parse('$baseUrl/analytic/donations/count/aval/volunteer/$id');
    return _getIntHelper(token, url);
  }

  
  // --- HELPER TO SAFELY PARSE NUMBERS ---
  Future<int> _getIntHelper(String token, Uri url) async {
    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      
      if (response.statusCode == 200) {
        // FIX: Parse as double first to handle "10.0", then round to int
        final doubleValue = double.tryParse(response.body);
        return doubleValue?.round() ?? 0; 
      }
      return 0;
    } catch (e) {
      print("Error fetching analytic: $e");
      return 0;
    }
  }

  // --- GET FINISHED COUNT ---
  Future<int> getVolunteerFinishedCount(String token, int id) async {
    final url = Uri.parse('$baseUrl/analytic/donations/count/finish/volunteer/$id');
    return _getIntHelper(token, url);
  }

  // --- VERIFY PICKUP (RESTAURANT SIDE) ---
  Future<bool> verifyPickupByRestaurant(String token, int restaurantId, String pickupToken) async {
    // Endpoint: /api/donations/{restaurantId}/verify-pickup?token={token}
    final url = Uri.parse('$baseUrl/donations/$restaurantId/verify-pickup?token=$pickupToken');
    
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // The API sends "true" or "false" as the body
      final body = response.body.toLowerCase();
      return body == "true";
    } else {
      throw Exception('Server Error: ${response.statusCode}');
    }
  }

  // --- ANALYTICS: GRAPH DATA ---
  Future<List<dynamic>> getGraphData(String token, int id) async {
    final url = Uri.parse('$baseUrl/analytic/graph/all/$id');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print("Error fetching graph: $e");
      return [];
    }
  }

  // --- ADMIN: STATISTICS ---
  Future<Map<String, dynamic>> getAdminStats(String token) async {
    final headers = {'Authorization': 'Bearer $token'};
    
    // Fetch all stats in parallel for performance
    final results = await Future.wait([
      http.get(Uri.parse('$baseUrl/admin/stats/tot-quantity'), headers: headers), // 0: Food Rescued
      http.get(Uri.parse('$baseUrl/admin/stats/users/count'), headers: headers),  // 1: Active Users
      http.get(Uri.parse('$baseUrl/admin/stats/tot-donations/available'), headers: headers), // 2: Active Donations
      http.get(Uri.parse('$baseUrl/admin/stats/tot-donations/completed'), headers: headers), // 3: Completed Donations
      http.get(Uri.parse('$baseUrl/admin/stats/tot-donations'), headers: headers), // 4: Total Donations
      http.get(Uri.parse('$baseUrl/admin/stats/tot-restaurants'), headers: headers), // 5: Total Restaurants
      http.get(Uri.parse('$baseUrl/admin/stats/tot-volunteers'), headers: headers), // 6: Total Volunteers
    ]);

    return {
      'foodRescued': _parseResponse(results[0]),
      'activeUsers': _parseResponse(results[1]),
      'activeDonations': _parseResponse(results[2]),
      'completedDonations': _parseResponse(results[3]),
      'totalDonations': _parseResponse(results[4]),
      'totalRestaurants': _parseResponse(results[5]),
      'totalVolunteers': _parseResponse(results[6]),
    };
  }

  String _parseResponse(http.Response response) {
    if (response.statusCode == 200) return response.body;
    return "0";
  }

  // --- ADMIN: PROFILE & MANAGEMENT ---
  Future<Map<String, dynamic>> getAdminDetails(String token, int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/get/admin/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load admin details');
  }

  Future<void> updateAdminPassword(String token, int id, String newPassword) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/update-password/$id/new?password=$newPassword'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception('Password update failed');
  }

  // --- SUPERADMIN ONLY ---
  Future<void> registerNewAdmin(String token, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/register'),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: jsonEncode({'userName': email, 'password': password}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to register admin');
    }
  }

  Future<List<dynamic>> getAllAdmins(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/admin/get/admin/all'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  // --- LISTS & APPROVALS ---
  Future<List<dynamic>> getAdminRestaurants(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/admin/stats/restaurants'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<List<dynamic>> getAdminVolunteers(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/admin/stats/volunteers'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<List<dynamic>> getUnapprovedVolunteers(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/admin/stats/volunteers/unapproved'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  Future<void> approveVolunteer(String token, int volunteerId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/volunteer/$volunteerId/approve'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception('Failed to approve');
  }

  // --- REGISTER RESTAURANT ---
  Future<void> registerRestaurant(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/restaurants/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  // --- REGISTER VOLUNTEER ---
  Future<void> registerVolunteer(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/volunteer/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Registration failed: ${response.body}');
    }
  }
  

}