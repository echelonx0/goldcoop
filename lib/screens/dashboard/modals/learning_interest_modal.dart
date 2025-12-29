// lib/models/learning_interest_model.dart
// Model for user learning interests collected in Learning Center modal

class LearningInterestModel {
  final String? interestId;
  final String userId;
  final List<String> selectedTopics;
  final String? customTopic;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LearningInterestModel({
    this.interestId,
    required this.userId,
    required this.selectedTopics,
    this.customTopic,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'interestId': interestId,
      'userId': userId,
      'selectedTopics': selectedTopics,
      'customTopic': customTopic,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Create from Firestore document data
  factory LearningInterestModel.fromJson(Map<String, dynamic> json) {
    // Handle createdAt - can be Timestamp or String from Firestore
    DateTime createdDateTime = DateTime.now();
    final createdAt = json['createdAt'];

    if (createdAt != null) {
      if (createdAt is String) {
        createdDateTime = DateTime.tryParse(createdAt) ?? DateTime.now();
      } else if (createdAt.runtimeType.toString() ==
              '_JsonQueryDocumentSnapshot' ||
          createdAt.runtimeType.toString().contains('Timestamp')) {
        // Handle Firestore Timestamp
        try {
          createdDateTime = createdAt.toDate();
        } catch (e) {
          createdDateTime = DateTime.now();
        }
      }
    }

    // Handle updatedAt similarly
    DateTime? updatedDateTime;
    final updatedAt = json['updatedAt'];

    if (updatedAt != null) {
      if (updatedAt is String) {
        updatedDateTime = DateTime.tryParse(updatedAt);
      } else {
        try {
          updatedDateTime = updatedAt.toDate();
        } catch (e) {
          updatedDateTime = null;
        }
      }
    }

    return LearningInterestModel(
      interestId: json['interestId'] as String?,
      userId: json['userId'] as String? ?? '',
      selectedTopics: List<String>.from(json['selectedTopics'] as List? ?? []),
      customTopic: json['customTopic'] as String?,
      createdAt: createdDateTime,
      updatedAt: updatedDateTime,
    );
  }

  /// Create a copy with modified fields
  LearningInterestModel copyWith({
    String? interestId,
    String? userId,
    List<String>? selectedTopics,
    String? customTopic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LearningInterestModel(
      interestId: interestId ?? this.interestId,
      userId: userId ?? this.userId,
      selectedTopics: selectedTopics ?? this.selectedTopics,
      customTopic: customTopic ?? this.customTopic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user has selected any topics
  bool get hasSelection => selectedTopics.isNotEmpty;

  /// Check if custom topic was provided
  bool get hasCustomTopic => customTopic != null && customTopic!.isNotEmpty;

  /// Get total number of interests (predefined + custom)
  int get totalInterests {
    int count = selectedTopics.where((t) => t != 'custom').length;
    if (hasCustomTopic) count += 1;
    return count;
  }

  /// Check if 'custom' marker is in selected topics
  bool get customTopicSelected => selectedTopics.contains('custom');

  @override
  String toString() =>
      'LearningInterestModel(userId: $userId, topics: ${selectedTopics.length}, custom: $hasCustomTopic)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LearningInterestModel &&
          runtimeType == other.runtimeType &&
          interestId == other.interestId &&
          userId == other.userId &&
          selectedTopics == other.selectedTopics &&
          customTopic == other.customTopic &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      interestId.hashCode ^
      userId.hashCode ^
      selectedTopics.hashCode ^
      customTopic.hashCode ^
      createdAt.hashCode;
}
