// // lib/models/goals_model.dart

// enum GoalCategory {
//   vacation,
//   realestate,
//   education,
//   vehicle,
//   wedding,
//   business,
//   investment,
//   retirement,
//   emergency,
//   other,
// }

// enum GoalStatus {
//   active,
//   paused,
//   completed,
//   cancelled,
// }

// class GoalModel {
//   final String goalId;
//   final String userId;
//   final String title;
//   final String description;
//   final GoalCategory category;
//   final GoalStatus status;

//   // Financial metrics
//   final double targetAmount;
//   final double currentAmount;
//   final double monthlyContribution; // Optional recurring amount

//   // Timeline
//   final DateTime createdAt;
//   final DateTime targetDate;

//   // Additional info
//   final String? iconEmoji; // e.g., 🚗 for car, 🏠 for house
//   final String? imageUrl;
//   final bool isPriority; // Pinned on home tab
//   final DateTime updatedAt;

//   GoalModel({
//     required this.goalId,
//     required this.userId,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.status,
//     required this.targetAmount,
//     required this.currentAmount,
//     required this.monthlyContribution,
//     required this.createdAt,
//     required this.targetDate,
//     this.iconEmoji,
//     this.imageUrl,
//     this.isPriority = false,
//     required this.updatedAt,
//   });

//   // Getters
//   double get progressPercentage {
//     if (targetAmount == 0) return 0;
//     return (currentAmount / targetAmount) * 100;
//   }

//   double get remainingAmount {
//     return (targetAmount - currentAmount).clamp(0.0, double.infinity);
//   }

//   int get daysRemaining {
//     return targetDate.difference(DateTime.now()).inDays;
//   }

//   bool get isCompleted => currentAmount >= targetAmount;

//   bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

//   String get statusLabel {
//     switch (status) {
//       case GoalStatus.active:
//         return 'Active';
//       case GoalStatus.paused:
//         return 'Paused';
//       case GoalStatus.completed:
//         return 'Completed';
//       case GoalStatus.cancelled:
//         return 'Cancelled';
//     }
//   }

//   String get categoryLabel {
//     switch (category) {
//       case GoalCategory.vacation:
//         return 'Vacation';
//       case GoalCategory.realestate:
//         return 'Real Estate';
//       case GoalCategory.education:
//         return 'Education';
//       case GoalCategory.vehicle:
//         return 'Vehicle';
//       case GoalCategory.wedding:
//         return 'Wedding';
//       case GoalCategory.business:
//         return 'Business';
//       case GoalCategory.investment:
//         return 'Investment';
//       case GoalCategory.retirement:
//         return 'Retirement';
//       case GoalCategory.emergency:
//         return 'Emergency Fund';
//       case GoalCategory.other:
//         return 'Other';
//     }
//   }

//   // Factory methods
//   factory GoalModel.fromJson(Map<String, dynamic> json) {
//     return GoalModel(
//       goalId: json['goalId'] ?? '',
//       userId: json['userId'] ?? '',
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       category: GoalCategory.values[json['category'] ?? 9],
//       status: GoalStatus.values[json['status'] ?? 0],
//       targetAmount: (json['targetAmount'] ?? 0).toDouble(),
//       currentAmount: (json['currentAmount'] ?? 0).toDouble(),
//       monthlyContribution:
//           (json['monthlyContribution'] ?? 0).toDouble(),
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'])
//           : DateTime.now(),
//       targetDate: json['targetDate'] != null
//           ? DateTime.parse(json['targetDate'])
//           : DateTime.now(),
//       iconEmoji: json['iconEmoji'],
//       imageUrl: json['imageUrl'],
//       isPriority: json['isPriority'] ?? false,
//       updatedAt: json['updatedAt'] != null
//           ? DateTime.parse(json['updatedAt'])
//           : DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'goalId': goalId,
//       'userId': userId,
//       'title': title,
//       'description': description,
//       'category': category.index,
//       'status': status.index,
//       'targetAmount': targetAmount,
//       'currentAmount': currentAmount,
//       'monthlyContribution': monthlyContribution,
//       'createdAt': createdAt.toIso8601String(),
//       'targetDate': targetDate.toIso8601String(),
//       'iconEmoji': iconEmoji,
//       'imageUrl': imageUrl,
//       'isPriority': isPriority,
//       'updatedAt': updatedAt.toIso8601String(),
//     };
//   }

