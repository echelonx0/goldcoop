// lib/services/admin_support_service.dart

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/support_models.dart';

class AdminSupportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== CONVERSATIONS ====================

  /// Get all open/active support conversations
  Stream<List<SupportConversation>> getActiveConversationsStream() {
    return _firestore
        .collection('support_conversations')
        .where('status', whereIn: ['open', 'assigned', 'inProgress'])
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportConversation.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get all support conversations (including resolved)
  Stream<List<SupportConversation>> getAllConversationsStream() {
    return _firestore
        .collection('support_conversations')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportConversation.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get conversations assigned to a specific admin
  Stream<List<SupportConversation>> getAdminConversationsStream(
    String adminId,
  ) {
    return _firestore
        .collection('support_conversations')
        .where('assignedToAdminId', isEqualTo: adminId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportConversation.fromFirestore(doc))
              .toList(),
        );
  }

  /// Assign conversation to admin
  Future<void> assignConversationToAdmin(
    String conversationId,
    String adminId,
    String adminName,
  ) async {
    try {
      await _firestore
          .collection('support_conversations')
          .doc(conversationId)
          .update({
            'assignedToAdminId': adminId,
            'assignedToAdminName': adminName,
            'status': 'assigned',
            'updatedAt': FieldValue.serverTimestamp(),
          });
      log('[AdminSupportService] Conversation assigned to $adminName');
    } catch (e) {
      log('[AdminSupportService] Error assigning conversation: $e');
      rethrow;
    }
  }

  /// Mark conversation as in progress
  Future<void> markConversationInProgress(String conversationId) async {
    try {
      await _firestore
          .collection('support_conversations')
          .doc(conversationId)
          .update({
            'status': 'inProgress',
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      log('[AdminSupportService] Error marking in progress: $e');
      rethrow;
    }
  }

  /// Close conversation (when resolved)
  Future<void> closeConversation(String conversationId) async {
    try {
      await _firestore
          .collection('support_conversations')
          .doc(conversationId)
          .update({
            'status': 'closed',
            'closedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      log('[AdminSupportService] Error closing conversation: $e');
      rethrow;
    }
  }

  // ==================== TICKETS ====================

  /// Get all open tickets
  Stream<List<SupportTicket>> getOpenTicketsStream() {
    return _firestore
        .collection('support_tickets')
        .where('status', whereIn: ['open', 'assigned', 'inProgress', 'waiting'])
        .orderBy('priority', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportTicket.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get tickets assigned to admin
  Stream<List<SupportTicket>> getAdminTicketsStream(String adminId) {
    return _firestore
        .collection('support_tickets')
        .where('assignedToAdminId', isEqualTo: adminId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportTicket.fromFirestore(doc))
              .toList(),
        );
  }

  /// Get tickets by status
  Stream<List<SupportTicket>> getTicketsByStatusStream(TicketStatus status) {
    return _firestore
        .collection('support_tickets')
        .where('status', isEqualTo: status.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SupportTicket.fromFirestore(doc))
              .toList(),
        );
  }

  /// Assign ticket to admin
  Future<void> assignTicketToAdmin(
    String ticketId,
    String adminId,
    String adminName,
  ) async {
    try {
      await _firestore.collection('support_tickets').doc(ticketId).update({
        'assignedToAdminId': adminId,
        'assignedToStaffName': adminName,
        'status': TicketStatus.assigned.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      log('[AdminSupportService] Error assigning ticket: $e');
      rethrow;
    }
  }

  // ==================== ADMIN STATS ====================

  /// Get support dashboard stats
  Future<Map<String, dynamic>> getSupportStats() async {
    try {
      final openTickets = await _firestore
          .collection('support_tickets')
          .where('status', whereIn: ['open', 'assigned', 'inProgress'])
          .count()
          .get();

      final resolvedTickets = await _firestore
          .collection('support_tickets')
          .where('status', isEqualTo: TicketStatus.resolved.name)
          .count()
          .get();

      final activeConversations = await _firestore
          .collection('support_conversations')
          .where('status', whereIn: ['open', 'assigned', 'inProgress'])
          .count()
          .get();

      final pendingConversations = await _firestore
          .collection('support_conversations')
          .where('status', isEqualTo: 'open')
          .count()
          .get();

      return {
        'openTickets': openTickets.count,
        'resolvedTickets': resolvedTickets.count,
        'activeConversations': activeConversations.count,
        'pendingConversations': pendingConversations.count,
      };
    } catch (e) {
      log('[AdminSupportService] Error fetching stats: $e');
      return {
        'openTickets': 0,
        'resolvedTickets': 0,
        'activeConversations': 0,
        'pendingConversations': 0,
      };
    }
  }

  /// Get average response time
  Future<Duration?> getAverageResponseTime() async {
    try {
      final snapshot = await _firestore
          .collection('support_conversations')
          .limit(50)
          .get();

      if (snapshot.docs.isEmpty) return null;

      int totalMilliseconds = 0;
      int count = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAt = data['createdAt'] as Timestamp?;
        final updatedAt = data['updatedAt'] as Timestamp?;

        if (createdAt != null && updatedAt != null) {
          totalMilliseconds += updatedAt
              .toDate()
              .difference(createdAt.toDate())
              .inMilliseconds;
          count++;
        }
      }

      if (count == 0) return null;

      return Duration(milliseconds: totalMilliseconds ~/ count);
    } catch (e) {
      log('[AdminSupportService] Error calculating response time: $e');
      return null;
    }
  }

  // ==================== FAQ MANAGEMENT ====================

  /// Get all FAQ items
  Future<List<FAQItem>> getAllFAQItems() async {
    try {
      final snapshot = await _firestore
          .collection('faq')
          .orderBy('order', descending: false)
          .get();

      return snapshot.docs.map((doc) => FAQItem.fromFirestore(doc)).toList();
    } catch (e) {
      log('[AdminSupportService] Error fetching FAQ: $e');
      return [];
    }
  }

  /// Create FAQ item
  Future<void> createFAQItem(FAQItem item) async {
    try {
      await _firestore.collection('faq').add(item.toJson());
      log('[AdminSupportService] FAQ item created');
    } catch (e) {
      log('[AdminSupportService] Error creating FAQ: $e');
      rethrow;
    }
  }

  /// Update FAQ item
  Future<void> updateFAQItem(String itemId, FAQItem item) async {
    try {
      await _firestore.collection('faq').doc(itemId).update(item.toJson());
      log('[AdminSupportService] FAQ item updated');
    } catch (e) {
      log('[AdminSupportService] Error updating FAQ: $e');
      rethrow;
    }
  }

  /// Delete FAQ item
  Future<void> deleteFAQItem(String itemId) async {
    try {
      await _firestore.collection('faq').doc(itemId).delete();
      log('[AdminSupportService] FAQ item deleted');
    } catch (e) {
      log('[AdminSupportService] Error deleting FAQ: $e');
      rethrow;
    }
  }

  /// Stream FAQ items
  Stream<List<FAQItem>> getFAQStream() {
    return _firestore
        .collection('faq')
        .orderBy('order', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => FAQItem.fromFirestore(doc)).toList(),
        );
  }

  // ==================== CONVERSATIONS WITH TICKET LINKING ====================

  /// Get conversation with related ticket data
  Future<Map<String, dynamic>?> getConversationWithTicket(
    String conversationId,
  ) async {
    try {
      final conversationDoc = await _firestore
          .collection('support_conversations')
          .doc(conversationId)
          .get();

      if (!conversationDoc.exists) return null;

      final conversation = SupportConversation.fromFirestore(conversationDoc);
      SupportTicket? relatedTicket;

      if (conversation.relatedTicketId != null) {
        final ticketDoc = await _firestore
            .collection('support_tickets')
            .doc(conversation.relatedTicketId!)
            .get();

        if (ticketDoc.exists) {
          relatedTicket = SupportTicket.fromFirestore(ticketDoc);
        }
      }

      return {'conversation': conversation, 'ticket': relatedTicket};
    } catch (e) {
      log('[AdminSupportService] Error fetching conversation with ticket: $e');
      return null;
    }
  }

  /// Get all messages in conversation
  Future<List<ChatMessage>> getConversationMessages(
    String conversationId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('support_conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('sentAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('[AdminSupportService] Error fetching messages: $e');
      return [];
    }
  }

  /// Stream messages for real-time updates
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
              .map((doc) => ChatMessage.fromFirestore(doc))
              .toList(),
        );
  }

  // ==================== UNREAD TICKETS ====================

  /// Get count of unread tickets
  Future<int> getUnreadTicketCount() async {
    try {
      final snapshot = await _firestore
          .collection('support_tickets')
          .where('status', whereIn: ['open', 'waiting'])
          .count()
          .get();

      return snapshot.count!.toInt();
    } catch (e) {
      log('[AdminSupportService] Error fetching unread count: $e');
      return 0;
    }
  }

  /// Stream unread ticket count
  Stream<int> getUnreadTicketCountStream() {
    return _firestore
        .collection('support_tickets')
        .where('status', whereIn: ['open', 'waiting'])
        .snapshots()
        .map((snapshot) => snapshot.size);
  }
}
