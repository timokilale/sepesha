import 'package:flutter/material.dart';
import 'package:sepesha_app/models/driver_review.dart';
import 'package:sepesha_app/services/rating_service.dart';
import 'package:sepesha_app/widgets/driver_rating_display.dart';

class SmartDriverRating extends StatefulWidget {
  final String driverId;
  final double iconSize;
  final double? fallbackRating;
  final int? fallbackReviews;

  const SmartDriverRating({
    Key? key,
    required this.driverId,
    this.iconSize = 14.0,
    this.fallbackRating,
    this.fallbackReviews,
  }) : super(key: key);

  @override
  State<SmartDriverRating> createState() => _SmartDriverRatingState();
}

class _SmartDriverRatingState extends State<SmartDriverRating> {
  DriverRatingData? _ratingData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRating();
  }

  Future<void> _loadRating() async {
    try {
      final data = await RatingService.getDriverReviews(widget.driverId);
      if (mounted) {
        setState(() {
          _ratingData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: 60,
        height: widget.iconSize + 2,
        child: Center(
          child: SizedBox(
            width: widget.iconSize,
            height: widget.iconSize,
            child: CircularProgressIndicator(strokeWidth: 1),
          ),
        ),
      );
    }

    if (_ratingData != null) {
      return CompactDriverRating(
        rating: _ratingData!.averageRating,
        totalReviews: _ratingData!.totalReviews,
        iconSize: widget.iconSize,
      );
    }

    // Fallback to provided values or default
    return CompactDriverRating(
      rating: widget.fallbackRating ?? 0.0,
      totalReviews: widget.fallbackReviews ?? 0,
      iconSize: widget.iconSize,
    );
  }
}
