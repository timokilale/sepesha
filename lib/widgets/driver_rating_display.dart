import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/models/driver_review.dart';
import 'package:sepesha_app/screens/reviews/driver_reviews_screen.dart';
import 'package:sepesha_app/services/rating_service.dart';

class DriverRatingDisplay extends StatefulWidget {
  final String driverId;
  final bool showReviewsList;
  final int maxReviewsToShow;
  final String? driverName;

  const DriverRatingDisplay({
    Key? key,
    required this.driverId,
    this.showReviewsList = true,
    this.maxReviewsToShow = 5,
    this.driverName
  }) : super(key: key);

  @override
  State<DriverRatingDisplay> createState() => _DriverRatingDisplayState();
}

class _DriverRatingDisplayState extends State<DriverRatingDisplay> {
  DriverRatingData? _ratingData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDriverRatings();
  }

  Future<void> _loadDriverRatings() async {
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
        _errorMessage = 'Failed to load ratings';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.grey[400], size: 48),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: AppTextStyle.bodyTextStyle.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadDriverRatings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_ratingData == null) {
      return const Center(child: Text('No rating data available'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rating Summary
        _buildRatingSummary(),

        if (widget.showReviewsList && _ratingData!.reviews.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildReviewsList(),
        ],
      ],
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Average Rating
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _ratingData!.averageRating.toStringAsFixed(1),
                style: AppTextStyle.headingTextStyle.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primaryColor,
                ),
              ),
              RatingBarIndicator(
                rating: _ratingData!.averageRating,
                itemBuilder:
                    (context, index) =>
                        const Icon(Icons.star, color: Colors.amber),
                itemCount: 5,
                itemSize: 20.0,
                direction: Axis.horizontal,
              ),
              const SizedBox(height: 4),
              Text(
                '${_ratingData!.totalReviews} reviews',
                style: AppTextStyle.bodyTextStyle.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // Rating Breakdown
          Expanded(child: _buildRatingBreakdown()),
        ],
      ),
    );
  }

  Widget _buildRatingBreakdown() {
    // Calculate rating distribution
    Map<int, int> ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in _ratingData!.reviews) {
      ratingCounts[review.rating] = (ratingCounts[review.rating] ?? 0) + 1;
    }

    return Column(
      children: [
        for (int i = 5; i >= 1; i--)
          _buildRatingBar(i, ratingCounts[i] ?? 0, _ratingData!.totalReviews),
      ],
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    double percentage = total > 0 ? count / total : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: AppTextStyle.bodyTextStyle.copyWith(fontSize: 12),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(AppColor.primaryColor),
              minHeight: 4,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: AppTextStyle.bodyTextStyle.copyWith(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    final reviewsToShow =
        _ratingData!.reviews.take(widget.maxReviewsToShow).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reviews',
          style: AppTextStyle.headingTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        ...reviewsToShow.map((review) => _buildReviewItem(review)).toList(),

        if (_ratingData!.reviews.length > widget.maxReviewsToShow)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextButton(
              onPressed: () {
                _showAllReviews();
              },
              child: Text(
                'View all ${_ratingData!.reviews.length} reviews',
                style: TextStyle(color: AppColor.primaryColor),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewItem(DriverReview review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    review.reviewer?.reviewerPhoto != null
                        ? NetworkImage(review.reviewer!.reviewerPhoto!)
                        : null,
                child:
                    review.reviewer?.reviewerPhoto == null
                        ? const Icon(Icons.person, size: 16)
                        : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.reviewer?.reviewerName ?? 'Anonymous',
                      style: AppTextStyle.bodyTextStyle.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        RatingBarIndicator(
                          rating: review.rating.toDouble(),
                          itemBuilder:
                              (context, index) =>
                                  const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: 12.0,
                          direction: Axis.horizontal,
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
            const SizedBox(height: 8),
            Text(
              review.review,
              style: AppTextStyle.bodyTextStyle.copyWith(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  void _showAllReviews() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DriverReviewsScreen(
        driverId: widget.driverId,
        driverName: widget.driverName ?? 'Driver',
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
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }
}

class CompactDriverRating extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double iconSize;

  const CompactDriverRating({
    Key? key,
    required this.rating,
    required this.totalReviews,
    this.iconSize = 14.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: Colors.amber, size: iconSize),
        const SizedBox(width: 4),
        Text(
          '${rating.toStringAsFixed(1)} ($totalReviews)',
          style: AppTextStyle.bodyTextStyle.copyWith(
            fontSize: iconSize - 2,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
