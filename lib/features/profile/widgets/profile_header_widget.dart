import 'package:flutter/material.dart';

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(radius: 24, child: Text(initials)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.fullName, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text('${profile.employeeNumber} · ${profile.department} · ${profile.grade}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

