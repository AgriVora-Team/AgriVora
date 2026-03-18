import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late Future<Map<String, String>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<Map<String, String>> _loadUser() async {
    // Simulating API fetch (replace with real API if needed)
    await Future.delayed(const Duration(milliseconds: 500));

    return {
      "name": ApiService.userName ?? "Guest",
      "email": ApiService.userEmail ?? "No Email"
    };
  }

  void _updateName() async {
    // Simulate updating name
    setState(() {
      _userFuture = Future.value({
        "name": "Updated User",
        "email": ApiService.userEmail ?? ""
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Settings")),
      body: FutureBuilder<Map<String, String>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final user = snapshot.data!;

          return Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(user["name"]!),
                subtitle: Text(user["email"]!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateName,
                child: const Text("Update Name"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await ApiService.logout();
                  Navigator.pushReplacementNamed(context, '/welcome');
                },
                child: const Text("Logout"),
              ),
            ],
          );
        },
      ),
    );
  }
}