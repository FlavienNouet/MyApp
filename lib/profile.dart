import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CompteApi {
  static const String baseUrl = 'http://localhost:1234';

  static Future<Map<String, dynamic>> getUserById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/getUserById?id=$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Utilisateur non trouvé');
      }
    } catch (error) {
      throw Exception('Erreur de connexion : ${error.toString()}');
    }
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Map<String, dynamic>>? _futureUser;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedUserId = prefs.getInt('userId') ?? 1; // Défaut ID 3 si absent

    setState(() {
      _userId = storedUserId;
      _futureUser = CompteApi.getUserById(_userId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Utilisateur'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: _futureUser == null
            ? Text('Chargement...', style: TextStyle(color: Colors.white))
            : FutureBuilder<Map<String, dynamic>>(
                future: _futureUser,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}', style: TextStyle(color: Colors.white));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Aucune donnée trouvée', style: TextStyle(color: Colors.white));
                  }

                  final user = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('ID: ${_userId}', style: TextStyle(fontSize: 20, color: Colors.white)),
                      Text('Nom: ${user['nom'] ?? "Inconnu"}', style: TextStyle(fontSize: 24, color: Colors.white)),
                      Text('Email: ${user['email'] ?? "Non défini"}', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ],
                  );
                },
              ),
      ),
      backgroundColor: Colors.black,
    );
  }
}  