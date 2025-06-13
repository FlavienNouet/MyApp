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
    int? userId = prefs.getInt('userId');

    if (token == null || userId == null) {
      setState(() {
        errorMessage = 'Aucun token ou ID utilisateur trouvé';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:1234/user/getUserById?id=$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Réponse de l\'API: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = jsonDecode(response.body);

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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Profil Utilisateur',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[800]!),
                ),
              )
            else if (errorMessage.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[800]),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  // Carte de profil
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // En-tête avec avatar
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue[800],
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.blue[800],
                                ),
                              ),
                              SizedBox(height: 16),
                              Text(
                                username,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                role,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Détails
                        Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                icon: Icons.email,
                                label: 'Email',
                                value: email,
                              ),
                              SizedBox(height: 16),
                              _buildInfoRow(
                                icon: Icons.verified_user,
                                label: 'Rôle',
                                value: role,
                              ),
                              SizedBox(height: 24),
                              Divider(height: 1),
                              SizedBox(height: 16),

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.blue[800],
          size: 24,
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[800],
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}