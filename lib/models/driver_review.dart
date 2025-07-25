class DriverReview {
  final String id;
  final String driverId;
  final String userId;
  final int rating;
  final String review;
  final String createdAt;
  final ReviewerInfo? reviewer; // Optional, for when getting reviews

  DriverReview({
    required this.id,
    required this.driverId,
    required this.userId,
    required this.rating,
    required this.review,
    required this.createdAt,
    this.reviewer,
  });

  factory DriverReview.fromJson(Map<String, dynamic> json) {
    return DriverReview(
      id: json['id'],
      driverId: json['driver_id'],
      userId: json['user_id'],
      rating: json['rating'],
      review: json['review'],
      createdAt: json['created_at'],
      reviewer:
          json['user'] != null ? ReviewerInfo.fromJson(json['user']) : null,
    );
  }
}

class ReviewerInfo {
  final String reviewerId;
  final String reviewerName;
  final String? reviewerPhoto;

  ReviewerInfo({
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerPhoto,
  });

  factory ReviewerInfo.fromJson(Map<String, dynamic> json) {
    return ReviewerInfo(
      reviewerId: json['reviewer_id'],
      reviewerName: json['reviewer_name'],
      reviewerPhoto: json['reviewer_photo'],
    );
  }
}

class DriverRatingData {
  final String driverId;
  final int totalReviews;
  final double averageRating;
  final List<DriverReview> reviews;

  DriverRatingData({
    required this.driverId,
    required this.totalReviews,
    required this.averageRating,
    required this.reviews,
  });

  factory DriverRatingData.fromJson(Map<String, dynamic> json) {
    return DriverRatingData(
      driverId: json['driver_id'],
      totalReviews: json['total_reviews'],
      averageRating: (json['average_rating'] as num).toDouble(),
      reviews:
          (json['reviews'] as List)
              .map((review) => DriverReview.fromJson(review))
              .toList(),
    );
  }
}

class CreateReviewRequest {
  final String driverId;
  final int rating;
  final String review;

  CreateReviewRequest({
    required this.driverId,
    required this.rating,
    required this.review,
  });

  Map<String, dynamic> toJson() {
    return {'driver_id': driverId, 'rating': rating, 'review': review};
  }
}
