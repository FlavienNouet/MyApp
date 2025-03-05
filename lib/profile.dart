import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CompteApi {
  // URL mise à jour pour le serveur local dans un environnement Android
  static String baseUrl = 'http://10.0.2.2:1234/';

  // Récupération des données du compte
  static Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      var res = await http.get(
        Uri.parse(baseUrl + '/user/getUserById?id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else {
        throw Exception('Erreur lors de la récupération des données du compte.');
      }
    } catch (err) {
      throw Exception(err.toString());
    }
  }
}

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Déclaration de futureUser et userId
  Future<Map<String, dynamic>>? _futureUser;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  // Fonction pour charger l'ID utilisateur depuis les SharedPreferences
  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedUserId = prefs.getString('userId') ?? '1'; // Défaut à ID '1' si absent

    setState(() {
      _userId = storedUserId;
      _futureUser = CompteApi.getUserById(_userId!); // Utilisation de l'ID utilisateur dynamique
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
                      Text('ID: $_userId', style: TextStyle(fontSize: 20, color: Colors.white)),
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