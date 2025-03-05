import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'historique.dart';
import 'reserv.dart';// Import des écrans
import 'main.dart'; // Assurez-vous d'importer votre écran principal
import 'profile.dart'; // Assurez-vous d'importer votre écran de profil
import 'confirmation.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

// Ecran Principal avec la navigation
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Index de la page actuellement affichée

  // Liste des pages à afficher dans la navigation
  final List<Widget> _pages = [
    HistoryScreen(),
    HomeContent(),
    ConfirmationScreen(), // Ajout de la page confirmation ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Affiche la page correspondant à l'index courant
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Réservation'),
        ],
        currentIndex: _currentIndex, // Index actuel dans la barre de navigation
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Met à jour l'index lorsqu'un élément est sélectionné
          });
        },
      ),
    );
  }
}



// Ecran d'accueil avec le menu latéral
class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // Fonction de déconnexion
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprime le token de session

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Redirection vers l'écran de connexion
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.grey[850],
        child: Column(
          children: [
            SizedBox(height: 50),
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('../assets/profile.jpg'), // Image de profil
            ),
            SizedBox(height: 20),
            Divider(color: Colors.white54),
            ListTile(
              leading: Icon(Icons.person, color: Colors.white),
              title: Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()), // Navigue vers l'écran de profil
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Déconnexion', style: TextStyle(color: Colors.white)),
              onTap: _logout, // Déconnexion
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(color: Colors.black),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              children: [
                Row(
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer(); // Ouvre le menu latéral
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage('../assets/profile.jpg'), // Image de profil
                        ),
                      ),
                    ),
                    Spacer(),
                    Text('Dayliho', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                SizedBox(height: 50),
                Container(
                  width: 300,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: AssetImage('../assets/home.jpg'), // Image de fond
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Bienvenue', style: TextStyle(fontSize: 22, color: Colors.white)), // Bouton d'accueil
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

