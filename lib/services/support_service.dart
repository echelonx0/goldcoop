// lib/services/support_service.dart

import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/support_models.dart';

class SupportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== FAQ OPERATIONS ====================

  /// Get all visible FAQ items, optionally filtered by category
  Future<List<FAQItem>> getFAQItems({String? category}) async {
    try {
      Query query = _firestore
          .collection('faq')
          .where('isVisible', isEqualTo: true)
          .orderBy('order');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => FAQItem.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      dev.log('Error fetching FAQ: $e');
      return [];
    }
  }

  /// Stream FAQ items (real-time)
  Stream<List<FAQItem>> getFAQItemsStream({String? category}) {
    try {
      Query query = _firestore
          .collection('faq')
          .where('isVisible', isEqualTo: true)
          .orderBy('order');

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      return query
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(
                  (doc) => FAQItem.fromJson(doc.data() as Map<String, dynamic>),
                )
                .toList(),
          )
          .handleError((e) {
            dev.log('FAQ stream error: $e');
            return <FAQItem>[];
          });
    } catch (e) {
      dev.log('Error in FAQ stream: $e');
      return Stream.value([]);
    }
  }

  /// Search FAQ by question or tags
  Future<List<FAQItem>> searchFAQ(String query) async {
    try {
      final lowerQuery = query.toLowerCase();
      final allItems = await getFAQItems();

      return allItems
          .where(
            (item) =>
                item.question.toLowerCase().contains(lowerQuery) ||
                item.answer.toLowerCase().contains(lowerQuery) ||
                item.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)),
          )
          .toList();
    } catch (e) {
      dev.log('Error searching FAQ: $e');
      return [];
    }
  }

  /// Mark FAQ as helpful
  Future<bool> markFAQHelpful(String faqId, bool isHelpful) async {
    try {
      await _firestore.collection('faq').doc(faqId).update({
        if (isHelpful) 'helpfulCount': FieldValue.increment(1),
        if (!isHelpful) 'unhelpfulCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      dev.log('Error marking FAQ: $e');
      return false;
    }
  }

  /// Create FAQ item (admin only)
  Future<bool> createFAQItem(FAQItem faqItem) async {
    try {
      await _firestore.collection('faq').doc(faqItem.id).set(faqItem.toJson());
      return true;
    } catch (e) {
      dev.log('Error creating FAQ: $e');
      return false;
    }
  }

  /// Update FAQ item (admin only)
  Future<bool> updateFAQItem(FAQItem faqItem) async {
    try {
      await _firestore
          .collection('faq')
          .doc(faqItem.id)
          .update(faqItem.toJson());
      return true;
    } catch (e) {
      dev.log('Error updating FAQ: $e');
      return false;
    }
  }

  /// Delete FAQ item (admin only)
  Future<bool> deleteFAQItem(String faqId) async {
    try {
      await _firestore.collection('faq').doc(faqId).delete();
      return true;
    } catch (e) {
      dev.log('Error deleting FAQ: $e');
      return false;
    }
  }

  /// Create a new FAQ item
  // Future<bool> createFAQItem(FAQItem faqItem) async {
  //   try {
  //     await _firestore.collection('faq').doc(faqItem.id).set(
  //           faqItem.toJson(),
  //           SetOptions(merge: false),
  //         );
  //     dev.log('FAQ created: ${faqItem.id}');
  //     return true;
  //   } catch (e) {
  //     dev.log('Error creating FAQ: $e');
  //     return false;
  //   }
  // }

  /// Delete a FAQ item
  // Future<bool> deleteFAQItem(String faqId) async {
  //   try {
  //     await _firestore.collection('faq').doc(faqId).delete();
  //     dev.log('FAQ deleted: $faqId');
  //     return true;
  //   } catch (e) {
  //     dev.log('Error deleting FAQ: $e');
  //     return false;
  //   }
  // }

  /// Update a FAQ item
  // Future<bool> updateFAQItem(String faqId, Map<String, dynamic> updates) async {
  //   try {
  //     updates['updatedAt'] = DateTime.now();
  //     await _firestore.collection('faq').doc(faqId).update(updates);
  //     dev.log('FAQ updated: $faqId');
  //     return true;
  //   } catch (e) {
  //     dev.log('Error updating FAQ: $e');
  //     return false;
  //   }
  // }

  // ==================== SUPPORT TICKET OPERATIONS ====================

  /// Create a support ticket
  Future<String?> createTicket(SupportTicket ticket) async {
    try {
      final docRef = _firestore.collection('support_tickets').doc();
      await docRef.set(ticket.copyWith(ticketId: docRef.id).toJson());
      return docRef.id;
    } catch (e) {
      dev.log('Error creating ticket: $e');
      return null;
    }
  }

  /// Get user's tickets
  Future<List<SupportTicket>> getUserTickets(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('support_tickets')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SupportTicket.fromJson(doc.data()))
          .toList();
    } catch (e) {
      dev.log('Error fetching user tickets: $e');
      return [];
    }
  }

  /// Stream user's tickets (real-time)
  Stream<List<SupportTicket>> getUserTicketsStream(String userId) {
    return _firestore
        .collection('support_tickets')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportTicket.fromJson(doc.data()))
              .toList(),
        )
        .handleError((e) {
          dev.log('User tickets stream error: $e');
          return <SupportTicket>[];
        });
  }

  /// Get single ticket
  Future<SupportTicket?> getTicket(String ticketId) async {
    try {
      final doc = await _firestore
          .collection('support_tickets')
          .doc(ticketId)
          .get();
      if (!doc.exists) return null;
      return SupportTicket.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      dev.log('Error fetching ticket: $e');
      return null;
    }
  }

  /// Update ticket status
  Future<bool> updateTicketStatus(
    String ticketId,
    TicketStatus newStatus,
  ) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      dev.log('Error updating ticket status: $e');
      return false;
    }
  }

  /// Update ticket priority
  Future<bool> updateTicketPriority(
    String ticketId,
    TicketPriority priority,
  ) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'priority': priority.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      dev.log('Error updating ticket priority: $e');
      return false;
    }
  }

  /// Resolve ticket
  Future<bool> resolveTicket(String ticketId, String resolutionNotes) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'status': TicketStatus.resolved.name,
        'resolutionNotes': resolutionNotes,
        'resolvedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      dev.log('Error resolving ticket: $e');
      return false;
    }
  }

  // ==================== CHAT OPERATIONS ====================

  /// Create or get conversation
  Future<String?> createConversation(SupportConversation conversation) async {
    try {
      final docRef = _firestore.collection('support_conversations').doc();
      await docRef.set(
        conversation.copyWith(conversationId: docRef.id).toJson(),
      );
      return docRef.id;
    } catch (e) {
      dev.log('Error creating conversation: $e');
      return null;
    }
  }

  /// Get user's conversations
  Future<List<SupportConversation>> getUserConversations(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('support_conversations')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SupportConversation.fromJson(doc.data()))
          .toList();
    } catch (e) {
      dev.log('Error fetching conversations: $e');
      return [];
    }
  }

  /// Stream user's conversations (real-time)
  Stream<List<SupportConversation>> getUserConversationsStream(String userId) {
    return _firestore
        .collection('support_conversations')
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportConversation.fromJson(doc.data()))
              .toList(),
        )
        .handleError((e) {
          dev.log('Conversations stream error: $e');
          return <SupportConversation>[];
        });
  }

  /// Send chat message
  Future<String?> sendMessage(ChatMessage message) async {
    try {
      final docRef = _firestore
          .collection('support_conversations')
          .doc(message.conversationId)
          .collection('messages')
          .doc();

      await _firestore.runTransaction((transaction) async {
        // Add message
        transaction.set(
          docRef,
          message.copyWith(messageId: docRef.id).toJson(),
        );

        // Update conversation metadata
        transaction.update(
          _firestore
              .collection('support_conversations')
              .doc(message.conversationId),
          {
            'updatedAt': FieldValue.serverTimestamp(),
            'lastMessageAt': FieldValue.serverTimestamp(),
            'messageCount': FieldValue.increment(1),
          },
        );
      });

      return docRef.id;
    } catch (e) {
      dev.log('Error sending message: $e');
      return null;
    }
  }

  /// Get conversation messages
  Future<List<ChatMessage>> getConversationMessages(
    String conversationId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('support_conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('sentAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList();
    } catch (e) {
      dev.log('Error fetching messages: $e');
      return [];
    }
  }

  /// Stream conversation messages (real-time)
  Stream<List<ChatMessage>> getConversationMessagesStream(
    String conversationId,
  ) {
    return _firestore
        .collection('support_conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessage.fromJson(doc.data()))
              .toList(),
        )
        .handleError((e) {
          dev.log('Messages stream error: $e');
          return <ChatMessage>[];
        });
  }

  /// Mark messages as read
  Future<bool> markMessagesAsRead(String conversationId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('support_conversations')
          .doc(conversationId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .get();

      for (final doc in snapshot.docs) {
        await doc.reference.update({'isRead': true});
      }

      // Reset unread count
      await _firestore
          .collection('support_conversations')
          .doc(conversationId)
          .update({'unreadCount': 0});

      return true;
    } catch (e) {
      dev.log('Error marking messages as read: $e');
      return false;
    }
  }

  // ==================== NOTIFICATION OPERATIONS ====================

  /// Get user's notifications
  Future<List<SupportNotification>> getUserNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('support_notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => SupportNotification.fromJson(doc.data()))
          .toList();
    } catch (e) {
      dev.log('Error fetching notifications: $e');
      return [];
    }
  }

  /// Stream user's notifications (real-time)
  Stream<List<SupportNotification>> getUserNotificationsStream(String userId) {
    return _firestore
        .collection('support_notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportNotification.fromJson(doc.data()))
              .toList(),
        )
        .handleError((e) {
          dev.log('Notifications stream error: $e');
          return <SupportNotification>[];
        });
  }

  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('support_notifications')
          .doc(notificationId)
          .update({'isRead': true});
      return true;
    } catch (e) {
      dev.log('Error marking notification as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection('support_notifications')
          .doc(notificationId)
          .delete();
      return true;
    } catch (e) {
      dev.log('Error deleting notification: $e');
      return false;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Create notification (called by admin/system)
  Future<String?> createNotification(SupportNotification notification) async {
    try {
      final docRef = _firestore.collection('support_notifications').doc();
      await docRef.set(
        notification.copyWith(notificationId: docRef.id).toJson(),
      );
      return docRef.id;
    } catch (e) {
      dev.log('Error creating notification: $e');
      return null;
    }
  }

  /// Get unread notification count (real-time stream)
  Stream<int> getUnreadNotificationCount(String userId) {
    try {
      return _firestore
          .collection('support_notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .map((snapshot) => snapshot.docs.length)
          .handleError((e) {
            dev.log('Error in unread count stream: $e');
            return 0;
          });
    } catch (e) {
      dev.log('Error setting up unread count stream: $e');
      return Stream.value(0);
    }
  }
}

// ==================== EXTENSION METHODS ====================

extension SupportTicketExtension on SupportTicket {
  SupportTicket copyWith({
    String? ticketId,
    String? userId,
    String? subject,
    String? description,
    TicketCategory? category,
    TicketStatus? status,
    TicketPriority? priority,
    String? assignedToStaffId,
    String? assignedToStaffName,
    List<String>? attachmentUrls,
    int? messageCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    String? resolutionNotes,
  }) {
    return SupportTicket(
      ticketId: ticketId ?? this.ticketId,
      userId: userId ?? this.userId,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedToStaffId: assignedToStaffId ?? this.assignedToStaffId,
      assignedToStaffName: assignedToStaffName ?? this.assignedToStaffName,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      messageCount: messageCount ?? this.messageCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
    );
  }
}

extension SupportConversationExtension on SupportConversation {
  SupportConversation copyWith({
    String? conversationId,
    String? userId,
    String? relatedTicketId,
    String? title,
    bool? isActive,
    List<String>? staffMemberIds,
    int? unreadCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
  }) {
    return SupportConversation(
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      relatedTicketId: relatedTicketId ?? this.relatedTicketId,
      title: title ?? this.title,
      isActive: isActive ?? this.isActive,
      staffMemberIds: staffMemberIds ?? this.staffMemberIds,
      unreadCount: unreadCount ?? this.unreadCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      status: ConversationStatus.open,
    );
  }
}

extension ChatMessageExtension on ChatMessage {
  ChatMessage copyWith({
    String? messageId,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    MessageSender? senderType,
    String? content,
    List<String>? attachmentUrls,
    bool? isRead,
    DateTime? sentAt,
    DateTime? editedAt,
    String? replyToMessageId,
  }) {
    return ChatMessage(
      messageId: messageId ?? this.messageId,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      senderType: senderType ?? this.senderType,
      content: content ?? this.content,
      attachmentUrls: attachmentUrls ?? this.attachmentUrls,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt ?? this.sentAt,
      editedAt: editedAt ?? this.editedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
    );
  }
}

extension SupportNotificationExtension on SupportNotification {
  SupportNotification copyWith({
    String? notificationId,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? relatedTicketId,
    String? relatedConversationId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return SupportNotification(
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      relatedTicketId: relatedTicketId ?? this.relatedTicketId,
      relatedConversationId:
          relatedConversationId ?? this.relatedConversationId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
