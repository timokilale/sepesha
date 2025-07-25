import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/components/app_button.dart';
import 'package:sepesha_app/services/rating_service.dart';

class RatingDialog extends StatefulWidget {
  final String driverId;
  final String driverName;
  final String? driverPhoto;
  final VoidCallback? onRatingSubmitted;

  const RatingDialog({
    Key? key,
    required this.driverId,
    required this.driverName,
    this.driverPhoto,
    this.onRatingSubmitted,
  }) : super(key: key);

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 5.0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (!RatingService.isValidRating(_rating.toInt())) {
      _showErrorSnackBar('Please select a rating between 1 and 5 stars');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await RatingService.createDriverReview(
        driverId: widget.driverId,
        rating: _rating.toInt(),
        review: _reviewController.text.trim(),
      );

      if (result != null) {
        // Success
        Navigator.of(context).pop();
        _showSuccessSnackBar('Thank you for your feedback!');
        widget.onRatingSubmitted?.call();
      } else {
        _showErrorSnackBar('Failed to submit rating. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred. Please try again.');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              'Rate Your Driver',
              style: AppTextStyle.headingTextStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Driver Info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage:
                      widget.driverPhoto != null
                          ? NetworkImage(widget.driverPhoto!)
                          : null,
                  child:
                      widget.driverPhoto == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.driverName,
                        style: AppTextStyle.bodyTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'How was your trip?',
                        style: AppTextStyle.bodyTextStyle.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Rating Stars
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 40,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder:
                  (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 8),

            // Rating Text
            Text(
              _getRatingText(_rating.toInt()),
              style: AppTextStyle.bodyTextStyle.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColor.primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Review Text Field
            TextField(
              controller: _reviewController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Write a review (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColor.primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed:
                        _isSubmitting
                            ? null
                            : () {
                              Navigator.of(context).pop();
                            },
                    child: Text(
                      'Skip',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: _isSubmitting ? 'Submitting...' : 'Submit Rating',
                    onPressed: _isSubmitting ? null : _submitRating,
                    backgroundColor: AppColor.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Rate your experience';
    }
  }
}
