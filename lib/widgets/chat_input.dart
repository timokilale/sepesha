import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sepesha_app/models/message_model.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';

class ChatInput extends StatefulWidget {
  final Function(String message, MessageType type, String? attachment)
  onSendMessage;
  final VoidCallback? onSendLocation;
  final Function(bool isTyping)? onTypingChanged;
  final bool isEnabled;
  final String hintText;
  final int maxLines;
  final int? maxLength;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.onSendLocation,
    this.onTypingChanged,
    this.isEnabled = true,
    this.hintText = 'Type a message...',
    this.maxLines = 5,
    this.maxLength,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isTyping = false;
  bool _isRecording = false;
  bool _showAttachmentOptions = false;
  File? _selectedImage;

  late AnimationController _attachmentAnimationController;
  late AnimationController _sendButtonAnimationController;
  late Animation<double> _attachmentAnimation;
  late Animation<double> _sendButtonAnimation;

  @override
  void initState() {
    super.initState();

    _attachmentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _sendButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _attachmentAnimation = CurvedAnimation(
      parent: _attachmentAnimationController,
      curve: Curves.easeInOut,
    );

    _sendButtonAnimation = CurvedAnimation(
      parent: _sendButtonAnimationController,
      curve: Curves.easeInOut,
    );

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _attachmentAnimationController.dispose();
    _sendButtonAnimationController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;

    if (hasText != _isTyping) {
      setState(() {
        _isTyping = hasText;
      });

      widget.onTypingChanged?.call(_isTyping);

      if (_isTyping) {
        _sendButtonAnimationController.forward();
      } else {
        _sendButtonAnimationController.reverse();
      }
    }
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _showAttachmentOptions) {
      _hideAttachmentOptions();
    }
  }

  void _sendTextMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && widget.isEnabled) {
      widget.onSendMessage(text, MessageType.text, null);
      _textController.clear();
      _hideAttachmentOptions();

      // Haptic feedback
      HapticFeedback.lightImpact();
    }
  }

  void _toggleAttachmentOptions() {
    setState(() {
      _showAttachmentOptions = !_showAttachmentOptions;
    });

    if (_showAttachmentOptions) {
      _attachmentAnimationController.forward();
      _focusNode.unfocus();
    } else {
      _attachmentAnimationController.reverse();
    }
  }

  void _hideAttachmentOptions() {
    if (_showAttachmentOptions) {
      setState(() {
        _showAttachmentOptions = false;
      });
      _attachmentAnimationController.reverse();
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null) {
          _handleImageSelected(File(image.path));
        }
      } else {
        _showPermissionDeniedDialog('Camera');
      }
    } catch (e) {
      _showErrorDialog('Failed to take photo: $e');
    }

    _hideAttachmentOptions();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final status = await Permission.photos.request();
      if (status.isGranted) {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null) {
          _handleImageSelected(File(image.path));
        }
      } else {
        _showPermissionDeniedDialog('Photos');
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }

    _hideAttachmentOptions();
  }

  void _handleImageSelected(File imageFile) {
    setState(() {
      _selectedImage = imageFile;
    });

    _showImagePreviewDialog(imageFile);
  }

  void _showImagePreviewDialog(File imageFile) {
    showDialog(
      context: context,
      builder:
          (context) => ImagePreviewDialog(
            imageFile: imageFile,
            onSend: (caption) {
              // Here you would upload the image and get the URL
              // For now, we'll use the local path as placeholder
              widget.onSendMessage(
                caption ?? '',
                MessageType.image,
                imageFile.path, // In real app, this would be the uploaded URL
              );
              setState(() {
                _selectedImage = null;
              });
            },
            onCancel: () {
              setState(() {
                _selectedImage = null;
              });
            },
          ),
    );
  }

  void _sendLocation() {
    widget.onSendLocation?.call();
    _hideAttachmentOptions();
  }

  void _showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Permission Required'),
            content: Text(
              '$permission permission is required to use this feature.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text('Settings'),
              ),
            ],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Attachment options
        AnimatedBuilder(
          animation: _attachmentAnimation,
          builder: (context, child) {
            return SizeTransition(
              sizeFactor: _attachmentAnimation,
              child: _buildAttachmentOptions(),
            );
          },
        ),

        // Main input area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColor.lightGrey, width: 1),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  onPressed: widget.isEnabled ? _toggleAttachmentOptions : null,
                  icon: AnimatedRotation(
                    turns: _showAttachmentOptions ? 0.125 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.add,
                      color:
                          widget.isEnabled ? AppColor.primary : AppColor.grey,
                    ),
                  ),
                ),

                // Text input
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 40,
                      maxHeight: 120,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.lightGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      enabled: widget.isEnabled,
                      maxLines: widget.maxLines,
                      maxLength: widget.maxLength,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle: AppTextStyle.bodyTextStyle.copyWith(
                          color: AppColor.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        counterText: '',
                      ),
                      style: AppTextStyle.bodyTextStyle,
                      onSubmitted: (_) => _sendTextMessage(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send button
                AnimatedBuilder(
                  animation: _sendButtonAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.8 + (_sendButtonAnimation.value * 0.2),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              _isTyping && widget.isEnabled
                                  ? AppColor.primary
                                  : AppColor.grey,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed:
                              _isTyping && widget.isEnabled
                                  ? _sendTextMessage
                                  : null,
                          icon: Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColor.lightGrey, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentOption(
            icon: Icons.camera_alt,
            label: 'Camera',
            color: AppColor.primary,
            onTap: _pickImageFromCamera,
          ),
          _buildAttachmentOption(
            icon: Icons.photo_library,
            label: 'Gallery',
            color: Colors.green,
            onTap: _pickImageFromGallery,
          ),
          _buildAttachmentOption(
            icon: Icons.location_on,
            label: 'Location',
            color: Colors.red,
            onTap: _sendLocation,
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyle.captionTextStyle.copyWith(color: AppColor.grey),
          ),
        ],
      ),
    );
  }
}

// Image preview dialog
class ImagePreviewDialog extends StatefulWidget {
  final File imageFile;
  final Function(String? caption) onSend;
  final VoidCallback onCancel;

  const ImagePreviewDialog({
    super.key,
    required this.imageFile,
    required this.onSend,
    required this.onCancel,
  });

  @override
  State<ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<ImagePreviewDialog> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onCancel();
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  'Send Image',
                  style: AppTextStyle.headingTextStyle.copyWith(
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onSend(
                      _captionController.text.trim().isEmpty
                          ? null
                          : _captionController.text.trim(),
                    );
                  },
                  icon: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),

          // Image
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(widget.imageFile, fit: BoxFit.contain),
              ),
            ),
          ),

          // Caption input
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _captionController,
              style: AppTextStyle.bodyTextStyle.copyWith(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Add a caption...',
                hintStyle: AppTextStyle.bodyTextStyle.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ],
      ),
    );
  }
}

// Character counter widget
class CharacterCounter extends StatelessWidget {
  final int currentLength;
  final int maxLength;

  const CharacterCounter({
    super.key,
    required this.currentLength,
    required this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final isNearLimit = currentLength > maxLength * 0.8;
    final isOverLimit = currentLength > maxLength;

    return Text(
      '$currentLength/$maxLength',
      style: AppTextStyle.smallTextStyle.copyWith(
        color:
            isOverLimit
                ? Colors.red
                : isNearLimit
                ? Colors.orange
                : AppColor.grey,
      ),
    );
  }
}
