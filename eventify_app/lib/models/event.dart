import 'package:eventify_app/services/api_service.dart';
import 'package:eventify_app/utils/date_formatter.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final String _rawDate;
  final String venue;
  final String? category;
  final String? image;
  final String creator;
  final Map<String, dynamic>? creatorDetails;
  final bool isFree;
  final double? price;
  final bool isFavorite;
  final int? capacity;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required String date,
    required this.venue,
    this.category,
    this.image,
    required this.creator,
    this.creatorDetails,
    required this.isFree,
    this.price,
    this.isFavorite = false,
    this.capacity,
  }) : _rawDate = date;

  String get date => DateFormatter.format(_rawDate);

  String get rawDate => _rawDate;

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'] ?? '',
      name: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      venue: json['location'] ?? '',
      category: json['category'],
      image:
          json['image'] != null ? ApiService.getImageUrl(json['image']) : null,
      creator: json['creator'] is Map
          ? json['creator']['_id'] ?? ''
          : json['creator'] ?? '',
      creatorDetails: json['creator'] is Map
          ? json['creator']
          : null,
      isFree: json['isFree'] ?? false,
      price: json['price']?.toDouble(),
      isFavorite: json['isFavorite'] ?? false,
      capacity: json['capacity']?.toInt(),
    );
  }
}
