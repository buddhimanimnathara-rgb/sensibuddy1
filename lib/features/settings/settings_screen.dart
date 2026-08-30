import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.language,
              ),
              title: const Text(
                "Language",
              ),
              subtitle: const Text(
                "English / Sinhala / Tamil",
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.notifications,
              ),
              title: const Text(
                "Notifications",
              ),
              subtitle: const Text(
                "Manage reminders",
              ),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.dark_mode,
              ),
              title: const Text(
                "Theme",
              ),
              subtitle: const Text(
                "Light / Dark",
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.lock,
              ),
              title: const Text(
                "Change Parent PIN",
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.face,
              ),
              title: const Text(
                "Re-register Face",
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
              ),
              onTap: () {},
            ),
          ),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.info,
              ),
              title: const Text(
                "About SensiBuddy",
              ),
              subtitle: const Text(
                "Version 1.0",
              ),
            ),
          ),
        ],
      ),
    );
  }
}