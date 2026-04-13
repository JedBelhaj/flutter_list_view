import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xampp/api_config.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final listUsers = [];

  Future<void> fetchUsers() async {
    var response = await http.get(Uri.parse(ApiConfig.getUsersUrl));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data["users"]);
      setState(() {
        listUsers.addAll(data['users']);
      });
    } else {
      // Handle error
      print('Failed to load users: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
      body: ListView.builder(
        itemCount: listUsers.length,
        itemBuilder: (context, index) {
          final user = listUsers[index];
          return Card(
            child: ListTile(
              title: Text('${user['nom']} ${user['prenom']}'),
              leading: Icon(Icons.person),
              subtitle: Text(user['mail']),
            ),
          );
        },
      ),
    );
  }
}
