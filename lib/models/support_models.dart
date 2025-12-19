// lib/models/support_models.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// ==================== FAQ MODEL ====================

class FAQItem {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int order;
  final bool isVisible;
  final List<String> tags;
  final int helpfulCount;
  final int unhelpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  FAQItem({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.order,
    this.isVisible = true,
    this.tags = const [],
    this.helpfulCount = 0,
    this.unhelpfulCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FAQItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FAQItem.fromJson({...data, 'id': doc.id});
  }

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      category: json['category'] ?? 'general',
      order: json['order'] ?? 0,
      isVisible: json['isVisible'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      helpfulCount: json['helpfulCount'] ?? 0,
      unhelpfulCount: json['unhelpfulCount'] ?? 0,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    'category': category,
    'order': order,
    'isVisible': isVisible,
    'tags': tags,
    'helpfulCount': helpfulCount,
    'unhelpfulCount': unhelpfulCount,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

// ==================== SUPPORT TICKET MODEL ====================

enum TicketStatus {
  open,
  assigned,
  inProgress,
  waiting,
  resolved,
  closed,
  reopened,
}

enum TicketPriority { low, medium, high, urgent }

enum TicketCategory { billing, account, investments, goals, technical, other }

class SupportTicket {
  final String ticketId;
  final String userId;
  final String subject;
  final String description;
  final TicketCategory category;
  final TicketStatus status;
  final TicketPriority priority;
  final String? assignedToStaffId;
  final String? assignedToStaffName;
  final List<String> attachmentUrls;
  final int messageCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final String? resolutionNotes;

  SupportTicket({
    required this.ticketId,
    required this.userId,
    required this.subject,
    required this.description,
    required this.category,
    required this.status,
    required this.priority,
    this.assignedToStaffId,
    this.assignedToStaffName,
    this.attachmentUrls = const [],
    this.messageCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.resolutionNotes,
  });

  factory SupportTicket.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SupportTicket.fromJson({...data, 'ticketId': doc.id});
  }

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      ticketId: json['ticketId'] ?? '',
      userId: json['userId'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      category: _parseCategory(json['category']),
      status: _parseStatus(json['status']),
      priority: _parsePriority(json['priority']),
      assignedToStaffId: json['assignedToStaffId'],
      assignedToStaffName: json['assignedToStaffName'],
      attachmentUrls: List<String>.from(json['attachmentUrls'] ?? []),
      messageCount: json['messageCount'] ?? 0,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      resolvedAt: json['resolvedAt'] != null
          ? _parseDate(json['resolvedAt'])
          : null,
      resolutionNotes: json['resolutionNotes'],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'subject': subject,
    'description': description,
    'category': category.name,
    'status': status.name,
    'priority': priority.name,
    'assignedToStaffId': assignedToStaffId,
    'assignedToStaffName': assignedToStaffName,
    'attachmentUrls': attachmentUrls,
    'messageCount': messageCount,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    'resolutionNotes': resolutionNotes,
  };

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static TicketCategory _parseCategory(dynamic value) {
    return TicketCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TicketCategory.other,
    );
  }

  static TicketStatus _parseStatus(dynamic value) {
    return TicketStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TicketStatus.open,
    );
  }

  static TicketPriority _parsePriority(dynamic value) {
    return TicketPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TicketPriority.medium,
    );
  }
}

// ==================== CHAT MESSAGE MODEL ====================

enum MessageSender { user, support, system }

class ChatMessage {
  final String messageId;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final MessageSender senderType;
  final String content;
  final List<String> attachmentUrls;
  final bool isRead;
  final DateTime sentAt;
  final DateTime? editedAt;
  final String? replyToMessageId;

  ChatMessage({
    required this.messageId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.senderType,
    required this.content,
    this.attachmentUrls = const [],
    this.isRead = false,
    required this.sentAt,
    this.editedAt,
    this.replyToMessageId,
  });