//   GoalModel copyWith({
//     String? goalId,
//     String? userId,
//     String? title,
//     String? description,
//     GoalCategory? category,
//     GoalStatus? status,
//     double? targetAmount,
//     double? currentAmount,
//     double? monthlyContribution,
//     DateTime? createdAt,
//     DateTime? targetDate,
//     String? iconEmoji,
//     String? imageUrl,
//     bool? isPriority,
//     DateTime? updatedAt,
//   }) {
//     return GoalModel(
//       goalId: goalId ?? this.goalId,
//       userId: userId ?? this.userId,
//       title: title ?? this.title,
//       description: description ?? this.description,
//       category: category ?? this.category,
//       status: status ?? this.status,
//       targetAmount: targetAmount ?? this.targetAmount,
//       currentAmount: currentAmount ?? this.currentAmount,
//       monthlyContribution: monthlyContribution ?? this.monthlyContribution,
//       createdAt: createdAt ?? this.createdAt,
//       targetDate: targetDate ?? this.targetDate,
//       iconEmoji: iconEmoji ?? this.iconEmoji,
//       imageUrl: imageUrl ?? this.imageUrl,
//       isPriority: isPriority ?? this.isPriority,
//       updatedAt: updatedAt ?? this.updatedAt,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is GoalModel &&
//         other.goalId == goalId &&
//         other.userId == userId &&
//         other.currentAmount == currentAmount;
//   }

//   @override
//   int get hashCode => goalId.hashCode ^ userId.hashCode ^ currentAmount.hashCode;
// }

// // Goal contribution transaction (links goal to transaction)
// class GoalContributionModel {
//   final String contributionId;
//   final String goalId;
//   final String userId;
//   final double amount;
//   final String transactionId;
//   final DateTime createdAt;

//   GoalContributionModel({
//     required this.contributionId,
//     required this.goalId,
//     required this.userId,
//     required this.amount,
//     required this.transactionId,
//     required this.createdAt,
//   });

//   factory GoalContributionModel.fromJson(Map<String, dynamic> json) {
//     return GoalContributionModel(
//       contributionId: json['contributionId'] ?? '',
//       goalId: json['goalId'] ?? '',
//       userId: json['userId'] ?? '',
//       amount: (json['amount'] ?? 0).toDouble(),
//       transactionId: json['transactionId'] ?? '',
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'])
//           : DateTime.now(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'contributionId': contributionId,
//       'goalId': goalId,
//       'userId': userId,
//       'amount': amount,
//       'transactionId': transactionId,
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }
// lib/models/goals_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalCategory {
  vacation,
  realestate,
  education,
  vehicle,
  wedding,
  business,
  investment,
  retirement,
  emergency,
  other,
}

enum GoalStatus { active, paused, completed, cancelled }

class GoalModel {
  final String goalId;
  final String userId;
  final String title;
  final String description;
  final GoalCategory category;
  final GoalStatus status;

  // Financial metrics
  final double targetAmount;
  final double currentAmount;
  final double monthlyContribution; // Optional recurring amount

  // Timeline
  final DateTime createdAt;
  final DateTime targetDate;

  // Additional info
  final String? iconEmoji; // e.g., 🚗 for car, 🏠 for house
  final String? imageUrl;
  final bool isPriority; // Pinned on home tab
  final DateTime updatedAt;

  GoalModel({
    required this.goalId,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyContribution,
    required this.createdAt,
    required this.targetDate,
    this.iconEmoji,
    this.imageUrl,
    this.isPriority = false,
    required this.updatedAt,
  });

