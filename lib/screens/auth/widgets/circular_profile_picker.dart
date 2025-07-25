import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:sepesha_app/Utilities/app_color.dart';

class CircularProfilePicker extends StatelessWidget {
  final File? image;
  final Function(File?) onImageSelected;
  final double size;

  const CircularProfilePicker({
    Key? key,
    required this.image,
    required this.onImageSelected,
    this.size = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceDialog(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColor.primary, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipOval(
          child:
              image != null
                  ? Image.file(
                    image!,
                    fit: BoxFit.cover,
                    width: size,
                    height: size,
                  )
                  : Container(
                    color: Colors.grey.shade100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: size * 0.3,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add Photo',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Profile Picture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      context,
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      source: ImageSource.camera,
                    ),
                    _buildSourceOption(
                      context,
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      source: ImageSource.gallery,
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildSourceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _pickAndCropImage(source);
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColor.primary.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColor.primary),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColor.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        await _cropImage(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _cropImage(String imagePath) async {
    try {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // Square crop
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Profile Picture',
            toolbarColor: AppColor.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle, // This makes it circular
            showCropGrid: false,
          ),
          IOSUiSettings(
            title: 'Crop Profile Picture',
            aspectRatioLockEnabled: true,
            cropStyle: CropStyle.circle,
          ),
        ],
      );

      if (croppedFile != null) {
        onImageSelected(File(croppedFile.path));
      }
    } catch (e) {
      print('Error cropping image: $e');
    }
  }
}
