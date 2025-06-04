import 'package:flutter/material.dart';
import 'package:sepesha_app/Utilities/app_color.dart';

class DriverInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const DriverInfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColor.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