  // Getters
  double get progressPercentage {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount) * 100;
  }

  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0.0, double.infinity);
  }

  int get daysRemaining {
    return targetDate.difference(DateTime.now()).inDays;
  }

  bool get isCompleted => currentAmount >= targetAmount;

  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

  String get statusLabel {
    switch (status) {
      case GoalStatus.active:
        return 'Active';
      case GoalStatus.paused:
        return 'Paused';
      case GoalStatus.completed:
        return 'Completed';
      case GoalStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get categoryLabel {
    switch (category) {
      case GoalCategory.vacation:
        return 'Vacation';
      case GoalCategory.realestate:
        return 'Real Estate';
      case GoalCategory.education:
        return 'Education';
      case GoalCategory.vehicle:
        return 'Vehicle';
      case GoalCategory.wedding:
        return 'Wedding';
      case GoalCategory.business:
        return 'Business';
      case GoalCategory.investment:
        return 'Investment';
      case GoalCategory.retirement:
        return 'Retirement';
      case GoalCategory.emergency:
        return 'Emergency Fund';
      case GoalCategory.other:
        return 'Other';
    }
  }

  // ==================== DATE PARSING HELPER ====================

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();

    // Handle Firestore Timestamp
    if (value is Timestamp) {
      return value.toDate();
    }

    // Handle String (ISO 8601)
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }

    // Fallback
    return DateTime.now();
  }

  // ==================== FACTORY METHODS ====================

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      goalId: json['goalId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: _parseCategory(json['category']),
      status: _parseStatus(json['status']),
      targetAmount: (json['targetAmount'] ?? 0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0).toDouble(),
      monthlyContribution: (json['monthlyContribution'] ?? 0).toDouble(),
      createdAt: _parseDate(json['createdAt']),
      targetDate: _parseDate(json['targetDate']),
      iconEmoji: json['iconEmoji'],
      imageUrl: json['imageUrl'],
      isPriority: json['isPriority'] ?? false,
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  static GoalCategory _parseCategory(dynamic value) {
    if (value is int) {
      return value < GoalCategory.values.length
          ? GoalCategory.values[value]
          : GoalCategory.other;
    }
    return GoalCategory.other;
  }

  static GoalStatus _parseStatus(dynamic value) {
    if (value is int) {
      return value < GoalStatus.values.length
          ? GoalStatus.values[value]
          : GoalStatus.active;
    }
    return GoalStatus.active;
  }

  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'userId': userId,
      'title': title,
      'description': description,
      'category': category.index,
      'status': status.index,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'monthlyContribution': monthlyContribution,
      'createdAt': Timestamp.fromDate(createdAt),
      'targetDate': Timestamp.fromDate(targetDate),
      'iconEmoji': iconEmoji,
      'imageUrl': imageUrl,
      'isPriority': isPriority,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  GoalModel copyWith({
    String? goalId,
    String? userId,
    String? title,
    String? description,
    GoalCategory? category,
    GoalStatus? status,
    double? targetAmount,
    double? currentAmount,
    double? monthlyContribution,
    DateTime? createdAt,
    DateTime? targetDate,
    String? iconEmoji,
    String? imageUrl,
    bool? isPriority,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      imageUrl: imageUrl ?? this.imageUrl,
      isPriority: isPriority ?? this.isPriority,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GoalModel &&
        other.goalId == goalId &&
        other.userId == userId &&
        other.currentAmount == currentAmount;
  }

  @override
  int get hashCode =>
      goalId.hashCode ^ userId.hashCode ^ currentAmount.hashCode;
}

// ==================== GOAL CONTRIBUTION MODEL ====================

class GoalContributionModel {
  final String contributionId;
  final String goalId;
  final String userId;
  final double amount;
  final String transactionId;
  final DateTime createdAt;

  GoalContributionModel({
    required this.contributionId,
    required this.goalId,
    required this.userId,
    required this.amount,
    required this.transactionId,
    required this.createdAt,
  });

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  factory GoalContributionModel.fromJson(Map<String, dynamic> json) {
    return GoalContributionModel(
      contributionId: json['contributionId'] ?? '',
      goalId: json['goalId'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      transactionId: json['transactionId'] ?? '',
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contributionId': contributionId,
      'goalId': goalId,
      'userId': userId,
      'amount': amount,
      'transactionId': transactionId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
