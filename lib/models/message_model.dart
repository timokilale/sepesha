class Message {
  final String id;
  final String senderId;
  final String recipientId;
  final String? bookingId;
  final String message;
  final MessageType messageType;
  final String? attachment;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.recipientId,
    this.bookingId,
    required this.message,
    required this.messageType,
    this.attachment,
    required this.isRead,
    required this.createdAt,
    this.updatedAt,
  });

  // Create Message from API JSON response
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      recipientId: json['recipient_id'] as String? ?? '',
      bookingId: json['booking_id'] as String?,
      message: json['message'] as String? ?? '',
      messageType: _parseMessageType(json['message_type'] as String?),
      attachment: json['attachment'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'] as String? ?? '')
              : null,
    );
  }

  // Convert Message to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'recipient_id': recipientId,
      if (bookingId != null) 'booking_id': bookingId,
      'message': message,
      'message_type': messageType.name,
      if (attachment != null) 'attachment': attachment,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Helper method to parse message type from string
  static MessageType _parseMessageType(String? type) {
    switch (type?.toLowerCase()) {
      case 'text':
        return MessageType.text;
      case 'image':
        return MessageType.image;
      case 'location':
        return MessageType.location;
      case 'audio':
        return MessageType.audio;
      case 'video':
        return MessageType.video;
      default:
        return MessageType.text;
    }
  }

  // Create a copy of message with updated fields
  Message copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? bookingId,
    String? message,
    MessageType? messageType,
    String? attachment,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      bookingId: bookingId ?? this.bookingId,
      message: message ?? this.message,
      messageType: messageType ?? this.messageType,
      attachment: attachment ?? this.attachment,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if message is sent by current user
  bool isSentByUser(String currentUserId) {
    return senderId == currentUserId;
  }

  // Check if message has attachment
  bool get hasAttachment => attachment != null && attachment!.isNotEmpty;

  // Get formatted time string
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Get time in HH:MM format
  String get timeOnly {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Message(id: $id, senderId: $senderId, recipientId: $recipientId, message: $message, messageType: $messageType, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Message && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum for different message types
enum MessageType {
  text,
  image,
  location,
  audio,
  video;

  // Get display name for message type
  String get displayName {
    switch (this) {
      case MessageType.text:
        return 'Text';
      case MessageType.image:
        return 'Image';
      case MessageType.location:
        return 'Location';
      case MessageType.audio:
        return 'Audio';
      case MessageType.video:
        return 'Video';
    }
  }

  // Get icon for message type
  String get icon {
    switch (this) {
      case MessageType.text:
        return '💬';
      case MessageType.image:
        return '📷';
      case MessageType.location:
        return '📍';
      case MessageType.audio:
        return '🎵';
      case MessageType.video:
        return '🎥';
    }
  }
}

// Message status for UI display
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed;

  String get displayName {
    switch (this) {
      case MessageStatus.sending:
        return 'Sending...';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.read:
        return 'Read';
      case MessageStatus.failed:
        return 'Failed';
    }
  }
}
