import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xampp/user_list_view.dart';
import 'api_config.dart';

class AddUserPage extends StatefulWidget {
  const AddUserPage({super.key});

  @override
  State<AddUserPage> createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController mailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    mailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add User')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nomController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: prenomController,
              decoration: const InputDecoration(
                labelText: 'Prenom',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: mailController,
              decoration: const InputDecoration(
                labelText: 'Mail',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : addUser,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Add User'),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserListPage(),
                    ),
                  );
                },
                child: const Text('View Users'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addUser() async {
    final String nom = nomController.text.trim();
    final String prenom = prenomController.text.trim();
    final String mail = mailController.text.trim();

    if (nom.isEmpty || prenom.isEmpty || mail.isEmpty) {
      showSnackbar('Please enter nom, prenom and mail.', Colors.orange);
      return;
    }

    if (!mail.contains('@') || !mail.contains('.')) {
      showSnackbar('Please enter a valid mail address.', Colors.orange);
      return;
    }

    if (mounted) {
      setState(() {
        _isSubmitting = true;
      });
    }

    final Uri url = Uri.parse(ApiConfig.addUserUrl);

    try {
      final response = await http
          .post(url, body: {'nom': nom, 'prenom': prenom, 'mail': mail})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        showSnackbar('Server error (${response.statusCode}).', Colors.red);
        return;
      }

      final dynamic data = json.decode(response.body);
      final bool isSuccess = data is Map && '${data['success']}' == '1';

      if (isSuccess) {
        showSnackbar(
          'User added successfully.',
          Colors.green,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserListPage()),
              );
            },
          ),
        );
        nomController.clear();
        prenomController.clear();
        mailController.clear();
      } else {
        final String message = data is Map && data['message'] != null
            ? '${data['message']}'
            : 'Failed to add user.';
        showSnackbar(message, Colors.red);
      }
    } on TimeoutException {
      showSnackbar('Request timed out: ${ApiConfig.addUserUrl}', Colors.red);
    } on FormatException {
      showSnackbar('Invalid response from server.', Colors.red);
    } catch (e) {
      showSnackbar('Error adding user: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void showSnackbar(String message, Color color, {SnackBarAction? action}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, action: action),
    );
  }
}
