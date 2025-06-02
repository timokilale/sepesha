// widgets/image_upload_card.dart
import 'dart:io';

import 'package:flutter/material.dart';

class ImageUploadCard extends StatelessWidget {
  final String title;
  final File? imageFile;
  final VoidCallback onTap;
  final double height;

  const ImageUploadCard({
    super.key,
    required this.title,
    required this.onTap,
    this.imageFile,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                imageFile != null
                    ? Image.file(imageFile!, fit: BoxFit.cover)
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 40),
                        Text('Tap to upload photo'),
                      ],
                    ),
          ),
        ),
      ],
    );
  }
}
