import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = '';
  String email = '';
  String role = '';
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('userId');  // Récupérer l'ID utilisateur en tant qu'int

    if (token == null || userId == null) {
      setState(() {
        errorMessage = 'Aucun token ou ID utilisateur trouvé';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:1234/user/getUserById?id=$userId'), // L'ID utilisateur est maintenant un entier
        headers: {'Authorization': 'Bearer $token'},
      );

      // Imprimer la réponse brute pour le débogage
      print('Réponse de l\'API: ${response.body}');

      // Vérification du statut HTTP
      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);

        // Vérification que la réponse contient bien les données utilisateur
        if (userData.isNotEmpty) {
          String nom = userData['nom'] ?? 'Nom non renseigné';
          String prenom = userData['prenom'] ?? 'Prénom non renseigné';
          String email = userData['email'] ?? 'Non renseigné';
          String role = userData['role'] ?? 'Non spécifié';

          setState(() {
            username = (nom + ' ' + prenom).trim();
            this.email = email;
            this.role = role;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Données utilisateur non trouvées dans la réponse';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Erreur serveur : ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de communication avec le serveur: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator()
              : errorMessage.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        errorMessage,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Container(
                      width: 350,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Text(
                              'Informations de l\'utilisateur',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          buildDetailRow(Icons.person, username),
                          buildDetailRow(Icons.email, email),
                          buildDetailRow(Icons.security, role),
                          SizedBox(height: 25),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text.isNotEmpty ? text : 'Non renseigné',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
