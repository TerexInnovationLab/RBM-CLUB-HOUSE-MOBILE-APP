import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/staff_profile_model.dart';

/// Profile header widget.
class ProfileHeaderWidget extends StatelessWidget {
  /// Creates profile header widget.
  const ProfileHeaderWidget({super.key, required this.profile});

  /// Profile.
  final StaffProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final initials = profile.fullName
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 3),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(color: AppColors.primaryBlue, fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              profile.fullName,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              '${profile.employeeNumber} · Grade ${profile.grade}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                profile.department,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
