import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/models/driver_review.dart';
import 'package:sepesha_app/services/rating_service.dart';

class DriverReviewsScreen extends StatefulWidget {
  final String driverId;
  final String driverName;

  const DriverReviewsScreen({
    Key? key,
    required this.driverId,
    required this.driverName,
  }) : super(key: key);

  @override
  State<DriverReviewsScreen> createState() => _DriverReviewsScreenState();
}

class _DriverReviewsScreenState extends State<DriverReviewsScreen> {
  DriverRatingData? _ratingData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllReviews();
  }

  Future<void> _loadAllReviews() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ratingData = await RatingService.getDriverReviews(widget.driverId);
      setState(() {
        _ratingData = ratingData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reviews';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.driverName} Reviews'),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllReviews,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_ratingData == null || _ratingData!.reviews.isEmpty) {
      return const Center(
        child: Text('No reviews available'),
      );
    }

    return Column(
      children: [
        _buildRatingSummary(),
        Expanded(child: _buildReviewsList()),
      ],
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                _ratingData!.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              RatingBarIndicator(
                rating: _ratingData!.averageRating,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 20.0,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_ratingData!.totalReviews} Reviews',
                  style: AppTextStyle.headingTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on customer feedback',
                  style: AppTextStyle.bodyTextStyle.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _ratingData!.reviews.length,
      itemBuilder: (context, index) {
        final review = _ratingData!.reviews[index];
        return _buildReviewCard(review);
      },
    );
  }

  Widget _buildReviewCard(DriverReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColor.primaryColor,
                  child: Text(
                    (review.reviewer?.reviewerName ?? 'A')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.reviewer?.reviewerName ?? 'Anonymous',
                        style: AppTextStyle.bodyTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: review.rating.toDouble(),
                            itemBuilder: (context, index) =>
                                const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 14.0,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(review.createdAt),
                            style: AppTextStyle.bodyTextStyle.copyWith(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (review.review.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.review,
                style: AppTextStyle.bodyTextStyle.copyWith(
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else {
        return 'Recently';
      }
    } catch (e) {
      return dateString;
    }
  }
}