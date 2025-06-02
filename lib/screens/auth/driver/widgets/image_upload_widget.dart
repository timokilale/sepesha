import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadWidget extends StatelessWidget {
  final File? image;
  final String? label;
  final bool isCircle;
  final Function(File) onImageSelected;

  const ImageUploadWidget({
    super.key,
    this.image,
    this.label,
    this.isCircle = false,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showImageSourceDialog(context),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: image != null ? Colors.blue : Colors.grey,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(isCircle ? 60 : 8),
            ),
            child:
                image != null
                    ? isCircle
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.file(image!, fit: BoxFit.cover),
                        )
                        : Image.file(image!, fit: BoxFit.cover)
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.grey,
                        ),
                        if (label != null) ...[
                          const SizedBox(height: 8),
                          Text(label!),
                        ],
                      ],
                    ),
          ),
        ),
        if (image != null && label != null) ...[
          const SizedBox(height: 8),
          Text(label!),
        ],
      ],
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Upload Image'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, context);
                },
                child: const Text('Camera'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, context);
                },
                child: const Text('Gallery'),
              ),
            ],
          ),
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        onImageSelected(File(pickedFile.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.toString()}')),
      );
    }
  }
}
