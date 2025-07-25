import 'package:sepesha_app/models/message_model.dart';

class Conversation {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantPhoto;
  final String? participantPhone;
  final String? bookingId;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;
  final bool isOnline;
  final ConversationType type;

  const Conversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantPhoto,
    this.participantPhone,
    this.bookingId,
    this.lastMessage,
    required this.unreadCount,
    required this.lastActivity,
    required this.isOnline,
    required this.type,
  });

  // Create Conversation from API JSON response
  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String? ?? '',
      participantId: json['participant_id'] as String? ?? '',
      participantName: json['participant_name'] as String? ?? 'Unknown',
      participantPhoto: json['participant_photo'] as String?,
      participantPhone: json['participant_phone'] as String?,
      bookingId: json['booking_id'] as String?,
      lastMessage:
          json['last_message'] != null
              ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
              : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      lastActivity:
          DateTime.tryParse(json['last_activity'] as String? ?? '') ??
          DateTime.now(),
      isOnline: json['is_online'] as bool? ?? false,
      type: _parseConversationType(json['type'] as String?),
    );
  }

  // Convert Conversation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participant_id': participantId,
      'participant_name': participantName,
      if (participantPhoto != null) 'participant_photo': participantPhoto,
      if (participantPhone != null) 'participant_phone': participantPhone,
      if (bookingId != null) 'booking_id': bookingId,
      if (lastMessage != null) 'last_message': lastMessage!.toJson(),
      'unread_count': unreadCount,
      'last_activity': lastActivity.toIso8601String(),
      'is_online': isOnline,
      'type': type.name,
    };
  }

  // Helper method to parse conversation type from string
  static ConversationType _parseConversationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'driver_customer':
        return ConversationType.driverCustomer;
      case 'customer_driver':
        return ConversationType.customerDriver;
      case 'driver_support':
        return ConversationType.driverSupport;
      case 'customer_support':
        return ConversationType.customerSupport;
      case 'vendor_customer':
        return ConversationType.vendorCustomer;
      case 'vendor_driver':
        return ConversationType.vendorDriver;
      default:
        return ConversationType.general;
    }
  }

  // Create a copy of conversation with updated fields
  Conversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantPhoto,
    String? participantPhone,
    String? bookingId,
    Message? lastMessage,
    int? unreadCount,
    DateTime? lastActivity,
    bool? isOnline,
    ConversationType? type,
  }) {
    return Conversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantPhoto: participantPhoto ?? this.participantPhoto,
      participantPhone: participantPhone ?? this.participantPhone,
      bookingId: bookingId ?? this.bookingId,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastActivity: lastActivity ?? this.lastActivity,
      isOnline: isOnline ?? this.isOnline,
      type: type ?? this.type,
    );
  }

  // Check if conversation has unread messages
  bool get hasUnreadMessages => unreadCount > 0;

  // Get last message preview text
  String get lastMessagePreview {
    if (lastMessage == null) return 'No messages yet';

    switch (lastMessage!.messageType) {
      case MessageType.text:
        return lastMessage!.message;
      case MessageType.image:
        return '📷 Image';
      case MessageType.location:
        return '📍 Location';
      case MessageType.audio:
        return '🎵 Audio message';
      case MessageType.video:
        return '🎥 Video';
    }
  }

  // Get formatted last activity time
  String get formattedLastActivity {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inDays > 7) {
      return '${lastActivity.day}/${lastActivity.month}/${lastActivity.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Get conversation title based on type
  String get conversationTitle {
    switch (type) {
      case ConversationType.driverCustomer:
      case ConversationType.customerDriver:
        return bookingId != null
            ? '$participantName (Trip #${bookingId!.substring(0, 8)})'
            : participantName;
      case ConversationType.driverSupport:
      case ConversationType.customerSupport:
        return 'Support - $participantName';
      case ConversationType.vendorCustomer:
        return 'Order - $participantName';
      case ConversationType.vendorDriver:
        return 'Delivery - $participantName';
      case ConversationType.general:
        return participantName;
    }
  }

  // Get conversation subtitle
  String get conversationSubtitle {
    if (isOnline) {
      return 'Online';
    } else {
      return 'Last seen $formattedLastActivity';
    }
  }

  // Check if conversation is related to a booking
  bool get isBookingRelated => bookingId != null && bookingId!.isNotEmpty;

  // Get participant initials for avatar fallback
  String get participantInitials {
    final names = participantName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  @override
  String toString() {
    return 'Conversation(id: $id, participantId: $participantId, participantName: $participantName, unreadCount: $unreadCount, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum for different conversation types
enum ConversationType {
  driverCustomer,
  customerDriver,
  driverSupport,
  customerSupport,
  vendorCustomer,
  vendorDriver,
  general;

  // Get display name for conversation type
  String get displayName {
    switch (this) {
      case ConversationType.driverCustomer:
        return 'Driver Chat';
      case ConversationType.customerDriver:
        return 'Customer Chat';
      case ConversationType.driverSupport:
        return 'Driver Support';
      case ConversationType.customerSupport:
        return 'Customer Support';
      case ConversationType.vendorCustomer:
        return 'Vendor Chat';
      case ConversationType.vendorDriver:
        return 'Delivery Chat';
      case ConversationType.general:
        return 'Chat';
    }
  }

  // Get icon for conversation type
  String get icon {
    switch (this) {
      case ConversationType.driverCustomer:
      case ConversationType.customerDriver:
        return '🚗';
      case ConversationType.driverSupport:
      case ConversationType.customerSupport:
        return '🎧';
      case ConversationType.vendorCustomer:
        return '🛒';
      case ConversationType.vendorDriver:
        return '📦';
      case ConversationType.general:
        return '💬';
    }
  }
}

// Conversation list item data for UI
class ConversationListItem {
  final Conversation conversation;
  final bool isSelected;
  final bool isTyping;

  const ConversationListItem({
    required this.conversation,
    this.isSelected = false,
    this.isTyping = false,
  });

  ConversationListItem copyWith({
    Conversation? conversation,
    bool? isSelected,
    bool? isTyping,
  }) {
    return ConversationListItem(
      conversation: conversation ?? this.conversation,
      isSelected: isSelected ?? this.isSelected,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}
