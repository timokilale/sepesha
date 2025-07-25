import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';
import 'package:sepesha_app/Utilities/app_text_style.dart';
import 'package:sepesha_app/services/session_manager.dart';
import 'package:sepesha_app/services/preferences.dart';

class AppDrawerHeader extends StatefulWidget {
  const AppDrawerHeader({super.key});

  @override
  State<AppDrawerHeader> createState() => _AppDrawerHeaderState();
}

class _AppDrawerHeaderState extends State<AppDrawerHeader> {
  String? firstName;
  String? lastName;
  String? email;
  String? profilePhotoUrl;
  double? userRating;
  int? totalRides;
  String? userType;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      firstName = await Preferences.instance.firstName;
      lastName = await Preferences.instance.lastName;
      email = await Preferences.instance.email;

      final sessionUser = SessionManager.instance.user;
      if (sessionUser != null) {
        userType = sessionUser.userType;
        userRating = sessionUser.averageRating;
        totalRides = sessionUser.totalRides;
        profilePhotoUrl = sessionUser.profilePhotoUrl;
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error loading user data for drawer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : 'User';

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColor.primary,
            AppColor.primary.withOpacity(0.8),
            AppColor.primary.withOpacity(0.9),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColor.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Row(
                children: [
                  // Enhanced Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColor.white,
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: AppColor.white,
                        backgroundImage: profilePhotoUrl != null
                            ? NetworkImage(profilePhotoUrl!)
                            : null,
                        child: profilePhotoUrl == null
                            ? Icon(
                                Icons.person_rounded,
                                size: 40,
                                color: AppColor.primary,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyle.paragraph1(AppColor.white).copyWith(
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (email != null)
                          Text(
                            email!,
                            style: AppTextStyle.paragraph1(
                              AppColor.white.withOpacity(0.9),
                            ).copyWith(
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Stats and Badge Section
              Row(
                children: [
                  // Driver Rating
                  if (userType == 'driver' && userRating != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            userRating!.toStringAsFixed(1),
                            style: AppTextStyle.paragraph1(AppColor.white).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Total Rides
                  if (totalRides != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColor.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            color: AppColor.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalRides rides',
                            style: AppTextStyle.paragraph1(AppColor.white).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // User Type Badge
                  if (userType != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColor.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColor.white.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        userType!.toUpperCase(),
                        style: AppTextStyle.smallText(AppColor.white).copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
