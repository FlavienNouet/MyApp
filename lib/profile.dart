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

  // Fonction pour récupérer les informations de l'utilisateur
  Future<void> fetchUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null) {
      try {
        var userId = 2; // Vous pouvez adapter cela pour obtenir l'ID réel de l'utilisateur connecté.
        final response = await http.get(
          Uri.parse('http://localhost:1234/user/getUserById?id=$userId'), // Endpoint pour récupérer les infos du profil
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> userData = jsonDecode(response.body);

          // Debug : affiche la réponse brute pour comprendre sa structure
          print('Réponse brute de l\'API: $userData');

          // Debug supplémentaire : inspecter toutes les clés disponibles dans la réponse JSON
          userData.forEach((key, value) {
            print('Clé: $key, Valeur: $value');
          });

          // Vérifier si 'user' existe
          if (userData.containsKey('user')) {
            var currentUser = userData['user'];

            if (currentUser != null) {
              setState(() {
                username = '${currentUser['nom']} ${currentUser['prenom']}'; // Combinaison nom et prénom
                email = currentUser['email'] ?? ''; // Email
                role = currentUser['role'] ?? '';   // Rôle
                isLoading = false;
              });
            } else {
              setState(() {
                errorMessage = 'Utilisateur non trouvé';
                isLoading = false;
              });
            }
          } else {
            // Si 'user' n'est pas dans la réponse, afficher un message plus détaillé
            setState(() {
              errorMessage = 'Données utilisateur manquantes. Réponse de l\'API: ${response.body}';
              isLoading = false;
            });
          }
        } else {
          setState(() {
            errorMessage = 'Erreur de réponse: ${response.statusCode}';
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Erreur de communication avec le serveur: $e';
          isLoading = false;
        });
      }
    } else {
      setState(() {
        errorMessage = 'Aucun token trouvé dans les préférences partagées';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator() // Affiche un loader pendant le chargement
            : errorMessage.isNotEmpty
                ? Text(errorMessage, style: TextStyle(color: Colors.red)) // Affiche un message d'erreur si nécessaire
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Informations utilisateur:',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Nom d\'utilisateur: $username',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Email: $email',
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Rôle: $role',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
      ),
    );
  }
}
