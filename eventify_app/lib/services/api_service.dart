import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:io' show Platform;
import 'package:http_parser/http_parser.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/event.dart';

class ApiService {
  static String get baseUrl => Platform.isAndroid
      ? 'http://10.0.2.2:5000/api' // Android emulator
      : 'http://localhost:5000/api'; // iOS simulator or web

  static String get imageBaseUrl =>
      Platform.isAndroid ? 'http://10.0.2.2:5000' : 'http://localhost:5000';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await setToken(data['token']);
      return data;
    }
    throw Exception(json.decode(response.body)['error']);
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['error']);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      print('Getting current user with token');
      final response = await http.get(
        Uri.parse('$baseUrl/user/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Current user response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  static Future<List<Event>> getEvents({String? search}) async {
    final token = await getToken();
    final queryParams = search != null ? '?search=$search' : '';

    print('Calling API: $baseUrl/events$queryParams'); // Debug log

    final response = await http.get(
      Uri.parse('$baseUrl/events$queryParams'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Event.fromJson(json)).toList();
    }
    throw Exception('Failed to load events');
  }

  static Future<List<Event>> getUserEvents() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      print('Fetching user events with token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/events/user/created'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('User events response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      }
      throw Exception('Failed to load user events');
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Event>> getFavoriteEvents() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      print('Fetching user favorites...');
      final response = await http.get(
        Uri.parse('$baseUrl/events/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Favorites response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<void> toggleFavorite(String eventId) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      print('Toggling favorite for event: $eventId');
      final isFavorite = await _checkIfFavorite(eventId);

      final response = await (isFavorite ? http.delete : http.post)(
        Uri.parse('$baseUrl/events/favorites/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Toggle response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update favorite status');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> _checkIfFavorite(String eventId) async {
    try {
      final favorites = await getFavoriteEvents();
      return favorites.any((event) => event.id == eventId);
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  static Future<Event> createEvent(Map<String, dynamic> eventData,
      {File? imageFile}) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      if (imageFile != null) {
        // Create multipart request for image upload
        final request =
            http.MultipartRequest('POST', Uri.parse('$baseUrl/events'));
        request.headers['Authorization'] = 'Bearer $token';

        // Add the image file with correct MIME type
        final mimeType = imageFile.path.toLowerCase().endsWith('.jpg') ||
                imageFile.path.toLowerCase().endsWith('.jpeg')
            ? 'image/jpeg'
            : imageFile.path.toLowerCase().endsWith('.png')
                ? 'image/png'
                : 'image/gif';

        request.files.add(await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ));

        // Add other fields as form fields
        eventData.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        print('Sending request with fields: ${request.fields}');
        print('And file: ${request.files.first.filename} (${mimeType})');

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Create event response: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 201) {
          return Event.fromJson(json.decode(response.body));
        }
        throw Exception(
            json.decode(response.body)['error'] ?? 'Failed to create event');
      } else {
        // Regular JSON request without image
        final response = await http.post(
          Uri.parse('$baseUrl/events'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(eventData),
        );

        if (response.statusCode == 201) {
          return Event.fromJson(json.decode(response.body));
        }
        throw Exception('Failed to create event');
      }
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  static Future<void> updateEvent(
      String eventId, Map<String, dynamic> eventData,
      {File? imageFile}) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      if (imageFile != null) {
        // Create multipart request for image upload
        final request =
            http.MultipartRequest('PUT', Uri.parse('$baseUrl/events/$eventId'));
        request.headers['Authorization'] = 'Bearer $token';

        // Add the image file
        final stream = http.ByteStream(imageFile.openRead());
        final length = await imageFile.length();
        final multipartFile = http.MultipartFile(
          'image', // This should match your backend field name
          stream,
          length,
          filename: imageFile.path.split('/').last,
        );
        request.files.add(multipartFile);

        // Add other fields
        eventData.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode != 200) {
          throw Exception(
              json.decode(response.body)['error'] ?? 'Failed to update event');
        }
      } else {
        // Regular JSON request without image
        final response = await http.put(
          Uri.parse('$baseUrl/events/$eventId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(eventData),
        );

        if (response.statusCode != 200) {
          throw Exception(
              json.decode(response.body)['error'] ?? 'Failed to update event');
        }
      }
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/events/$eventId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete event');
    }
  }

  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    print('Original imagePath: $imagePath');

    // Remove any 'uploads/' prefix and add it back properly
    final cleanPath = imagePath.replaceAll('uploads/', '');
    final url = '$imageBaseUrl/uploads/$cleanPath';
    print('Final URL: $url');
    return url;
  }

  static Future<Event> getEventById(String eventId) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/events/$eventId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Event.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load event');
  }

  static Future<void> registerForEvent(String eventId) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      print('Registering for event: $eventId');

      final response = await http.post(
        Uri.parse('$baseUrl/events/$eventId/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Registration response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error =
            json.decode(response.body)['error'] ?? 'Failed to register';
        throw Exception(error);
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> checkEventRegistration(
      String eventId) async {
    try {
      final token = await getToken();
      if (token == null) return {'isRegistered': false};

      print('Checking registration with token');
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/register/check'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Registration check response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'isRegistered': data['isRegistered'] ?? false};
      }
      return {'isRegistered': false};
    } catch (e) {
      print('Error checking registration: $e');
      return {'isRegistered': false};
    }
  }

  static Future<List<Event>> getRegisteredEvents() async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      print(
          'Fetching registered events with token: ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/events/user/registered'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Registered events response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      }

      if (response.statusCode == 404) {
        return [];
      }

      throw Exception(
          'Failed to load registered events: ${response.statusCode}');
    } catch (e) {
      print('Error getting registered events: $e');
      rethrow;
    }
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<void> updateProfile(Map<String, dynamic> updates,
      {File? imageFile}) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('Not authenticated');

      if (imageFile != null) {
        // Create multipart request for image upload
        final request =
            http.MultipartRequest('PUT', Uri.parse('$baseUrl/profile'));
        request.headers['Authorization'] = 'Bearer $token';

        // Add the image file with correct MIME type
        final mimeType = imageFile.path.toLowerCase().endsWith('.jpg') ||
                imageFile.path.toLowerCase().endsWith('.jpeg')
            ? 'image/jpeg'
            : imageFile.path.toLowerCase().endsWith('.png')
                ? 'image/png'
                : 'image/gif';

        request.files.add(await http.MultipartFile.fromPath(
          'profileImage',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        ));

        // Add other fields
        updates.forEach((key, value) {
          request.fields[key] = value.toString();
        });

        print('Sending profile update with fields: ${request.fields}');
        print('And file: ${request.files.first.filename} (${mimeType})');

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        print('Profile update response: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode != 200) {
          throw Exception(json.decode(response.body)['error'] ??
              'Failed to update profile');
        }
      } else {
        // Regular JSON request without image
        final response = await http.put(
          Uri.parse('$baseUrl/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(updates),
        );

        if (response.statusCode != 200) {
          throw Exception(json.decode(response.body)['error'] ??
              'Failed to update profile');
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }

  static Future<void> checkUploads() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/check-uploads'));
      print('Uploads directory contents: ${response.body}');
    } catch (e) {
      print('Error checking uploads: $e');
    }
  }
}
