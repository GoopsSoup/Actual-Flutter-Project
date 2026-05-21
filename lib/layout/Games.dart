// lib/game_model.dart
class GameModel {
  final String id;
  final String title;
  final String image;
  final List<String> innerImageUrls;
  final List<String> tags;
  final String rating;
  final String reviewCount;
  final String desc;
  final String compDesc;
  final String section;
  final List<String> minimumRequirements;
  final List<String> recommendedRequirements;

  const GameModel({
    required this.id, required this.title, required this.image,
    required this.innerImageUrls, required this.tags, required this.rating,
    required this.reviewCount, required this.desc, required this.section, required this.compDesc,
    required this.minimumRequirements, required this.recommendedRequirements,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      innerImageUrls: List<String>.from(json['innerImageUrls'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      rating: json['rating'] ?? '0.0',
      reviewCount: json['reviewCount'] ?? '0 reviews',
      desc: json['desc'] ?? '',
      compDesc: json['compDesc'] ?? '',
      section: json['section'] ?? '',
      minimumRequirements: List<String>.from(json['minimumRequirements'] ?? []),
      recommendedRequirements: List<String>.from(json['recommendedRequirements'] ?? []),
    );
  }
}