  factory ChatMessage.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ChatMessage.fromJson({...data, 'messageId': doc.id});
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderAvatar: json['senderAvatar'] ?? '',
      senderType: _parseSenderType(json['senderType']),
      content: json['content'] ?? '',
      attachmentUrls: List<String>.from(json['attachmentUrls'] ?? []),
      isRead: json['isRead'] ?? false,
      sentAt: _parseDate(json['sentAt']),
      editedAt: json['editedAt'] != null ? _parseDate(json['editedAt']) : null,
      replyToMessageId: json['replyToMessageId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'conversationId': conversationId,
    'senderId': senderId,
    'senderName': senderName,
    'senderAvatar': senderAvatar,
    'senderType': senderType.name,
    'content': content,
    'attachmentUrls': attachmentUrls,
    'isRead': isRead,
    'sentAt': Timestamp.fromDate(sentAt),
    'editedAt': editedAt != null ? Timestamp.fromDate(editedAt!) : null,
    'replyToMessageId': replyToMessageId,
  };

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static MessageSender _parseSenderType(dynamic value) {
    return MessageSender.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageSender.user,
    );
  }
}

// ==================== CONVERSATION MODEL ====================

// ==================== CONVERSATION MODEL ====================

enum ConversationStatus { open, assigned, inProgress, closed }

class SupportConversation {
  final String conversationId;
  final String userId;
  final String? relatedTicketId;
  final String title;

  final ConversationStatus status;
  final bool isActive;

  final String? assignedToAdminId;
  final String? assignedToAdminName;

  final List<String> staffMemberIds;
  final int unreadCount;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final DateTime? closedAt;

  SupportConversation({
    required this.conversationId,
    required this.userId,
    this.relatedTicketId,
    required this.title,
    required this.status,
    this.isActive = true,
    this.assignedToAdminId,
    this.assignedToAdminName,
    this.staffMemberIds = const [],
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.closedAt,
  });

  // ---------- Firestore ----------

  factory SupportConversation.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SupportConversation.fromJson({...data, 'conversationId': doc.id});
  }

  factory SupportConversation.fromJson(Map<String, dynamic> json) {
    return SupportConversation(
      conversationId: json['conversationId'] ?? '',
      userId: json['userId'] ?? '',
      relatedTicketId: json['relatedTicketId'],
      title: json['title'] ?? '',
      status: _parseStatus(json['status']),
      isActive: json['isActive'] ?? true,
      assignedToAdminId: json['assignedToAdminId'],
      assignedToAdminName: json['assignedToAdminName'],
      staffMemberIds: List<String>.from(json['staffMemberIds'] ?? []),
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      lastMessageAt: json['lastMessageAt'] != null
          ? _parseDate(json['lastMessageAt'])
          : null,
      closedAt: json['closedAt'] != null ? _parseDate(json['closedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'relatedTicketId': relatedTicketId,
    'title': title,
    'status': status.name,
    'isActive': isActive,
    'assignedToAdminId': assignedToAdminId,
    'assignedToAdminName': assignedToAdminName,
    'staffMemberIds': staffMemberIds,
    'unreadCount': unreadCount,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'lastMessageAt': lastMessageAt != null
        ? Timestamp.fromDate(lastMessageAt!)
        : null,
    'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
  };

  // ---------- Helpers ----------

  static ConversationStatus _parseStatus(dynamic value) {
    if (value is String) {
      return ConversationStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ConversationStatus.open,
      );
    }
    return ConversationStatus.open;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

// ==================== NOTIFICATION MODEL ====================

enum NotificationType {
  faqHelpful,
  ticketUpdate,
  messageReceived,
  ticketResolved,
  newTicketAssigned,
}

class SupportNotification {
  final String notificationId;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? relatedTicketId;
  final String? relatedConversationId;
  final bool isRead;
  final DateTime createdAt;

  SupportNotification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.relatedTicketId,
    this.relatedConversationId,
    this.isRead = false,
    required this.createdAt,
  });

  factory SupportNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return SupportNotification.fromJson({...data, 'notificationId': doc.id});
  }

  factory SupportNotification.fromJson(Map<String, dynamic> json) {
    return SupportNotification(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      type: _parseType(json['type']),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      relatedTicketId: json['relatedTicketId'],
      relatedConversationId: json['relatedConversationId'],
      isRead: json['isRead'] ?? false,
      createdAt: _parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'type': type.name,
    'title': title,
    'body': body,
    'relatedTicketId': relatedTicketId,
    'relatedConversationId': relatedConversationId,
    'isRead': isRead,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static NotificationType _parseType(dynamic value) {
    return NotificationType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationType.messageReceived,
    );
  }
}
